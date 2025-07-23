//
//  SignInView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 28.11.2024.
//

import SwiftUI
import Lottie
import FirebaseAuth



struct RegisterView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false // Tema durumu saklanır
    @StateObject var registerVm = RegisterViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var name:String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isPasswordVisible: Bool = false
    @Environment(\.colorScheme) private var colorScheme
    
    // Animasyon için State
    @State private var welcomeText: String = ""
    @State private var logInText: String = ""
    private let welcomeFullText = "Welcome,"
    private let logInFullText = "Sign Up Now!"
    @State var onTap:Bool = false
    
    @State var nameTapped:Bool = false
    @State var isTapped:Bool = false
    @State var isPasswordTapped:Bool = false
    @State var count:Int = 1
    
    @State private var showToast = false
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        NavigationStack{
            
               
                
            ZStack {
                VStack(spacing: 20) {
                    
                    
                    Spacer()
                    
                    
                    //MARK: TOP
                    if !isTapped && !isPasswordTapped && !nameTapped{
                        if count == 1{
                            textView
                                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                        }else{
                            textView2
                                .transition(.opacity.animation(.easeInOut(duration: 0.2)))
                        }
                        
                    }
                    
                    
                    Spacer()
                    //MARK:  CENTER
                    VStack(alignment: .leading, spacing: 4) {
                        
                      RegisterNameTextField(header: "Full Name".addLocalizableString(str: languageManager.language), textFieldText: $registerVm.name, image: "person", isTapped: $nameTapped,count: $count)
                        
                        
                        LoginRegisterTextField(header: "Email".addLocalizableString(str: languageManager.language), textFieldText: $registerVm.email, image: "envelope", isTapped: $isTapped,count:$count)
                            .padding(.top,10)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                        
                        PasswordTextField(password: $registerVm.password, isPasswordTapped: $isPasswordTapped)
                            .padding(.top,10)
                        
                        
                        
                        LoginRegisterButtonView(action: {
                            Task{
//                               try await registerVm.registerNew(name: name, password: password, email: email)
                                await   registerVm.register()
                            }
                            
                            
//
                        }, buttonText: "Sign up".addLocalizableString(str: languageManager.language), colorHexCode: "0C7B93")
                        .padding(.top)
                        
                        
                        
                        lineView
                        
                        
                        
                        //MARK: LOGOLAR
                        
                        LoginRegisterLogoViews()
                        
                        
                    } //:VStack
                    
                    .padding(.horizontal, 25)
                    .zIndex(-1)
                    /// iç background
                    .background(
                        Color(.systemGray6)
                            .clipShape(CustomShape())
                            .padding(.bottom,-100)
                            .padding(.top,-30)
                            .ignoresSafeArea(.all)
                           
                    )
                    Spacer()
                } //:VStack
               
                /// dış background
                .background(colorScheme == .dark ?  Color.hex("0C7B93").opacity(0.8):  Color.hex("0C7B93").opacity(0.8)
                            
                            
                )
                //MARK: - TOOLBAR
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
               
                
                if registerVm.isLoading {
                    ZStack {
                        Color.black.opacity(0.5)
                            .edgesIgnoringSafeArea(.all)
                        ProgressView("Please wait...")
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(10)
                    }
                }
                
            }
            .navigationBarBackButtonHidden(true)
            
            .ignoresSafeArea(.keyboard, edges: .bottom)
          
               
            
            
        }
        .overlay(
            toastView
           
                 
                 , alignment: .top)
        .overlay(
            BackSwipeEnabler()
                .allowsHitTesting(false) // Tıklama engelleme sorununu çözer
        )
        .sheet(isPresented: $registerVm.showEmailVericationView, content: {
            EmailVerificationView()
                .presentationDetents([.height(350)])
                .presentationCornerRadius(25)
                .interactiveDismissDisabled()
        })
        
    }
    
    //MARK: - TOAST VIEW
    private var toastView: some View {
        VStack {
            if !registerVm.errorMessage.isEmpty {
                Text(registerVm.errorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 5)
                    .transition(.opacity)
                    .onAppear(){
                        showToast = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showToast = false
                                withAnimation {
                                    registerVm.errorMessage = "" // Mesajı sıfırla
                                }
                            }
                        }
                    }
                
            }

            // Existing UI components
            Spacer()
        }
        .frame(width: 220)
       
        .animation(.easeInOut, value: !registerVm.errorMessage.isEmpty)
      }
    
    
    //MARK: - VERIFICATION VIEW
    @ViewBuilder
    func EmailVerificationView()-> some View{
        VStack(spacing:6){
            LottieView2(lottiFile: "authGif")
                .frame(width: 300, height: 200)
                .padding(.bottom,20)
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
                hapticImpact.impactOccurred()
                registerVm.showEmailVericationView = false
                ///Optional: You cna delete the account in firebase
                ///if let user = Auth.auth.currentUser { user.delete {_ in}}
                registerVm.deleteUser()
                
                
            }
        }
        .padding(.bottom,15)
       


    }
    // Harf Harf Animasyon Fonksiyonu
   
}

#Preview {
    RegisterView()
}

//MARK: - EXTENSION
extension RegisterView{
    
    private var textView2: some View{
        VStack(alignment: .leading, spacing: 8) {
            Text("Welcome,".addLocalizableString(str: languageManager.language))
                .font(.system(size: 37))
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .dark ? Color.hex("#F2F2F7") : Color.hex("#F2F2F7"))
            
            Text("Sign Up Now!".addLocalizableString(str: languageManager.language))
                .font(.system(size: 30))
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? Color.hex("#F2F2F7") : Color.hex("#F2F2F7"))
        }
        .frame(maxWidth: .infinity,maxHeight:300, alignment: .leading)
        .padding(.horizontal, 25)
        .padding(.bottom, 40)
        
    }

    private var textView: some View{
        VStack(alignment: .leading, spacing: 8) {
            Text(registerVm.welcomeText)
                .font(.system(size: 37))
                .fontWeight(.bold)
                .foregroundStyle(colorScheme == .dark ? Color.hex("#F2F2F7") : Color.hex("#F2F2F7"))
            
            Text(registerVm.logInText)
                .font(.system(size: 30))
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? Color.hex("#F2F2F7") : Color.hex("#F2F2F7"))
        }
        .frame(maxWidth: .infinity,maxHeight:300, alignment: .leading)
        .padding(.horizontal, 25)
        .padding(.bottom, 40)
        .onAppear {
            registerVm.animateText()
        }
    }
    
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
}
