//
//  SideMenuPractice2.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 22.10.2024.
//

import SwiftUI
import FirebaseAuth
import SwiftData
import MapKit

struct SideMenuView: View {
    @EnvironmentObject var settingsVm:SettingsViewModel
    @EnvironmentObject var searchViewModel:SearchViewModel
    @EnvironmentObject var vm:MapViewModel
    @EnvironmentObject var uiStateVm:UIStateViewModel
    @EnvironmentObject var mapMateVm:MapMateViewModel
    @EnvironmentObject var routeVm:RouteViewModel
    @EnvironmentObject var locationManager:LocationManagerDummy
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Binding var isShowing:Bool
    @EnvironmentObject var loginVm:LoginViewModel
    @Query(sort: \LastSearchedPlaces.timestamp) private var items: [LastSearchedPlaces]
    @Environment(\.modelContext) var context
    @EnvironmentObject var sideMenuVm:SideMenuViewModel
    @AppStorage("log_status") private var logStatus:Bool = false
    @Environment(\.colorScheme) private var colorScheme
    @Binding var searchResults: [SearchResultModel]
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        ZStack{
            
            if isShowing{
                
                //MARK: - Gizli Kapatma Butonu
               
                secretButton
                   
                HStack{
                    VStack(alignment:.leading){
                    //MARK: - HEAD
                        
                        SideMenuHeadView
                        Divider()
                            .overlay(content: {
                                Color.hex(colorScheme == .light ? "0C7B93": "F2F2F7")
                            })
                        //MARK: - BODY
                        Text("Browse Now".addLocalizableString(str: languageManager.language))
                            .font(.system(size: 14))
                          
//                            .foregroundStyle(Color.hex(colorScheme == .light ? "0C7B93":"F2F2F7").opacity(0.7))
                            .foregroundStyle(colorScheme == .light ? Color(.systemGray) : Color(.systemGray))
                            .padding([.leading,.top])
                            .padding([.top],6)
                        
                        
                        searchButton
                        
                        assitantButton
                        
                        settingsButton
                        
                        
//                        Text("Pharmacies on Duty".addLocalizableString(str: languageManager.language))
//                            .font(.system(size: 14))
//                          
//                            .foregroundStyle(colorScheme == .light ? Color(.systemGray) : Color(.systemGray))
//                            .padding([.leading,.top])
//                        
//                       
//                            Button {
//                                withAnimation{
//                                    hapticImpact.impactOccurred()
//                                    uiStateVm.activeSheet = .pharmacyView
//                                    sideMenuVm.sideMenuShow.toggle()
//                                }
//                               
//                            } label: {
//                                HStack{
//                                    Image(systemName: "e.square")
//                                        .foregroundStyle(.red)
//                                        .font(.system(size: 25, weight: .medium))
//                                    
//                                    Spacer()
//                                    
//                                    Image(systemName: "chevron.right")
//                                        .font(.system(size: 13))
//                                }
//                                .frame(width: 200, height: 30, alignment: .leading)
//                                .foregroundStyle(colorScheme == .light ? Color.hex("0C7B93") :  Color.hex("F2F2F7"))
//                            }
//                        
//                          .padding(.horizontal)
//                        
                        
//                        lastSearchedPlacesList
                        Text("Last Searched".addLocalizableString(str: languageManager.language))
                            .font(.system(size: 14))
                            .foregroundStyle(colorScheme == .light ? Color(.systemGray) : Color(.systemGray))
                            .padding([.leading, .top])
                  
                        CustomLastSearchDropDownMenu()
                            
                        
//                        Text("Nearby places".addLocalizableString(str: languageManager.language))
//                            .font(.system(size: 14))
//                          
//                            .foregroundStyle(colorScheme == .light ? Color(.systemGray) : Color(.systemGray))
//                            .padding([.leading,.top])
                        
//                        CustomNearbyDropDownMenu()
                        
                        
                        
//                        HStack{
//                            Text("Language:".addLocalizableString(str: languageManager.language))
//                                .foregroundStyle(Color.white)
//                                .font(.subheadline)
//                                .opacity(0.6)
//                            Picker("Select Language".addLocalizableString(str: languageManager.language), selection: $languageManager.language) {
//                                Text("English")
//                                    .tag("en")
//                                Text("Türkçe")
//                                    .tag("tr")
//                            }
//                            .tint(Color.white)
//                            .font(.subheadline)
//                            .pickerStyle(DefaultPickerStyle())
//                            .frame(alignment: .leading)
//                        }
//                        .padding()
//                        .padding(.horizontal,5)
                            
                       
                       
                      


                        
                        //MARK: - FOOTER
                        
                        Spacer()
                        
                        VStack{
                            
//                            darkLightModeButton
                            
                            Divider()
                                .overlay(content: {
                                    Color.hex(colorScheme == .light ? "0C7B93": "F2F2F7")
                                })
                            
                            SideMenuSignOutButton()

                            
                        }
                        
                    } //:VStack
                    
                    .frame(maxWidth: 235,maxHeight: .infinity,alignment: .leading)
                  
                    .background(colorScheme == .light ? Color.hex("F2F2F7") : Color("DarkBg2"))
                    
                    Spacer()
                }//:HStack
                .transition(.move(edge: .leading))
               
            } //:if
        }//:ZStack
        .animation(.spring, value: isShowing)
        .zIndex(isShowing ? 0:-2)
        .onChange(of: searchViewModel.searchResults, { _, newValue in
            searchResults = newValue
        })
    }
    

    
}


