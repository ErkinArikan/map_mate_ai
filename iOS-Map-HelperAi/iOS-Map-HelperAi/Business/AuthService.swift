import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import CryptoKit
import AuthenticationServices
import FirebaseFirestore

class AuthService: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    
    @Published var signedIn: Bool = false
    @AppStorage("log_status") var logStatus: Bool = false
    @Published private var isLoading: Bool = false
    var currentNonce: String?
    @Published var logInStyle: LogInStyle = .unknown
    @Published var currentUser:UserModel?

    override init() {
        super.init()
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.logInStyle = .apple
                self.isLoading = false
                self.logStatus = true
                print("Auth state changed, is signed in")
            } else {
                self.logStatus = false
                print("Auth state changed, is signed out")
            }
        }
    }

    func getIsLoading() -> Bool {
        return self.isLoading
    }

    func loadingTriggered() {
        self.isLoading = true
        print("isLoading : \(isLoading)")
    }

    func updateLogInStyle() {
        if let provider = Auth.auth().currentUser?.providerData.first?.providerID {
            if provider == LogInStyle.google.rawValue {
                self.logInStyle = .google
            } else if provider == LogInStyle.email.rawValue {
                self.logInStyle = .email
            } else if provider == LogInStyle.apple.rawValue {
                self.logInStyle = .apple
            }
        } else {
            self.logInStyle = .unknown
        }
        print("Giriş yöntemi güncellendi: \(logInStyle)")
    }

    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }

    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetch identity token")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
                }

                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)

                Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                    if let error = error {
                        print("Error during Firebase Sign-In: \(error.localizedDescription)")
                        return
                    }

                    guard let user = authResult?.user else {
                        print("Failed to get user after Firebase Sign-In.")
                        return
                    }

                    // Kullanıcı adı ve e-posta ekleme işlemi
                    if let fullName = appleIDCredential.fullName {
                        let displayName = "\(fullName.givenName ?? "") \(fullName.familyName ?? "")"
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = displayName.isEmpty ? "Anonymous" : displayName
                        changeRequest.commitChanges { error in
                            if let error = error {
                                print("Error updating display name: \(error.localizedDescription)")
                            } else {
                                print("Display name updated to: \(displayName)")
                            }
                        }
                    }

                    if let email = appleIDCredential.email {
                        Task {
                            do {
                                let newUser = UserModel(
                                    id: user.uid,
                                    name: user.displayName ?? "Anonymous",
                                    email: email,
                                    favoritesPlaces: [],
                                    userPromptLimit: 5,
                                    joined: Date().timeIntervalSince1970,
                                    userAgreement: false,
                                    messages: []
                                )
                                try await self?.saveUserToFirestore(user: user)
                            } catch {
                                print("Error saving user to Firestore: \(error.localizedDescription)")
                            }
                        }
                    }

                    Task {
                        do {
                            try await self?.saveUserToFirestore(user: user)
                            await self?.fetchUser()
                            await MainActor.run {
                                self?.logStatus = true
                                self?.logInStyle = .apple
                                print("Apple Sign-In complete and user saved to Firestore.")
                            }
                        } catch {
                            print("Error saving user to Firestore: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }


    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
    }

    private func saveUserToFirestore(user: User) async throws {
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(user.uid)

        do {
            let documentSnapshot = try await userDocument.getDocument()
            if documentSnapshot.exists {
                let existingUser = try documentSnapshot.data(as: UserModel.self)
                var updatedUser = existingUser
                updatedUser.name = user.displayName ?? existingUser.name
                updatedUser.email = user.email ?? existingUser.email
                try await userDocument.setData(updatedUser.toDictionary(), merge: true)
                print("User updated in Firestore.")
            } else {
                let newUser = UserModel(
                    id: user.uid,
                    name: user.displayName ?? "Anonymous",
                    email: user.email ?? "No Email",
                    favoritesPlaces: [],
                    userPromptLimit: 5,
                    joined: Date().timeIntervalSince1970,
                    userAgreement: false,
                    messages: []
                )
                try await userDocument.setData(newUser.toDictionary())
                print("New user saved to Firestore.")
            }
        } catch {
            print("Error saving user to Firestore: \(error.localizedDescription)")
            throw error
        }
    }

    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {
            return
        }
        await MainActor.run {
            self.currentUser = try? snapshot.data(as: UserModel.self)
        }
    }
}




