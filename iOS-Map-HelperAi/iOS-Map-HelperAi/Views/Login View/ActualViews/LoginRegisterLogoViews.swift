//
//  LoginRegisterLogoViews.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 7.12.2024.
//

import SwiftUI
import AuthenticationServices
import Firebase
import CryptoKit

struct LoginRegisterLogoViews: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var loginVm: LoginViewModel
    var body: some View {
        HStack(spacing: 15) {
            Spacer()
//            SignInWithAppleButton(.signIn) { request in
//                
//                
//            } onCompletion: { result in
//                
//            }
//            .frame(height: 45)
//            .clipShape(Circle())

            Button(action: {
                // Apple sign in action
                authService.loadingTriggered()
                hapticImpact.impactOccurred()
                authService.startSignInWithAppleFlow()
                
            }) {
                Image(systemName: "applelogo")
                    .font(.title2)
                    .foregroundColor(Color.white)
                    .frame(width: 50, height: 50)
                    .background(colorScheme == .dark ? Color.hex("0C7B93"):Color.hex("0C7B93"))
                    .cornerRadius(30)
                    
            }
            
            Button(action: {
                loginVm.loadingTriggered()
                Task {
                    do {
                       
                        try await loginVm.googleOauth()
//                        loginVm.isLoading = true
                    } catch AuthenticationError.runtimeError(let errorMessage) {
                        loginVm.errorMessage = errorMessage
                    }
                }
                
                hapticImpact.impactOccurred()
            }) {
                Image(systemName: "g.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.hex("0C7B93").opacity(0.8))
                    .cornerRadius(30)
                   
            }
            
            
            Spacer()
        }
        .padding(.top)
    }
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

#Preview {
    LoginRegisterLogoViews()
        .environmentObject(LoginViewModel())
}
