//
//  CustomSearchTextField.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 17.10.2024.
//

import SwiftUI




struct CustomSearchTextField: View {
    @EnvironmentObject var locationManager: LocationManagerDummy
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    
    @EnvironmentObject var routeVm:RouteViewModel
    @State var fname:String = ""
    @State var lname:String = ""
    @Binding var searchResults: [SearchResultModel]
    @Binding var getDirections:Bool
    @Environment(\.colorScheme) private var colorScheme
    var body: some View {
        VStack(spacing: 10) {
            
            InfoField2(title: "Write something", text: $searchViewModel.searchText)
            
            InfoField(searchResults: $searchResults, getDirections: $getDirections, title: "Search Place", text: $searchViewModel.searchText)
           
        }
        .padding()
    }
}

#Preview {
    CustomSearchTextField(searchResults: .constant(.init()), getDirections: .constant(false))
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
}


struct InfoField:View {
    @EnvironmentObject var locationManager: LocationManagerDummy
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @EnvironmentObject var languageManager:LanguageManager
    @EnvironmentObject var iosVm:RouteViewModel
    @Binding var searchResults: [SearchResultModel]
    @Binding var getDirections:Bool
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @Environment(\.colorScheme) private var colorScheme
    let title:String
    @Binding var text:String
    @FocusState var isTyping:Bool
    @State private var moveUp = false
    
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State var isRecording:Bool = false
    @State var color:Color = .gray
    var body: some View {
        ZStack(alignment: .leading){
            TextField("", text: $text,axis: .vertical)
                .padding(.vertical)
                .padding(.horizontal, 24)
                .focused($isTyping)  // Odaklanma durumunu izliyoruz
                .background(colorScheme == .light ? Color("BabyBlue"):Color(.systemGray6))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isTyping ? Color.blue : Color.gray, lineWidth: 2) // isTyping durumuna göre renk değişimi
                )
                .clipShape(Capsule(style: .continuous))
                .shadow(color: Color("ShadowColor").opacity(isDarkMode ?  0.2:0.9), radius: 1, x: 0, y: 1)
                .keyboardType(.asciiCapable)
                .disableAutocorrection(true)

                
//            Color.hex("F2F2F7")Color.hex("0C7B93")
                
            HStack {
      
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 10)
                    .background(Color(.clear).opacity(isTyping || !text.isEmpty ? 1 : 0))
                   
                    .foregroundStyle(isTyping ? Color.hex("0C7B93") : colorScheme == .light ?  Color.hex("0C7B93"): Color.hex("F2F2F7"))
                
                    .offset(y: isTyping || !text.isEmpty ? -25 : 0)
                    .font(.system(size: isTyping || !text.isEmpty ? 12 : 16))
                    .onTapGesture {
                        isTyping.toggle()
                    }
                
               
                Text(title.addLocalizableString(str: languageManager.language))
                  
                    .background(Color(.clear).opacity(isTyping || !text.isEmpty ? 1 : 0))
                    .cornerRadius(20)
                    .foregroundStyle(isTyping ? Color.hex("0C7B93") : colorScheme == .light ?  Color.hex("0C7B93"): Color.hex("F2F2F7"))
//                    .foregroundColor(colorScheme == .dark ? Color.hex("0C7B93").opacity(0.8): Color.hex("0C7B93"))
                    .offset(y: isTyping || !text.isEmpty ? -25 : 0)
                    .font(.system(size: isTyping || !text.isEmpty ? 12 : 16))
                    .onTapGesture {
                        isTyping.toggle()
                    }

                Spacer()

                if !isTyping && text.isEmpty { // Eğer yazma durumu yoksa ve metin boşsa
                    HStack {

                        Button {
                            withAnimation {
                                speechRecognizer.transcribe()
                                isRecording.toggle()
                            }
                        } label: {
                            Image(systemName: "mic.fill")
                                .foregroundStyle(isTyping ? .blue : colorScheme == .light ?  Color.hex("0C7B93"): Color.hex("F2F2F7"))
                                .padding(.trailing)
                        }
                    }
                } else if !text.isEmpty { // Eğer metin doluysa
                    Button {
                        withAnimation {
                            searchViewModel.searchText = ""
                            isTyping.toggle()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(isTyping ? .blue : colorScheme == .light ?  Color.hex("0C7B93"): Color.hex("F2F2F7"))
                            .padding(.trailing)
                    }
                }
            }
            .animation(.interactiveSpring, value: isTyping)

           
            .onAppear {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: true)) {
                    moveUp.toggle() // Animasyonu sonsuz hale getiriyoruz
                }
            }
            
            
            
        }
        
        .animation(.spring(duration: 0.2), value: isTyping)
        .sheet(isPresented: $isRecording){
            CustomSpeechSheetView(isRecording: self.$isRecording, searchText: $searchViewModel.searchText, color: self.$color)
                .presentationDetents([.height(200), .fraction(0.5)])
                    .presentationDragIndicator(.visible)
            }
    }
        
}


struct InfoField2: View {
    @EnvironmentObject var searchViewModel: SearchViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) private var colorScheme
    let title: String
    @Binding var text: String
    @FocusState var isTyping: Bool
    @State private var moveUp = false

    var body: some View {
        ZStack(alignment: .leading) {
            // TextField
            TextField("", text: $text, axis: .vertical)
                .padding(.vertical,11)
                .padding(.horizontal, 24)
                .focused($isTyping) // Odaklanma durumunu izliyoruz
                .background(colorScheme == .light ? Color("BabyBlue"):Color(.systemGray6))
                .clipShape(Capsule(style: .continuous))
                .shadow(color: Color("ShadowColor").opacity(isDarkMode ? 0.2 : 0.9), radius: 1, x: 0, y: 1)
                .keyboardType(.asciiCapable)
                .disableAutocorrection(true)

            // Başlık (Title)
            if !isTyping && text.isEmpty { // Eğer yazma durumu yoksa ve metin boşsa göster
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, 10)
                        .foregroundStyle(isTyping ? Color.hex("0C7B93") : colorScheme == .light ?  Color.hex("0C7B93"): Color.hex("F2F2F7"))

                    Text(title)
                        .foregroundStyle(isTyping ? Color.hex("0C7B93") : colorScheme == .light ?  Color.hex("0C7B93"): Color.hex("F2F2F7"))
                        .onTapGesture {
                            isTyping.toggle() // Odaklanmayı etkinleştir
                        }

                    Spacer()
                }
//                .padding(.horizontal, 24)
            }

            // Sağdaki X butonu
            if !text.isEmpty { // Eğer metin doluysa
                HStack {
                    Spacer()
                    Button {
                        withAnimation {
                            searchViewModel.searchText = ""
                            isTyping.toggle()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(isTyping ? .blue : colorScheme == .light ?  Color.hex("0C7B93"): Color.hex("F2F2F7"))
                            .padding(.trailing)
                    }
                }
            }
        }
        .frame(maxWidth: 280)
        .animation(.spring(duration: 0.2), value: isTyping)
    }
}
