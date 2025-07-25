import 'package:shared_preferences/shared_preferences.dart';
import '../models/plan.dart';

class PlanStorageService {
  static const String _plansKey = 'saved_plans';
  static const String _planCountKey = 'plan_count';

  // Singleton pattern
  static final PlanStorageService _instance = PlanStorageService._internal();
  factory PlanStorageService() => _instance;
  PlanStorageService._internal();

  // Tüm planları getir
  Future<List<Plan>> getAllPlans() async {
    try {
      print('🔍 Plan Storage: SharedPreferences erişimi başlatılıyor...');
      final prefs = await SharedPreferences.getInstance();
      final plansJson = prefs.getStringList(_plansKey) ?? [];
      
      print('🔍 Plan Storage: SharedPreferences\'tan ${plansJson.length} plan JSON\'ı bulundu');
      
      if (plansJson.isEmpty) {
        print('⚠️ Plan Storage: Hiç plan bulunamadı!');
        return [];
      }
      
      List<Plan> plans = [];
      for (int i = 0; i < plansJson.length; i++) {
        try {
          final plan = Plan.fromJsonString(plansJson[i]);
          plans.add(plan);
          print('✅ Plan Storage: Plan ${i + 1} başarıyla yüklendi: ${plan.title}');
        } catch (e) {
          print('❌ Plan Storage: Plan ${i + 1} yüklenirken hata: $e');
        }
      }
      
      // Kronolojik sıralama (en yeni en üstte)
      plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('📊 Plan Storage: Toplam ${plans.length} plan başarıyla yüklendi');
      return plans;
    } catch (e) {
      print('❌ Plan Storage: Plan okuma hatası: $e');
      return [];
    }
  }

  // Plan kaydet
  Future<bool> savePlan(Plan plan) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPlans = await getAllPlans();
      
      // Aynı ID'li plan varsa güncelle, yoksa ekle
      final existingIndex = existingPlans.indexWhere((p) => p.id == plan.id);
      if (existingIndex != -1) {
        existingPlans[existingIndex] = plan;
      } else {
        existingPlans.add(plan);
      }
      
      // JSON string listesine çevir
      final plansJson = existingPlans
          .map((plan) => plan.toJsonString())
          .toList();
      
      // Kaydet
      await prefs.setStringList(_plansKey, plansJson);
      await _updatePlanCount(existingPlans.length);
      
      return true;
    } catch (e) {
      print('Plan kaydetme hatası: $e');
      return false;
    }
  }

  // Plan sil
  Future<bool> deletePlan(String planId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingPlans = await getAllPlans();
      
      existingPlans.removeWhere((plan) => plan.id == planId);
      
      final plansJson = existingPlans
          .map((plan) => plan.toJsonString())
          .toList();
      
      await prefs.setStringList(_plansKey, plansJson);
      await _updatePlanCount(existingPlans.length);
      
      return true;
    } catch (e) {
      print('Plan silme hatası: $e');
      return false;
    }
  }

  // Belirli bir planı getir
  Future<Plan?> getPlanById(String planId) async {
    try {
      final plans = await getAllPlans();
      return plans.firstWhere(
        (plan) => plan.id == planId,
        orElse: () => throw StateError('Plan bulunamadı'),
      );
    } catch (e) {
      print('Plan getirme hatası: $e');
      return null;
    }
  }

  // Tüm planları sil
  Future<bool> clearAllPlans() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_plansKey);
      await prefs.remove(_planCountKey);
      return true;
    } catch (e) {
      print('Tüm planları silme hatası: $e');
      return false;
    }
  }

  // Plan sayısını getir
  Future<int> getPlanCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_planCountKey) ?? 0;
    } catch (e) {
      print('Plan sayısı getirme hatası: $e');
      return 0;
    }
  }

  // Plan sayısını güncelle
  Future<void> _updatePlanCount(int count) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_planCountKey, count);
    } catch (e) {
      print('Plan sayısı güncelleme hatası: $e');
    }
  }

  // Planları temaya göre filtrele
  Future<List<Plan>> getPlansByTheme(String theme) async {
    try {
      final allPlans = await getAllPlans();
      return allPlans.where((plan) => plan.theme == theme).toList();
    } catch (e) {
      print('Tema filtreleme hatası: $e');
      return [];
    }
  }

  // Son N planı getir
  Future<List<Plan>> getRecentPlans(int count) async {
    try {
      final allPlans = await getAllPlans();
      return allPlans.take(count).toList();
    } catch (e) {
      print('Son planları getirme hatası: $e');
      return [];
    }
  }

  // Storage durumunu kontrol et
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final planCount = await getPlanCount();
      final plans = await getAllPlans();
      final totalSize = plans.fold<int>(
        0, 
        (sum, plan) => sum + plan.toJsonString().length,
      );
      
      return {
        'planCount': planCount,
        'totalSizeBytes': totalSize,
        'themes': plans.map((p) => p.theme).toSet().toList(),
        'oldestPlan': plans.isNotEmpty ? plans.last.createdAt : null,
        'newestPlan': plans.isNotEmpty ? plans.first.createdAt : null,
      };
    } catch (e) {
      print('Storage bilgisi alma hatası: $e');
      return {};
    }
  }
}
