import SwiftUI

struct SettingsResetPasswordView: View {
    @EnvironmentObject var loginVm: LoginViewModel
    @State private var isProcessing = false // Loading state
    @State private var showSuccessMessage = false // Success message state
    @EnvironmentObject var languageManager:LanguageManager
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .light {
                                Color.hex("F2F2F7").ignoresSafeArea(.all)
                            } else {
                                Color("NewBlack1").ignoresSafeArea(.all)
                            }
                VStack(spacing: 20) {
                    Spacer(minLength: 50)
                    
                    // Title
                    VStack(spacing: 10) {
                        Text("Reset Your Password".addLocalizableString(str: languageManager.language))
                            .font(.largeTitle)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                        
                        Text("Enter your registered email address, and we will send you a link to reset your password.".addLocalizableString(str: languageManager.language))
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }
                    
                    Spacer(minLength: 30)
                    
                    // Email Input Field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address".addLocalizableString(str: languageManager.language))
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        TextField("Enter your email".addLocalizableString(str: languageManager.language), text: $loginVm.resetEmailAdress)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding(.horizontal, 20)
                    
                    // Reset Button
                    Button(action: {
                        isProcessing = true
                        Task {
                            await resetPassword() // Call your method here
                        }
                    }) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Reset Password".addLocalizableString(str: languageManager.language))
                                .font(.headline)
                                .foregroundColor(colorScheme == .light ? Color.hex("F2F2F7"): Color.hex("F2F2F7"))
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(colorScheme == .light ? Color.hex("0C7B93"):Color(.systemGray6))
                                .cornerRadius(10)
                                .padding(.horizontal, 20)
                        }
                    }
                    .disabled(loginVm.resetEmailAdress.isEmpty || isProcessing)
                    
                    // Success Message
                    if showSuccessMessage {
                        Text("A password reset link has been sent to your email.".addLocalizableString(str: languageManager.language))
                            .font(.footnote)
                            .foregroundColor(.green)
                            .multilineTextAlignment(.center)
                            .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                .navigationTitle("Reset Password".addLocalizableString(str: languageManager.language))
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }

    private func resetPassword() async {
        // Simulate API call or handle actual password reset logic
        loginVm.sendResetLink()
        try? await Task.sleep(nanoseconds: 2 * 1_000_000_000) // Simulated delay
        isProcessing = false
        showSuccessMessage = true
    }
}

#Preview {
    SettingsResetPasswordView()
        .environmentObject(LoginViewModel())
        
}
