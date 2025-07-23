import SwiftUI
import FirebaseAuth

import Lottie



struct LogInView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false // Tema durumu saklanır
    @AppStorage("log_status") private var logStatus:Bool = false
    @EnvironmentObject var loginVm:LoginViewModel
    @StateObject var internetManagerVm = InternetConnectivityChecker()
    @Environment(\.presentationMode) var presentationMode
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @State var isTapped:Bool = false
    @State var isPasswordTapped:Bool = false
    
    @State var isRegister:Bool = false
    @State var count  = 1
    @State private var showToast = false // Toast visibility control
//    @State var googleLoading = false
    @EnvironmentObject var languageManager:LanguageManager
    @EnvironmentObject var authService: AuthService
    var body: some View {
        NavigationStack{
            
            ZStack{
                
            
                
                VStack(spacing: 20) {
                    
                    
                    Spacer()
                    
                    //MARK: Top
                    if !isTapped && !isPasswordTapped{
                        if count == 1{
                            TopView
                                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                        }else{
                            TopViewSecond
                                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                        }
                        
                    }
              
                    Spacer()
                    //MARK:  CENTER
                    VStack(alignment: .leading, spacing: 3) {
                       
                        LoginRegisterTextField(header: "Email", textFieldText: $loginVm.email, image: "envelope", isTapped: $isTapped,count:$count)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                           
                           
                        PasswordTextField(password: $loginVm.password, isPasswordTapped: $isPasswordTapped)
                            .padding(.top,4)
                           
                        
                        
                        forgetPassword
                            .padding(.trailing)
                        
                        
                        LoginRegisterButtonView(action: {
                            Task{
                                try await loginVm.signIn(withEmail: loginVm.email, withPassword: loginVm.password)
                                internetManagerVm.startMonitoring()
                               
                            }
                            
                            
                        }, buttonText: "Log in".addLocalizableString(str: languageManager.language), colorHexCode: "0C7B93")
                        
                        
                        lineView
                        
                        
                       
                        LoginRegisterLogoViews()
                        .padding(.top)
                        
                        footer
                       
                        
                    }
                   
                    .padding(.horizontal, 25)
                    .zIndex(-1)
                    .background(
                        Color(.systemGray6)
                            .clipShape(CustomShape())
                            .padding(.bottom, -100)
                            .padding(.top, -30)
                            .ignoresSafeArea(.all)
                            .contentShape(Rectangle()) // Dokunma olayını geçerli yapar
                    )

                    
                    Spacer()
                } //:VStack
                

               
            } //:ZStack
           
            
            
                .background(colorScheme == .dark ?  Color.hex("0C7B93").opacity(0.8):  Color.hex("0C7B93").opacity(0.8))
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            HStack {
                                Image(systemName: "arrow.backward")
                                    .font(.title2)
                                    .foregroundColor(colorScheme == .dark ? .white:.white)
                                    .fontWeight(.bold)
                                    .padding(.leading,9)
                            }
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        // Dark/Light Mode Toggle Button
                                   Button(action: {
                                       isDarkMode.toggle() // Tema değiştir
                                   }) {
                                       
                                           Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                                           .resizable()
                                           .scaledToFit()
                                           .frame(width: 25,height:25)
                                           .foregroundColor(colorScheme == .dark ? Color.hex("#F2F2F7"): Color.hex("#F2F2F7"))
                                   }
                                 
                                   .padding()
                                   .animation(.easeInOut, value: isDarkMode) // Yumuşak geçiş
                    }
                }
                .navigationBarBackButtonHidden(true)
                .ignoresSafeArea(.keyboard, edges: .bottom)
               
        } //:Nav Stack
        
        .sheet(isPresented: $loginVm.showEmailVericationView, content: {
            EmailVerificationView()
                .presentationDetents([.height(350)])
                .presentationCornerRadius(25)
                .interactiveDismissDisabled()
        })
        .overlay(
            toastView
           
                 
                 , alignment: .top)
        .overlay(content: {
            if loginVm.isLoading && authService.getIsLoading() == true {
                   Color.black.opacity(0.5)
                       .edgesIgnoringSafeArea(.all)
                   ProgressView("Signing In".addLocalizableString(str: languageManager.language))
                       .progressViewStyle(CircularProgressViewStyle(tint: .white))
                       .foregroundColor(.white)
                       .padding()
                       .background(Color.gray.opacity(0.8))
                       .cornerRadius(10)
                       .zIndex(1) // Öne çıkar
                
                
                
                
               }
        })
        
        .overlay(
                       BackSwipeEnabler()
                           .allowsHitTesting(false) // Tıklama engelleme sorununu çözer
                   )

        .alert("Reset Password".addLocalizableString(str: languageManager.language), isPresented: $loginVm.showResetAlert, actions: {
            TextField("Email Address".addLocalizableString(str: languageManager.language), text: $loginVm.resetEmailAdress)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
            Button("Send Reset Link".addLocalizableString(str: languageManager.language), role: .destructive, action: loginVm.sendResetLink )
            
            Button("Cancel".addLocalizableString(str: languageManager.language), role: .cancel){
                loginVm.resetEmailAdress = ""
            }
        }, message: {
            Text("Enter the mail address".addLocalizableString(str: languageManager.language))
        })
        
        .alert("Reset Password".addLocalizableString(str: languageManager.language), isPresented: $loginVm.showAlertMessage, actions: {
           
            
            Button("OK".addLocalizableString(str: languageManager.language), role: .cancel){
//                loginVm.resetEmailAdress = ""
            }
        }, message: {
            Text(loginVm.alertErrorMessage)
        })
        .onAppear(){
            print("isLoading On Login View Appear : \(loginVm.isLoading)")
        }
       
        
        
    }
    
    //MARK: - TOAST VIEW
    private var toastView: some View {
        
        
        HStack{
            if !loginVm.errorMessage.isEmpty {
                HStack{
                    Image("NewestLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 45)
                 
                        .background(.thinMaterial, in: .rect(cornerRadius: 10))
                        .padding(.leading,10)
                    
                   
                    
                    Text(loginVm.errorMessage)
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.leading)
                        
                        .transition(.opacity)
                    
                        .onAppear(){
                            showToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation {
                                    showToast = false
                                    withAnimation {
                                        loginVm.errorMessage = "" // Mesajı sıfırla
                                    }
                                }
                            }
                        }
                    Spacer()
                }
                .bold()
                .frame(maxWidth: 260, maxHeight: 70)
                .background(.thinMaterial, in: .rect (cornerRadius: 20))
              
                
            }
 
        }
       
        .animation(.easeInOut, value: !loginVm.errorMessage.isEmpty)
      }
    

    
    //MARK: - EMAIL VERIFICATION
    @ViewBuilder
    func EmailVerificationView()-> some View{
        VStack(spacing:6){
            LottieView2(lottiFile: "authGif")
                .frame(width: 300, height: 200)
                .padding(.bottom,20)
                 
                    
            Text("Verification".addLocalizableString(str: languageManager.language))
                .font(.title.bold())
            
            Text("We have sent a verification email to your email adress. \nPlease verify to continue.".addLocalizableString(str: languageManager.language))
                .multilineTextAlignment(.center)
                .font(.caption)
                .foregroundStyle(.gray)
                .padding(.horizontal, 25)
            
            
        }
        .overlay(alignment: .topTrailing) {
            Button("Cancel".addLocalizableString(str: languageManager.language)){
                loginVm.showEmailVericationView = false
                ///Optional: You cna delete the account in firebase
                ///if let user = Auth.auth.dcurrentUser { user.delete {_ in}}
                
                
            }
        }
        .padding(.bottom,15)

    }
}

