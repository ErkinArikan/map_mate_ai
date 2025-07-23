//
//  FavoritesSearchView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 23.09.2024.
//

import SwiftUI
import MapKit
import _SwiftData_SwiftUI
import FirebaseAuth
import Firebase


/// Bu sayfa favorilere eklendikten sonra yatayda listenin gösterilip, tıklanabilir ve tıklanan adrese gidilebildiği favoriler  butonlarının gösterildiği yer.

struct FavoritesButtonsView: View {
    //MARK: - VARIABLES
    @EnvironmentObject var languageManager:LanguageManager
    @EnvironmentObject var  searchViewModel:SearchViewModel
    @EnvironmentObject var locationManager:LocationManagerDummy
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.colorScheme) private var colorScheme
    //    @Query(sort:\FavoriteLocationDB.poiadi) private var items:[FavoriteLocationDB]
    @Query(sort: \FavoriteLocationDB.timestamp) private var items: [FavoriteLocationDB]
    @Environment(\.modelContext) var context
    @State var isTrashTapped:Bool = false
    @EnvironmentObject var favoritesVm:FavoritesViewModel
//    @State private var favorites: [[String: Any]] = []
    //MARK: - BODY
    var body: some View {
        VStack(alignment:.leading){
            HStack {
                Text("Favorites".addLocalizableString(str: languageManager.language))
                    .font(.system(size: 13))
                    .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93"): Color.hex("F2F2F7"))
                    .padding(.horizontal,20)
                
                
                Spacer()
                
                //MARK: - TRASH BUTTON
                if !favoritesVm.favorites.isEmpty{
                    Button {
                        withAnimation(.spring(duration: 0.3)){
                            isTrashTapped.toggle()
                        }
                    } label: {
                        Image(systemName: "trash")
                            .fontWeight(.medium)
                            .padding(4)
                            .foregroundStyle(Color.hex("F2F2F7"))
                            .background(Color.hex("0C7B93").opacity(0.7))
                            .clipShape(Circle())
                        
                    }
                    .padding(.trailing)
                }
                
                
                //MARK: - PLUS BUTTON
                Button {
                    withAnimation(.spring(duration: 0.3)){
                        uiStateVm.activeSheet = .favorites
                        uiStateVm.selectedDetent = .height(900)
                    }
                } label: {
                    Image(systemName: "plus")
                        .fontWeight(.medium)
                        .padding(4)
                        .foregroundStyle(Color.hex("F2F2F7"))
                        .background(Color.hex("0C7B93").opacity(0.7))
                        .clipShape(Circle())
                    
                }
                .padding(.trailing)
                
            }
            Divider()
                .overlay(content: {
                    Color.hex("0C7B93")
                })
            
            //MARK: - FAVORITES BUTTON
            ScrollView(.horizontal) {
                HStack {
                    ForEach(favoritesVm.favorites.indices, id: \.self) { index in
                        let place = favoritesVm.favorites[index] // Firestore'dan çekilen her favori

                        Button(action: {
                            handleItemSelection(place: place)
                        }) {
                            HStack {
                                Text(place["poiadi"] as? String ?? "Unknown")
                                    .font(.system(size: 16, weight: .medium))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .foregroundStyle(Color.hex("F2F2F7"))

                                if isTrashTapped {
                                    Button {
                                        withAnimation(.spring(duration: 0.3)) {
                                            favoritesVm.deleteFavorite(place: place)
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .font(.system(size: 16, weight: .medium))
                                            .padding(4)
                                            .foregroundStyle(Color.hex("F2F2F7"))
                                            .background(Color.red)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding()
                            .padding(.horizontal, 5)
                            .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.6) : Color(UIColor.systemGray6))
                            .cornerRadius(20)
                        }
                        .frame(maxWidth: 150)
                        .cornerRadius(8)
                        .transition(.opacity)
                    }

                    if favoritesVm.favorites.isEmpty {
                        Button(action: {}) {
                            HStack {
                                Text("No Favorites Yet".addLocalizableString(str: languageManager.language))
                                    .fontWeight(.medium)
                            }
                            .padding()
                            .padding(.horizontal, 5)
                            .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.6) : Color(UIColor.systemGray6).opacity(0.7))
                            .cornerRadius(20)
                            .foregroundStyle(Color.hex("F2F2F7"))
                        }
                    }
                }
                .padding(.horizontal)
                .padding(5)
            }

            
            
//            ScrollView(.horizontal) {
//                HStack{
//                    
//                    // Köşeleri yuvarla
//                    
////                    ForEach(items, id: \.self) { item in
////                        Button(action: {
////                            handleItemSelection(item: item)
////                            withAnimation {
////                                hapticImpact.impactOccurred()
////                                searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
////                            }
////                        }) {
////                            HStack {
////                                Text(item.poiadi)
////                                    .font(.system(size: 16, weight: .medium))
////                                    .lineLimit(1) // Metni tek satırda sınırla
////                                    .truncationMode(.tail) // Metni sağdan kes ve '...' ekle
////                                    .foregroundStyle(colorScheme == .light ? Color.hex("F2F2F7") : Color.hex("F2F2F7"))
////                                
////                                if isTrashTapped {
////                                    Button {
////                                        withAnimation(.spring(duration: 0.3)) {
////                                            context.delete(item)
////                                        }
////                                    } label: {
////                                        Image(systemName: "trash")
////                                            .font(.system(size: 16, weight: .medium))
////                                            .padding(4)
////                                            .foregroundStyle(Color.hex("F2F2F7"))
////                                            .background(Color.red)
////                                            .clipShape(Circle())
////                                        
////                                    }
////                                    
////                                }
////                            }
////                            .padding()
////                            .padding(.horizontal, 5)
////                            .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.6) : Color(UIColor.systemGray6))
////                            .cornerRadius(20)
////                            .foregroundStyle(Color.hex("F2F2F7"))
////                            //                            .shadow(color: .gray.opacity(0.4), radius: 20, x: 0, y: 20)
////                            
////                        }
////                        
////                        .frame(maxWidth: 150)
////                        .cornerRadius(8)
////                        .transition(.opacity)
////                    }
//                    
//            
//                    
//                    if items.isEmpty {
//                        
//                        //MARK: - NO FAVORITES BUTTON
//                        Button(action: {
//                            
//                        }, label: {
//                            HStack{
//                                Text("No Favoirites Yet".addLocalizableString(str: languageManager.language))
//                                    .fontWeight(.medium)
//                            }
//                            .padding()
//                            .padding(.horizontal, 5)
//                            .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.6):Color(UIColor.systemGray6).opacity(0.7))
//                            
//                            .cornerRadius(20)
//                            .foregroundStyle(Color.hex("F2F2F7"))
//                        })
//                    }
//                } //:HStack
//                .padding(.horizontal)
//                .padding(5)
//            }//:Scroll View
            .scrollIndicators(.hidden)
        }
//        .onAppear {
//            fetchUserFavorites()
//        }
        
        
        
    }
    
   

