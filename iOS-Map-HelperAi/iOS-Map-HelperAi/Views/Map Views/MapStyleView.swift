//
//  MapStyleView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 31.10.2024.
//

import SwiftUI

struct MapStyleView: View {
    @EnvironmentObject var locationManager: LocationManagerDummy
    @EnvironmentObject var vm: MapViewModel
    @EnvironmentObject var searchViewModel: SearchViewModel
    
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @Binding var mapStyleConfig:MapStyleConfig
    @AppStorage("isDarkMode") private var isDarkMode = false
    var body: some View {
       
            VStack(alignment: .leading){
                HStack{
                    Text("Map Style")
                        .font(.largeTitle)
                    Spacer()
                    Button {
                        withAnimation(.easeInOut){
                            
                            uiStateVm.isSearchViewShow = false
                            searchViewModel.searchText = ""
                            uiStateVm.selectedDetent = .height(310)
                            searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
                            uiStateVm.activeSheet = nil
                            uiStateVm.isShowNearByPlaces = false
                            uiStateVm.isSecondViewSearchView = false
                            hapticImpact.impactOccurred()
                        }
                     
                    
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(.systemGray6))
                                .frame(width: 35, height: 35)
                                .padding(.leading)
                                .shadow(color: Color("ShadowColor").opacity(isDarkMode ?  0.2:0.9), radius: 1, x: 0, y: 1)
                            
                            
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 17, height: 17)
                                .background(Color(UIColor.systemGray6))
                                .padding(.leading)
                                .foregroundStyle( Color("TextColor"))
                                .fontWeight(.medium)
                                
                        }

                    }
                }
                .padding(.bottom,16)
              
                
                LabeledContent("Base Style"){
                    Picker("Base Style", selection: $mapStyleConfig.baseStyle) {
                        ForEach(MapStyleConfig.BaseMapStyle.allCases, id:\.self) { type in
                            Text(type.label)
                        }
                    }
                }
                LabeledContent("Elevation"){
                    Picker("Elevation", selection: $mapStyleConfig.elevation) {
                        Text("Flat").tag(MapStyleConfig.MapElevation.flat)
                        Text("Realistic").tag(MapStyleConfig.MapElevation.realistic)
                    }
                }
                
                
                if mapStyleConfig.baseStyle != .imagery{
                    LabeledContent("Points of interest"){
                        Picker("Points of Interest",selection:$mapStyleConfig.pointsOfInterest){
                            Text("None").tag(MapStyleConfig.MapPOI.excludingAll)
                            Text("All").tag(MapStyleConfig.MapPOI.all)
                        }
                        
                    }
                    
                }
                Button("Apply"){
                    
                }
                .frame(maxWidth: .infinity,alignment: .trailing)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .navigationTitle("Map Style")
            .navigationBarTitleDisplayMode(.inline)
            Spacer()
                
        
        
    }
}

#Preview {
    MapStyleView(mapStyleConfig: .constant(MapStyleConfig.init()))
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
//        .environmentObject(MapStyleConfig())
}
