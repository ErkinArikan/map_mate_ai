import Foundation
import FirebaseAuth
import SwiftUI
import Firebase
import GoogleSignIn
import FirebaseAuth
import Network



enum LogInStyle: String {
    case google = "google.com"
    case email = "password"
    case apple = "apple.com"
    case unknown = "unknown"
}



class LoginViewModel:ObservableObject,SignInUpProtocol{
   
    
    @Published var isValidEmail = true
    @Published var isValidPassword = true
    
    @Published var isLoading = false
    @Published var signingOut = false
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    
    @Published var userSession:FirebaseAuth.User?
    @Published var welcomeText: String = ""
    @Published var logInText: String = ""
    private let welcomeFullText = "Welcome Back,"
    private let logInFullText = "Log In!"
    @Published var showEmailVericationView:Bool = false
    @Published var currentUser:UserModel?
    
    
    @AppStorage("log_status") var logStatus:Bool = false
    @Published var currentUserId:String = ""
    @Published var showResetAlert:Bool = false 
    @Published var resetEmailAdress:String = ""
    @Published var alertErrorMessage:String = ""
    @Published var showAlertMessage:Bool = false
    
    
    private var connectivityChecker: InternetConnectivityChecker
    // Bağlantı durumu
    
    @Published var logInStyle: LogInStyle = .unknown // Varsayılan olarak "unknown"
    
    
    
    
    //MARK: INIT
    init() {
        self.userSession = Auth.auth().currentUser
        
        self.connectivityChecker = InternetConnectivityChecker()
        
        self.updateLogInStyle()
        
        Task{
            await fetchUser()
        }
        // Bağlantı durumu takibi

    }
    
   
    
 
    //MARK:  SIGN IN
    ///Sign in
    func signIn(withEmail: String, withPassword: String) async throws {
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = ""
        }
        guard validate() else {
            await MainActor.run {
                self.isLoading = false
            }
            return
        }
        do {
            let result = try await Auth.auth().signIn(withEmail: withEmail, password: withPassword)
            // Kullanıcıyı yeniden yükle
                try await result.user.reload()

                // Giriş yöntemi stilini güncelle
            await MainActor.run {
                self.updateLogInStyle() // Giriş yöntemi güncellendi
            }
                
                print("Login style after update: \(logInStyle)")
            if !result.user.isEmailVerified {
                await MainActor.run {
                    
                    self.errorMessage = "Please verify your email address."
                }
                
                do {
                    try await result.user.sendEmailVerification()
                    print("Doğrulama e-postası başarıyla gönderildi.")
                    await MainActor.run {
                        self.showEmailVericationView = true
                    }
                   
                } catch {
                    print("Doğrulama e-postası gönderilemedi: \(error.localizedDescription)")
                    if let errorCode = AuthErrorCode(rawValue: (error as NSError).code) {
                        if errorCode == .tooManyRequests {
                            await MainActor.run {
                            self.errorMessage = "Doğrulama e-postası çok kısa süre içinde tekrar gönderilemez. Lütfen birkaç dakika sonra tekrar deneyin."
                            }
                        } else {
                            self.errorMessage = "Failed to send a verification email: \(error.localizedDescription)"
                        }
                    }
                }
                
                // Kullanıcının email doğrulama durumunu kontrol etmek için bir Timer başlat
                Task{
                    await startEmailVerificationPolling(for: result.user)
                }
            } else {
                // Kullanıcı doğrulandıysa hemen logStatus'u güncelle
                await MainActor.run {
                    self.logStatus = true
                    self.userSession = result.user
                }
            }
            await MainActor.run {
                self.isLoading = false
            }
            await fetchUser()
            

        } catch let error as NSError {
            await MainActor.run {
                switch AuthErrorCode(rawValue: error.code) {
                case .invalidEmail:
                    self.errorMessage = "You entered an invalid email address."
                case .wrongPassword:
                    self.errorMessage = "You entered the wrong password."
                case .userNotFound:
                    self.errorMessage = "No account matching this email address was found."
                default:
                    self.errorMessage = "Failed to log in. Please check your e-mail and password."
                }
                self.isLoading = false
            }
        }
    }
    
    
    
    
    
    

    func loadingTriggered() {
        self.isLoading = true
        print("isLoading : \(isLoading)")
    }
    
    
    //MARK: googleOauth
    @MainActor
    func googleOauth() async throws {
        // Google Sign-In
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No Firebase clientID found")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = scene?.windows.first?.rootViewController else {
            fatalError("There is no root view controller!")
        }

        do {
            // Google Sign-In işlemi
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            let user = result.user
            guard let idToken = user.idToken?.tokenString else {
                throw AuthenticationError.runtimeError("Unexpected error occurred, please retry")
            }

            // Firebase Authentication işlemi
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken, accessToken: user.accessToken.tokenString
            )
            let authResult = try await Auth.auth().signIn(with: credential)

            // Giriş başarıyla tamamlandı, logStatus hemen true yapılabilir
            await MainActor.run {
                self.logStatus = true
                self.logInStyle = .google
                self.isLoading = false
                print("Log Status güncellendi: \(logStatus)")
            }

            // Firestore kayıt işlemi (arkaplanda yapılabilir)
            try await authResult.user.reload()
            try await saveUserToFirestore(user: authResult.user)
            await fetchUser()

            await MainActor.run {
                self.updateLogInStyle() // Giriş yöntemi güncellendi
            }
        } catch let error as GIDSignInError where error.code == .canceled {
            // Kullanıcı işlemi iptal ettiğinde
            await MainActor.run {
                self.isLoading = false
                print("Kullanıcı Google girişini iptal etti.")
            }
        } catch {
            // Diğer hatalar
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = "Bir hata oluştu: \(error.localizedDescription)"
            }
            throw error
        }
    }


