//
//  SettingsRow.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 13.01.2025.
//


import SwiftUI
import FirebaseAuth

struct SettingsRow: View {
    var icon: String
    var title: String
    @State var isNext: Bool = false
    @EnvironmentObject var loginVm:LoginViewModel
    @EnvironmentObject var settingsVm:SettingsViewModel
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        Button {
            withAnimation {
                hapticImpact.impactOccurred()
                isNext.toggle()
                if title == "Log Out" || title == "Çıkış Yap"{
                    loginVm.signOut()
                    settingsVm.isShow.toggle()
                }
               
            }
           
            
        } label: {
            HStack {
                Image(systemName: icon)
                    .frame(width: 30, height: 30)
                    .foregroundColor(colorScheme == .light ? Color.hex("0C7B93").opacity(0.7): Color.hex("F2F2F7").opacity(0.7))
                
                Text(title)
                    .foregroundColor(colorScheme == .light ? Color.hex("0C7B93"): Color.hex("F2F2F7"))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(colorScheme == .light ? Color.hex("0C7B93").opacity(0.7): Color.hex("F2F2F7").opacity(0.7))
            }
            .padding(.vertical, 8)
            
            
        }
        .listRowBackground(Color.clear)
        
        .navigationDestination(isPresented: $isNext) {
            if title == "Profile Settings" || title == "Hesap Ayarları"{
//                SettingsResetPasswordView()
                AccountPage()
            }
            
            if title == "Display Languages" || title == "Dilleri Ayarları"{
                LanguageView()
            }
            if title == "Privacy Policy" || title == "Gizlilik Politikası"{
                PrivacyPolicyView()
            }
            if title == "Contact" || title == "İletişim"{
                ContactPageView()
            }
            if title == "About the App" || title == "Uygulama Hakkında"{
                AboutPageView()
            }
            if title == "Feedback" || title == "Geri bildirim"{
                FeedbackPageView()
            }
        }
        
        
    }
}
