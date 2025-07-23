//
//  WifiNotiftow.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 23.12.2024.
//

import SwiftUI

import Network

struct WifiNotiftow: View {
    @Binding var isConnected: Bool
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        HStack(spacing:15){
            Image (systemName: isConnected ? "wifi" : "wifi.slash") .foregroundStyle(isConnected ? .green : .red)
                .font(.title2)
                .frame(width: 55, height: 50)
                .background(.thinMaterial, in: .rect(cornerRadius: 10))
                .padding(.leading,10)
            Text(isConnected ? "Internet connection restored".addLocalizableString(str: languageManager.language) : "Internet connection lost".addLocalizableString(str: languageManager.language))
            
            Spacer()
               
        }
        .bold()
        .frame(maxWidth: .infinity, maxHeight: 70)
        .background(.thinMaterial, in: .rect (cornerRadius: 20))
    }
    
   
    }


#Preview {
    WifiNotiftow(isConnected: .constant(true))
}




