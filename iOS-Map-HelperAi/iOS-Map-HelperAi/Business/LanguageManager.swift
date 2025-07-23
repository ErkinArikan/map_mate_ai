//
//  LanguageManager.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 28.11.2024.
//

import Foundation

class LanguageManager: ObservableObject {
    @Published var language = "en" {
        didSet {
            UserDefaults.standard.set(language, forKey: "AppLanguage")
        }
    }
    
    init() {
        // Uygulama başlatıldığında varsayılan dil ayarlanır
        if let defaultLanguage = UserDefaults.standard.string(forKey: "AppLanguage") {
            self.language = defaultLanguage
        }
    }
}
