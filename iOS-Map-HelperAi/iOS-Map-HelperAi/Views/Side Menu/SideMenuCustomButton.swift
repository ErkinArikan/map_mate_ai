//
//  SideMenuCustomButton.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 10.01.2025.
//

import SwiftUI

struct SideMenuCustomButton: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var languageManager:LanguageManager
    var action: () -> Void
    var imageText: String?
    var text: String?
    
    var body: some View {
        Button {
            // Perform action
            withAnimation {
                action()
            }
        } label: {
            HStack {
                // Left icon
                Image(systemName: imageText ?? "heart.fill")
                    .font(.system(size: 15))
                    
                // Text
                Text(text?.addLocalizableString(str: languageManager.language) ?? "heart asda ill")
                    .font(.system(size: 15, weight: .regular))
//                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer()
                
                // Chevron icon
                Image(systemName: "chevron.right")
                    .font(.system(size: 13))
            }
//            .foregroundStyle(colorScheme == .light ? Color.hex("F2F2F7") : Color.hex("0C7B93").opacity(0.5))
            .frame(width: 200, height: 30, alignment: .leading)
            .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93") : Color.hex("F2F2F7"))
        }
        .padding(.horizontal)
    }
}

#Preview {
    SideMenuCustomButton(action: {})
}


//    VStack {
//
//        Button {
//            withAnimation {
//                action()
//            }
//        } label: {
//            HStack(spacing: 0) {
//                // Light Mode Tarafı
//                HStack {
//                    Image(systemName: imageNameFirst ?? "")
//                        .font(.system(size: 14, weight: .bold)) // Daha küçük font boyutu
//                    Text(text ?? "")
//                        .font(.system(size: 14, weight: .bold)) // Daha küçük font boyutu
//                }
//                .frame(maxWidth: .infinity) // Eşit genişlik
//                .padding()
//                .background(isDarkMode ? Color.gray.opacity(0.2) : Color.hex("0C7B93")) // Aktif ve pasif renkler
//                .foregroundStyle(isDarkMode ? Color.gray : Color.hex("F2F2F7"))
//
//                // Dark Mode Tarafı
//                HStack {
//                    Image(systemName: imageNameSecond ?? "")
//                        .font(.system(size: 14, weight: .bold)) // Daha küçük font boyutu
//                    Text("Dark")
//                        .font(.system(size: 14, weight: .bold)) // Daha küçük font boyutu
//                }
//                .frame(maxWidth: .infinity) // Eşit genişlik
//                .padding()
//                .background(isDarkMode ? Color.hex("0C7B93") : Color.gray.opacity(0.2)) // Aktif ve pasif renkler
//                .foregroundStyle(isDarkMode ? Color.hex("F2F2F7") : Color.gray)
//            }
//            .cornerRadius(8) // Kenar yumuşatma
//            .frame(height: 40) // Yükseklik düşürüldü
//        }
//        .padding(.horizontal, 10) // Yan boşluklar
//        .padding(.bottom, 10) // Alt boşluk
//    }
//    .frame(maxWidth: .infinity) // Yan menü genişliği
//    .background(colorScheme == .light ? Color.hex("F2F2F7") : Color("DarkBg2")) // Arka plan
//}

