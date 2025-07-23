//
//  LLMClient.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 21.11.2024.
//

import Foundation


protocol LLMClient {
    
    var provider: LLMProvider { get }
    
    func sendMessageStream(text: String) async throws -> AsyncThrowingStream<String, Error>
//    func sendMessage(_ text: String) async throws -> String
    func deleteHistoryList()
    
}

