<img width="3780" height="1890" alt="PUSULAM(2)" src="https://github.com/user-attachments/assets/56401d38-2c8c-4216-80cf-bd3f926f979d" />

# 🏆 Pusulam - AI Destekli Plan Oluşturucu
*BTK Akademi Hackathon 2025 Yarışması Projesi*

**Gemini AI** ile kişiselleştirilmiş planlar oluşturan cross-platform uygulama.

## 🎯 Hackathon 2025 Uyumluluğu

### ✅ Yarışma Gereksinimlerini Karşılama:
- **🤖 Gemini AI Kullanımı**: Projenin ana işlevi olan plan oluşturma özelliği tamamen **Gemini 1.5 Flash** modeli ile çalışır
- **📱 Cross-Platform Uygulama**: Flutter ile hem Android hem iOS desteği
- **🌐 RESTful API**: FastAPI ile modern backend mimarisi
- **📦 Tam Teslimat Paketi**: GitHub kodları + Canlı demo + Proje dokümantasyonu

## 📱 Proje Yapısı

Bu proje mono-repo yapısında organize edilmiştir:

```
pusulam/
├── pusulam_backend/     # FastAPI Backend (Gemini AI Entegrasyonu)
│   ├── main.py         # Ana API - Gemini modeli entegrasyonu
│   ├── requirements.txt # Python bağımlılıkları
│   ├── .env           # Gemini API Key konfigürasyonu
│   └── README.md      # Backend dokümantasyonu
├── pusulam_mobile/     # Flutter Cross-Platform Uygulama
│   ├── lib/           # Dart kaynak kodları
│   ├── services/      # API servisleri ve veri yönetimi
│   ├── providers/     # State management (Provider pattern)
│   ├── screens/       # UI ekranları ve kullanıcı deneyimi
│   ├── models/        # Veri modelleri
│   ├── pubspec.yaml   # Flutter bağımlılıkları
│   └── README.md      # Mobil uygulama dokümantasyonu
└── README.md          # Bu dosya
```

## 🚀 Hızlı Başlangıç

### Backend Kurulumu
```bash
cd pusulam_backend
pip install -r requirements.txt
# .env dosyasında GEMINI_API_KEY'inizi ayarlayın
uvicorn main:app --reload
```

### Mobil Uygulama Kurulumu
```bash
cd pusulam_mobile
flutter pub get
flutter run
```

## 🔧 Teknolojiler

### Backend (Gemini AI Core)
- **FastAPI** - Modern Python web framework
- **Gemini 1.5 Flash** - Projemize uygun hızlı AI modeli (hız odaklı seçim) ⭐
- **Google GenerativeAI** - Gemini API entegrasyonu
- **Uvicorn** - ASGI server
- **Python-dotenv** - Environment variables

### Mobil (Cross-Platform)
- **Flutter** - Cross-platform framework
- **Dart** - Programlama dili
- **Provider** - State management
- **HTTP** - API iletişimi
- **Material 3** - Modern UI tasarım sistemi

## 🎯 Ana Özellikler

- 🤖 **Gemini AI Destekli Plan Oluşturma**: Ana işlev - Gemini ile akıllı, kişiselleştirilmiş planlar
- 📚 **Çoklu Tema Desteği**: Eğitim, sağlık, sürdürülebilirlik, turizm alanlarında planlar
- 📱 **Cross-Platform**: Android ve iOS tam desteği
- 🔄 **RESTful API**: Temiz ve ölçeklenebilir API mimarisi
- 🎨 **Modern UI/UX**: Material 3 tasarım sistemi
- 🌙 **Dark/Light Mode**: Kullanıcı tercihi tema desteği
- 💾 **Yerel Veri Saklama**: Planların offline erişimi
- 🔔 **Akıllı Bildirimler**: Plan takibi ve hatırlatmalar

## 📋 Geliştirme Durumu ✅

- [x] **Backend API Yapısı** - Tamamlandı
- [x] **Gemini AI Entegrasyonu** - Aktif ve çalışır durumda
- [x] **Flutter Temel Yapısı** - Cross-platform hazır
- [x] **API Servisleri** - HTTP iletişimi kuruldu
- [x] **State Management** - Provider pattern uygulandı
- [x] **UI/UX Tasarımı** - Material 3 entegrasyonu
- [x] **Plan Oluşturma Sistemi** - Gemini ile çalışır durumda
- [x] **Tema Sistemi** - Dark/Light mode desteği
- [x] **Veri Modelleri** - API Response yapıları
- [x] **Yerel Veri Saklama** - SharedPreferences entegrasyonu

