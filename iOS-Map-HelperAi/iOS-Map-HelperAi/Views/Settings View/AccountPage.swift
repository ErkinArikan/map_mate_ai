//
//  AccountPage.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 24.01.2025.
//

import SwiftUI
import FirebaseAuth
import Firebase

struct AccountPage: View {
    
    @EnvironmentObject var loginVm: LoginViewModel
    @State private var isProcessing = false // For loading states
    @State private var showSuccessMessage = false // Success message state
    @State private var showDeleteConfirmation = false // Confirmation for delete
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showErrorMessage = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .light {
                    Color.hex("F2F2F7").ignoresSafeArea(.all)
                } else {
                    Color("NewBlack1").ignoresSafeArea(.all)
                }
                
                VStack(spacing: 30) {
                    Spacer(minLength: 30)
                    
                    // Profile Section
                    VStack(spacing: 10) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        
                        Text(loginVm.currentUser?.email ?? "user@example.com")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("Manage your account settings".addLocalizableString(str: languageManager.language))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Change Password Button
                    VStack(spacing: 10) {
                        Text("Change Password".addLocalizableString(str: languageManager.language))
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            isProcessing = true
                            Task {
                                loginVm.resetEmailAdress = loginVm.resetEmailAdress.trimmingCharacters(in: .whitespacesAndNewlines)
                                await resetPassword()
                            }
                        }) {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Reset Password".addLocalizableString(str: languageManager.language))
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .background(Color.hex("0C7B93"))
                                    .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                      
                        
                        if showSuccessMessage {
                            Text("A password reset link has been sent to your email:\(loginVm.currentUser?.email ?? "user@example.com")".addLocalizableString(str: languageManager.language))
                                .font(.footnote)
                                .foregroundColor(.green)
                                .multilineTextAlignment(.center)
                                .padding(.top, 10)
                        }
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Delete Account Button
                    VStack(spacing: 10) {
                        Text("Delete Account".addLocalizableString(str: languageManager.language))
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        Button(action: {
                            showDeleteConfirmation = true
                        }) {
                            Text("Delete My Account".addLocalizableString(str: languageManager.language))
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                    }
                    if !loginVm.errorMessage.isEmpty {
                        Text("You need to re-login for deleting your account".addLocalizableString(str: languageManager.language))
                            .font(.footnote)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                .navigationTitle("Account Settings".addLocalizableString(str: languageManager.language))
                .navigationBarTitleDisplayMode(.inline)
                .alert(isPresented: $showDeleteConfirmation) {
                    Alert(
                        title: Text("Are you sure?".addLocalizableString(str: languageManager.language)),
                        message: Text("Deleting your account is irreversible.".addLocalizableString(str: languageManager.language)),
                        primaryButton: .destructive(Text("Delete".addLocalizableString(str: languageManager.language))) {
                            Task {
                                await loginVm.deleteAccount()
                            }
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                if loginVm.signingOut {
                    ProgressView("Sign Out")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.gray.opacity(0.8))
                        .cornerRadius(10)
                        .zIndex(1) // Öne çıkar
                }
            }
        }
        .onAppear(){
            loginVm.resetEmailAdress = loginVm.currentUser?.email ?? ""
        }
    }
    
    private func resetPassword() async {
        loginVm.sendResetLink()
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Simulated delay
        isProcessing = false
        showSuccessMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
            showSuccessMessage = false
        }
    }
    
  
}

#Preview {
    AccountPage()
        .environmentObject(LoginViewModel())
        .environmentObject(LanguageManager())
}
