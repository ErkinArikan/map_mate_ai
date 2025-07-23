import SwiftUI

struct ContactPageView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var languageManager: LanguageManager
    var body: some View {
            ZStack {
                // Background color based on color scheme
                if colorScheme == .light {
                    Color.hex("F2F2F7").ignoresSafeArea(.all)
                } else {
                    Color("NewBlack1").ignoresSafeArea(.all)
                }

                VStack(alignment: .leading, spacing: 16) {
                 

                    Text("We are here to assist you. Feel free to reach out to us through any of the methods below.".addLocalizableString(str: languageManager.language))
                        .font(.body)
                        .foregroundColor(.secondary)

                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.blue)
                            Text("erkinarikan@gmail.com")
                                .foregroundColor(.primary)
                        }

                        Button {
                            if let url = URL(string: "tel://+905074334675"), UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "phone.fill")
                                    .foregroundColor(.green)
                                Text("+90 5074334675")
                                    .foregroundColor(.primary)
                            }
                        }

                       

                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundColor(.red)
                            Text("Ankara, Turkey")
                                .foregroundColor(.primary)
                        }

                        HStack {
                            Image(systemName: "l.circle.fill")
                                .foregroundColor(.blue)
                            Button(action: {
                                if let url = URL(string: "https://www.linkedin.com/in/erkinar%C4%B1kan/") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("Visit my LinkedIn".addLocalizableString(str: languageManager.language))
                                    .foregroundColor(.primary)
                            }
                        }
                        HStack {
                            Image(systemName: "pc")
                                .foregroundColor(.purple)
                            Button(action: {
                                if let url = URL(string: "https://github.com/ErkinArikan") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                Text("Visit my Github Profile".addLocalizableString(str: languageManager.language))
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        
                        
                    }
                    .padding(.top, 10)

                    Spacer()


                }
                .padding()
            }
            .navigationTitle("Contact".addLocalizableString(str: languageManager.language))
        }
}



struct ContactPageView_Previews: PreviewProvider {
    static var previews: some View {
        ContactPageView()
            .environment(\.colorScheme, .light)

        ContactPageView()
            .environment(\.colorScheme, .dark)
    }
}
