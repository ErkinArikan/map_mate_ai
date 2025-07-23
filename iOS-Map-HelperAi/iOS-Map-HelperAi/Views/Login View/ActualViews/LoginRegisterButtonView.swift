//
//  LoginRegisterButtonView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 7.12.2024.
//

import SwiftUI

struct LoginRegisterButtonView: View {
    let action: () -> Void
    var buttonText:String?
    var colorHexCode:String?
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        VStack{
            
      
            Button(action: {
               action()
                hapticImpact.impactOccurred()
            }) {
                Text(buttonText ?? "Buton".addLocalizableString(str: languageManager.language))
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.hex(colorHexCode ?? ""))
                    .cornerRadius(30)
            }
            .padding(.top,20)
            
        }
    }
}

#Preview {
    LoginRegisterButtonView(action: {})
}
