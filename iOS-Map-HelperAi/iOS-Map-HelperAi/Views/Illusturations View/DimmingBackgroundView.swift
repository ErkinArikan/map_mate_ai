//import SwiftUI
//
//struct DimmingBackgroundView: View {
//    @State private var isShowingNotification = false
//    
//    var body: some View {
//        ZStack {
//            // Asıl içerik
//            VStack {
//                Text("Main Page")
//                    .font(.largeTitle)
//                    .padding()
//                
//                Button("Show Notification") {
//                    withAnimation {
//                        isShowingNotification = true
//                    }
//                }
//                .padding()
//            }
//            
//            // Arka plan karartma ve bildirim
//            if isShowingNotification {
//                Color.black.opacity(0.5) // Karartma efekti
//                    .ignoresSafeArea()
//                    .transition(.opacity)
//                
//                VStack {
//                    ProgressView("Loading...") // Bildirim içeriği
//                        .padding()
//                        .background(Color.white)
//                        .cornerRadius(10)
//                        .shadow(radius: 10)
//                    
//                    Button("Close") {
//                        withAnimation {
//                            isShowingNotification = false
//                        }
//                    }
//                    .padding(.top)
//                }
//                .frame(maxWidth: 300)
//                .padding()
//                .transition(.scale)
//            }
//        }
//        .animation(.easeInOut, value: isShowingNotification)
//    }
//}
//
//#Preview {
//    DimmingBackgroundView()
//}
