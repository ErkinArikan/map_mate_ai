//
//  DarkLightModeButton.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 7.12.2024.
//

import Foundation
import SwiftUI

struct DarkLightModeButton:View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    var hexStringDark:String?
    var hexStringLight:String?
    var body: some View {
        Button(action: {
            isDarkMode.toggle() // Tema değiştir
        }) {
            
                Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 25,height:25)
                .foregroundColor(colorScheme == .dark ? Color.hex(hexStringDark ?? ""): Color.hex(hexStringLight ?? ""))
        }
      
        .padding()
        .animation(.easeInOut, value: isDarkMode) // Yumuşak geçiş
    }
}
