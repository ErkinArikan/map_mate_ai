//
//  SplashScreenView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 6.11.2024.
//

import SwiftUI

struct SplashScreenView: View {
    @StateObject var internetManagerVm = InternetConnectivityChecker()
    @Binding var isActive: Bool
    @State private var isAnimating: Bool = false
    @State private var offsetY: CGFloat = -30 // Başlangıç offset değeri
    @EnvironmentObject var languageManager:LanguageManager
    @EnvironmentObject var updateChecker:UpdateChecker
    var body: some View {
        if isActive {
            FinalMapView()
        } else {
            NavigationStack {
                ZStack {
                    LinearGradient(colors: [Color.hex("0C7B93").opacity(0.8), Color.hex("0C7B93").opacity(0.8)], startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea(.all, edges: .all)

                    VStack {
                        Spacer()
                        
                        // Logo
                        HStack{
                            Spacer()
                            Image("NewestLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 600, height: 370, alignment: .center)
                                .shadow(radius: 10)
                                .offset(x:0,y: offsetY) // Offset değerini bağlama
                                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: offsetY) // Animasyon
                            Spacer()
                        }
                        
                      Text("Map Mate-AI")
                            .font(.system(size: 30))
                            
                            .fontWeight(.medium)
                            .foregroundStyle(Color.hex("F2F2F7"))
                        Spacer()
                        Spacer()
                        
                        // Copyright metni
                        Text("Copyright © reserved by Erkin Arıkan".addLocalizableString(str: languageManager.language))
                            .font(.caption2)
                            .foregroundStyle(Color.hex("F2F2F7"))
                        
                        Spacer()
                    }
                    WifiNotiftow(isConnected: $internetManagerVm.isConnected)
                        .frame(maxHeight: .infinity,alignment: .top)
                        .offset(y: internetManagerVm.showNotification ? 0:-200)
                        .padding()
                        .onAppear(){
                            internetManagerVm.startMonitoring()
                            
                            
                        }
                }
            } //: NavigationStack
            .onAppear {
                // Animasyonu başlat
                withAnimation {
                    isAnimating.toggle()
                }
                // Logo hareketi
                DispatchQueue.main.async {
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        offsetY = offsetY == -30 ? 30 : -30
                    }
                }
                // Splash ekranından çıkış
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        if !updateChecker.isUpdateRequired{
                            isActive = true
                        }
                      
                    }
                }
            }
            .alert(isPresented: $updateChecker.isUpdateRequired) {
                Alert(
                    title: Text("Güncelleme Gerekli".addLocalizableString(str: languageManager.language)),
                    message: Text("Yeni \(updateChecker.latestVersion) sürümü çıktı. Devam etmek için güncellemeniz gerekiyor.".addLocalizableString(str: languageManager.language)),
                    primaryButton: .default(Text("Güncelle".addLocalizableString(str: languageManager.language)), action: {
                        if let url = URL(string: "https://apps.apple.com/ae/app/map-mateai-navigate-with-chat/id6740746255?uo=2"),
                           UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url)
                        }
                    }),
                    secondaryButton: .cancel(Text("Çıkış"), action: {
                        exit(0)
                    })
                )
            }
        }
    }
}

#Preview {
    SplashScreenView(isActive: .constant(false))
        .environmentObject(LocationManagerDummy())
        .environmentObject(MapViewModel(locationManager: LocationManagerDummy()))
        .environmentObject(RouteViewModel( locationManager: LocationManagerDummy()))
        .environmentObject(SearchViewModel())
        .environmentObject(LanguageManager())
        .environmentObject(UpdateChecker())
}
