//import SwiftUI
//import MapKit
//
//struct FavoritesView2: View {
//    @EnvironmentObject var searchViewModel: SearchViewModel
//    @Binding var searchResultsFav: [SearchResultModel]
//    @Binding var showDetails: Bool
//    @Binding var getDirections: Bool
//    @Binding var mapSelectionPlace: MKMapItem?
//    @State private var showToast: Bool = false
//    // MARK: - BODY
//    var body: some View {
//        ZStack {
//            // Background Color
//            Color("DarkBg2").ignoresSafeArea()
//
//            VStack {
//                // MARK: - SEARCH BAR
//                FavoritesSearchRowView(searchResultsFav: $searchResultsFav, getDirections: $getDirections)
//                    .padding(.horizontal)
//
//                Divider()
//
//                // MARK: - MAIN CONTENT
//                if !searchViewModel.searchText.isEmpty {
//                    // Search Results View
//                    SearchResultsView
//                } else {
//                    if let selectedLocation = searchViewModel.selectedLocationFav {
//                        SelectedPlaceView(selectedLocation: selectedLocation)
//                    } else {
//                        FavoritesPreviewView()
//                    }
//                }
//               
//
//                Spacer()
//            }
//            .padding()
//            
//            ///SearchResultsFavdan döneni  local searchReuslstFav'a yolluyoruz
//            .onChange(of: searchViewModel.searchResultsFav, { _, newValue in
//                searchResultsFav = newValue
//            })
//           
//        }
////        .overlay(alignment: .top) {
////            if showToast {
////                ToastView(message: "Added to Favorites")
////                    .transition(.move(edge: .bottom))
////                    .animation(.easeInOut, value: showToast)
////            }
////        }
//        
//    }
//
//    // MARK: - SEARCH RESULTS VIEW
//    private var SearchResultsView: some View {
//        List {
//            ForEach(searchViewModel.locationService.completions) { completion in
//                Button(action: {
//                    searchViewModel.didTapOnSearchCompletionFavorites(completion)
//                    searchViewModel.searchText = ""
//                }) {
//                    VStack(alignment: .leading, spacing: 4) {
//                        Text(completion.title).font(.headline)
//                        Text(completion.subTitle).font(.subheadline).foregroundColor(.gray)
//                    }
//                }
//            }
//        }
//        .listStyle(PlainListStyle())
//    }
//
//    // MARK: - SELECTED PLACE VIEW
//    private func SelectedPlaceView(selectedLocation: SearchResultModel) -> some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text("Selected Location")
//                .font(.headline)
//                .foregroundColor(.secondary)
//
//            VStack(alignment: .leading, spacing: 4) {
//                Text(selectedLocation.mapItem.name ?? "Unknown Name")
//                    .font(.title3)
//                    .fontWeight(.bold)
//                Text(selectedLocation.mapItem.placemark.title ?? "Unknown Address")
//                    .font(.body)
//                    .foregroundColor(.gray)
//            }
//
//            Divider()
//
//            Button(action: {
//                // Add functionality to handle favorite location
//                withAnimation {
//                    searchViewModel.isFavLocationSelected.toggle()
//                    showToastMessage()
//                }
//          
//            }) {
//                Text("Add to Favorites")
//                    .font(.headline)
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .cornerRadius(10)
//            }
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(10)
//        .shadow(radius: 5)
//    }
//    func showToastMessage() {
//        print("Toast shoving")
//            withAnimation {
//                showToast = true
//            }
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                withAnimation {
//                    showToast = false
//                    print("Toast closed")
//                }
//            }
//        }
//}
//
//// MARK: - PREVIEW
//struct FavoritesView_Previews2: PreviewProvider {
//    static var previews: some View {
//        FavoritesView2(
//            searchResultsFav: .constant([]),
//            showDetails: .constant(false),
//            getDirections: .constant(false),
//            mapSelectionPlace: .constant(nil)
//        )
//        .environmentObject(SearchViewModel())
//        .environmentObject(LanguageManager())
//    }
//}
//