#Preview {
    LogInView()
        .environmentObject(LoginViewModel())
        .environmentObject(LanguageManager())
        .environmentObject(AuthService())
        
}




//MARK: - EXTENSION

extension LogInView{
    
    //MARK: - TopView Second
    private var TopViewSecond:some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome Back,".addLocalizableString(str: languageManager.language))
                .font(.system(size: 37))
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .dark ? Color.hex("#F2F2F7") : Color.hex("#F2F2F7"))
            Text("Log In!".addLocalizableString(str: languageManager.language))
                .font(.system(size: 30))
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? Color.hex("#F2F2F7") : Color.hex("#F2F2F7"))
        }
        .frame(maxWidth: .infinity,maxHeight:300, alignment: .leading)
        .padding(.horizontal, 25)
        .padding(.bottom, 60)
      
    }
    
    //MARK: Top
    private var TopView:some View{
     
        VStack(alignment: .leading, spacing: 8) {
            Text(loginVm.welcomeText)
                .font(.system(size: 37))
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .dark ? Color.hex("#F2F2F7") : Color.hex("#F2F2F7"))
            
            Text(loginVm.logInText)
                .font(.system(size: 30))
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? Color.hex("#F2F2F7") : Color.hex("#F2F2F7"))
        }
        .frame(maxWidth: .infinity,maxHeight:300, alignment: .leading)
        .padding(.horizontal, 25)
        .padding(.bottom, 50)
        .onAppear {
            loginVm.animateText()
        }
    }
    
    //MARK: - Forget Password
    private var forgetPassword: some View{
        
         HStack {
             Spacer()
             Button(action: {
                 loginVm.showResetAlert = true
             }) {
                 Text("Forgot password?".addLocalizableString(str: languageManager.language))
                     .font(.system(size: 14))
                     .fontWeight(.semibold)
                     .foregroundColor(Color.hex("0C7B93"))
             }
         }
         .padding(.top)
         .padding(.bottom,30)
    }
    
    //MARK: - Line View
    private var lineView: some View{
        
        HStack {
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.hex("0C7B93"))
            
            Text("or".addLocalizableString(str: languageManager.language))
                .foregroundColor(colorScheme == .dark ? Color.hex("0C7B93"): Color.hex("0C7B93"))
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color.hex("0C7B93"))
        }
        .padding(.top)
    }
    
    //MARK: - Footer
    private var footer:some View{
        HStack {
            Spacer()
            Text("Don’t have an account?".addLocalizableString(str: languageManager.language))
                .foregroundColor(Color.gray)
            
            Button(action: {
                isRegister.toggle()
            }) {
                Text("Sign up".addLocalizableString(str: languageManager.language))
                    .fontWeight(.bold)
                    .foregroundColor(Color.hex("0C7B93")
                    )
            }
            .navigationDestination(isPresented: $isRegister) {
                RegisterView()
            }
            Spacer()
        }
        .padding(.top, 10)
    }
    
   
}
