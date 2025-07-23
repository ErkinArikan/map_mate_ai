import SwiftUI

struct LanguageView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            // Background color based on color scheme
            if colorScheme == .light {
                Color.hex("F2F2F7").ignoresSafeArea(.all)
            } else {
                Color("NewBlack1").ignoresSafeArea(.all)
            }

            VStack(spacing: 20) {
                // Title
                Text("Select Your Language".addLocalizableString(str: languageManager.language))
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Text("Please choose your preferred language for the app.".addLocalizableString(str: languageManager.language))
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Language List
                List {
                    Button(action: {
                        languageManager.language = "en"
                    }) {
                        HStack {
                            Text("English")
                            Spacer()
                            if languageManager.language == "en" {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .foregroundColor(.primary)
                    .listRowBackground(Color.clear)

                    Button(action: {
                        languageManager.language = "tr"
                    }) {
                        HStack {
                            Text("Türkçe")
                            Spacer()
                            if languageManager.language == "tr" {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    .foregroundColor(.primary)
                    .listRowBackground(Color.clear)
                }
                .listStyle(PlainListStyle())
                .listRowBackground(Color.clear)
                Spacer()
            }
            .padding()
        }
        
    }
}



struct LanguageView_Previews: PreviewProvider {
    static var previews: some View {
        LanguageView()
            .environmentObject(LanguageManager())
            .environment(\.colorScheme, .light)

        LanguageView()
            .environmentObject(LanguageManager())
            .environment(\.colorScheme, .dark)
    }
}
