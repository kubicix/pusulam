import os
import google.generativeai as genai
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv
import json
from datetime import datetime

# .env dosyasındaki değişkenleri yükle
load_dotenv()

# FastAPI uygulamasını başlat
app = FastAPI(
    title="Pusulam API",
    description="Gemini AI ile kişiselleştirilmiş planlar oluşturan backend servisi",
    version="1.0.0"
)

# Gemini API anahtarını ayarla
try:
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        print("UYARI: GEMINI_API_KEY bulunamadı. .env dosyasını kontrol edin.")
        model = None
    else:
        genai.configure(api_key=api_key)
        model = genai.GenerativeModel('gemini-1.5-flash')  # En hızlı modellerden biri
        print("Gemini modeli başarıyla yüklendi.")
except Exception as e:
    print(f"HATA: Gemini modeli yüklenemedi. API anahtarınızı kontrol edin. Hata: {e}")
    model = None

# Flutter'dan gelecek isteğin formatını tanımla
class PlanRequest(BaseModel):
    goal: str  # Örneğin: "3 haftada başlangıç seviyesi Python öğrenmek istiyorum"
    theme: str = "eğitim"  # eğitim, sağlık, sürdürülebilirlik, turizm
    duration: str = "3 hafta"  # süre bilgisi
    daily_time: str = "1 saat"  # günlük ayırabileceği zaman

# Sağlık kontrolü endpoint'i
@app.get("/api/health")
async def health_check():
    """Sistem sağlık durumunu kontrol eden endpoint"""
    return {
        "status": "healthy" if model else "partial",
        "timestamp": datetime.now().isoformat(),
        "gemini_status": "connected" if model else "disconnected",
        "message": "Pusulam Backend çalışıyor!"
    }

# Ana endpoint
@app.get("/")
def read_root():
    return {
        "message": "Pusulam Backend'i çalışıyor!",
        "version": "1.0.0",
        "endpoints": {
            "health": "/api/health",
            "generate_plan": "/api/generate-plan",
            "docs": "/docs"
        }
    }

# Test endpoint'i
@app.get("/api/test")
async def test_endpoint():
    return {
        "status": "success", 
        "message": "API test endpoint çalışıyor!",
        "gemini_available": model is not None
    }

# Ana plan oluşturma endpoint'i
@app.post("/api/generate-plan")
async def generate_plan(request: PlanRequest):
    if not model:
        raise HTTPException(
            status_code=503, 
            detail="Gemini modeli yüklenemediği için işlem yapılamıyor. API anahtarını kontrol edin."
        )

    print(f"Alınan hedef: {request.goal}")
    print(f"Tema: {request.theme}")

    # Temaya göre özelleştirilmiş prompt hazırla
    theme_prompts = {
        "eğitim": """
        Bir eğitim planı oluştur. Konuları mantıklı sırayla düzenle, 
        her gün için pratik örnekler ve kaynaklar öner.
        """,
        "sağlık": """
        Sağlıklı yaşam planı oluştur. Egzersizler, beslenme önerileri ve 
        dinlenme zamanlarını dahil et.
        """,
        "sürdürülebilirlik": """
        Çevre dostu yaşam planı oluştur. Karbon ayak izini azaltacak 
        günlük eylemler ve alışkanlıklar öner.
        """,
        "turizm": """
        Detaylı gezi planı oluştur. Ziyaret edilecek yerler, ulaşım, 
        yerel lezzetler ve bütçe önerilerini dahil et.
        """
    }

    theme_instruction = theme_prompts.get(request.theme, theme_prompts["eğitim"])

    # Gemini için prompt'u hazırla
    prompt = f"""
    Kullanıcının hedefi: '{request.goal}'.
    Tema: {request.theme}
    Süre: {request.duration}
    Günlük ayırabileceği zaman: {request.daily_time}
    
    {theme_instruction}
    
    Bu hedefe uygun, haftalara/günlere bölünmüş, detaylı bir eylem planı oluştur.
    Cevabı mutlaka JSON formatında ver. Sadece JSON döndür, başka metin ekleme.

    JSON formatı:
    {{
      "plan_title": "Plan başlığı",
      "total_duration": "{request.duration}",
      "daily_time": "{request.daily_time}",
      "theme": "{request.theme}",
      "plan": {{
        "hafta_1": [
          {{
            "gun": "1-2",
            "konu": "Konu başlığı",
            "aciklama": "Detaylı açıklama",
            "gorevler": ["Görev 1", "Görev 2"],
            "kaynaklar": ["Kaynak 1", "Kaynak 2"]
          }}
        ],
        "hafta_2": [
          {{
            "gun": "8-10",
            "konu": "Konu başlığı",
            "aciklama": "Detaylı açıklama",
            "gorevler": ["Görev 1", "Görev 2"],
            "kaynaklar": ["Kaynak 1", "Kaynak 2"]
          }}
        ]
      }},
      "genel_ipuclari": ["İpucu 1", "İpucu 2"],
      "basari_kriterleri": ["Kriter 1", "Kriter 2"]
    }}
    """

    try:
        # Gemini'den cevabı al
        response = model.generate_content(prompt)
        response_text = response.text.strip()
        
        # JSON formatını temizle (eğer ```json ile sarılmışsa)
        if response_text.startswith("```json"):
            response_text = response_text[7:-3]
        elif response_text.startswith("```"):
            response_text = response_text[3:-3]
        
        # JSON'ı parse et
        try:
            parsed_plan = json.loads(response_text)
            return {
                "success": True,
                "generated_plan": parsed_plan,
                "timestamp": datetime.now().isoformat()
            }
        except json.JSONDecodeError:
            # Eğer JSON parse edilemezse, raw text döndür
            return {
                "success": True,
                "generated_plan": {"raw_response": response_text},
                "timestamp": datetime.now().isoformat(),
                "note": "JSON formatında parse edilemedi, ham cevap döndürüldü"
            }
            
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Gemini'den cevap alınırken bir hata oluştu: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
