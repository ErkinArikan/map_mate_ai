import SwiftUI

struct UserAgreementView: View {
    @State private var isToggleOn: Bool = false // Toggle durumu
    @State private var showNextScreen: Bool = false
    @EnvironmentObject var routeVm: RouteViewModel
    @EnvironmentObject var mapMateVm: MapMateViewModel

    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("User Agreement")
                            .font(.largeTitle)
                            .bold()
                            .padding(.bottom, 10)

                        Text("Last Updated: December 28, 2024")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        Text("Welcome to our app! Before using our services, please carefully read and agree to the following terms and conditions:")

                        Text("**1. Data Collection and Usage**")
                            .font(.headline)

                        Text("We collect and process the messages you send within the app. These messages are sent to OpenAI’s GPT services to provide you with accurate and personalized responses. By using this app, you agree to this data processing.")

                        Text("**2. Data Sharing**")
                            .font(.headline)

                        Text("Your messages and related information will be shared with OpenAI, which processes the data under its [privacy policy](https://openai.com/privacy/). We do not share your data with any other third parties.")

                        Text("**3. User Rights**")
                            .font(.headline)

                        Text("You have the right to request the deletion of your data or inquire about how your data is used. For any requests, please contact our support team.")

                        Text("**4. Limitation of Liability**")
                            .font(.headline)

                        Text("We are not responsible for the accuracy of the information provided by the AI model or any decisions made based on this information.")

                        Text("By tapping 'I Agree', you confirm that you have read and agree to these terms.")
                            .padding(.top, 20)
                    }
                    .padding()
                }

                Spacer()

                // Toggle sadece butonu aktif/deaktif eder
                Toggle(isOn: $isToggleOn) {
                    Text("I have read and agree to the User Agreement")
                        .font(.subheadline)
                }
                .padding()

                // "I Agree" Butonu
                Button(action: {
                    Task {
                        await mapMateVm.updateUserAgreementStatus(isAccepted: true)
                        showNextScreen = true
                    }
                }) {
                    Text("I Agree")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isToggleOn ? Color.blue : Color.gray)
                        .cornerRadius(8)
                }
                .disabled(!isToggleOn) // Toggle kapalıysa buton devre dışı
                .padding(.horizontal)

                .navigationDestination(isPresented: $showNextScreen) {
                    MapMateChatView(cameraPosition: $routeVm.cameraPosition)
                }
            }
        }
    }
}

#Preview {
    UserAgreementView()
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
}
