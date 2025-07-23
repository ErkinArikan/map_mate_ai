import SwiftUI
import Foundation
import FirebaseAuth


struct MessageRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let message: MessageModel
    let retryCallback: (MessageModel) -> Void
    @EnvironmentObject var loginVm:LoginViewModel

    var body: some View {
        VStack(spacing: 8) {
            // Kullanıcı mesajı
            if !message.sendText.isEmpty {
                HStack(spacing:5) {
                    Spacer()
                    messageBubble(messageType: message.send, isUser: true)
                        .padding(.leading)
                    if loginVm.logInStyle == .google {
                    if let photoURL = Auth.auth().currentUser?.photoURL {
                        // Profil fotoğrafı mevcutsa yüklenir
                        AsyncImage(url: photoURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView() // Yüklenme aşamasında bir gösterge
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 35, height: 45)
                                    .clipShape(Circle())
                            case .failure:
                                Image(systemName: "person.circle.fill") // Varsayılan bir görsel
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 45)
                                    .foregroundColor(.gray)
                            @unknown default:
                                Image(systemName: "exclamationmark.triangle.fill")
                            }
                        }
                    } else {
                        // Profil fotoğrafı yoksa varsayılan bir görsel göster
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 45)
                            .foregroundColor(.gray)
                    }
                    
                    }
                    else if loginVm.logInStyle == .email{
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.red)
                        
                    }
                    
                    
                }
            }
            
            // Asistan mesajı
            if let response = message.response, !response.text.isEmpty {
                HStack(spacing:5) {
                    Image("NewestLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35, height: 45)
                        .padding(4)
                        .background(content: {
                            colorScheme == .light ? Color.hex("0C7B93").opacity(0.7) : Color(.systemGray6)
                        })
                        .clipShape(Circle())
                        .padding(.leading)
                    
                    messageBubble(messageType: response, isUser: false)
                        .padding(.trailing)
                       
                    Spacer()
                    
                }
            }
        }
    }
    
    @ViewBuilder
    func messageBubble(messageType: MessageType, isUser: Bool) -> some View {
        switch messageType {
        case .attributed(let attributedOutput):
            // Eğer mesaj 'attributed' türündeyse
            attributedView(results: attributedOutput.results)
                .padding(12)
                .background(isUser ? Color.hex("0C7B93").opacity(0.6) : (colorScheme == .light ? Color.gray.opacity(0.2) : Color.gray.opacity(0.4)))
                .foregroundColor(isUser ? .white : .primary)
                .clipShape(MessageBubble(isFromCurrentUser: isUser))
        case .simpleText(let text):
            // Eğer mesaj 'simpleText' türündeyse
            if !text.isEmpty {
                Text(text)
                    .padding(12)
                    .background(isUser ? Color.hex("0C7B93").opacity(0.6) : (colorScheme == .light ? Color.gray.opacity(0.2) : Color.gray.opacity(0.4)))
                    .foregroundColor(isUser ? .white : .primary)
                    .clipShape(MessageBubble(isFromCurrentUser: isUser))
            }
        }
    }

    
    func triangle(isFromCurrentUser: Bool) -> some View {
        Path { path in
            if isFromCurrentUser {
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: 10, y: 10))
                path.addLine(to: CGPoint(x: 0, y: 10))
                path.closeSubpath()
            } else {
                path.move(to: CGPoint(x: 10, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 10))
                path.addLine(to: CGPoint(x: 10, y: 10))
                path.closeSubpath()
            }
        }
        .frame(width: 10, height: 10)
    }
    
    func attributedView(results: [ParserResult]) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(results) { parsed in
                Text(parsed.attributedString)
                    .textSelection(.enabled)
            }
        }
    }
}

// MARK: - Bubble Shape
struct MessageBubble: Shape {
    let isFromCurrentUser: Bool
    
    func path(in rect: CGRect) -> Path {
        let corners: UIRectCorner = isFromCurrentUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight]
        let bubblePath = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 16, height: 16))
        return Path(bubblePath.cgPath)
    }
}

// MARK: - Preview
struct MessageRowView_Previews: PreviewProvider {
    static let message = MessageModel(
        isInteracting: true,
        sendImage: "profile",
        send: .simpleText("What is SwiftUI?"),
        responseImage: "logo",
        response: .simpleText("SwiftUI is a framework for building user interfaces."),
        responseError: nil
    )
    
    static var previews: some View {
        NavigationStack {
            ScrollView {
                MessageRowView(message: message) { _ in }
            }
            .previewLayout(.sizeThatFits)
        }
    }
}