## 🔑 API Endpoints

### Gemini AI Endpoints
- `POST /api/generate-plan` - **Ana özellik**: Gemini AI ile kişiselleştirilmiş plan oluşturma
- `POST /api/chat` - Gemini ile etkileşimli sohbet sistemi

### Sistem Endpoints
- `GET /` - Ana sayfa ve proje bilgileri
- `GET /api/health` - Sistem sağlık durumu ve Gemini bağlantı kontrolü
- `GET /api/test` - API test endpoint'i
- `GET /docs` - Swagger UI - API dokümantasyonu

## 🎪 Demo ve Test

### 🌐 Canlı Demo
- **Backend API**: `http://localhost:8000` (yerel geliştirme)
- **Swagger UI**: `http://localhost:8000/docs` (API test arayüzü)
- **Mobil App**: Flutter ile Android/iOS cihazlarda çalışır

### 🧪 API Test Örneği
```bash
# Sistem durumu kontrolü
curl http://localhost:8000/api/health

# Gemini AI ile plan oluşturma
curl -X POST "http://localhost:8000/api/generate-plan" \
  -H "Content-Type: application/json" \
  -d '{
    "goal": "3 haftada Python öğrenmek",
    "theme": "eğitim",
    "duration": "3 hafta",
    "daily_time": "2 saat"
  }'
```

## 🏆 Hackathon 2025 Teslimat Paketi

### 📦 Teslim Edilecek Materyaller:
1. **✅ GitHub Kodları**: Tüm kaynak kodlar bu repository'de
2. **✅ Proje Açıklaması**: Bu README dosyası + teknik dokümantasyon
3. **✅ Canlı Demo**: Yerel kurulum + API test arayüzü

### 🎯 Gemini AI Kullanım Kanıtı:
- Backend'de `google.generativeai` kütüphanesi entegrasyonu
- Plan oluşturma algoritması tamamen Gemini 1.5 Flash modeli ile çalışır
- API endpoint'lerinde Gemini'nin doğrudan kullanımı
- Kişiselleştirilmiş içerik üretimi için Gemini'nin üretken AI yetenekleri

## 🛠️ Geliştirme Süreci

### Git Workflow
```bash
git add .
git commit -m "feat: Gemini entegrasyonu ile plan oluşturma"
git push origin master
```

### Yerel Geliştirme
```bash
# Backend çalıştırma
cd pusulam_backend
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Mobil uygulama (Android)
cd pusulam_mobile
flutter run

# Mobil uygulama (iOS)
flutter run -d ios
```

## 🚀 Gelecek Hedefler

- [ ] **Gelişmiş Gemini Prompts**: Daha detaylı ve özelleştirilebilir plan şablonları
- [ ] **Multi-Modal AI**: Görsel ve ses destekli plan oluşturma
- [ ] **Sosyal Özellikler**: Plan paylaşımı ve topluluk etkileşimi
- [ ] **Analytics Dashboard**: Plan başarı takibi ve AI insights
- [ ] **Offline Mode**: İnternet bağlantısı olmadan temel özellikler

## 📊 Proje Metrikleri

- **📁 Toplam Kod Satırı**: ~2000+ satır
- **🔧 API Endpoint'leri**: 6 aktif endpoint
- **📱 Platform Desteği**: Android + iOS
- **🤖 AI Entegrasyonu**: %100 Gemini tabanlı
- **⚡ Performans**: <2 saniye plan oluşturma süresi

## 📄 Lisans

Bu proje MIT lisansı altındadır. Hackathon 2025 yarışması kapsamında geliştirilmiştir.

## 👥 Geliştirici

**Kubicix** - *Full Stack Developer*
- 🎯 Hackathon 2025 Katılımcısı
- 🚀 AI & Cross-Platform Geliştirici
- 📧 Email: kubilaybirer@hotmail.com
- 🔗 GitHub: [@kubicix](https://github.com/kubicix)

## 🏅 Hackathon 2025 Taahhütü

Bu proje, **BTK Akademi Hackathon 2025** yarışması için geliştirilmiştir ve aşağıdaki kriterleri karşılamaktadır:

✅ **Gemini AI ana özellik olarak kullanılmaktadır**  
✅ **Tema uyumluluğu** (eğitim, sağlık, sürdürülebilirlik, turizm)  
✅ **Özgün geliştirme** - Tamamen kendi çabamızla geliştirildi  
✅ **Tam teslimat paketi** hazır  
✅ **Canlı demo** mevcut  

---
*"AI ile geleceği planlıyoruz, Pusulam ile hedefe ulaşıyoruz!"* 🧭✨
