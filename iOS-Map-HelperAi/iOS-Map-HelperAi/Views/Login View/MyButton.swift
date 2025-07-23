import SwiftUI
import Network

struct MyButton: View {
//    let title: String
//    let action: () -> Void
    @State var textFieldText: String = ""
    @FocusState private var isTapped: Bool // Focus state for TextField
    @State var isTaapppedd:Bool = false
    
    @State var showNotification = false
    @State var wasDisconnected = false
    let monitor = NWPathMonitor()
    let queue =  DispatchQueue(label:"NetworkMonitor")
    @State var isConnected = false
    @EnvironmentObject var loginVm:LoginViewModel
    @State var showToast:Bool = false
    var body: some View {
        ZStack{
//            VStack(spacing: 16) {
//                TextField("Tıkla", text: $textFieldText)
//                    .focused($isTapped) // Bind focus state
//                    .onChange(of: isTapped) { newValue in
//                        if newValue {
//                            isTaapppedd = newValue
//                            print("TextField focused: \(isTaapppedd)")
//                        } else {
//                            isTaapppedd = newValue
//                            print("Focus lost: \( isTaapppedd)")
//                        }
//                    }
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                
//                TextField("Tıkla", text: $textFieldText)
//                   
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    .padding(.horizontal)
//                
////                Button(action: action, label: {
////                    ZStack {
////                        RoundedRectangle(cornerRadius: 5)
////                            .foregroundStyle(.primary)
////                        Text(title)
////                            .foregroundStyle(.white)
////                    }
////                })
////                .frame(height: 50)
////                .padding(.horizontal)
//            }
//            
//            WifiNotiftow(isConnected: $isConnected)
//                .frame(maxHeight: .infinity,alignment: .top)
//                .offset(y: showNotification ? 0:-200)
//                .padding()
//                .onAppear(){
//                    startMonitoring()
//                }
            
            HStack{
                Image("NewestLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 45)
                    .padding(3)
                    .background(.thinMaterial, in: .rect(cornerRadius: 10))
                    .padding(.trailing,10)
                
               
                
                Text("Please fill in all fields.")
                    .font(.system(size: 18))
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
            }
            .bold()
            .frame(maxWidth: 290, maxHeight: 70)
            .background(.thinMaterial, in: .rect (cornerRadius: 20))
        }
       
    
    }
    
    func startMonitoring(){
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async{
                let currentStatus = path.status == .satisfied
                if self.isConnected != currentStatus {
                    if currentStatus {
                        if self.wasDisconnected{
                            self.showNotification = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation{
                                    self.showNotification = false
                                }
                            }
                        }
                    }else{
                        self.showNotification = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                            withAnimation{
                                self.showNotification = false
                            }
                        }
//                        self.wasDisconnected
                    }
                    self.isConnected = currentStatus
                }
                
                
            }
        }
        monitor.start(queue: queue)
    }
}

#Preview {
    MyButton()
        .environmentObject(LoginViewModel())
}
