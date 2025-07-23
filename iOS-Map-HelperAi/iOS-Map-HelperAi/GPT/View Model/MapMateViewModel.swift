
import Foundation
import SwiftUI
import AVKit
import Markdown
import FirebaseAuth
import Firebase



class MapMateViewModel: ObservableObject {
    
    @Published var isInteracting = false
    @Published var messages: [MessageModel] = []
    
    @Published var inputMessage: String = ""
    @Published var openingCount:Int = 1
    var task: Task<Void, Never>?
//    var allMessages:[MessageModel]{
//        firestoreMessages + gptMessages
//    }
    @Published var promptLimitReached = false // Prompt limiti kontrolü için
    
    
    
    
    private let maxPrompts = 4 // Maksimum prompt sayısı
    @Published var userPromptCount = 0 // Kullanıcı prompt sayacı
    @Published var currentUser:UserModel?
    
    private var synthesizer: AVSpeechSynthesizer?
    
    private var api: LLMClient
    @Published var showWelcomeMessage = false // Animasyon için kontrol
    private var db = Firestore.firestore()
    
//    @Published var firestoreMessages: [MessageModel] = [] // Firestore'dan gelen mesajlar
//    @Published var gptMessages: [MessageModel] = [] // GPT'ye gönderilecek mesajlar
    
    
    
    init(api: LLMClient, enableSpeech: Bool = false) {
        self.api = api
        
        if enableSpeech {
            synthesizer = .init()
        }
        Task{
          await  fetchUser()
            await fetchMessagesForCurrentUser()
        }
        
       /* addWelcomeMessage()*/ // --> Kullanıcı giriş yaptığında otomatik hoş geldiniz mesajı ekliyoruz.
    }

