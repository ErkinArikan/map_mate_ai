//
//  ErrorToastView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 23.12.2024.
//

import SwiftUI

struct ErrorToastView: View {
    @Binding var errorMessage:String
    @State var showNotification = false
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        HStack(spacing:15){
            Image ("NewestLogo")
                .resizable()
                .scaledToFit()
                .font(.title2)
                .frame(width: 55, height: 50)
                .background(.thinMaterial, in: .rect(cornerRadius: 10))
                .padding(.leading,10)
            Text(errorMessage.addLocalizableString(str: languageManager.language))
                .font(.system(size: 13))
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .padding()
                .transition(.opacity)
            
            Spacer()
               
        }
        .bold()
        .frame(maxWidth: .infinity, maxHeight: 70)
        .background(.thinMaterial, in: .rect (cornerRadius: 20))
        .onAppear {
            self.showNotification = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation{
                    self.showNotification = false
                }
            }
        }
    }
}

#Preview {
    ErrorToastView(errorMessage:.constant("Bu bir error messajı örneğidir buraya bakarlar ne kadar uzun olabilir."))
        .environmentObject(LoginViewModel())
}
