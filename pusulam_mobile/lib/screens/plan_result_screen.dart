import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_themes.dart';
import '../models/plan.dart';
import '../services/plan_storage_service.dart';

class PlanResultScreen extends StatefulWidget {
  final Map<String, dynamic> planData;
  final String timestamp;

  const PlanResultScreen({
    super.key,
    required this.planData,
    required this.timestamp,
  });

  @override
  State<PlanResultScreen> createState() => _PlanResultScreenState();
}

class _PlanResultScreenState extends State<PlanResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final _storageService = PlanStorageService();
  bool _isPlanSaved = false;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    // Planı otomatik olarak kaydet
    _savePlanToStorage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final padding = isTablet ? 32.0 : 16.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Planınız Hazır!',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true), // Plan kaydedildiğini belirt
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePlan,
            tooltip: 'Paylaş',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Kopyala'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save_txt',
                child: Row(
                  children: [
                    Icon(Icons.text_snippet),
                    SizedBox(width: 8),
                    Text('TXT olarak kaydet'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  theme.colorScheme.primary.withOpacity(0.05),
                  theme.colorScheme.surface,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(padding),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 800 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPlanHeader(theme),
                      SizedBox(height: screenSize.height * 0.03),
                      _buildPlanContent(theme),
                      SizedBox(height: screenSize.height * 0.03),
                      _buildTipsAndCriteria(theme),
                      SizedBox(height: screenSize.height * 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanHeader(ThemeData theme) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final planTitle = widget.planData['plan_title'] ?? 'Kişisel Plan';
        final totalDuration = widget.planData['total_duration'] ?? '';
        final dailyTime = widget.planData['daily_time'] ?? '';
        final planTheme = widget.planData['theme'] ?? '';

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: CustomColors.primaryGradient(themeProvider.seedColor),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: themeProvider.seedColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                planTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoCard(
                      'Süre',
                      totalDuration,
                      Icons.schedule,
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Günlük',
                      dailyTime,
                      Icons.access_time,
                      Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildInfoCard(
                      'Tema',
                      planTheme,
                      Icons.category,
                      Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanContent(ThemeData theme) {
    final plan = widget.planData['plan'] as Map<String, dynamic>?;
    if (plan == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Detayları',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        ...plan.entries.map((entry) {
          final weekName = entry.key;
          final weekPlan = entry.value as List<dynamic>;
          
          return _buildWeekSection(theme, weekName, weekPlan);
        }).toList(),
      ],
    );
  }

  Widget _buildWeekSection(ThemeData theme, String weekName, List<dynamic> weekPlan) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: CustomColors.cardGradient(themeProvider.seedColor),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: themeProvider.seedColor.withOpacity(0.2),
            ),
          ),
          child: ExpansionTile(
            title: Text(
              weekName.replaceAll('_', ' ').toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: themeProvider.seedColor,
              ),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: themeProvider.seedColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 20,
              ),
            ),
            initiallyExpanded: true,
            children: weekPlan.map((dayPlan) {
              return _buildDayCard(theme, dayPlan as Map<String, dynamic>);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDayCard(ThemeData theme, Map<String, dynamic> dayPlan) {
    final gun = dayPlan['gun'] ?? '';
    final konu = dayPlan['konu'] ?? '';
    final aciklama = dayPlan['aciklama'] ?? '';
    final gorevler = dayPlan['gorevler'] as List<dynamic>? ?? [];
    final kaynaklar = dayPlan['kaynaklar'] as List<dynamic>? ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Gün $gun',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            konu,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            aciklama,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          if (gorevler.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Görevler:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            ...gorevler.map((gorev) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        gorev.toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          if (kaynaklar.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Kaynaklar:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 4),
            ...kaynaklar.map((kaynak) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.link,
                      size: 16,
                      color: theme.colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        kaynak.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.secondary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildTipsAndCriteria(ThemeData theme) {
    final genelIpuclari = widget.planData['genel_ipuclari'] as List<dynamic>? ?? [];
    final basariKriterleri = widget.planData['basari_kriterleri'] as List<dynamic>? ?? [];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (genelIpuclari.isNotEmpty)
          Expanded(
            child: _buildInfoSection(
              theme,
              'Genel İpuçları',
              genelIpuclari,
              Icons.lightbulb,
              theme.colorScheme.tertiary,
            ),
          ),
        if (genelIpuclari.isNotEmpty && basariKriterleri.isNotEmpty)
          const SizedBox(width: 16),
        if (basariKriterleri.isNotEmpty)
          Expanded(
            child: _buildInfoSection(
              theme,
              'Başarı Kriterleri',
              basariKriterleri,
              Icons.emoji_events,
              theme.colorScheme.secondary,
            ),
          ),
      ],
    );
  }

  Widget _buildInfoSection(
    ThemeData theme,
    String title,
    List<dynamic> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: color.withOpacity(0.8),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'copy':
        _copyPlanToClipboard();
        break;
      case 'save_txt':
        _savePlanAsText();
        break;
    }
  }

  void _copyPlanToClipboard() {
    final planText = _generatePlanText();
    Clipboard.setData(ClipboardData(text: planText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plan panoya kopyalandı!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _savePlanAsText() {
    // Bu özellik için file_picker ve path_provider paketleri gerekli
    // Şimdilik sadece kullanıcıyı bilgilendirelim
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kaydetme'),
        content: const Text(
          'Dosya kaydetme özelliği yakında eklenecek. '
          'Şimdilik "Kopyala" seçeneğini kullanabilirsiniz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _sharePlan() {
    // Share özelliği için share_plus paketi gerekli
    // Şimdilik kopyala fonksiyonunu kullanıyoruz
    _copyPlanToClipboard();
  }

  String _generatePlanText() {
    final planTitle = widget.planData['plan_title'] ?? 'Kişisel Plan';
    final totalDuration = widget.planData['total_duration'] ?? '';
    final dailyTime = widget.planData['daily_time'] ?? '';
    final planTheme = widget.planData['theme'] ?? '';
    
    StringBuffer buffer = StringBuffer();
    buffer.writeln('🎯 $planTitle');
    buffer.writeln('');
    buffer.writeln('📅 Süre: $totalDuration');
    buffer.writeln('⏰ Günlük Çalışma: $dailyTime');
    buffer.writeln('🏷️ Tema: $planTheme');
    buffer.writeln('');
    buffer.writeln('═══════════════════════════');
    buffer.writeln('');

    final plan = widget.planData['plan'] as Map<String, dynamic>?;
    if (plan != null) {
      plan.forEach((weekName, weekPlan) {
        buffer.writeln('📅 ${weekName.replaceAll('_', ' ').toUpperCase()}');
        buffer.writeln('');
        
        for (var dayPlan in weekPlan as List<dynamic>) {
          final dayData = dayPlan as Map<String, dynamic>;
          buffer.writeln('🗓️ Gün ${dayData['gun'] ?? ''}');
          buffer.writeln('📚 ${dayData['konu'] ?? ''}');
          buffer.writeln('${dayData['aciklama'] ?? ''}');
          
          final gorevler = dayData['gorevler'] as List<dynamic>? ?? [];
          if (gorevler.isNotEmpty) {
            buffer.writeln('');
            buffer.writeln('✅ Görevler:');
            for (var gorev in gorevler) {
              buffer.writeln('• $gorev');
            }
          }
          
          final kaynaklar = dayData['kaynaklar'] as List<dynamic>? ?? [];
          if (kaynaklar.isNotEmpty) {
            buffer.writeln('');
            buffer.writeln('🔗 Kaynaklar:');
            for (var kaynak in kaynaklar) {
              buffer.writeln('• $kaynak');
            }
          }
          
          buffer.writeln('');
          buffer.writeln('---');
          buffer.writeln('');
        }
      });
    }

    final genelIpuclari = widget.planData['genel_ipuclari'] as List<dynamic>? ?? [];
    if (genelIpuclari.isNotEmpty) {
      buffer.writeln('💡 Genel İpuçları:');
      for (var ipucu in genelIpuclari) {
        buffer.writeln('• $ipucu');
      }
      buffer.writeln('');
    }

    final basariKriterleri = widget.planData['basari_kriterleri'] as List<dynamic>? ?? [];
    if (basariKriterleri.isNotEmpty) {
      buffer.writeln('🏆 Başarı Kriterleri:');
      for (var kriter in basariKriterleri) {
        buffer.writeln('• $kriter');
      }
    }

    buffer.writeln('');
    buffer.writeln('Generated by Pusulam AI Assistant');
    buffer.writeln('Timestamp: ${widget.timestamp}');

    return buffer.toString();
  }

  Future<void> _savePlanToStorage() async {
    try {
      // Plan verilerinden gerekli bilgileri çıkar
      final planTheme = widget.planData['tema'] as String? ?? 'genel';
      final planDuration = widget.planData['sure'] as String? ?? '1 hafta';
      final planDailyTime = widget.planData['gunluk_zaman'] as String? ?? '1 saat';
      
      // Akıllı başlık oluşturma
      final planTitle = _generateSmartTitle(widget.planData, planTheme, planDuration);
      
      // Plan açıklamasını oluştur
      final planDescription = widget.planData['aciklama'] as String? ?? 
          '${planTheme.toUpperCase()} temalı kişiselleştirilmiş plan';
      
      // Plan içeriğini oluştur
      final planContent = _generatePlanText();
      
      // Benzersiz ID oluştur
      final planId = '${DateTime.now().millisecondsSinceEpoch}_${planTitle.hashCode}';
      
      // Plan nesnesi oluştur
      final plan = Plan(
        id: planId,
        title: planTitle,
        description: planDescription,
        theme: planTheme,
        duration: planDuration,
        dailyTime: planDailyTime,
        content: planContent,
        createdAt: DateTime.now(),
      );
      
      // Local storage'a kaydet
      final success = await _storageService.savePlan(plan);
      
      if (success) {
        setState(() => _isPlanSaved = true);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plan başarıyla kaydedildi!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Plan kaydetme hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Plan kaydedilemedi: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Planın içeriğinden akıllı başlık oluşturur
  String _generateSmartTitle(Map<String, dynamic> planData, String theme, String duration) {
    // Önce hedef alanını kontrol et
    final hedef = planData['hedef'] as String?;
    if (hedef != null && hedef.trim().isNotEmpty && hedef.trim() != 'Yeni Plan') {
      return hedef.trim();
    }

    // Plan başlığı alanını kontrol et
    final planTitle = planData['plan_title'] as String?;
    if (planTitle != null && planTitle.trim().isNotEmpty && planTitle.trim() != 'Yeni Plan') {
      return planTitle.trim();
    }

    // Açıklama alanından ilk cümleyi al
    final aciklama = planData['aciklama'] as String?;
    if (aciklama != null && aciklama.trim().isNotEmpty) {
      final firstSentence = aciklama.split('.').first.trim();
      if (firstSentence.length > 10 && firstSentence.length < 80) {
        return firstSentence;
      }
    }

    // Günlük rutinlerden başlık oluştur
    final gunlukRutinler = planData['gunluk_rutinler'];
    if (gunlukRutinler is List && gunlukRutinler.isNotEmpty) {
      final firstRoutine = gunlukRutinler.first;
      if (firstRoutine is String && firstRoutine.trim().length > 10) {
        final title = firstRoutine.trim();
        if (title.length > 50) {
          return '${title.substring(0, 47)}...';
        }
        return title;
      }
    }

    // Öneriler alanından başlık oluştur
    final oneriler = planData['oneriler'];
    if (oneriler is List && oneriler.isNotEmpty) {
      final firstSuggestion = oneriler.first;
      if (firstSuggestion is String && firstSuggestion.trim().length > 10) {
        final title = firstSuggestion.trim();
        if (title.length > 50) {
          return '${title.substring(0, 47)}...';
        }
        return title;
      }
    }

    // Haftalık planlardan başlık oluştur
    final haftalikPlan = planData['haftalik_plan'];
    if (haftalikPlan is Map) {
      final firstWeek = haftalikPlan['Hafta 1'] ?? haftalikPlan['hafta_1'] ?? haftalikPlan.values.first;
      if (firstWeek is Map) {
        final firstDay = firstWeek.values.first;
        if (firstDay is List && firstDay.isNotEmpty) {
          final firstActivity = firstDay.first;
          if (firstActivity is String && firstActivity.trim().length > 10) {
            final title = firstActivity.trim();
            if (title.length > 50) {
              return '${title.substring(0, 47)}...';
            }
            return title;
          }
        }
      }
    }

    // Motivasyon mesajlarından başlık oluştur
    final motivasyon = planData['motivasyon_mesajlari'] ?? planData['motivasyon'];
    if (motivasyon is List && motivasyon.isNotEmpty) {
      final firstMotivation = motivasyon.first;
      if (firstMotivation is String && firstMotivation.trim().length > 10) {
        final title = firstMotivation.trim();
        if (title.length > 50) {
          return '${title.substring(0, 47)}...';
        }
        return title;
      }
    }

    // Tema ve süreye göre varsayılan başlık oluştur
    final themeMap = {
      'eğitim': 'Eğitim Planı',
      'sağlık': 'Sağlık Planı', 
      'sürdürülebilirlik': 'Sürdürülebilirlik Planı',
      'turizm': 'Turizm Planı',
      'genel': 'Kişisel Plan',
    };

    final themeTitle = themeMap[theme.toLowerCase()] ?? 'Kişisel Plan';
    final cleanDuration = duration.replaceAll('hafta', '').trim();
    
    return '$cleanDuration Haftalık $themeTitle';
  }
}
