//
//  ProfileView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 25.12.2024.
//

import SwiftUI
import FirebaseAuth

//enum LogInStyle: String, CaseIterable {
//    case google,email
//}


struct ProfileView: View {
    @EnvironmentObject var loginVm:LoginViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment:.leading) {
            if loginVm.logInStyle == .google || loginVm.logInStyle == .apple {
                
                if let photoURL = Auth.auth().currentUser?.photoURL {
                    // Profil fotoğrafı mevcutsa yüklenir
                    AsyncImage(url: photoURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView() // Yüklenme aşamasında bir gösterge
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        case .failure:
                            Image(systemName: "person.circle.fill") // Varsayılan bir görsel
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.gray)
                        @unknown default:
                            Image(systemName: "exclamationmark.triangle.fill")
                        }
                    }
                } else {
                    // Profil fotoğrafı yoksa varsayılan bir görsel göster
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                   
                }

                // Kullanıcı adı
                Text(Auth.auth().currentUser?.displayName ?? "Username not found")
                    .font(.system(size: 16))
                    .padding(.top,3)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .light ? Color.hex("0C7B93"):Color.hex("F2F2F7"))
                
            }
            else if loginVm.logInStyle == .email{
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                
                Text(loginVm.currentUser?.name ?? "Username not found!")
                    .font(.system(size: 16))
                    .padding(.top,2)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .light ? Color.hex("0C7B93"):Color.hex("F2F2F7"))
            }
            
           
        }
        .padding(.leading)
        .onAppear{
            print("Profile view appeared! Login style:\(loginVm.logInStyle)")
            Task{
                
                await loginVm.fetchUser()
            }
            loginVm.updateLogInStyle()
           
        }
    }
        
}



#Preview {
    ProfileView()
        .environmentObject(LoginViewModel())
}
