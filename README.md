🚀 Map Mate-AI

Yapay Zeka Destekli Konum Asistanınız! 🌍

Map Mate-AI, gerçek zamanlı konum verileri ve yapay zeka destekli öneriler sunarak, kullanıcıların günlük yaşamını ve seyahatlerini kolaylaştırmak için geliştirilmiş bir mobil uygulamadır.

📱 iOS 16+ için Swift ile geliştirilmiştir.
🌐 Türkçe ve İngilizce dil desteği vardır.
🤖 Yapay zeka servisleriyle entegre çalışır.

⸻

✨ Neden Map Mate-AI?
	•	Bu akşam nereye gitmeliyim? → AI, yakın mekanları ve tercihlerini analiz ederek öneri verir.
	•	Yakınımda hastane, eczane, ATM var mı? → Gerçek zamanlı API’lerden en güncel sonuçları getirir.
	•	Ellerim dolu, sesli arama yapabilir miyim? → Evet, Siri benzeri sesli komutlarla çalışır.
	•	Çok mu karmaşık? → Hayır, sade bir arayüz ile 2 dokunuşta ihtiyacın olan her şeye ulaşabilirsin.

⸻

🏗 Projenin Temel Mimarisi

Map Mate-AI, MVVM (Model-View-ViewModel) mimarisi ile geliştirilmiştir.
	•	Model: Mekan, kullanıcı konumu ve AI önerilerini temsil eden veri modelleri
	•	View: SwiftUI / UIKit tabanlı kullanıcı arayüzü
	•	ViewModel: API çağrılarını ve veri işleme mantığını yöneten katman
	•	Services:
	•	LocationService → CoreLocation ile konum takibi
	•	PlacesService → Yakın mekanlar için harici API’ler
	•	AIService → OpenAI veya özel LLM servislerine istekler
	•	VoiceService → Sesli komut desteği

⸻

🛠 Kullanılan Teknolojiler
	•	Swift 5.x – Ana geliştirme dili
	•	CoreLocation & MapKit – Konum ve harita yönetimi
	•	URLSession / Alamofire – API istekleri
	•	AI API (OpenAI / LLM) – Akıllı öneriler
	•	Speech Framework – Sesli komutlar
	•	Localization (.strings) – Çok dilli destek
	•	Keychain / UserDefaults – Hafif veri depolama

⸻

📡 Harici API’ler
	•	Google Places API → Yakındaki mekanlar
	•	Nöbetçi Eczane API → En güncel sağlık hizmeti bilgileri
	•	Yapay Zeka API → Kullanıcıya özel öneriler

⸻

🔐 Güvenlik ve Gizlilik
	•	Kullanıcı konumu yalnızca uygulama içi öneriler için alınır, sunucuya kaydedilmez.
	•	API anahtarları .xcconfig dosyasında tutulur ve public repo’da paylaşılmaz.
	•	Kullanıcı verileri cihazda şifreli olarak saklanır.

⸻

📲 Kullanıcı Akışı

1️⃣ Konum İzni Alınır
Uygulama, sadece gerekli olduğunda konuma erişir.

2️⃣ Kullanıcı Komutu Alınır
	•	“Yakınımdaki ATM’leri göster”
	•	“Bu akşam nereye gitmeliyim?”

3️⃣ AI & Konum API’leri Çalışır
	•	Gerçek zamanlı konum verisi alınır
	•	Yakındaki mekanlar listelenir
	•	AI tarafından öneriler sıralanır

4️⃣ Sonuç Kullanıcıya Gösterilir
Harita üzerinde işaretlenmiş konumlar + AI önerisi

⸻

🖼 Kullanıcı Arayüzü
	•	Ana Ekran: Hızlı arama ve AI önerileri
	•	Harita Görünümü: Yakındaki mekanları filtreleyerek görme
	•	Sesli Arama: Eller serbest kullanım
	•	AI Önerileri: Günlük 5 ücretsiz öneri

⸻

🚀 Gelecek Planları
	•	✅ Favori Mekanlar Listesi
	•	✅ Offline Mod
	•	✅ Android Desteği
	•	⏳ Apple Watch Uygulaması

⸻

📱 Yayında
	•	App Store: 👉 Şimdi İndir  https://apps.apple.com/tr/app/map-mateai-navigate-with-chat/id6740746255?l=tr
	•	Demo Videosu: 🎥 İzle https://www.youtube.com/watch?v=7dfwLjxD-sc&t=5s&ab_channel=Erkin