//
//    func detectLoginStyle() {
//        if let provider = Auth.auth().currentUser?.providerData.first?.providerID {
//            if provider == "google.com" {
//                self.logInStyle = .google
//            } else if provider == "password" {
//                self.logInStyle = .email
//            }
//            print("Detected Login Style: \(self.logInStyle)")
//        }
//    }

    
    
    //MARK: - UPDATE LOGIN STYLE
    // Kullanıcının giriş yöntemini belirleyen fonksiyon
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
    
    
    //MARK: startEmailVerificationPolling
    /// Email doğrulama durumu kontrolü (Polling)
    private func startEmailVerificationPolling(for user: User) async {
        for _ in 0..<20  { // 10 kez kontrol eder (örneğin 20 saniye boyunca 2 saniye aralıklarla)
            try? await Task.sleep(nanoseconds: 500 * 1_000_000_000) // 2 saniye bekle
            do {
                try await user.reload()
                if user.isEmailVerified {
                    await MainActor.run {
                        withAnimation {
                               self.showEmailVericationView = false
                               self.logStatus = true
                           }
                        errorMessage = "Accessing! ... You are switching to Final Map View!"
                    }
                    break
                }
            } catch {
                print("Kullanıcı yenileme hatası: \(error.localizedDescription)")
            }
        }
    }
  

    
    //MARK: - SIGN OUT
    
    func signOut(){
        do{
            logStatus = false
            try Auth.auth().signOut()
            userSession = nil
            self.currentUser = nil
            GIDSignIn.sharedInstance.signOut()
        }catch{
            
        }
    }
    func deleteAccount() async {
        isLoading = true // İşlem sırasında yükleme durumu göster
        errorMessage = "" // Hata mesajını sıfırla
        
        do {
            guard let user = Auth.auth().currentUser else {
                print("No authenticated user found.")
                isLoading = false
                errorMessage = "No authenticated user found. Please log in again."
                return
            }
            
            // Firestore dokümanını kontrol et ve sil
            let db = Firestore.firestore()
            let userDocument = db.collection("users").document(user.uid)
            
            let documentSnapshot = try await userDocument.getDocument()
            if documentSnapshot.exists {
                try await userDocument.delete()
                print("Firestore document deleted for user ID: \(user.uid)")
            } else {
                print("No Firestore document found for user ID: \(user.uid)")
            }
            
            // Firebase Authentication'dan kullanıcıyı sil
            try await user.delete()
            print("Firebase Auth user deleted.")
            
            // Çıkış yap
            await MainActor.run {
                self.signOut()
                self.signingOut = true
                self.isLoading = false
            }
        } catch let error as NSError {
            // Hata durumunda mesaj göster
            print("Error deleting account: \(error.localizedDescription)")
            
            await MainActor.run {
                self.isLoading = false
                if error.code == AuthErrorCode.requiresRecentLogin.rawValue {
                    self.errorMessage = "To delete your account, please log in again and try again."
                } else {
                    self.errorMessage = "An error occurred while deleting your account. Please try again later."
                }
            }
        }
    }

    
    //MARK: sendResetLink
    func sendResetLink() {
        Task {
            do {
                if resetEmailAdress.isEmpty {
                    await MainActor.run {
                        alertErrorMessage = "Please enter an email address."
                        showAlertMessage = true
                    }
                    return
                }
                
                // Ensure email validity
                guard resetEmailAdress.contains("@"), resetEmailAdress.contains(".") else {
                    await MainActor.run {
                        alertErrorMessage = "Please enter a valid email address."
                        showAlertMessage = true
                    }
                    return
                }
                
                // Send the password reset link
                try await Auth.auth().sendPasswordReset(withEmail: resetEmailAdress)
                
                await MainActor.run {
                    alertErrorMessage = "Please check your email (\(resetEmailAdress)) for the reset link."
                    resetEmailAdress = "" // Clear input field
                    showAlertMessage = true
                }
            } catch {
                await MainActor.run {
                    alertErrorMessage = "An error occurred: \(error.localizedDescription)"
                    showAlertMessage = true
                }
            }
        }
    }

    
    
    //MARK: - FETCH USER
    func fetchUser()async {
        guard let uid = Auth.auth().currentUser?.uid else{
            return
        }
        guard let snaphot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else{
            return
        }
        await MainActor.run {
            self.currentUser = try? snaphot.data(as:UserModel.self)
        }
        
       
    }
    
    
    //MARK: validate
    func validate()-> Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,!password.trimmingCharacters(in: .whitespaces).isEmpty else{
            errorMessage = "Lütfen tüm alanları doldurun"
            return false
            
        }
        
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Lütfen geçerli bir email adresi girin."
            return false
        }
        return true
    }
    
  
    
   
    
    //MARK: isSignedIn
    public var isSignedIn:Bool {
        
        return Auth.auth().currentUser != nil
    }
    
    
    
   

    //MARK: Save User to Firebase
    private func saveUserToFirestore(user: User) async throws {
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(user.uid)

        // Kullanıcıyı Firestore'dan kontrol et
        do {
            let documentSnapshot = try await userDocument.getDocument()
            if documentSnapshot.exists {
                // Kullanıcı zaten varsa, sadece eksik veya güncellenmesi gereken alanları güncelle
                let existingUser = try documentSnapshot.data(as: UserModel.self)
                var updatedUser = existingUser

                // Gerekirse diğer alanları güncelleyin
                updatedUser.name = user.displayName ?? updatedUser.name
                updatedUser.email = user.email ?? updatedUser.email
                
                updatedUser.messages = existingUser.messages // Mesajları koru
                
                try await userDocument.setData(updatedUser.toDictionary(), merge: true)
                print("Kullanıcı güncellendi.")
            } else {
                // Kullanıcı yoksa yeni kullanıcı oluştur
                let newUser = UserModel(
                    id: user.uid,
                    name: user.displayName ?? "Anonymous",
                    email: user.email ?? "No Email",
                    favoritesPlaces: [], // Başlangıçta boş bir liste
                    userPromptLimit: 5, // Bu değer atanıyor mu kontrol edin
                    joined: Date().timeIntervalSince1970,
                    userAgreement: false,
                    messages: [] // Başlangıçta boş bir mesaj listesi
                )
                try await userDocument.setData(newUser.toDictionary())
                print("Yeni kullanıcı Firestore'a kaydedildi.")
            }
        } catch {
            print("Kullanıcıyı kaydederken hata oluştu: \(error.localizedDescription)")
            throw error
        }
    }



    
    
    //MARK: Log Out
//    func logout() async throws {
//        GIDSignIn.sharedInstance.signOut()
//        try Auth.auth().signOut()
//    }
    
    
    //MARK: animateText
    func animateText() {
        welcomeText = ""
        logInText = ""
        
        // Dil kontrolü
        let languageManager = LanguageManager()
        let isTurkish = languageManager.language == "tr"

        // Metinleri dil seçimine göre belirleyin
        let welcomeCharacters = Array((isTurkish ? "Tekrar Hoş Geldiniz," : "Welcome Back,"))
        let logInCharacters = Array((isTurkish ? "Giriş Yap!" : "Log In!"))
        
        let haptic = UIImpactFeedbackGenerator(style: .soft)
        
        // İlk yazıyı animasyonla oluştur
        for (index, char) in welcomeCharacters.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(index)) {
                self.welcomeText.append(char)
                haptic.impactOccurred()
            }
        }
        
        // İkinci yazıyı animasyonla oluştur
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(welcomeCharacters.count)) {
            for (index, char) in logInCharacters.enumerated() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(index)) {
                    self.logInText.append(char)
                    haptic.impactOccurred()
                }
            }
        }
    }

    
    
}

//MARK: - AuthError
enum AuthenticationError: Error {
    case runtimeError(String)
}
