import SwiftUI
import MapKit



struct PharmacySearchView: View {
    @State private var selectedCity: String = "Ankara" // Varsayılan şehir
//    @State private var selectedDistrict: String = "Çankaya" // Varsayılan şehir
    @State private var pharmacyList: [Pharmacy] = []
    @State private var filteredPharmacies: [Pharmacy] = []
    @State private var selectedDistrict: String = "" // İlçe filtreleme için
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    
    private let cities: [String] = [
        "Adana", "Adıyaman", "Afyonkarahisar", "Ağrı", "Aksaray", "Amasya", "Ankara", "Antalya", "Ardahan", "Artvin",
        "Aydın", "Balıkesir", "Bartın", "Batman", "Bayburt", "Bilecik", "Bingöl", "Bitlis", "Bolu", "Burdur",
        "Bursa", "Çanakkale", "Çankırı", "Çorum", "Denizli", "Diyarbakır", "Düzce", "Edirne", "Elazığ", "Erzincan",
        "Erzurum", "Eskişehir", "Gaziantep", "Giresun", "Gümüşhane", "Hakkari", "Hatay", "Iğdır", "Isparta", "İstanbul",
        "İzmir", "Kahramanmaraş", "Karabük", "Karaman", "Kars", "Kastamonu", "Kayseri", "Kırıkkale", "Kırklareli", "Kırşehir",
        "Kilis", "Kocaeli", "Konya", "Kütahya", "Malatya", "Manisa", "Mardin", "Mersin", "Muğla", "Muş", "Nevşehir",
        "Niğde", "Ordu", "Osmaniye", "Rize", "Sakarya", "Samsun", "Şanlıurfa", "Siirt", "Sinop", "Şırnak", "Sivas",
        "Tekirdağ", "Tokat", "Trabzon", "Tunceli", "Uşak", "Van", "Yalova", "Yozgat", "Zonguldak"
    ]
 
    private let ankaraIlceleri: [String] = [
        "Akyurt", "Altındağ", "Ayaş", "Bala", "Beypazarı", "Çamlıdere", "Çankaya", "Çubuk", "Elmadağ", "Etimesgut",
        "Evren", "Gölbaşı", "Güdül", "Haymana", "Kalecik", "Kahramankazan", "Keçiören", "Kızılcahamam", "Mamak",
        "Nallıhan", "Polatlı", "Pursaklar", "Sincan", "Şereflikoçhisar", "Yenimahalle"
    ]

    private let apiManager = PharmacyApiManager()
    
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @Environment(\.colorScheme) private var colorScheme
    @EnvironmentObject var sideMenuVm:SideMenuViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @EnvironmentObject var languageManager:LanguageManager
    
