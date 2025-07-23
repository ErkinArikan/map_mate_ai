import SwiftUI

struct FeedbackPageView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var feedbackText: String = ""
    @State private var isSubmitted: Bool = false

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
//                    Text("Feedback")
//                        .font(.largeTitle)
//                        .fontWeight(.bold)

                    Text("We value your feedback to improve Map Mate-AI.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Feedback Input Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Feedback:")
                        .font(.headline)
                        .fontWeight(.bold)

                    TextEditor(text: $feedbackText)
                        .frame(height: 150)
                        .padding()
                       
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .foregroundColor(.primary)
                    
                }

                Spacer()

                // Submit Button
                Button(action: {
                    isSubmitted = true
                }) {
                    Text("Submit Feedback")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .alert(isPresented: $isSubmitted) {
                    Alert(title: Text("Thank You!"),
                          message: Text("Your feedback has been submitted successfully."),
                          dismissButton: .default(Text("OK")))
                }
            }
            .padding()
        }
        .navigationTitle("Feedback")
    }
}



struct FeedbackPageView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackPageView()
            .environment(\.colorScheme, .light)

        FeedbackPageView()
            .environment(\.colorScheme, .dark)
    }
}
