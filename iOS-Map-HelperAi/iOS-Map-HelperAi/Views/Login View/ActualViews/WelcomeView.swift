import SwiftUI
import SDWebImageSwiftUI



struct WelcomeView: View {
    
    @AppStorage("isOnTutorial") var isOnTutorial:Bool = true
    @Environment(\.colorScheme) private var colorScheme
    @State var isLoginPage: Bool = false
    @State var isSignUpPage: Bool = false
    @State private var welcomeText: String = ""
    @State private var logInText: String = ""
    @State private var isWelcomeVisible: Bool = false // Fade-in için durum
    @State private var isLogInVisible: Bool = false   // Fade-in için durum
    private let welcomeFullText = "Hello!"
    private let logInFullText = "Create your account and if you have one login"
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 20) {
                    Spacer()
                    
                    // Görsel
                    LottieView2(lottiFile: "welcomeJ")
                        .frame(width: 300, height: 300)
                             
//                              .scaledToFit()
//                              .frame(width: 500, height: 300)
//                              .padding(.bottom,20)
                    // Metinler
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(welcomeFullText.addLocalizableString(str: languageManager.language)) // Metin sabit
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(colorScheme == .dark ? Color.hex("#F2F2F7") : Color.hex("#F2F2F7"))
                                .opacity(isWelcomeVisible ? 1 : 0) // Fade-in
                                .animation(.easeInOut(duration: 1), value: isWelcomeVisible)
                            Spacer()
                        }
//                        Button {
//                            isOnTutorial = true
//                        } label: {
//                            Text("Tutorial Page")
//                                .foregroundStyle(.white)
//                        }
                        Text(logInFullText.addLocalizableString(str: languageManager.language)) // Metin sabit
                            .font(.title3)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(colorScheme == .dark ? Color.hex("#F2F2F7") : Color.hex("#F2F2F7"))
                            .opacity(isLogInVisible ? 1 : 0) // Fade-in
                            .animation(.easeInOut(duration: 1).delay(1), value: isLogInVisible)
                    }
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                    
                    Spacer()
                    Text("Get Started?".addLocalizableString(str: languageManager.language))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(colorScheme == .dark ? Color.hex("#F2F2F7") : Color.hex("#F2F2F7"))
                        .opacity(isLogInVisible ? 1 : 0) // Fade-in
                        .animation(.easeInOut(duration: 1).delay(1), value: isLogInVisible)
                    
                    // Butonlar
                    VStack(spacing: 10) {
                        Button(action: {
                            isLoginPage.toggle()
                        }) {
                            Text("Sign In".addLocalizableString(str: languageManager.language))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(colorScheme == .dark ? Color.hex("0C7B93") : Color.hex("0C7B93"))
                                .background(Color.hex("#F2F2F7"))
                                .cornerRadius(30)
                        }
                        
                        .shadow(radius: 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(Color("Mor"), lineWidth: 3) // Çerçeve rengi ve kalınlık
                        )
                        .padding(.horizontal, 40)
                        .navigationDestination(isPresented: $isLoginPage) {
                            LogInView()
                        }
                        .padding(.bottom, 4)
                        
                        Button(action: {
                            isSignUpPage.toggle()
                        }) {
                            Text("Sign Up".addLocalizableString(str: languageManager.language))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(colorScheme == .dark ? Color.hex("0C7B93") : Color.hex("0C7B93"))
                                .background(Color.hex("#F2F2F7"))
                                .cornerRadius(30)
                        }
                        .shadow(radius: 4)
                        .padding(.horizontal, 40)
                        .navigationDestination(isPresented: $isSignUpPage) {
                            RegisterView()
                        }
                    }
                    
                    Spacer()
                }
               
                .navigationBarHidden(true)
            }
            .background(colorScheme == .dark ? Color.hex("0C7B93").opacity(0.8) : Color.hex("0C7B93").opacity(0.8))
            .onAppear {
                animateTextWithFadeIn()
                
            }
           
        }
    }

    private func animateTextWithFadeIn() {
        // Animasyonu başlat
        isWelcomeVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // İlk metin tamamlansın
            isLogInVisible = true
        }
        
        // Harf harf metin oluşturma
        DispatchQueue.main.async {
            welcomeText = welcomeFullText
            logInText = logInFullText
        }
    }
}

#Preview {
    WelcomeView()
}
