//
//  SettingsDummy.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 12.01.2025.
//

import SwiftUI

struct SettingsDummy: View {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) private var colorScheme
    @State private var profileImage: UIImage? = UIImage(systemName: "person.crop.circle")
    @EnvironmentObject var uiStateVm: UIStateViewModel
    @EnvironmentObject var settingsVm:SettingsViewModel
    @Binding var isShowing:Bool
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        
        NavigationStack{
            if isShowing {
                ZStack{
                    colorScheme == .light ?  Color.hex("F2F2F7").ignoresSafeArea(.all):Color("NewBlack1").ignoresSafeArea(.all)
                    VStack{
                        ProfileImageView2(image: profileImage)
                            .padding(.horizontal)
                            .padding(.top)
                        // List Items
                        List {
                            
                            
                            
                            SettingsRow(icon: "person.crop.circle", title: "Profile Settings".addLocalizableString(str: languageManager.language))
                            
                            SettingsRow(icon: "envelope", title: "Contact".addLocalizableString(str: languageManager.language))
                            
//                            SettingsRow(icon: "star", title: "Rate It".addLocalizableString(str: languageManager.language))
//                            SettingsRow(icon: "exclamationmark.bubble", title: "Feedback".addLocalizableString(str: languageManager.language))
                            
//                            SettingsRow(icon: "square.and.arrow.up", title: "Share with Friends".addLocalizableString(str: languageManager.language))
                            
                            SettingsRow(icon: "globe", title: "Display Languages".addLocalizableString(str: languageManager.language))
                            
                            SettingsRow(icon: "info.circle", title: "About the App".addLocalizableString(str: languageManager.language))
                            
                            SettingsRow(icon: "shield", title: "Privacy Policy".addLocalizableString(str: languageManager.language))
                            
                            SettingsRow(icon: "door.right.hand.open", title: "Log Out".addLocalizableString(str: languageManager.language))
                            
                        }
                        
                        .listStyle(.plain)
                    }
                    .toolbar {
                        // MARK: - TOOLBAR
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                withAnimation(.easeInOut) {
                                    
                                    settingsVm.isShow.toggle()
                                    hapticImpact.impactOccurred()
                                    
                                }
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8) : Color(.systemGray6))
                                        .frame(width: 35, height: 35)
                                        .shadow(color: Color("ShadowColor").opacity(colorScheme == .light ? 0.2 : 0.9), radius: 1, x: 0, y: 1)
                                    
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 17, height: 17)
                                        .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8) : Color(UIColor.systemGray6))
                                        .foregroundStyle(colorScheme == .light ? Color.hex("F2F2F7") : Color.hex("F2F2F7"))
                                        .fontWeight(.medium)
                                }
                            }
                            .transition(.move(edge: .bottom)) // Aşağıdan kaybolma animasyonu
                            .zIndex(1)
                        }
                        
                        //                DarkLightModeButton(hexStringDark: "0C7B93", hexStringLight: "0C7B93")
                    }
                    .navigationTitle("Settings".addLocalizableString(str: languageManager.language))
                }
            }
            
        }
        .animation(.easeInOut, value: isShowing) // Animasyonu ekler
    }
}

#Preview {
    SettingsDummy(isShowing: .constant(false))
        .environmentObject(LoginViewModel())
}
