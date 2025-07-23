import FirebaseFirestore
import Foundation
import FirebaseAuth
import SwiftUI

class RegisterViewModel: ObservableObject, SignInUpProtocol {
    @Published var name = ""
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var favoritesPlaces: [FavoritePlaceModel] = []
    @Published var welcomeText: String = ""
    @Published var logInText: String = ""
    @Published var isLoading: Bool = false // Loading durumu
    @Published var showEmailVericationView: Bool = false
    @Published var userSession: FirebaseAuth.User?
    @AppStorage("log_status") var logStatus: Bool = false
    @Published var userId: String = ""

    private let welcomeFullText = "Welcome,"
    private let logInFullText = "Sign Up Now!"

    init() {
        self.userSession = Auth.auth().currentUser
        
    }

    
    
    
    func register() async {
        guard await validate() else {
            self.isLoading = false
            return
        }

        // Loading animasyonu başlatılır
        await MainActor.run { self.isLoading = true }

        Auth.auth().createUser(withEmail: self.email, password: self.password) { [weak self] result, error in
            guard let self = self else { return }

            // Hata durumu kontrolü
            if let error = error {
            
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                
                return
            }

            // Kullanıcı ID kontrolü
            guard let user = result?.user else {
                
                    self.errorMessage = "User could not be created, please try again."
                    self.isLoading = false
                
                return
            }
            self.userId = user.uid

            // E-posta doğrulama görünümünü göster
        
                self.showEmailVericationView = true
         

            // E-posta doğrulama gönderme
            user.sendEmailVerification { error in
                if let error = error {
                    print("RegisterVM Doğrulama e-postası gönderilemedi: \(error.localizedDescription)")
                } else {
                    print("RegisterVm Doğrulama e-postası başarıyla gönderildi.")
                }
            }

            // Email doğrulama kontrolü başlat
            Task {
                await self.startEmailVerificationPolling(for: user)
            }

            // Firestore'a kullanıcı ekleme işlemi
            Task {
               self.insertUserRecord(id: user.uid)
            }

         
                self.isLoading = false
            
        }
    }

    private func startEmailVerificationPolling(for user: User) async {
        for _ in 0..<20 { // 20 kez kontrol eder (örneğin 20 saniye boyunca 1 saniye aralıklarla)
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 saniye bekle
            do {
                try await user.reload()
                if user.isEmailVerified {
                    await MainActor.run {
                        self.showEmailVericationView = false
                        self.logStatus = true // Sadece doğrulama başarılıysa `true` yap
                        print("E-posta doğrulandı, logStatus: \(self.logStatus)")
                    }
                    break
                } else {
                    await MainActor.run {
                        self.logStatus = false // Doğrulama tamamlanmamışsa `false` olarak bırak
                    }
                }
            } catch {
                print("Kullanıcı yenileme hatası: \(error.localizedDescription)")
            }
        }
    }


   
    func deleteUser(){
        
        if let user = Auth.auth().currentUser {
               user.delete { error in
                   if let error = error {
                       print("Kullanıcı silinirken hata oluştu: \(error.localizedDescription)")
                   } else {
                       print("Kullanıcı başarıyla silindi.")
                   }
               }
           } else {
               print("Oturum açmış bir kullanıcı bulunamadı.")
           }
        
        let db = Firestore.firestore()
           db.collection("users").document(userId).delete { error in
               if let error = error {
                   print("Doküman silinirken hata oluştu: \(error.localizedDescription)")
               } else {
                   print("Doküman başarıyla silindi.")
               }
           }
    }

    
    //MARK: - Insert User Record
    
    private func insertUserRecord(id: String) {
        let newUser = UserModel(
                id: id,
                name: name,
                email: email,
                favoritesPlaces: favoritesPlaces,
                userPromptLimit: 5,
                joined: Date().timeIntervalSince1970,
                userAgreement: false,
                
                messages: [] // Başlangıçta boş bir mesaj listesi
            )
        let db = Firestore.firestore()

        db.collection("users")
            .document(id)
            .setData(newUser.asDictionary()) { [weak self] error in
                guard let self = self else { return }

                // İşlem tamamlandığında veya hata oluştuğunda loading durdurulur
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    print("Kullanıcı Firestore'a kaydedildi.")
                }
                self.isLoading = false
            }
    }

    
    //MARK: -  Validate
    private func validate() async -> Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            await MainActor.run {
                errorMessage = "Please enter your name."
            }
            return false
        }

        if email.trimmingCharacters(in: .whitespaces).isEmpty {
            await MainActor.run {
                errorMessage = "Please enter an e-mail address."
            }
            return false
        }

        if password.trimmingCharacters(in: .whitespaces).isEmpty {
            await MainActor.run {
                errorMessage = "Please enter a password."
            }
            return false
        }

        if !email.contains("@") || !email.contains(".") {
            await MainActor.run {
                errorMessage = "Enter a valid e-mail address."
            }
            return false
        }

//

        return true
    }



    //MARK: - Animate Text
    func animateText() {
        welcomeText = ""
        logInText = ""
        
        // Dil kontrolü
        let languageManager = LanguageManager()
        let isTurkish = languageManager.language == "tr"

        // Metinleri dil seçimine göre belirleyin
        let welcomeCharacters = Array((isTurkish ? "Tekrar Hoş Geldiniz," : "Welcome Back,"))
        let logInCharacters = Array((isTurkish ? "Giriş Yap!" : "Log In!"))
        
        let haptic = UIImpactFeedbackGenerator(style: .soft)
        
        // İlk yazıyı animasyonla oluştur
        for (index, char) in welcomeCharacters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(index)) {
                self.welcomeText.append(char)
                haptic.impactOccurred()
            }
        }
        
        // İkinci yazıyı animasyonla oluştur
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(welcomeCharacters.count)) {
            for (index, char) in logInCharacters.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(index)) {
                    self.logInText.append(char)
                    haptic.impactOccurred()
                }
            }
        }
    }

    
}
