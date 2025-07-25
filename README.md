# Pusulam - AI Destekli Plan Oluşturucu

Gemini AI ile kişiselleştirilmiş planlar oluşturan cross-platform uygulama.

## 📱 Proje Yapısı

Bu proje mono-repo yapısında organize edilmiştir:

```
pusulam/
├── pusulam_backend/     # FastAPI Backend
│   ├── main.py         # Ana API dosyası
│   ├── requirements.txt # Python bağımlılıkları
│   ├── .env           # Çevre değişkenleri (dahil edilmez)
│   └── README.md      # Backend dokümantasyonu
├── pusulam_mobile/     # Flutter Mobil Uygulama
│   ├── lib/           # Dart kaynak kodları
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

### Backend
- **FastAPI** - Modern Python web framework
- **Gemini AI** - Google'ın yapay zeka modeli
- **Uvicorn** - ASGI server
- **Python-dotenv** - Environment variables

### Mobil
- **Flutter** - Cross-platform framework
- **Dart** - Programlama dili
- **Material 3** - Modern UI tasarım sistemi

## 🎯 Özellikler

- 🤖 **AI Destekli Planlar**: Gemini AI ile akıllı plan oluşturma
- 📚 **Çoklu Tema**: Eğitim, sağlık, sürdürülebilirlik, turizm
- 📱 **Cross-Platform**: Android ve iOS desteği
- 🔄 **RESTful API**: Temiz ve düzenli API yapısı
- 🎨 **Modern UI**: Material 3 tasarım sistemi
- 🌙 **Dark/Light Mode**: Tema desteği

## 📋 Geliştirme Durumu

- [x] Backend API yapısı
- [x] Gemini AI entegrasyonu
- [x] Flutter temel yapısı
- [x] Constants ve konfigürasyon
- [ ] API servisleri
- [ ] Plan oluşturma UI
- [ ] Plan görüntüleme
- [ ] Yerel veri saklama
- [ ] Bildirimler

## 🔑 API Endpoints

- `GET /` - Ana sayfa
- `GET /api/health` - Sağlık kontrolü
- `GET /api/test` - Test endpoint
- `POST /api/generate-plan` - Plan oluşturma
- `GET /docs` - Swagger UI

## 🛠️ Geliştirme

### Git Workflow
```bash
git add .
git commit -m "feat: yeni özellik"
git push origin main
```

### API Test
```bash
curl http://localhost:8000/api/health
```

### Flutter Test
```bash
cd pusulam_mobile
flutter test
```

## 📄 Lisans

Bu proje MIT lisansı altındadır.

## 👥 Katkıda Bulunma

1. Fork edin
2. Feature branch oluşturun (`git checkout -b feature/yeni-ozellik`)
3. Commit atın (`git commit -am 'feat: yeni özellik eklendi'`)
4. Push yapın (`git push origin feature/yeni-ozellik`)
5. Pull Request oluşturun

## 📞 İletişim

Proje sahibi: Kubicix
Email: [email]
GitHub: [github-username]