//MARK: - PREVIEW
#Preview {
    SideMenuView(isShowing: .constant(true), searchResults: .constant(.init()))
        .environmentObject(LoginViewModel())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(UIStateViewModel())
        .environmentObject(UIStateViewModel())
        .environmentObject(SideMenuViewModel())
        .environmentObject(LanguageManager())
}


//MARK: - EXTENSION
extension SideMenuView{
    //MARK: - HEAD VIEW
    private var SideMenuHeadView:some View{
        HStack {

            //MARK: - Profile View
            ProfileView()
                .padding(.leading)

         
            Spacer()
            
            //MARK: - X Mark Button
            VStack{
                Button {
                    withAnimation {
                        sideMenuVm.sideMenuShow.toggle()
                        uiStateVm.activeSheet = uiStateVm.lastActiveSheet
                        hapticImpact.impactOccurred()
                        searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
                        print("side menu activated sheet:\(String(describing: uiStateVm.activeSheet))")
                    }
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold)) // Daha küçük ve yan menüye uygun boyutta font
                        .foregroundStyle(colorScheme == .light ? Color.hex("F2F2F7") : Color.hex("F2F2F7"))
                        .padding(10) // Düğmeye çevresel boşluk ekliyoruz
                        .background(colorScheme == .light ? Color.hex("0C7B93").opacity(0.7) : Color(.systemGray6))
                        .cornerRadius(20)
                }
                .frame(width: 40, height: 40) // Yan menü için daha küçük bir çerçeve
    //
                .padding(.trailing,10)
    //            .padding(.bottom,12)
                Text("")
            }
          

        }
    }
    
   


    //MARK: - SEARCH BUTTON
    private var searchButton:some View{
        
        SideMenuCustomButton(action: {
            uiStateVm.activeSheet = .search
            sideMenuVm.sideMenuShow.toggle()
            hapticImpact.impactOccurred()
        }, imageText: "magnifyingglass", text: "Search On Map".addLocalizableString(str: languageManager.language))

    }
    
    //MARK: - ASSITANT BUTTON
    private var assitantButton:some View{
        SideMenuCustomButton(action: {
            uiStateVm.activeSheet = .chat
            hapticImpact.impactOccurred()
            sideMenuVm.sideMenuShow.toggle()
        }, imageText: "lasso.badge.sparkles", text: "AI-Assistant".addLocalizableString(str: languageManager.language))
        

    }
    
    //MARK: - SETTINGS BUTTON
    private var settingsButton:some View{
        
        SideMenuCustomButton(action: {
//            uiStateVm.activeSheet = .settingsView
            hapticImpact.impactOccurred()
            sideMenuVm.sideMenuShow.toggle()
            settingsVm.isShow.toggle()
        }, imageText: "gear", text: "Settings".addLocalizableString(str: languageManager.language))
        

    }
    
    //MARK: - SECRET BUTTON
    private var secretButton:some View{
        Button {
            withAnimation {
                isShowing = false
                searchViewModel.exSearchResul.removeAll(keepingCapacity: false)
                uiStateVm.activeSheet = uiStateVm.lastActiveSheet
                hapticImpact.impactOccurred()
            }
        } label: {
            
            Rectangle()
                .fill(Color.black.opacity(0.6))
                .ignoresSafeArea()
                .frame(maxWidth: isShowing ? .infinity:0)
        }
    }
    

    //MARK: - DARK LIGHT MODE BUTTON
    private var darkLightModeButton: some View {
        VStack {
            Spacer()
            Button {
                withAnimation {
                    isDarkMode.toggle()
                    hapticImpact.impactOccurred()
                }
            } label: {
                HStack(spacing: 0) {
                    // Light Mode Tarafı
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .font(.system(size: 11, weight: .bold)) // Daha küçük font boyutu
                        Text("Light")
                            .font(.system(size: 11, weight: .bold)) // Daha küçük font boyutu
                    }
                    .frame(maxWidth: .infinity) // Eşit genişlik
                    .padding()
                    .background(isDarkMode ? Color.gray.opacity(0.2) : Color.hex("0C7B93").opacity(0.8)) // Aktif ve pasif renkler
                    .foregroundStyle(isDarkMode ? Color.gray : Color.hex("F2F2F7"))

                    // Dark Mode Tarafı
                    HStack {
                        Image(systemName: "moon.fill")
                            .font(.system(size: 11, weight: .bold)) // Daha küçük font boyutu
                        Text("Dark")
                            .font(.system(size: 11, weight: .bold)) // Daha küçük font boyutu
                    }
                    .frame(maxWidth: .infinity) // Eşit genişlik
                    .padding()
                    .background(isDarkMode ? Color.hex("0C7B93") : Color.gray.opacity(0.2)) // Aktif ve pasif renkler
                    .foregroundStyle(isDarkMode ? Color.hex("F2F2F7") : Color.gray)
                }
                .cornerRadius(8) // Kenar yumuşatma
                .frame(height: 40) // Yükseklik düşürüldü
            }
            .padding(.horizontal, 10) // Yan boşluklar
            .padding(.bottom, 10) // Alt boşluk
        }
        .frame(maxWidth: .infinity) // Yan menü genişliği
        .background(colorScheme == .light ? Color.hex("F2F2F7") : Color("DarkBg2")) // Arka plan
    }
}













