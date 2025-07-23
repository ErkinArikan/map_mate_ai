//
//  IllusturartionListViewDeneme.swift
//  iOS-Map-HelperAi
//
//  Created by Erkin Arikan on 22.12.2024.
//

import SwiftUI
import Lottie

struct IllusturartionListViewDeneme: View {
    @AppStorage("isOnTutorial") var isOnTutorial: Bool = true
    private let illustrations: [IlusturationModelDeneme] = IlusturationModelDeneme.sampleIllustrations
    let haptic = UIImpactFeedbackGenerator(style: .soft)

    @State private var isAnimating: Bool = false
    @State private var navigateToWelcome: Bool = false
    @State private var currentIndex: Int = 0
    @EnvironmentObject var languageManager:LanguageManager

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    // Gösterilen öğe
                    if let currentIllustration = illustrations[safe: currentIndex] {
                        IllustrationRowViewDeneme(ilustration: currentIllustration)
                            .frame(maxHeight: 450)
                            .transition(.slide)
                    }
                    
                    Spacer()

                    // "Next" veya "Home" düğmesi
                    if currentIndex < illustrations.count - 1 {
                        Button(action: nextIllustration) {
                            HStack {
                                Text("Next".addLocalizableString(str: languageManager.language))
                                Image(systemName: "arrow.right")
                            }
                            .padding()
                            .padding(.horizontal)
                            .foregroundColor(.white)
                            .background(Color.hex("0C7B93").opacity(0.8))
                            .cornerRadius(13)
                        }
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 20)
                    } else {
                        Button(action: goToHome) {
                            HStack {
                                Text("Home".addLocalizableString(str: languageManager.language))
                            }
                            .padding()
                            .padding(.horizontal)
                            .foregroundColor(.white)
                            .background(Color("Mor"))
                            .cornerRadius(13)
                        }
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 20)
                    }
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }

    // MARK: - İşlevler
    private func nextIllustration() {
        withAnimation {
            if currentIndex < illustrations.count - 1 {
                currentIndex += 1
                haptic.impactOccurred()
            }
        }
    }

    private func goToHome() {
        withAnimation {
            navigateToWelcome = true
            isOnTutorial = false
            haptic.impactOccurred()
        }
    }
}

#Preview {
    IllusturartionListViewDeneme()
}


// MARK: - IllustrationRowView
struct IllustrationRowViewDeneme: View {
    var ilustration: IlusturationModelDeneme
    @EnvironmentObject var languageManager:LanguageManager
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            LottieViewDeneme(lottiFile: ilustration.imageName)
                .frame(width: 300, height: 240)

            Text(ilustration.name.addLocalizableString(str: languageManager.language))
                .font(.system(size: 20))
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)

            Text(ilustration.description.addLocalizableString(str: languageManager.language))
                .foregroundColor(.white)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(Color.hex("0C7B93").opacity(0.8))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 20)
    }
}

// MARK: - LottieView
struct LottieViewDeneme: UIViewRepresentable {
    let lottiFile: String
    let animationView = LottieAnimationView()

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        animationView.animation = LottieAnimation.named(lottiFile)
        animationView.loopMode = .loop
        animationView.backgroundBehavior = .pauseAndRestore
        animationView.play()
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Animasyonun güncellenmesi gerekiyorsa burası kullanılabilir
    }
}

// MARK: - Sample Model
struct IlusturationModelDeneme: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let imageName: String
    let tag: Int

    static let sampleIllustrations = [
        IlusturationModelDeneme(name: "Example 1", description: "Description 1", imageName: "aiJ", tag: 0),
        IlusturationModelDeneme(name: "chatJ", description: "Description 2", imageName: "favJ", tag: 1),
        IlusturationModelDeneme(name: "firstJ", description: "Description 3", imageName: "welcomeJ", tag: 2),
    ]
}

// MARK: - Safe Array Access
extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    IllusturartionListViewDeneme()
}
