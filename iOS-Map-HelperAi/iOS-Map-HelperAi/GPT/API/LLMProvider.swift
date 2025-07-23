//
//  LLMProvider.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 21.11.2024.
//

import Foundation


enum LLMProvider: Identifiable, CaseIterable {
    
    case chatGPT

    var id: Self { self }
    
    var imageName: String {
        switch self {
        case .chatGPT:
            return "Logo"

        }
    }
}
