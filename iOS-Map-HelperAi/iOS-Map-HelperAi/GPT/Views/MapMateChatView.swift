//
//  MapMateChatView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 21.11.2024.
//

import SwiftUI
import AVKit
import MapKit
import FirebaseAuth

struct MapMateChatView: View {
    //MARK: -  F
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var mapMateVm: MapMateViewModel
    @FocusState var isTextFieldFocused: Bool
    @State private var showToast = false
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @EnvironmentObject var locationManager: LocationManagerDummy
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Binding var cameraPosition: MapCameraPosition
//    @Binding var searchResults: [SearchResultModel]
    @State private var shouldShowScrollToBottomButton = false
    @State private var showingPopover = false
    @AppStorage("isUserAgreementAccepted") var isUserAgreementAccepted:Bool = false
    @EnvironmentObject var languageManager:LanguageManager
    @State var openingCount:Int = 1
    
    @State private var showDeleteConfirmation = false

    @State private var lastMessageID: UUID? // En son mesajın ID'sini saklar
    @State private var showInfoPopover:Bool = false
    
    var body: some View {

        NavigationStack {
            ZStack {
                
                
                // Kullanıcı anlaşması kabul edilmediyse UserAgreementView göster
                if !(mapMateVm.currentUser?.userAgreement ?? false) {
                    UserAgreementView()
//                        .zIndex(2) // Üstte görünmesini sağlamak için zIndex ekleyin
                }else{
                    VStack {
                        chatListView
                        Divider()
                        bottomView()
                    }
                    .background{
                        colorScheme == .light ?  Color.hex("F2F2F7").ignoresSafeArea(.all):Color("NewBlack1").ignoresSafeArea(.all)
                    }
                  
                
                    if showToast {
                        VStack {
                            Text("You have used all 5 prompts for today. Your limit will reset in 24 hours.".addLocalizableString(str: languageManager.language))
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(8)
                                .padding(.top, 50)
                                .transition(.move(edge: .top).combined(with: .opacity))
                                .zIndex(1)
                                .frame(width: 240)
                                
                            Spacer()
                        }
                        .animation(.spring(), value: showToast)
                    }
                    
                    
                    
                }
                // Özel onay diyaloğu
                if showDeleteConfirmation {
                    ZStack {
                        Color.black.opacity(0.4) // Arkaya koyu bir blur efekti ekle
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            Text("Are you sure?")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("This will delete all messages permanently.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            HStack {
                                Button("Cancel") {
                                    showDeleteConfirmation = false
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.5))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                
                                Button("Delete") {
                                    Task {
                                        await mapMateVm.clearMessagesInFirestore()
                                        showDeleteConfirmation = false
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .cornerRadius(12)
                        .shadow(radius: 10)
                        .frame(width: 300)
                    }
                    .transition(.opacity)
                    .animation(.easeInOut, value: showDeleteConfirmation)
                }

               
                
            }
            .background{
                colorScheme == .light ?  Color.hex("F2F2F7").ignoresSafeArea(.all):Color("NewBlack1").ignoresSafeArea(.all)
            }
            .onAppear {
                mapMateVm.checkPormptLimit()
//                Task{
//                   await mapMateVm.fetchUser()
//                    await  mapMateVm.fetchMessagesForCurrentUser()
//                }
               
             
                print("user prompt limit = \(String(describing: mapMateVm.currentUser?.userPromptLimit) )")
            }
            /// Aklımızı karıştıran kısım bu.
            /// burada bulunan binding searchResults aslında routeVm.searchResult onun binding kısmına onu atıyoruz.Yani
//            .onChange(of: searchViewModel.searchResults, { _, newValue in
////                searchResults = newValue
//                routeVm.searchResults = newValue
////                print("searchResults = \(searchResults)")
//            })
            .onChange(of: mapMateVm.promptLimitReached) { old,newValue in
                if newValue {
                    showToastMessage()
                }
            }
            .onChange(of: searchViewModel.cameraPosition, { _, newValue in
                cameraPosition = newValue
            })
            .navigationTitle("AI-Powered Chat".addLocalizableString(str: languageManager.language))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar{
                ToolbarItem(placement: .topBarTrailing) {
                    HStack{ /*mapMateVm.currentUser?.userPromptLimit ?? 0*/
                        
                        //MARK: - PROMPT LIMIT NUMBER
                        Button {
                            withAnimation(.easeInOut){
                                showingPopover = true
                                hapticImpact.impactOccurred()
                            }
                         
                        
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8):Color(.systemGray6))
                                    .frame(width: 35, height: 35)
                                    .padding(.leading)
                                    .shadow(color: Color("ShadowColor").opacity(isDarkMode ?  0.2:0.9), radius: 1, x: 0, y: 1)
                                
                                
                                Text("\(mapMateVm.currentUser?.userPromptLimit ?? 0)")
                                    .frame(width: 17, height: 17)
                                    .padding(.leading)
                                    .foregroundStyle( Color.hex("F2F2F7"))
                                    .fontWeight(.medium)
                                    
                                    
                            }
                           

                        }
                        .popover(isPresented: $showingPopover,arrowEdge: .bottom) {
                            VStack(alignment:.leading,spacing:20){
                                Text("This number is your prompt limit.\n Every 24 hours, you have 3 prompts.")
                                    .font(.headline)
                                    .padding()
                                    .presentationCompactAdaptation(.popover)
                            }
                           
                        }
                        
                        
                        //MARK: - XMARK BUTTON
                        Button {
                            withAnimation(.easeInOut){
                                uiStateVm.selectedDetent = .height(310)
                                uiStateVm.isSearchViewShow = false
                                searchViewModel.searchText = ""
                               
                         
                                searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
                                uiStateVm.activeSheet = nil
                                uiStateVm.isShowNearByPlaces = false
                                uiStateVm.isSecondViewSearchView = false
                                hapticImpact.impactOccurred()
                            }
                         
                        
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8):Color(.systemGray6))
                                    .frame(width: 35, height: 35)
                                    .padding(.leading)
                                    .shadow(color: Color("ShadowColor").opacity(isDarkMode ?  0.2:0.9), radius: 1, x: 0, y: 1)
                                
                                
                                Image(systemName: "xmark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 17, height: 17)
                                   
                                    .padding(.leading)
                                    .foregroundStyle( Color.hex("F2F2F7"))
                                    .fontWeight(.medium)
                                    
                            }
                           

                        }
                        
                        
                    }

              
                    
                }
                
                
                ToolbarItem(placement: .topBarLeading) {
                    //MARK: - TRASH BUTTON
                    Button{
                        withAnimation{
                            showDeleteConfirmation = true
                        }
//                        Task{
//                            await  mapMateVm.clearMessagesInFirestore()
//                        }
//                       
                    } label:{
                        ZStack{
                            Circle()
                                .fill(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8):Color(.systemGray6))
                                .frame(width: 35, height: 35)
                                .padding(.leading)
                                .shadow(color: Color("ShadowColor").opacity(isDarkMode ?  0.2:0.9), radius: 1, x: 0, y: 1)
                            
                            Image(systemName: "trash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .padding(.leading)
                                .foregroundStyle( Color.hex("F2F2F7"))
                                .fontWeight(.medium)
                        }
                      
                    }
                }
              
            }
            .onAppear(){
                if mapMateVm.openingCount == 1{
                    mapMateVm.addWelcomeMessage()
                }
                mapMateVm.openingCount += 1
               print("user agreement = \(mapMateVm.currentUser?.userAgreement)")
            }
            // MARK: - Scroll Position Listener
            .onChange(of: mapMateVm.messages.count) { oldValue, newValue in
                shouldShowScrollToBottomButton = false // Yeni mesaj gelince butonu gizle
            }
            .onAppear {
                shouldShowScrollToBottomButton = false // İlk yüklemede gizle
            }
            .onDisappear {
                shouldShowScrollToBottomButton = true // Scroll yapınca göster
            }
            
            
            
        }
        .ignoresSafeArea(.keyboard)
        .ignoresSafeArea()
    }
    
    
    
    
    // MARK: - CHAT VIEW
    @ViewBuilder
    var chatListView: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(mapMateVm.messages) { message in
                            VStack(alignment: .leading, spacing: 8) {
                                // Mesaj Görünümü
                                MessageRowView(message: message) { _ in }

                                // Place Name ve Adres Butonları
                                let places = extractPlaceNamesAndAddresses(from: message.responseText)
                                if !places.isEmpty {
                                   
                                    VStack(spacing: 8) {
                                        ForEach(places, id: \.address) { place in
                                            Button(action: {
                                               
                                                withAnimation {
                                                    print("Debug: \(place.placeName) (\(place.address)) butonuna tıklandı.")
                                                        tapAddress(placeName: place.placeName, placeSubTitle: place.address)
                                                        hapticImpact.impactOccurred()
                                                        uiStateVm.showDestinationDetailsView = true
                                                    uiStateVm.showAnnotation = true
//                                                    searchViewModel.searchForLocalPlaces(for: place.placeName)
                                                    
                                                    
                                                    uiStateVm.activeSheet = .details
                                                   
                                                 
                                                    

                                                    uiStateVm.selectedDetent = .height(300)
                                                    }
                                               
                                            }) {
                                                HStack {
                                                    VStack(alignment: .leading) {
                                                        Text(place.placeName) // Place Name
                                                            .font(.headline)
                                                    }
                                                    Spacer()
                                                    ZStack {
                                                        Circle()
                                                            .frame(width: 50, height: 50)
                                                            .foregroundStyle(.red.opacity(0.25))
                                                            .shadow(color: .red.opacity(0.3), radius: 4, x: 2, y: 2)
                                                        
                                                        Circle()
                                                            .frame(width: 30, height: 30)
                                                            .foregroundStyle(.white)
                                                            .shadow(color: .gray.opacity(0.3), radius: 2, x: 1, y: 1)
                                                        
                                                        Image(systemName: "paperplane.fill")
                                                            .resizable()
                                                            .frame(width: 17, height: 17)
                                                            .foregroundStyle(.red)
                                                    }
                                                }
                                                .frame(maxWidth: 250)
                                                .padding()
                                                .background(Color.blue)
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                    .padding(.top, 8)
                                }

                            }
                            
                        }
                    }
                    .onTapGesture {
                        isTextFieldFocused = false
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        if let lastMessageID = mapMateVm.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastMessageID, anchor: .bottom)
                            }
                        }
                    }
                }
                .onChange(of: mapMateVm.messages.last?.responseText) { _ in
                    scrollToBottom(proxy: proxy)
                }
             
                
            }
            .background{
                colorScheme == .light ?  Color.hex("F2F2F7").ignoresSafeArea(.all):Color("NewBlack1").ignoresSafeArea(.all)
            }
            
            
            
            
        }
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
    }


    // MARK: - BOTTOM VIEW
    func bottomView() -> some View {
        HStack(alignment: .top, spacing: 8) {
            if let photoURL = Auth.auth().currentUser?.photoURL {
                // Profil fotoğrafı mevcutsa yüklenir
                AsyncImage(url: photoURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Yüklenme aşamasında bir gösterge
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 35, height: 45)
                            .clipShape(Circle())
//                            .onTapGesture {
//                                showingPopover = true
//                            }
//                            .popover(isPresented: $showingPopover) {
//                                VStack{
//                                    Text("You have \(mapMateVm.currentUser?.userPromptLimit ?? 0) prompt left!")
//                                        .font(.headline)
//                                        .padding()
//                                        .presentationCompactAdaptation(.popover)
//                                }
//                                    }
                    case .failure:
                        Image(systemName: "person.circle.fill") // Varsayılan bir görsel
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 45)
                            .foregroundColor(.gray)
//                            .onTapGesture {
//                                showingPopover = true
//                            }
//                            .popover(isPresented: $showingPopover) {
//                                VStack{
//                                    Text("You have \(mapMateVm.currentUser?.userPromptLimit ?? 0) prompt left!")
//                                        .font(.headline)
//                                        .padding()
//                                        .presentationCompactAdaptation(.popover)
//                                }
//                                
//                                    }
                    @unknown default:
                        Image(systemName: "exclamationmark.triangle.fill")
                    }
                }
            } else {
                // Profil fotoğrafı yoksa varsayılan bir görsel göster
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 45)
                    .foregroundColor(.gray)
