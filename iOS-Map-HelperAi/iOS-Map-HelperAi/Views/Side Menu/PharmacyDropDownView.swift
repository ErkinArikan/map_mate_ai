//
//  PharmacyDropDownView.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 10.01.2025.
//

import SwiftUI

struct PharmacyDropDownView: View {
    private let apiManager = PharmacyApiManager() // API Manager örneği

    @State private var pharmacyList: [Pharmacy] = [] // Gelen eczane listesini saklamak için
    @State private var errorMessage: String? = nil // Hata mesajını saklamak için
    @State private var isLoading: Bool = false // Yükleme durumu
    @State private var isExpanded = false // Drop-down durumu
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        VStack(alignment: .leading) {
            // API Çağrısı İçin Buton
            Button(action: fetchPharmacies) {
                Text("Fetch Duty Pharmacies".addLocalizableString(str: languageManager.language))
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            // Yükleme Durumu
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

            // Drop-Down Başlık
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Duty Pharmacies".addLocalizableString(str: languageManager.language))
                        .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            }

            // Drop-Down İçerik
            if isExpanded {
                ScrollView {
                    ForEach(pharmacyList, id: \ .name) { pharmacy in
                        PharmacyRow(pharmacy: pharmacy)
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
                .transition(.opacity)
            }
        }
        .padding()
    }

    // Eczaneleri Fetch Eden Metod
    private func fetchPharmacies() {
        isLoading = true
        errorMessage = nil

        apiManager.fetchDutyPharmacies(il: "Ankara", ilce: "Çankaya") { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let pharmacies):
                    pharmacyList = pharmacies
                case .failure(let error):
                    errorMessage = "Failed to fetch pharmacies: \(error.localizedDescription)"
                }
            }
        }
    }
}

// Adresleri Listeleyen Alt View
struct PharmacyRow: View {
    let pharmacy: Pharmacy

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(pharmacy.name)
                .font(.headline)
            Text("Address: \(pharmacy.address)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .contextMenu {
                    Button(action: {
                        UIPasteboard.general.string = pharmacy.address
                    }) {
                        Label("Copy Address", systemImage: "doc.on.doc")
                    }
                }
                .overlay(
                    HStack {
                        Spacer()
                        Button(action: {
                            UIPasteboard.general.string = pharmacy.address
                        }) {
                            Image(systemName: "doc.on.doc")
                                .foregroundColor(.blue)
                        }
                    }
                )
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

#Preview {
    PharmacyDropDownView()
}
