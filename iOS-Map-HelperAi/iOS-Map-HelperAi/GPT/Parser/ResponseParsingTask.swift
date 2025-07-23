//
//  ResponseParsingTask.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 21.11.2024.
//

import Foundation

import Markdown

// Actor yapısı, eşzamanlı işlemler sırasında thread-safe (güvenli) bir şekilde çalışmayı sağlar.
// Actor, referans türüdür ve özelliklerine erişim yalnızca bir eşzamanlı işlem tarafından yapılabilir.
actor ResponseParsingTask {
    
    // Bu metod, verilen metni (text) işleyerek bir `AttributedOutput` döner.
    // `async` anahtar kelimesiyle asenkron olarak çalışır.
    func parse(text: String) async -> AttributedOutput {
        // Markdown metnini işlemek için `Document` sınıfını kullanıyoruz.
        // `Document`, Markdown metnini temsil eder ve parçalara ayırır.
        let document = Document(parsing: text)
        
        // Markdown'u `NSAttributedString`'e dönüştürmek için özel bir parser kullanıyoruz.
        var markdownParser = MarkdownAttributedStringParser()
        
        // Parser'dan işlenmiş sonuçları alıyoruz.
        // Bu sonuçlar, metin parçalarını ve kod bloklarını ayrı ayrı temsil eder.
        let results = markdownParser.parserResults(from: document)
        
        // İşlenen metni ve sonuçlarını `AttributedOutput` olarak döneriz.
        return AttributedOutput(string: text, results: results)
    }
    
}
