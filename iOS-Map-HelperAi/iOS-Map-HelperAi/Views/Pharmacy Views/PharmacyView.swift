//
//  PharmacyView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 9.01.2025.
//
//
//import SwiftUI
//
//struct PharmacyView: View {
//    private let apiManager = PharmacyApiManager() // API Manager örneği
//    
//    @State private var pharmacyList: [Pharmacy] = [] // Gelen eczane listesini saklamak için
//    @State private var errorMessage: String? = nil // Hata mesajını saklamak için
//    @State private var isLoading: Bool = false // Yükleme durumu
//    
//    var body: some View {
//        VStack {
//            // API Çağrısı İçin Buton
//            Button(action: fetchPharmacies) {
//                Text("Fetch Duty Pharmacies")
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//            }
//            .padding()
//            
//            // Yükleme Durumu
//            if isLoading {
//                ProgressView("Loading...")
//                    .padding()
//            }
//            
//            // Hata Mesajı
//            if let errorMessage = errorMessage {
//                Text(errorMessage)
//                    .foregroundColor(.red)
//                    .padding()
//            }
//            
//            // Eczane Listesi
//            ScrollView {
//                if pharmacyList.isEmpty && !isLoading && errorMessage == nil {
//                    Text("No pharmacies found.")
//                        .foregroundColor(.gray)
//                        .padding()
//                } else {
//                    ForEach(pharmacyList, id: \.name) { pharmacy in
//                        PharmacyRow1(pharmacy: pharmacy)
//                            .padding(.horizontal)
//                            .padding(.vertical, 5)
//                    }
//                }
//            }
//        }
//        .padding()
//    }
//    
//    // Eczaneleri Fetch Eden Metod
//    private func fetchPharmacies() {
//        isLoading = true
//        errorMessage = nil
//        
//        apiManager.fetchDutyPharmacies(il: "Ankara", ilce: "Çankaya") { result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let pharmacies):
//                    print("Eczane Listesi: \(pharmacies)")
//                case .failure(let error):
//                    print("Hata: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    PharmacyView()
//}

// Eczane Bilgilerini Görüntülemek için Alt View
//struct PharmacyRow1: View {
//    let pharmacy: Pharmacy
//    
//    var body: some View {
//        VStack(alignment: .leading, spacing: 8) {
//            Text(pharmacy.name)
//                .font(.headline)
//            Text("Region: \(pharmacy.dist)")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//            Text("Address: \(pharmacy.address)")
//                .font(.footnote)
//            Text("Phone: \(pharmacy.phone)")
//                .font(.footnote)
//            Text("Location: \(pharmacy.loc)")
//                .font(.footnote)
//                .foregroundColor(.blue)
//        }
//        .padding()
//        .background(Color(.systemGray6))
//        .cornerRadius(10)
//        .shadow(radius: 2)
//    }
//}
