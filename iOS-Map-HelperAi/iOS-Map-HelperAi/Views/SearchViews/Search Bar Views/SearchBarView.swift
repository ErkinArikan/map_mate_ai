import SwiftUI
import MapKit
import SwiftData

struct SearchBarView: View {
    //MARK: - VARIABLES
    @EnvironmentObject var locationManager: LocationManagerDummy
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    
    @EnvironmentObject var routeVm:RouteViewModel
    
    @Binding var searchResults: [SearchResultModel]
    @Binding var showDetails: Bool
    @Binding var cameraPosition: MapCameraPosition
    @Binding var getDirections:Bool
    @State var isLocalPlacesSearch:Bool = false
    @Environment(\.modelContext) var context
    @AppStorage("isDarkMode") private var isDarkMode = false
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @Environment(\.colorScheme) private var colorScheme
    //MARK: - BODY
    
    var body: some View {
        
        VStack {
            HStack {
                SearchBarTextView(searchResults: $searchResults, getDirections: $getDirections)
                
                XButton
            } //:Hsstack
            
            if !searchViewModel.searchText.isEmpty {
                SearchResultListView
            }
            
        } //:VStack
        .ignoresSafeArea(.keyboard)
        .onChange(of: uiStateVm.selectedDetent, { _, newValue in
            if newValue == .height(310) || newValue == .height(60)  {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    withAnimation(.easeInOut(duration: 0.01)) {
            
                        uiStateVm.isFavoritesShowing = true
                        uiStateVm.isGridActive = false
                    }
                  
                }
            }
        })
        .onChange(of: uiStateVm.selectedDetent, { oldValue, newValue in
            if newValue == .height(310) || newValue == .height(60) || newValue == .height(500)  {
                withAnimation(.spring) {
                    uiStateVm.isSearchViewShow.toggle()
                }
            }
        })
        .padding(.horizontal)
        /// Aratmadan dönen sonuçları buradakine eşitliyoruz.
        .onChange(of: searchViewModel.searchResults, { _, newValue in
            searchResults = newValue
        })

        .onChange(of: uiStateVm.showDetails, { oldValue, newValue in
            withAnimation {
                showDetails = newValue
            }
            
        })

        .onChange(of: searchViewModel.cameraPosition, { _, newValue in
            withAnimation {
                cameraPosition = newValue
            }
            
        })

        /// Mapte görünen noktaları siliyoruz eğer text boş ise
        .onChange(of: searchViewModel.searchText.isEmpty, { _, newValue in
            if newValue{
                searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
            }
        })
        

        
    }

       


}


//MARK: - EXTENSION
extension SearchBarView {
    
    //MARK: - BUTTON
    private var XButton:some View{
        Button {
            withAnimation(.easeInOut){
                uiStateVm.selectedDetent = .height(310)
                uiStateVm.isSearchViewShow = false
                searchViewModel.searchText = ""
                searchResults.removeAll()
                getDirections = false
                searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
                uiStateVm.activeSheet = nil
                uiStateVm.isShowNearByPlaces = false
                uiStateVm.showAnnotation = false
                uiStateVm.isSecondViewSearchView = false
                hapticImpact.impactOccurred()
                routeVm.selectedLocation = nil
            }
         
        
        } label: {
            ZStack {
                Circle()
                    .fill(colorScheme == .light ?  Color.hex("0C7B93").opacity(0.7): Color(.systemGray6))
                    .frame(width: 35, height: 35)
                    .padding(.leading)
//                    .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
                    
                
                
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
                
                    .padding(.leading)
                    .foregroundStyle( colorScheme == .light ? Color.hex("F2F2F7"): Color.hex("F2F2F7"))
                    .fontWeight(.medium)
//                Color.hex("0C7B93")
            }

        }
        
    }
    
    //MARK: - SearchResultListView
    private var SearchResultListView: some View {
        List {
            ForEach(sortedSearchResults) { completion in
                Button(action: {
                    searchViewModel.didTapOnSearchCompletion(completion)
                    uiStateVm.isSearchViewShow = false
                    uiStateVm.activeSheet = .details
                    uiStateVm.showDestinationDetailsView = true
                  
                    uiStateVm.showAnnotation = true
                    uiStateVm.selectedDetent = .height(300)
                    searchViewModel.searchText = ""
                    hapticImpact.impactOccurred()
                    searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundStyle(Color("TextColor").opacity(0.6))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(completion.title)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93") : Color.hex("F2F2F7"))
                                Text(completion.subTitle)
                                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93").opacity(0.6) : Color.hex("F2F2F7").opacity(0.6))
                                Text(completion.location)
                                    .font(.footnote)
                                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93").opacity(0.6) : Color.hex("F2F2F7").opacity(0.6))
                            }
                            Spacer()
                            Image(systemName: "map.circle")
                                .resizable()
                                .fontWeight(.light)
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93") : Color.hex("F2F2F7"))
                        }
                    }
                }
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
        .scrollIndicators(.hidden)
    }

    // Sıralanmış sonuçları döndürmek için bir computed property ekleyin
    private var sortedSearchResults: [SearchCompletionsModel] {
        guard let userLocation = locationManager.currentLocation else {
            return searchViewModel.locationService.completions
        }
        return sortedCompletions(userLocation: userLocation)
    }
    private func sortedCompletions(userLocation: CLLocationCoordinate2D) -> [SearchCompletionsModel] {
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        return searchViewModel.locationService.completions.sorted { completion1, completion2 in
            guard let loc1 = coordinateFromString(completion1.location),
                  let loc2 = coordinateFromString(completion2.location) else {
                return false
            }
            let distance1 = userCLLocation.distance(from: CLLocation(latitude: loc1.latitude, longitude: loc1.longitude))
            let distance2 = userCLLocation.distance(from: CLLocation(latitude: loc2.latitude, longitude: loc2.longitude))
            return distance1 < distance2
        }
    }

    // String'den CLLocationCoordinate2D'ye dönüştürme yardımcı fonksiyonu
    private func coordinateFromString(_ locationString: String) -> CLLocationCoordinate2D? {
        let components = locationString.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard components.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: components[0], longitude: components[1])
    }
   
}



//MARK: - PREVIEW
#Preview{
        SearchBarView(
            searchResults: .constant(.init()),
            showDetails: .constant(false),
            cameraPosition: .constant(MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                                                                                  span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))),
            getDirections: .constant(false)
        )
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(UIStateViewModel())
}
