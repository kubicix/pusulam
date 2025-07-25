# Pusulam Backend

Gemini AI ile kişiselleştirilmiş planlar oluşturan FastAPI backend servisi.

## Özellikler

- 🤖 Gemini AI entegrasyonu
- 📚 Eğitim planları oluşturma
- 🏃‍♂️ Sağlık ve fitness planları
- 🌱 Sürdürülebilirlik planları
- ✈️ Turizm ve gezi planları
- 🔄 RESTful API
- 📝 Otomatik API dokümantasyonu (Swagger UI)

## Kurulum

### 1. Gereksinimleri Yükleyin
```bash
pip install -r requirements.txt
```

### 2. Gemini API Anahtarı Alın
1. [Google AI Studio](https://aistudio.google.com/app/apikey) adresine gidin
2. API anahtarınızı oluşturun
3. `.env` dosyasında `GEMINI_API_KEY` değişkenine anahtarınızı yazın

### 3. Çevre Değişkenlerini Ayarlayın
`.env` dosyasını düzenleyin:
```env
GEMINI_API_KEY=your_actual_api_key_here
```

### 4. Uygulamayı Başlatın
```bash
uvicorn main:app --reload
```

## API Endpoint'leri

### Ana Endpoint'ler
- `GET /` - Ana sayfa
- `GET /api/health` - Sağlık kontrolü
- `GET /api/test` - Test endpoint'i
- `POST /api/generate-plan` - Plan oluşturma

### Dokümantasyon
- `GET /docs` - Swagger UI
- `GET /redoc` - ReDoc dokümantasyonu

## Plan Oluşturma API Kullanımı

### POST /api/generate-plan

**İstek Formatı:**
```json
{
  "goal": "3 haftada başlangıç seviyesi Python öğrenmek istiyorum",
  "theme": "eğitim",
  "duration": "3 hafta",
  "daily_time": "1 saat"
}
```

**Desteklenen Temalar:**
- `eğitim` - Eğitim ve öğrenme planları
- `sağlık` - Sağlık ve fitness planları
- `sürdürülebilirlik` - Çevre dostu yaşam planları
- `turizm` - Gezi ve turizm planları

**Yanıt Formatı:**
```json
{
  "success": true,
  "generated_plan": {
    "plan_title": "3 Haftalık Python Öğrenme Planı",
    "total_duration": "3 hafta",
    "daily_time": "1 saat",
    "theme": "eğitim",
    "plan": {
      "hafta_1": [
        {
          "gun": "1-2",
          "konu": "Python Temelleri",
          "aciklama": "Değişkenler, veri tipleri ve operatörler",
          "gorevler": ["Python kurulumu", "İlk 'Merhaba Dünya' programı"],
          "kaynaklar": ["Python.org tutorial", "W3Schools Python"]
        }
      ]
    },
    "genel_ipuclari": ["Düzenli pratik yapın", "Projeler geliştirin"],
    "basari_kriterleri": ["Temel syntax'ı öğrenme", "Basit program yazabilme"]
  },
  "timestamp": "2025-07-25T10:30:00"
}
```

## Geliştirme

### Lokal Geliştirme
```bash
# Geliştirme modunda başlatma
uvicorn main:app --reload --host 0.0.0.0 --port 8000

# Test etme
curl http://localhost:8000/api/health
```

### Git Kullanımı
```bash
# Repository'yi başlatma
git init
git add .
git commit -m "Initial commit"

# GitHub'a yükleme
git remote add origin <your-repo-url>
git push -u origin main
```

## Güvenlik
- `.env` dosyası `.gitignore`'da yer alır
- API anahtarları asla commit edilmez
- Production ortamında environment variables kullanın

## Teknolojiler
- **FastAPI** - Modern, hızlı web framework
- **Gemini AI** - Google'ın yapay zeka modeli
- **Pydantic** - Veri validasyonu
- **Uvicorn** - ASGI server
- **Python-dotenv** - Environment variables yönetimi

## Lisans
Bu proje MIT lisansı altındadır.
