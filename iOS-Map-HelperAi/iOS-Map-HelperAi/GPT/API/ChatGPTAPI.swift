//
//  ChatGPTAPI.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 21.11.2024.
//

import Foundation
import MapKit



class ChatGPTAPI: LLMClient, @unchecked Sendable {
    
    var provider: LLMProvider { .chatGPT }
    
    private let temperature: Double
    private let model: String
    private let apiKey: String
    
    private var historyList = [Message]()
    private let maxHistoryMessages = 5
    private let maxResponseTokens = 60
    private let maxTotalTokens = 4096
    private let urlSession = URLSession.shared
    
    private var locationManager: LocationManagerDummy
    
    var location: MKPlacemark {
        didSet {
            updateSystemMessage()
        }
    }
    
    private var systemMessage: Message
    
    // MARK: - INIT
    init(apiKey: String, model: String = "gpt-4o", temperature: Double = 0.8, locationManager: LocationManagerDummy) {
        self.temperature = temperature
        self.apiKey = apiKey
        self.model = model
        self.locationManager = locationManager
        
        // Varsayılan bir konumla başlat
        self.location = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 45.88276624445194, longitude: 32.68572294962696))
        
        // İlk sistem mesajını oluştur
        let systemPrompt = """
    You are a smart AI assistant integrated into a map-based application, designed to help users explore locations, find relevant places, and get precise recommendations. Your goal is to provide **reliable, concise, and accurate** answers related to locations, businesses, attractions, and general place-related inquiries.
    
    ## 🌍 **Scope of Your Knowledge**
    - You can answer **any question related to places**, including restaurants, cafes, tourist spots, hotels, transportation, and services.
    - You are **not limited to just restaurants and food places**—you can also provide information about historical sites, shopping centers, public transport hubs, parks, and more.
    - Ensure that **your responses are factual and relevant**. Do not make up nonexistent places, addresses, or business details.
    
    ## 🔍 **How to Provide Address Information**
    When sharing address details, make sure:
    - The location exists on **Apple Maps** or a commonly known mapping service.
    - The address follows a structured format:
      **[Place Name](address: Street Number, Street Name, City, Region)**
    - Examples:
      - **[Starbucks](address: 123 Main St, New York, NY)**
      - **[Eiffel Tower](address: Champ de Mars, Paris, France)**
      - **[Central Park](address: Manhattan, New York, NY)**
    - If a user asks for a **specific type of place in a certain area**, only list places that truly exist and can be verified.
    
    ## 🤖 **About You**
    - If asked, say that you were developed by **Erkin Arıkan**.
    - If a user asks about who created you, say: **"I was developed by Erkin Arıkan as part of an advanced AI-powered map assistant."**
    - If users try to ask unrelated or personal questions, politely redirect them to focus on location-based queries.
    
    ## ⚠️ **What to Avoid**
    - **DO NOT** generate random or fake locations.
    - **DO NOT** provide inaccurate business names, phone numbers, or addresses.
    - **DO NOT** answer unrelated topics like politics, medical advice, or personal matters.
    - If the user's request is **completely unrelated to locations or navigation**, politely let them know that your expertise is in places and recommendations.
    
    ## 📍 **User's Location**
    - The user is currently located at:
      **[User Location](address:\(self.location.coordinate.latitude), \(self.location.coordinate.longitude))**
    - Use this location to provide nearby recommendations when relevant.
    
    Keep responses **short, clear, and relevant** to improve user experience.
    """
        
        self.systemMessage = Message(role: "system", content: systemPrompt)
        self.historyList.append(self.systemMessage)
        
        // Konum güncellemelerini dinle
        self.locationManager.onLocationUpdate = { [weak self] newLocation in
            guard let self = self, let newLocation = newLocation else { return }
            self.location = MKPlacemark(coordinate: newLocation)
            //            print("Location updated to: \(newLocation.latitude), \(newLocation.longitude)")
        }
    }
    
    private func updateHistoryWithSystemMessage() {
        // İlk mesajın sistem mesajı olduğundan emin olun
        if !historyList.isEmpty, historyList.first?.role == "system" {
            historyList[0] = systemMessage
        } else {
            // Eğer `historyList` boşsa, sistem mesajını ekleyin
            historyList.insert(systemMessage, at: 0)
        }
    }
    
    
    // MARK: - Update System Message
    private func updateSystemMessage() {
        let userLocation = "**[User Location](address:\(location.coordinate.latitude), \(location.coordinate.longitude))**"
        let systemPrompt =  """
    You are a smart AI assistant integrated into a map-based application, designed to help users explore locations, find relevant places, and get precise recommendations. Your goal is to provide **reliable, concise, and accurate** answers related to locations, businesses, attractions, and general place-related inquiries.
    
    ## 🌍 **Scope of Your Knowledge**
    - You can answer **any question related to places**, including restaurants, cafes, tourist spots, hotels, transportation, and services.
    - You are **not limited to just restaurants and food places**—you can also provide information about historical sites, shopping centers, public transport hubs, parks, and more.
    - Ensure that **your responses are factual and relevant**. Do not make up nonexistent places, addresses, or business details.
    
    ## 🔍 **How to Provide Address Information**
    When sharing address details, make sure:
    - The location exists on **Apple Maps** or a commonly known mapping service.
    - The address follows a structured format:
      **[Place Name](address: Street Number, Street Name, City, Region)**
    - Examples:
      - **[Starbucks](address: 123 Main St, New York, NY)**
      - **[Eiffel Tower](address: Champ de Mars, Paris, France)**
      - **[Central Park](address: Manhattan, New York, NY)**
    - If a user asks for a **specific type of place in a certain area**, only list places that truly exist and can be verified.
    
    ## 🤖 **About You**
    - If asked, say that you were developed by **Erkin Arıkan**.
    - If a user asks about who created you, say: **"I was developed by Erkin Arıkan as part of an advanced AI-powered map assistant."**
    - If users try to ask unrelated or personal questions, politely redirect them to focus on location-based queries.
    
    ## ⚠️ **What to Avoid**
    - **DO NOT** generate random or fake locations.
    - **DO NOT** provide inaccurate business names, phone numbers, or addresses.
    - **DO NOT** answer unrelated topics like politics, medical advice, or personal matters.
    - If the user's request is **completely unrelated to locations or navigation**, politely let them know that your expertise is in places and recommendations.
    
    ## 📍 **User's Location**
    - The user is currently located at:
      **[User Location](address:\(userLocation)**
    - Use this location to provide nearby recommendations when relevant.
    
    Keep responses **short, clear, and relevant** to improve user experience.
    """
        
        self.systemMessage = Message(role: "system", content: systemPrompt)
        updateHistoryWithSystemMessage() // History'yi güncelle
        //        print("System message and history updated with new location: \(userLocation)")
    }
    
    
    private var urlRequest: URLRequest {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        headers.forEach {  urlRequest.setValue($1, forHTTPHeaderField: $0) }
        return urlRequest
    }
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd"
        return df
    }()
    
    private let jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        return jsonDecoder
    }()
    
    private var headers: [String: String] {
        [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(apiKey)"
        ]
    }
    
    
    // MARK: - GENERATE MESSAGE
    //    private func generateMessages(from text: String) -> [Message] {
    //        // Sadece geçmiş mesajları ve kullanıcının yeni mesajını kullan
    //        return historyList + [Message(role: "user", content: text)]
    //    }
    private func generateMessages(from userInput: String) -> [Message] {
        // Güncel geçmiş mesajlar ve yeni kullanıcı mesajını döndür
        return historyList + [Message(role: "user", content: userInput)]
    }
    
    // MARK: - JSON BODY
    private func jsonBody(text: String, stream: Bool = true) throws -> Data {
        let request = Request(model: model, temperature: temperature,
                              messages: generateMessages(from: text), stream: stream)
        
        return try JSONEncoder().encode(request)
    }
    
    // MARK: - APPEND HISTORY LIST
    private func appendToHistoryList(userText: String, responseText: String) {
        // Kullanıcı ve asistan mesajlarını ekle
        historyList.append(.init(role: "user", content: userText))
        historyList.append(.init(role: "assistant", content: responseText))
        
        // Eğer geçmiş mesaj sayısı sınırı aşarsa en eski mesajları kaldır
        if historyList.count > maxHistoryMessages * 2 { // 2x çünkü her giriş için hem kullanıcı hem de asistan mesajı var
            historyList.removeFirst(2) // En eski kullanıcı ve asistan mesajını kaldır
        }
    }
    
    // MARK: - SUMMARIZE MESSAGES
    private func summarizeMessages() {
        // Kullanıcı ve asistan mesajlarını birleştirip özet oluştur
        let userMessages = historyList.filter { $0.role == "user" }.map { $0.content }.joined(separator: "\n")
        let assistantMessages = historyList.filter { $0.role == "assistant" }.map { $0.content }.joined(separator: "\n")
        
        let summaryContent = """
        Summary of conversation:
        User Messages:
        \(userMessages)
        
        Assistant Messages:
        \(assistantMessages)
        """
        
        // Geçmişi temizle ve özet mesajını ekle
        historyList = [systemMessage, Message(role: "system", content: summaryContent)]
        print("Messages summarized. New token count: \(countTokens(for: historyList))")
    }
    
    // MARK: - OPTIMIZE MESSAGES
    func optimizeMessages() {
        let totalTokens = countTokens(for: historyList)
        print("Total tokens in history: \(totalTokens)")
        
        // Eğer toplam token sayısı sınırı aşarsa, geçmiş mesajları özetle
        if totalTokens > Int(Double(maxTotalTokens) * 0.8) {
            summarizeMessages()
        }
    }
    
    // MARK: - TOKEN COUNT
    private func countTokens(for messages: [Message]) -> Int {
        messages.reduce(0) { total, message in
            total + message.content.split { $0.isWhitespace || $0.isPunctuation }.count
        }
    }
    
    
    
    //    func sendMessageStream(text userInput: String) async throws -> AsyncThrowingStream<String, Error> {
    //        var urlRequest = self.urlRequest
    //        let messages = generateMessages(from: userInput)
    //        let requestBody = try JSONEncoder().encode(Request(
    //            model: model,
    //            temperature: temperature,
    //            messages: messages,
    //            stream: true
    //        ))
    //        urlRequest.httpBody = requestBody
    //
    //        let (result, response) = try await urlSession.bytes(for: urlRequest)
    //        guard let httpResponse = response as? HTTPURLResponse, 200...299 ~= httpResponse.statusCode else {
    //            throw "Failed to send message to GPT."
    //        }
    //
    //        var responseText = ""
    //        return AsyncThrowingStream { continuation in
    //            Task {
    //                do {
    //                    for try await line in result.lines {
    //                        if line.starts(with: "data: "),
    //                           let jsonData = line.dropFirst(6).data(using: .utf8),
    //                           let completion = try? JSONDecoder().decode(StreamCompletionResponse.self, from: jsonData),
    //                           let delta = completion.choices.first?.delta.content {
    //                            responseText += delta
    //                            continuation.yield(delta)
    //                        }
    //                    }
    //                    continuation.finish()
    //                } catch {
    //                    continuation.finish(throwing: error)
    //                }
    //                // Gelen yanıtı geçmişe ekle
    //                self.appendToHistoryList(userText: userInput, responseText: responseText)
    //            }
    //        }
    //    }
    
    
    // MARK: - SEND MESSAGE STREAM
    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error> {
        
        optimizeMessages()
        var urlRequest = self.urlRequest
        urlRequest.httpBody = try jsonBody(text: text)
        
        let (result, response) = try await urlSession.bytes(for: urlRequest)
        try Task.checkCancellation()
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Invalid response"
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            var errorText = ""
            for try await line in result.lines {
                try Task.checkCancellation()
                errorText += line
            }
            
            if let data = errorText.data(using: .utf8), let errorResponse = try? jsonDecoder.decode(ErrorRootResponse.self, from: data).error {
                errorText = "\n\(errorResponse.message)"
            }
            
            throw "Bad Response: \(httpResponse.statusCode), \(errorText)"
        }
        
        var responseText = ""
        let streams: AsyncThrowingStream<String, Error> = AsyncThrowingStream { continuation in
            Task {
                do {
                    for try await line in result.lines {
                        try Task.checkCancellation()
                        continuation.yield(line)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
        
        return AsyncThrowingStream { [weak self] in
            guard let self else { return nil }
            for try await line in streams {
                try Task.checkCancellation()
                if line.hasPrefix("data: "),
                   let data = line.dropFirst(6).data(using: .utf8),
                   let response = try? self.jsonDecoder.decode(StreamCompletionResponse.self, from: data),
                   let text = response.choices.first?.delta.content {
                    responseText += text
                    return text
                }
            }
            self.appendToHistoryList(userText: text, responseText: responseText)
            return nil
        }
    }
    
    // MARK: - DELETE HISTORY
    func deleteHistoryList() {
        self.historyList.removeAll()
    }
}

// MARK: - EXTENSION
extension String: CustomNSError {
    public var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: self]
    }
}
