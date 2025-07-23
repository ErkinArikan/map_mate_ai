//
//  MessageModel.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 21.11.2024.
//

import Foundation
import SwiftUI

/// AttributedOutput, bir mesajın Markdown işlenmiş içeriğini ve bunun ayrıştırılmış sonuçlarını temsil eder.
struct AttributedOutput {
    let string: String // İşlenmiş Markdown'ın düz metin hali.
    let results: [ParserResult] // Markdown'dan ayrıştırılmış sonuçlar (örneğin, kod blokları veya özel formatlar).
}

/// Mesajın türünü tanımlayan enum.
/// Gönderilen ve alınan mesajların ya Markdown işlenmiş ya da düz metin olarak tutulmasını sağlar.
enum MessageType {
    case attributed(AttributedOutput) // Markdown işlenmiş içerik.
    case simpleText(String) // Düz, işlenmemiş metin.
    
    // Mesaj türünden bağımsız olarak düz metin halini döndürür.
    var text: String {
        switch self {
        case .attributed(let attributedOutput):
            return attributedOutput.string // Markdown'dan işlenmiş düz metni döndür.
        case .simpleText(let string):
            return string // Düz metni döndür.
        }
    }
}

// Mesajları temsil eden ana yapı. Her bir mesajın gönderici ve yanıt bilgilerini içerir.
struct MessageModel: Identifiable {
    
    let id = UUID() // Mesaj için benzersiz bir kimlik.

    var isInteracting: Bool // Mesajın o an işlenip işlenmediğini belirtir (örneğin, yanıt bekleniyor mu?).

    let sendImage: String // Kullanıcının profil resmi (örneğin, kullanıcı balonunda gösterilir).
    var send: MessageType // Kullanıcının gönderdiği mesaj (Markdown veya düz metin olabilir).
    var sendText: String { // Kullanıcının gönderdiği mesajın düz metin hali.
        send.text
    }
    
    let responseImage: String // Asistanın profil resmi (örneğin, asistan balonunda gösterilir).
    var response: MessageType? // Asistanın verdiği yanıt (Markdown veya düz metin olabilir).
    var responseText: String? { // Asistanın yanıtının düz metin hali.
        response?.text
    }
    
    var responseError: String? // Yanıt sırasında oluşan hata mesajı (varsa).
    var attributedResponse: NSAttributedString? // Zengin metin
}






