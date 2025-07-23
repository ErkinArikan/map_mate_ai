import SwiftUI

struct AboutPageView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        ZStack {
            // Background color based on color scheme
            if colorScheme == .light {
                Color.hex("F2F2F7").ignoresSafeArea(.all)
            } else {
                Color("NewBlack1").ignoresSafeArea(.all)
            }

            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 8) {
                    Text("About Map Mate-AI".addLocalizableString(str: languageManager.language))
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Your AI-powered map assistant.".addLocalizableString(str: languageManager.language))
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Description Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Map Mate-AI is an innovative AI-powered map application designed to enhance your exploration and decision-making experience.".addLocalizableString(str: languageManager.language))
                        .font(.body)
                        .multilineTextAlignment(.leading)

                    Text("Features:".addLocalizableString(str: languageManager.language))
                        .font(.headline)
                        .fontWeight(.bold)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Get personalized recommendations for places to visit based on your preferences.".addLocalizableString(str: languageManager.language))
                                .font(.body)
                        }

                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Discover nearby locations, such as restaurants, cafes, and attractions.".addLocalizableString(str: languageManager.language))
                                .font(.body)
                        }

                        HStack(alignment: .top) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("Easily locate 24/7 pharmacies and other essential services in your area.".addLocalizableString(str: languageManager.language))
                                .font(.body)
                        }
                    }
                }

                Spacer()

                VStack(spacing: 12) {
                    Text("Thank you for choosing Map Mate-AI to guide your adventures.".addLocalizableString(str: languageManager.language))
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)

                    Text("We hope to make your journeys smarter, easier, and more enjoyable.".addLocalizableString(str: languageManager.language))
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
 
    }
}


struct AboutPageView_Previews: PreviewProvider {
    static var previews: some View {
        AboutPageView()
            .environment(\.colorScheme, .light)

        AboutPageView()
            .environment(\.colorScheme, .dark)
    }
}