//                    .onTapGesture {
//                        showingPopover = true
//                    }
//                    .popover(isPresented: $showingPopover) {
//                        VStack{
//                            Text("You have \(mapMateVm.currentUser?.userPromptLimit ?? 0) prompt left!")
//                                .font(.headline)
//                                .padding()
//                                .presentationCompactAdaptation(.popover)
//                        }
//                            }
            }
            
            
            
            /// Text Field
            InfoField2(title: "Send Message", text: $mapMateVm.inputMessage)
                .autocorrectionDisabled()
                .focused($isTextFieldFocused)
                .disabled(mapMateVm.isInteracting || mapMateVm.promptLimitReached)
                .onTapGesture {
                    mapMateVm.checkPormptLimit()
                    if mapMateVm.promptLimitReached {
                        showToastMessage()
                        
                    }
                }
//                .toolbar {
//                    ToolbarItemGroup(placement: .keyboard) {
//                        Spacer()
//                        Button("Done") { hideKeyboard() }
//
//                    }
//                }
            
      
            if mapMateVm.isInteracting {
                Button {
                    mapMateVm.cancelStreamingResponse()
                } label: {
                    Image(systemName: "stop.circle.fill")
                        .font(.system(size: 30))
                        .symbolRenderingMode(.multicolor)
                        .foregroundColor(.red)
                }
            } else {
                Button {
                    Task { @MainActor in
                        isTextFieldFocused = false
                        await mapMateVm.sendTapped()
                    }
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .rotationEffect(.degrees(45))
                        .font(.system(size: 40))
                        .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8): Color.hex("F2F2F7"))
                }
                .disabled(mapMateVm.inputMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        
        .padding(.horizontal, 16)
        .padding(.top, 1)
        .scrollIndicators(.hidden)
        .background{
            colorScheme == .light ?  Color.hex("F2F2F7").ignoresSafeArea(.all):Color("NewBlack1").ignoresSafeArea(.all)
        }
    }
    
    
    
    
    //MARK: - extractPlaceNamesAndAddresses
    private func extractPlaceNamesAndAddresses(from text: String?) -> [(placeName: String, address: String)] {
        guard let text = text else { return [] }

        // ✅ Yeni düzenli ifade: **[Place Name](address: Street, City)**
        let pattern = #"(?<=\*\*\[)(.*?)]\(address:\s*(.*?)\)"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }

        let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))

        return matches.compactMap { match in
            guard let placeNameRange = Range(match.range(at: 1), in: text),
                  let addressRange = Range(match.range(at: 2), in: text) else { return nil }

            let placeName = String(text[placeNameRange]).trimmingCharacters(in: .whitespacesAndNewlines)
            let address = String(text[addressRange]).trimmingCharacters(in: .whitespacesAndNewlines)

            return (placeName: placeName, address: address)
        }
    }



    
    func tapAddress(placeName: String, placeSubTitle: String) {
        let cleanedPlaceName = placeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedPlaceSubTitle = placeSubTitle.trimmingCharacters(in: .whitespacesAndNewlines)

        print("Debug: tapAddress çağrıldı. Place Name: \(cleanedPlaceName), Place SubTitle: \(cleanedPlaceSubTitle)")
        
        let recentSearchCompletion = SearchCompletionsModel(title: cleanedPlaceName, subTitle: cleanedPlaceSubTitle, location: "")
        searchViewModel.didTapOnSearchCompletionWithDistrict(recentSearchCompletion)
    }

   
    
    private func openInMaps(address: String) {
        let formattedAddress = address.replacingOccurrences(of: " ", with: "+")
        if let url = URL(string: "http://maps.apple.com/?q=\(formattedAddress)") {
            UIApplication.shared.open(url)
        }
    }
    
    private func showToastMessage() {
        withAnimation {
            showToast = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showToast = false
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        guard let id = mapMateVm.messages.last?.id else { return }
        proxy.scrollTo(id, anchor: .bottomTrailing)
    }
}

// Önizleme
#Preview {
    NavigationStack {
        MapMateChatView(
            cameraPosition: .constant(.automatic)
        )
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(UIStateViewModel())
        .environmentObject(MapMateViewModel(api: ChatGPTAPI(apiKey: Constants.API_KEY, locationManager: LocationManagerDummy())))
        
    }
}


