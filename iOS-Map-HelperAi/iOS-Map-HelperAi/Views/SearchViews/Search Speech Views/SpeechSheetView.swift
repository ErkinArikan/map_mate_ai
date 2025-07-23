//
//  SpeechSheetView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 8.11.2024.
//

import SwiftUI


struct SpeechSheetView: View {
    @StateObject var speechRecognizer = SpeechRecognizer()
    @Binding var isRecording:Bool
    @Binding var searchText:String
    @Binding var color:Color
    var body: some View {
        VStack{
            Spacer()
            Text("\((isRecording == false) ? "":((speechRecognizer.transcript == "") ? "Speak Now": speechRecognizer.transcript))")
                .frame(width: 300, height: 200, alignment: .center)
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .scaleEffect(2)
            Spacer()
        }
        .onAppear{
            speechRecognizer.transcribe()
            color = .red
        }
        .onDisappear{
            color = .gray
            speechRecognizer.stopTranscribing()
            searchText = speechRecognizer.transcript
        }
    }
}

//#Preview {
//    SpeechSheetView(isRecording: .constant(true), searchText: .constant(""), color: .constant(.gray))
//}
