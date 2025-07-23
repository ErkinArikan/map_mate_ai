//
//  AttributedTextView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 21.11.2024.
//

import Foundation
import SwiftUI

struct AttributedTextView: View {
    let attributedText: NSAttributedString
    var addressAction: (String) -> Void // Tıklanınca yapılacak işlem

    var body: some View {
        TextViewWrapper(attributedText: attributedText, addressAction: addressAction)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct TextViewWrapper: UIViewRepresentable {
    let attributedText: NSAttributedString
    var addressAction: (String) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.delegate = context.coordinator
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.attributedText = attributedText
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(addressAction: addressAction)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var addressAction: (String) -> Void

        init(addressAction: @escaping (String) -> Void) {
            self.addressAction = addressAction
        }

        private func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextViewDelegate) -> Bool {
            addressAction(URL.absoluteString) // Adres tıklandığında işlem
            return false // Varsayılan davranışı önle
        }
    }
}
