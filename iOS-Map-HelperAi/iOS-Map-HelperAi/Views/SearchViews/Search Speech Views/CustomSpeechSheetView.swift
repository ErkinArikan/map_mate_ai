import Foundation
import SwiftUI

struct CustomSpeechSheetView: View {
    @State private var scalSize: CGFloat = 1 // İlk değer olarak 1 başlatıyoruz
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Binding var isRecording: Bool
    @Binding var searchText: String
    @Binding var color: Color
    @Environment(\.presentationMode) var presentationMode // Ekranı kapatmak için
    
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var searchViewModel:SearchViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text((isRecording == false) ? "" : ((speechRecognizer.transcript == "") ? "Speak Now" : speechRecognizer.transcript))
                    .frame(width: 300, alignment: .center)
                    .font(.system(size: 25))
                    .foregroundStyle(.black)
                
                Spacer()
                
                Button {
                    withAnimation(.easeInOut){
                        
                        uiStateVm.isSearchViewShow = false
                        searchViewModel.searchText = ""
                   
                        self.presentationMode.wrappedValue.dismiss()
                        
                        
                        uiStateVm.isShowNearByPlaces = false
                        uiStateVm.isSecondViewSearchView = false
               
                   
                    }
                    
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.systemGray6))
                            .frame(width: 35, height: 35)
                            
                            .shadow(color: .gray.opacity(0.9), radius: 1, x: 0, y: 1)
                        
                        
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 17)
                            .background(Color(UIColor.systemGray6))
                        
                            .foregroundStyle( Color("TextColor"))
                            .fontWeight(.medium)
                    }
                } //:Xmark Button
                .padding(.trailing)
                    
            }
            .padding(.bottom,30)
            
            ZStack {
                ForEach(1..<1000) { index in
                    addCircleView(delayValue: CGFloat(Double(index) + 0.50))
                }
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "mic.fill")
                            .foregroundStyle(Color.blue.opacity(0.6))
                            .font(.system(size: 20))
                    }
            }
            Spacer()
        }
        .padding(.top,25)
        .onAppear {
            speechRecognizer.transcribe()
            color = .red
            
            // Animasyonu sayfa açılır açılmaz başlat
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scalSize = 3
            }
        }
        .onDisappear {
            color = .gray
            speechRecognizer.stopTranscribing()
            searchText = speechRecognizer.transcript
        }
        .onChange(of: speechRecognizer.transcript) { oldValue,newTranscript in
            // Kullanıcı konuşmasını bitirdikten sonra 2 saniye bekleyip ekranı kapat
            if !newTranscript.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.isRecording = false
                    self.presentationMode.wrappedValue.dismiss() // Ekranı kapat
                }
            }
        }
    }
    
    @ViewBuilder
    func addCircleView(delayValue: CGFloat) -> some View {
        Circle()
            .fill(Color.blue.opacity(scalSize == 3 ? 0.0 : 1.3))
            .frame(width: 30, height: 30)
            .scaleEffect(scalSize)
            .animation(.easeInOut(duration: 1.5).delay(delayValue).repeatForever(autoreverses: true), value: scalSize)
    }
}

#Preview {
    CustomSpeechSheetView(isRecording: .constant(true), searchText: .constant(""), color: .constant(.gray))
}
