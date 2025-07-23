//
//  CustomNearbyDropDownMenu.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 10.01.2025.
//

import SwiftUI
import SwiftData
import MapKit

struct CustomNearbyDropDownMenu: View {
    @Namespace private var animationNamespace
    @State private var isExpanded = false
    @State private var selectedOption = "Tap To See"

    @Environment(\.colorScheme) private var colorScheme
    @Query(sort: \LastSearchedPlaces.timestamp) private var items: [LastSearchedPlaces]
    @Environment(\.modelContext) var context
    @EnvironmentObject var sideMenuVm: SideMenuViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var uiStateVm: UIStateViewModel
    @EnvironmentObject var mapMateVm: MapMateViewModel
    @EnvironmentObject var routeVm: RouteViewModel
    @EnvironmentObject var locationManager: LocationManagerDummy
    @EnvironmentObject var languageManager:LanguageManager
    var dropDownHeaderText: String?

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
//                .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93") : Color("BabyBlue"))
                .foregroundStyle(colorScheme == .light ? Color.hex("F2F2F7") : Color.hex("F2F2F7"))
                .padding()
                .frame(width: 180, height: 30, alignment: .leading)
                .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.5) : Color(.systemGray6))
                .cornerRadius(8)
                .matchedGeometryEffect(id: "dropdown", in: animationNamespace)
            }
            .padding(.leading)

            if isExpanded {
                List {
                    ForEach(nearbyPlaces, id: \.id) { place in
                        Button(action: {
                            withAnimation {
                                updateCameraAndSearch(for: place.searchFor)
                                hapticImpact.impactOccurred()
                                uiStateVm.showDestinationDetailsView = true
                                sideMenuVm.sideMenuShow.toggle()
                                selectedOption = place.name
                                isExpanded = false
                            }
                        }) {
                            HStack {
                                NearByRowIconRowView(iconName: place.iconName, iconColor: place.iconColor)

                                Text(place.name.addLocalizableString(str: languageManager.language))
                                    .font(.system(size: 13))
                                    .fontWeight(.medium)
                                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93") : Color("TextColor"))
                            }
                        }
                        .transition(.opacity)
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listStyle(.plain)
                .transition(.scale)
            }
        }
        
    }

    func updateCameraAndSearch(for place: String) {
        DispatchQueue.main.async {
            let currentRegion = locationManager.region
            let zoomedOutRegion = MKCoordinateRegion(
                center: currentRegion.center,
                span: MKCoordinateSpan(latitudeDelta: currentRegion.span.latitudeDelta * 8,
                                       longitudeDelta: currentRegion.span.longitudeDelta * 8)
            )

            routeVm.cameraPosition = MapCameraPosition.region(zoomedOutRegion)
            searchViewModel.searchForLocalPlaces(for: place)
            uiStateVm.isShowNearByPlaces = true
            searchViewModel.nearBySearchName = place
            withAnimation(.easeInOut(duration: 0.01)) {
                uiStateVm.selectedDetent = .height(310)
                hideKeyboard()
            }
        }
    }
}

#Preview {
    CustomNearbyDropDownMenu()
        .environmentObject(SideMenuViewModel())
        .environmentObject(SearchViewModel())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(UIStateViewModel())
        .environmentObject(MapMateViewModel(api: ChatGPTAPI(apiKey: "API_KEY", locationManager: LocationManagerDummy())))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(LocationManagerDummy())
}
