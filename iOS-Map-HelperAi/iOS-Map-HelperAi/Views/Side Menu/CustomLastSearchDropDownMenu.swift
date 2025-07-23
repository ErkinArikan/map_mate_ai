import SwiftUI
import SwiftData
import MapKit


struct CustomLastSearchDropDownMenu: View {
  @Namespace private var animationNamespace
  @State private var isExpanded = false
  @State private var selectedOption = "Tap To See"

    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \LastSearchedPlaces.timestamp) private var items: [LastSearchedPlaces]
    @Environment(\.modelContext) var context
    @EnvironmentObject var sideMenuVm:SideMenuViewModel
    @EnvironmentObject var searchViewModel:SearchViewModel
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @EnvironmentObject var mapMateVm:MapMateViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var languageManager:LanguageManager
    var dropDownHeaderText:String?
    
  var body: some View {
      VStack(alignment: .leading) {
                
          
                Button(action: {
                      withAnimation(.spring()) {
                          isExpanded.toggle()
                      }
                  }) {
                      HStack {
                          Text(selectedOption.addLocalizableString(str: languageManager.language))
                              .font(.system(size: 15))
                          Spacer()
                          Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                              .font(.system(size: 13))
                      }
                      .foregroundStyle(colorScheme == .light ? Color.hex("F2F2F7") : Color.hex("F2F2F7"))
                      .padding()
                      .frame(width: 180, height: 30,alignment: .leading)
                      .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.5) : Color(.systemGray6))
                      .cornerRadius(8)
                      .matchedGeometryEffect(id: "dropdown", in: animationNamespace)
                  }
                  
                  if isExpanded {
                      VStack(alignment:.leading) {
                          ForEach(items.reversed(), id: \.self) { item in
                              Button(action: {
                                  withAnimation {
                                      handleItemSelection(item: item)
                                      hapticImpact.impactOccurred()
                                      sideMenuVm.sideMenuShow.toggle()
                                      searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
                                      selectedOption = item.poiadi
                                      isExpanded = false
                                  }
                              }) {
                                  HStack {
                                      NearByRowIconRowView(iconName: "magnifyingglass", iconColor: Color("myDark"))
                                      Text(item.poiadi)
                                          .font(.system(size: 16, weight: .medium))
                                          .lineLimit(1) // Metni tek satırda sınırla
                                          .truncationMode(.tail) // Metni sağdan kes ve '...' ekle
                                          .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93") : Color("TextColor"))
                                      Spacer()
                                  }
                              }
                          
                              .frame(maxWidth: .infinity)
//                              .background(Color.gray.opacity(0.1))
                              .cornerRadius(8)
                              .transition(.opacity)
                          }
                      }
//                      .background(Color.gray.opacity(0.1))
                      .cornerRadius(8)
                      .transition(.scale)
                  }
              }
      .padding(.leading)
          }
    
    func handleItemSelection(item: LastSearchedPlaces) {
        print("item.poiadi: \(item.poiadi)")
        print("item.il : \(item.il)" )
        // Son arananlarda seçili yerin lat ve lon bilgileri
        let recentSearchCompletion = SearchCompletionsModel(title: item.poiadi, subTitle: item.il, location: "")
        print("item il:\(item.poiadi)")
        print("item ilçe: \(item.ilce)")
        uiStateVm.showDestinationDetailsView = true
        uiStateVm.showAnnotation = true
        ///Deneme
        uiStateVm.activeSheet = .details
        uiStateVm.selectedDetent = .height(300)
        searchViewModel.searchText = ""
        searchViewModel.didTapOnSearchCompletion(recentSearchCompletion)
//            iosVm.shouldCenterMapOnUser = false

        // Kamerayı seçili lokasyona odaklama
        let newRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        withAnimation(.spring(duration: 0.3)) {
            // Search view kapansın
            uiStateVm.isSearchViewShow = false
            // Route view açılsın
            uiStateVm.showDestinationDetailsView = true
            // Kamera animasyonlu gelsin
//                vm.cameraRegion = EquatableCoordinateRegion(region: newRegion)
            routeVm.cameraPosition = MapCameraPosition.region(newRegion)
        }
    }
}

#Preview {
    CustomLastSearchDropDownMenu()
}

// MARK: - Preview
//ForEach(items.reversed()) { item in
//    VStack(alignment: .leading) {
//        Button(action: {
//            withAnimation {
//                handleItemSelection(item: item)
//                hapticImpact.impactOccurred()
//                sideMenuVm.sideMenuShow.toggle()
//                searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
//            }
//           
//        }, label: {
//            HStack {
//                NearByRowIconRowView(iconName: "magnifyingglass", iconColor:Color("myDark"))
//                    
//               
//                Text(item.poiadi)
//                    .font(.system(size: 16,weight: .medium))
//                    .lineLimit(1) // Metni tek satırda sınırla
//                    .truncationMode(.tail) // Metni sağdan kes ve '...' ekle
//                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color("TextColor"))
//                Spacer()
//                
//                
//            }
//        })
//        .frame(width: 180)
//        .padding(.leading)
//    
//        
//       
//    } //:VStack
////                                .frame(maxWidth: .infinity, alignment: .leading)
//
//}
//            Text(option)
//              .padding()
//              .frame(maxWidth: .infinity, alignment: .leading)
//              .background(Color.white)
//              .onTapGesture {
//                withAnimation(.spring()) {
//                  selectedOption = option
//                  isExpanded = false
//                }
//              }
//              .matchedGeometryEffect(id: "dropdown-\(option)", in: animationNamespace)