    //MARK: - BODY
    var body: some View {
        
        NavigationStack {
            
            
               
                VStack{
                    // Şehir Seçimi
                    
                        HStack{
                            Text("City: ".addLocalizableString(str: languageManager.language))
                                .padding(2)
                            
                            Picker("Select City".addLocalizableString(str: languageManager.language), selection: $selectedCity) {
                                ForEach(cities, id: \.self) { city in
                                    Text(city).tag(city)
                                      
                                        
                                }
                            }
                            .tint(colorScheme == .light ?  Color.hex("0C7B93"): Color.hex("F2F2F7"))
                            .padding([.bottom,.top])
                            .pickerStyle(MenuPickerStyle()) // Drop Down görünüm
                         
                            //MARK: - LIST
                            if !pharmacyList.isEmpty && selectedCity == "Ankara"{
                                HStack {
                                    Text("District:")
                                        .padding(2)
                                    
                                    Picker("District", selection: $selectedDistrict) {
                                        Text("All Districts").tag("") // Tüm ilçeler için seçenek
                                        ForEach(ankaraIlceleri, id: \.self) { district in
                                            Text(district).tag(district)
                                        }
                                    }
                                    .pickerStyle(MenuPickerStyle())
                                    .onChange(of: selectedDistrict) { _ in
                                        filterByDistrict()
                                    }
                                    .tint(colorScheme == .light ?  Color.hex("0C7B93"): Color.hex("F2F2F7"))
                                    
//                                    Spacer()
                                }
                                
                            }
                            
                        }
                    
                   
                   
                    
                    
                    // Ara Butonu
                    Button(action: fetchPharmacies) {
                        Text("Search".addLocalizableString(str: languageManager.language))
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8):  Color(.systemGray6))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    // Yükleniyor Göstergesi
                    if isLoading {
                        ProgressView("Loading...".addLocalizableString(str: languageManager.language))
                            .padding()
                    }
                    
                    // Hata Mesajı
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    if !pharmacyList.isEmpty && selectedCity != "Ankara" {
                        TextField("İlçe ile filtrele".addLocalizableString(str: languageManager.language), text: $selectedDistrict, onCommit: filterByDistrict)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    // İlçe Seçimi ve Filtreleme
                    if !pharmacyList.isEmpty {
                      
                        // Eczane Listesi
                        ScrollView {
                            ForEach(filteredPharmacies, id: \.name) { pharmacy in
                                PharmacyRow2(pharmacy: pharmacy)
                                    
                            }
                        }
                        .scrollDismissesKeyboard(.immediately)
                    } else if !isLoading && errorMessage == nil {
                        VStack{
                            Spacer()
                            Image("pharmacyPreview")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 400,height:300)
                                .opacity(0.5)
                            
                            Text("No pharmacy found.".addLocalizableString(str: languageManager.language))
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        }
                       
                    }
                    Spacer()
                }
                .padding()
                .navigationTitle("Pharmacy on Duty".addLocalizableString(str: languageManager.language))
                .navigationBarTitleDisplayMode(.inline)
                .onChange(of: searchViewModel.cameraPosition, { _, newValue in
                    routeVm.cameraPosition = newValue
                })
                .onChange(of: selectedCity) { newValu,oldValue in
                    fetchPharmacies() // Şehir değiştiğinde arama başlatılır
                }
            
            .background{
                colorScheme == .light ?  Color.hex("F2F2F7").ignoresSafeArea(.all):Color("NewBlack1").ignoresSafeArea(.all)
            }
            
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done".addLocalizableString(str: languageManager.language)) { hideKeyboard() }
                
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut){



                            uiStateVm.activeSheet = nil
                        
//                            sideMenuVm.sideMenuShow.toggle()
                            hapticImpact.impactOccurred()
//                            routeVm.selectedLocation = nil
                        }
                     
                    
                    } label: {
                        ZStack {
                            Circle()
                                .fill(colorScheme == .light ?  Color.hex("0C7B93").opacity(0.8): Color(.systemGray6))
                                .frame(width: 35, height: 35)
                                .padding(.leading)
                                
                            
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.8): Color(UIColor.systemGray6))
                                .padding(.leading)
                                .foregroundStyle( colorScheme == .light ? Color.hex("F2F2F7"): Color.hex("F2F2F7"))
                                .fontWeight(.medium)
            //                Color.hex("0C7B93")
                        }

                    }
                }
            }
        }
    }
    
    private func fetchPharmacies() {
        isLoading = true
        errorMessage = nil
        pharmacyList.removeAll()
        filteredPharmacies.removeAll()

        apiManager.insertPharmaciesRecord(il: selectedCity, ilce: "") { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success(let pharmacies):
                    pharmacyList = pharmacies.map { pharmacy in
                        var updatedPharmacy = pharmacy
                        updatedPharmacy.dist = pharmacy.dist.capitalized
                        return updatedPharmacy
                    }
                    filteredPharmacies = pharmacyList

                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    
    
    private func filterByDistrict() {
        if selectedDistrict.isEmpty {
            filteredPharmacies = pharmacyList
        } else {
            let formattedDistrict = selectedDistrict.capitalized
            filteredPharmacies = pharmacyList.filter { $0.dist.capitalized == formattedDistrict }
        }
    }
    
    
}



#Preview {
    PharmacySearchView()
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy())) // RouteViewModel'i ekle
        .environmentObject(SearchViewModel()) // SearchViewModel'i ekle
        .environmentObject(UIStateViewModel()) // UIStateViewModel'i ekle
        .environmentObject(LocationManagerDummy()) // LocationManagerDummy'yi ekle
        .environmentObject(SideMenuViewModel())
        .environmentObject(UIStateViewModel())
}

