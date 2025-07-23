import SwiftUI

struct MessageBubbles: View {
    var body: some View {
        VStack{
            
            
            Button(action: {
                // Butona basıldığında yapılacak işlemler
            }) {
                HStack {
                    Text("Adasfasgasfasldknaskdnaskldnaklsd dasmdklansdkas")
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    ZStack {
                        Circle()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(.red.opacity(0.25))
                            .shadow(color: .red.opacity(0.3), radius: 4, x: 2, y: 2) // Dış daireye gölge ekledik
                        
                        Circle()
                            .frame(width: 30, height: 30)
                            .foregroundStyle(.white)
                            .shadow(color: .gray.opacity(0.3), radius: 2, x: 1, y: 1) // İç daireye gölge ekledik
                        
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .frame(width: 17, height: 17)
                            .foregroundStyle(.red)
                    }
                }
                .frame(maxWidth: 250)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4) // Balonun tamamına gölge ekledik
            }
        }
        .onAppear(){
            let responseText = """
            Here are some places:
            - **[Home](address:123 Main St, Springfield)**
            - **[Work](address:456 Elm St, Shelbyville)**
            - **[Cafe](address:789 Coffee Rd, Brewtown)**
            """

            let extractedData = extractAddressesAndPlaceNames(from: responseText)

            for data in extractedData {
                print("Place Name: \(data.placeName), Address: \(data.address)")
            }
        }
    }
    func extractAddressesAndPlaceNames(from text: String?) -> [(placeName: String, address: String)] {
        guard let text = text else { return [] }
        
        // Düzenli ifade: **[Place Name](address:Address)**
        let pattern = #"(?<=\*\*\[)(.*?)(?=\]\(address:)(.*?)(?=\))"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
        
        // Eşleşmeleri ayıklayıp place name ve adresleri döndür
        return matches.compactMap { match in
            guard let placeNameRange = Range(match.range(at: 1), in: text),
                  let addressRange = Range(match.range(at: 2), in: text) else { return nil }
            
            let placeName = String(text[placeNameRange])
            let address = String(text[addressRange])
            
            return (placeName: placeName, address: address)
        }
    }
    
}

#Preview {
    MessageBubbles()
}