//       //MARK: - DELETE FAVORITE FROM FIRESTORE
//       func deleteFavorite(place: [String: Any]) {
//           guard let userID = Auth.auth().currentUser?.uid else {
//               print("Error: Kullanıcı oturum açmamış.")
//               return
//           }
//
//           let db = Firestore.firestore()
//           let userRef = db.collection("users").document(userID)
//
//           userRef.updateData([
//               "favoritesPlaces": FieldValue.arrayRemove([place])
//           ]) { error in
//               if let error = error {
//                   print("Firestore favori silme hatası: \(error.localizedDescription)")
//               } else {
//                   print("Favori başarıyla silindi: \(place["poiadi"] ?? "Unknown")")
//                   fetchUserFavorites()
//               }
//           }
//       }
    
    //MARK: - HANDLE ITEM SELECTION
    /// Bu kod favorilerde bulunanlara tıkladığımızda haritada gösterimini sağlamaktadır.
    
    func handleItemSelection(place: [String: Any]) {
          let poiName = place["poiadi"] as? String ?? "Unknown"
          let lat = place["lat"] as? Double ?? 0.0
          let lon = place["lon"] as? Double ?? 0.0
          let il = place["il"] as? String ?? ""
          let ilce = place["ilce"] as? String ?? ""

          print("Seçilen yer: \(poiName), \(il), \(ilce)")

          let recentSearchCompletion = SearchCompletionsModel(title: poiName, subTitle: il, location: "")

          uiStateVm.activeSheet = .details
          uiStateVm.selectedDetent = .height(300)
          searchViewModel.searchText = ""
          searchViewModel.didTapOnSearchCompletion(recentSearchCompletion)

          let newRegion = MKCoordinateRegion(
              center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
              span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
          )

          withAnimation(.spring(duration: 0.3)) {
              uiStateVm.isSearchViewShow = false
              uiStateVm.showDestinationDetailsView = true
              uiStateVm.showAnnotation = true
              routeVm.cameraPosition = MapCameraPosition.region(newRegion)
          }
      }
    
    
}

//MARK: - PREVIEW
#Preview {
    FavoritesButtonsView()
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(LocationManagerDummy())
        .environmentObject(LanguageManager())
}
