//
//  ProfileImageView2.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 13.01.2025.
//


import SwiftUI
import FirebaseAuth

struct ProfileImageView2: View {
    @EnvironmentObject var loginVm: LoginViewModel
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("isDarkMode") private var isDarkMode = false
    @EnvironmentObject var languageManager: LanguageManager
    var image: UIImage?

    var body: some View {
        HStack {
            if let photoURL = Auth.auth().currentUser?.photoURL {
                AsyncImage(url: photoURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                    case .failure:
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    @unknown default:
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                }
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
            }

            VStack(alignment: .leading) {
                Text(loginVm.currentUser?.email ?? "user@example.com") // E-posta adresini burada gösteriyoruz
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Welcome back!".addLocalizableString(str: languageManager.language))
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            DarkLightModeButton(hexStringDark: "0C7B93", hexStringLight: "0C7B93")
        }
    }

    
    private func toggleDarkMode(_ isEnabled: Bool) {
        print("Karanlık mod: \(isEnabled ? "Aktif" : "Kapalı")")
    }
}
