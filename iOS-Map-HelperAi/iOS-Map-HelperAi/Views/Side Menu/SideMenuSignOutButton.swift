//
//  SideMenuSignOutButton.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 10.01.2025.
//

import SwiftUI

struct SideMenuSignOutButton: View {
    
 
    @EnvironmentObject var mapMateVm:MapMateViewModel
    @EnvironmentObject var loginVm:LoginViewModel
    @EnvironmentObject var sideMenuVm:SideMenuViewModel
    @AppStorage("log_status") private var logStatus:Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        VStack {
//            Spacer()
            Button {
                withAnimation {
                    sideMenuVm.sideMenuShow.toggle()
                    loginVm.signOut()
                    loginVm.userSession = nil
                    logStatus = false
                    mapMateVm.currentUser = nil
                    mapMateVm.messages = []
                }
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right.fill")
                        .font(.system(size: 16, weight: .bold))
                    Text("Sign Out".addLocalizableString(str: languageManager.language))
                        .font(.system(size: 16, weight: .bold))
                }
                .frame(maxWidth: .infinity, minHeight: 50) // Buton genişliği ve yüksekliği
                .foregroundStyle(colorScheme == .light ? Color.hex("F2F2F7") : Color.hex("F2F2F7"))
                .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.7) :  Color(.systemGray6))
                .cornerRadius(10) // Kenar yumuşatma
                .padding(.horizontal, 10)
            }
            .padding(.bottom, 10) // Ekran altına biraz boşluk bırak
        }
        .frame(maxWidth: .infinity) // Yan menü genişliği
        .background(colorScheme == .light ? Color.hex("F2F2F7") : Color("DarkBg2")) // Side menü
    }
}

#Preview {
    SideMenuSignOutButton()
}