    // Kullanıcıya ait mesajları çekmek
    //MARK: - FETCH MESSAGE
    func fetchMessagesForCurrentUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }
        
        do {
            let snapshot = try await db.collection("users").document(uid).getDocument()
            
            if let userData = snapshot.data() {
                print("Firestore'dan gelen kullanıcı verisi: \(userData)")
                if let user = UserModel.fromDictionary(userData) {
                    await MainActor.run {
                        self.currentUser = user
                        self.messages = user.messages.map { $0.toMessageModel() }
                    }
                } else {
                    print("Kullanıcı verisi `UserModel`'e dönüştürülemedi.")
                }
            } else {
                print("Firestore snapshot boş: \(snapshot)")
            }
        } catch {
            print("Firestore'dan veri çekilirken hata oluştu: \(error.localizedDescription)")
        }
        
    }
    
   
    
    //MARK: - CHECK PROMPT LIMIT
    
    func checkPormptLimit(){
        if currentUser?.userPromptLimit ?? 5 <= 0 {
            promptLimitReached = true
        }else{
            promptLimitReached = false
        }
    }
    
    func updateUserAgreementStatus(isAccepted: Bool) async {
            guard let uid = Auth.auth().currentUser?.uid else {
                print("User not authenticated.")
                return
            }

            let db = Firestore.firestore()
            let userDocument = db.collection("users").document(uid)

            do {
                try await userDocument.updateData([
                    "userAgreement": isAccepted
                ])
                print("User agreement status successfully updated to: \(isAccepted)")

                // Lokal kullanıcı nesnesini güncelle
                await MainActor.run {
                    self.currentUser?.userAgreement = isAccepted
                }
            } catch {
                print("Failed to update user agreement status: \(error.localizedDescription)")
            }
        }
    // MARK: - Add Messages to User and Update Firestore
    func addMessageToUserAndSaveToFirestore(_ message: MessageModel) async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturum açmamış.")
            return
        }
        guard var currentUser = currentUser else {
            print("Kullanıcı modeli mevcut değil.")
            return
        }

        // Mesajı ekleyin
        let codableMessage = message.toCodable()
        currentUser.messages.append(codableMessage)

        // Firestore'da güncelleyin
        do {
            try await db.collection("users").document(uid).updateData([
                "messages": currentUser.messages.map { $0.toDictionary() }
            ])
            print("Mesaj Firestore'a başarıyla eklendi: \(message.sendText)")
            
            // Lokal olarak da güncellenen mesajı ekle
            
        } catch {
            print("Mesaj Firestore'a eklenemedi: \(error.localizedDescription)")
            await MainActor.run {
                // Hata durumunu UI üzerinde göstermek için errorMessage değişkeni kullanılabilir.
            }
        }
    }

    
    //MARK: - FETCH USER
    func fetchUser()async {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        guard let snaphot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else{
            return
        }
        await MainActor.run {
            self.currentUser = try? snaphot.data(as:UserModel.self)
        }
        
       
    }
    
    /// Kullanıcı "Gönder" butonuna bastığında çağrılır.
    /// Kullanıcı "Gönder" butonuna bastığında çağrılır.
    ///
    
    //MARK: - SEND TAPPED
        @MainActor
        func sendTapped() async {
            

            if currentUser?.userPromptLimit ?? 5 >= 0 {
                promptLimitReached = false
            } // Eğer limit aşıldıysa işlem yapılmaz.
           
            
            
            self.task = Task {
                let text = inputMessage // Kullanıcının mesajını al.
                inputMessage = "" // Mesaj alanını sıfırla.

                currentUser?.userPromptLimit -= 1
                print("Kalan prompt limiti: \(String(describing: currentUser?.userPromptLimit))")
                if currentUser?.userPromptLimit == 0 {
                    promptLimitReached = true // Prompt limiti aşıldı.
                }

                // Firestore'da kullanıcı prompt limitini güncelle
                await updateUserPromptLimitInFirestore()

                // Yeni mesaj oluştur ve Firestore'a ekle
                let newMessage = MessageModel(
                    isInteracting: false,
                    sendImage: "profile",
                    send: .simpleText(text),
                    responseImage: "assistant",
                    response: nil,
                    responseError: nil
                )
                await addMessageToUserAndSaveToFirestore(newMessage)
                /*self.gptMessages.append(newMessage)*/ // Sadece GPT mesajları için
                // API'nin akışlı yanıt özelliğini kullanarak mesaj gönder.
                if api.provider == .chatGPT {
                    await sendWithStreamingResponse(text: text)
                }
            }
        }
    
    // MARK: - Update User Prompt Limit in Firestore
    func updateUserPromptLimitInFirestore() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let promptLimit = currentUser?.userPromptLimit else { return }
        
        let db = Firestore.firestore()
        
        do {
            try await db.collection("users").document(uid).updateData(["userPromptLimit": promptLimit])
            print("Prompt limiti güncellendi: \(promptLimit)")
        } catch {
            print("Prompt limit güncellenemedi: \(error.localizedDescription)")
        }
    }
    
    //MARK: - DELETE
    func clearMessagesInFirestore() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not authenticated.")
            return
        }

        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(uid)

        do {
            try await userDocument.updateData([
                "messages": []
            ])
            
            // UI'daki messages dizisini de temizleyin
                    await MainActor.run {
                        
                        self.messages.removeAll()
                       
                    }
            
            print("Messages array successfully cleared in Firestore.")
        } catch {
            print("Failed to clear messages array: \(error.localizedDescription)")
        }
    }


    
    //MARK: - ADD WELCOME
    func addWelcomeMessage() {
            // Mesajı animasyon için önce görünmez ekliyoruz
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let welcomeMessage = MessageModel(
                    isInteracting: false,
                    sendImage: "", // Kullanıcının profil resmi boş bırakılıyor
                    send: .simpleText(""), // Kullanıcı tarafından gönderilen mesaj boş
                    responseImage: "BengiProfile", // Asistanın profil resmi
                    response: .simpleText("Hello  \(self.currentUser?.name ?? "user"),how can I help you today?"), // Asistanın yanıtı
                    responseError: nil
                )
               
                
                

                self.messages.append(welcomeMessage)
                
                // Mesajın animasyonla belirmesi için kontrolü değiştiriyoruz
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.showWelcomeMessage = true
                }
            }
        }
    
    
    @MainActor
    func resetPromptLimit() {
       
        userPromptCount = 0
        promptLimitReached = false
    }
    
    
    ///Hatalı bir mesajın yeniden gönderilmesini sağlar.
    ///Hatalı mesajı diziden kaldırır.
    ///API sağlayıcısına göre yeniden mesaj gönderir.
    /// Hatalı bir mesajı tekrar göndermek için kullanılır.
        @MainActor
        func retry(message: MessageModel) async {
            guard !promptLimitReached else { return } // Eğer limit aşıldıysa işlem yapılmaz.

            self.task = Task {
                guard let index = messages.firstIndex(where: { $0.id == message.id }) else { return }
                self.messages.remove(at: index) // Hatalı mesajı listeden çıkar.
                
                if api.provider == .chatGPT {
                    await sendWithStreamingResponse(text: message.sendText) // Mesajı yeniden gönder.
                }
            }
        }
    
    ///task iptal edilerek bir akış yanıtı beklenirken işlemi durdurur
    func cancelStreamingResponse() {
        self.task?.cancel()
        self.task = nil
    }
    
    
    // MARK: - Streaming Response
    // - Kullanım: API'nin akışlı yanıt (streaming response) desteklediği durumlarda kullanılır.
    // - İşleyiş: Yanıt parça parça alınır ve her parça kullanıcıya anında gösterilir.
    // - Avantaj: Uzun yanıtlar için hızlı görünürlük sağlar ve kullanıcı deneyimi akıcıdır.
    // - Kısıtlama: Streaming yanıt özelliği API tarafından desteklenmelidir.
    @MainActor
    private func sendWithStreamingResponse(text: String) async {
        print("message list : \(messages)")
        isInteracting = true
        
        var streamText = ""
        
        var chatMessage = MessageModel(
            isInteracting: true,
            sendImage: "profile",
            send: .simpleText(text),
            responseImage: api.provider.imageName,
            response: .simpleText(streamText),
            responseError: nil
        )
        
        do {
            let parsingTask = ResponseParsingTask()
            let attributedSend = await parsingTask.parse(text: text)
            try Task.checkCancellation()
            chatMessage.send = .attributed(attributedSend)
            self.messages.append(chatMessage)
            
            let parserThresholdTextCount = 64
            var currentTextCount = 0
            var currentOutput: AttributedOutput?
            
            let stream = try await api.sendMessageStream(text: text)
            for try await text in stream {
                streamText += text
                currentTextCount += text.count
                
                if currentTextCount >= parserThresholdTextCount || text.contains("```") {
                    currentOutput = await parsingTask.parse(text: streamText)
                    try Task.checkCancellation()
                    currentTextCount = 0
                }
                
                if let currentOutput = currentOutput, !currentOutput.results.isEmpty {
                    let suffixText = streamText.trimmingPrefix(currentOutput.string)
                    var results = currentOutput.results
                    let lastResult = results[results.count - 1]
                    var lastAttrString = lastResult.attributedString
                    
                    lastAttrString.append(AttributedString(String(suffixText)))
                    results[results.count - 1] = ParserResult(attributedString: lastAttrString)
                    chatMessage.response = .attributed(.init(string: streamText, results: results))
                } else {
                    chatMessage.response = .attributed(.init(string: streamText, results: [
                        ParserResult(attributedString: AttributedString(stringLiteral: streamText))
                    ]))
                }
                
                self.messages[self.messages.count - 1] = chatMessage
                
                if let currentString = currentOutput?.string, currentString != streamText {
                    let output = await parsingTask.parse(text: streamText)
                    try Task.checkCancellation()
                    chatMessage.response = .attributed(output)
                }
            }
        } catch is CancellationError {
            chatMessage.responseError = "The response was cancelled"
        } catch {
            chatMessage.responseError = error.localizedDescription
        }
        
        if chatMessage.response == nil {
            chatMessage.response = .simpleText(streamText)
        }
        
        chatMessage.isInteracting = false
        self.messages[self.messages.count - 1] = chatMessage
        
 
        isInteracting = false
        
        // Firestore'da güncellenen yanıtı kaydedin
              await addMessageToUserAndSaveToFirestore(chatMessage)
        
        speakLastResponse()
        
        // **Ekleme Başlangıcı**
        // Eğer yanıt Markdown formatında geliyorsa, adresleri tespit etmek ve tıklanabilir hale getirmek için işleme.
        if let document = try? Document(parsing: streamText) {
            var parser = MarkdownAttributedStringParser()
            let originalAttributedString = parser.attributedString(from: document)
            
            // NSMutableAttributedString oluşturun
            let attributedString = NSMutableAttributedString(attributedString: originalAttributedString)
            
            // Adres tespiti ve tıklanabilirlik ekleme
            if let regex = try? NSRegularExpression(pattern: #"\b\d{1,5}\s\w+(\s\w+)*,\s\w+(\s\w+)*"#) {
                let matches = regex.matches(in: streamText, range: NSRange(location: 0, length: streamText.utf16.count))
                for match in matches {
                    let matchRange = match.range
                    if let range = Range(matchRange, in: streamText) {
                        let address = streamText[range]
                        // NSMutableAttributedString'e tıklanabilir özellik ekle
                        attributedString.addAttribute(.link, value: "address:\(address)", range: matchRange)
                    }
                }
            }
            
            // Güncellenmiş attributed string'i atayın
            chatMessage.attributedResponse = attributedString
        }
        // **Ekleme Sonu**
    }

    
    
    
    
    
    
    
    func speakLastResponse() {
        
        guard let synthesizer, let responseText = self.messages.last?.responseText, !responseText.isEmpty else {
            return
        }
        stopSpeaking()
        let utterance = AVSpeechUtterance(string: responseText)
        utterance.voice = .init(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 0.8
        utterance.postUtteranceDelay = 0.2
        synthesizer.speak(utterance )
        
    }
    
    func stopSpeaking() {
        
        synthesizer?.stopSpeaking(at: .immediate)
        
    }
    
}






