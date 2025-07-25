import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/plan.dart';
import '../providers/theme_provider.dart';
import '../services/plan_storage_service.dart';

class PlanDetailScreen extends StatefulWidget {
  final Plan plan;
  final VoidCallback? onPlanDeleted;

  const PlanDetailScreen({
    super.key,
    required this.plan,
    this.onPlanDeleted,
  });

  @override
  State<PlanDetailScreen> createState() => _PlanDetailScreenState();
}

class _PlanDetailScreenState extends State<PlanDetailScreen>
    with TickerProviderStateMixin {
  final _storageService = PlanStorageService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Map<String, dynamic>? _parsedPlan;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _parsePlanContent();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
  }

  void _parsePlanContent() {
    try {
      // Plan içeriğini analiz etmeye çalış
      final content = widget.plan.content;
      
      // JSON formatında parse etmeye çalış (yeni planlar için)
      if (content.startsWith('{') || content.contains('"plan"')) {
        // JSON parse denemesi - bu başarısız olacak çünkü content text formatında
        // Metin tabanlı parsing'e geç
      }
      
      // Metin tabanlı parsing
      final lines = content.split('\n');
      final weeks = <String, List<Map<String, dynamic>>>{};
      final tips = <String>[];
      final criteria = <String>[];
      
      String? currentWeek;
      Map<String, dynamic>? currentDayData;
      bool inTips = false;
      bool inCriteria = false;
      bool inGorevler = false;
      bool inKaynaklar = false;
      
      for (final line in lines) {
        final trimmedLine = line.trim();
        
        if (trimmedLine.isEmpty) continue;
        
        // İpuçları bölümü tespiti
        if (trimmedLine.toLowerCase().contains('genel ipuç') || 
            trimmedLine.toLowerCase().contains('öneriler') ||
            trimmedLine.toLowerCase().contains('ipuçları')) {
          inTips = true;
          inCriteria = false;
          inGorevler = false;
          inKaynaklar = false;
          currentWeek = null;
          currentDayData = null;
          continue;
        }
        
        // Kriterler bölümü tespiti
        if (trimmedLine.toLowerCase().contains('başarı kriter') || 
            trimmedLine.toLowerCase().contains('değerlendirme') ||
            trimmedLine.toLowerCase().contains('ölçütler')) {
          inCriteria = true;
          inTips = false;
          inGorevler = false;
          inKaynaklar = false;
          currentWeek = null;
          currentDayData = null;
          continue;
        }
        
        // Hafta tespiti
        if (trimmedLine.toLowerCase().contains('hafta') && 
            (trimmedLine.startsWith('#') || trimmedLine.startsWith('**') || 
             trimmedLine.contains(':') || trimmedLine.toLowerCase().startsWith('hafta'))) {
          // Önceki günü kaydet
          if (currentWeek != null && currentDayData != null) {
            weeks[currentWeek] = weeks[currentWeek] ?? [];
            weeks[currentWeek]!.add(currentDayData);
          }
          
          currentWeek = trimmedLine
              .replaceAll('#', '')
              .replaceAll('*', '')
              .replaceAll(':', '')
              .trim();
          currentDayData = null;
          inTips = false;
          inCriteria = false;
          inGorevler = false;
          inKaynaklar = false;
          continue;
        }
        
        // Gün tespiti
        if (trimmedLine.toLowerCase().contains('gün') && 
            (trimmedLine.startsWith('#') || trimmedLine.startsWith('**') || 
             trimmedLine.contains(':') || RegExp(r'gün\s*\d+').hasMatch(trimmedLine.toLowerCase()))) {
          // Önceki günü kaydet
          if (currentWeek != null && currentDayData != null) {
            weeks[currentWeek] = weeks[currentWeek] ?? [];
            weeks[currentWeek]!.add(currentDayData);
          }
          
          // Gün numarasını çıkar
          final gunMatch = RegExp(r'gün\s*(\d+)', caseSensitive: false).firstMatch(trimmedLine);
          final gunNumarasi = gunMatch?.group(1) ?? trimmedLine.split(' ').last;
          
          currentDayData = {
            'gun': gunNumarasi,
            'konu': '',
            'aciklama': '',
            'gorevler': <String>[],
            'kaynaklar': <String>[],
          };
          inGorevler = false;
          inKaynaklar = false;
          continue;
        }
        
        // İpuçları ve kriterler için madde ekleme
        if (inTips && (trimmedLine.startsWith('-') || trimmedLine.startsWith('•') || trimmedLine.startsWith('*'))) {
          tips.add(trimmedLine.substring(1).trim());
          continue;
        }
        
        if (inCriteria && (trimmedLine.startsWith('-') || trimmedLine.startsWith('•') || trimmedLine.startsWith('*'))) {
          criteria.add(trimmedLine.substring(1).trim());
          continue;
        }
        
        // Görevler ve kaynaklar bölümü tespiti
        if (currentDayData != null) {
          if (trimmedLine.toLowerCase().contains('görev') || 
              trimmedLine.toLowerCase().contains('aktivite') ||
              trimmedLine.toLowerCase().contains('yapılacak')) {
            inGorevler = true;
            inKaynaklar = false;
            continue;
          }
          
          if (trimmedLine.toLowerCase().contains('kaynak') || 
              trimmedLine.toLowerCase().contains('materyal') ||
              trimmedLine.toLowerCase().contains('link')) {
            inKaynaklar = true;
            inGorevler = false;
            continue;
          }
          
          // İçerik ekleme
          if (trimmedLine.startsWith('-') || trimmedLine.startsWith('•') || trimmedLine.startsWith('*')) {
            final content = trimmedLine.substring(1).trim();
            if (inKaynaklar || content.toLowerCase().contains('http') || 
                content.toLowerCase().contains('link') || content.toLowerCase().contains('kaynak')) {
              currentDayData['kaynaklar'].add(content);
            } else if (inGorevler || content.toLowerCase().contains('yap') || 
                       content.toLowerCase().contains('öğren') || content.toLowerCase().contains('çalış')) {
              currentDayData['gorevler'].add(content);
            } else {
              // Varsayılan olarak görev olarak ekle
              currentDayData['gorevler'].add(content);
            }
          } else {
            // Konu ve açıklama
            if (currentDayData['konu'].isEmpty && !inGorevler && !inKaynaklar) {
              currentDayData['konu'] = trimmedLine;
            } else if (currentDayData['aciklama'].isEmpty && !inGorevler && !inKaynaklar) {
              currentDayData['aciklama'] = trimmedLine;
            }
          }
        }
      }
      
      // Son günü ekle
      if (currentWeek != null && currentDayData != null) {
        weeks[currentWeek] = weeks[currentWeek] ?? [];
        weeks[currentWeek]!.add(currentDayData);
      }
      
      _parsedPlan = {
        'plan': weeks,
        'genel_ipuclari': tips,
        'basari_kriterleri': criteria,
      };
      
      print('📊 Parse edilen plan yapısı:');
      print('Hafta sayısı: ${weeks.length}');
      print('İpucu sayısı: ${tips.length}');
      print('Kriter sayısı: ${criteria.length}');
      
    } catch (e) {
      print('❌ Plan parsing error: $e');
      _parsedPlan = null;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final padding = isTablet ? 32.0 : 16.0;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.plan.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _sharePlan,
            tooltip: 'Planı Paylaş',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: _copyPlanContent,
            tooltip: 'İçeriği Kopyala',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'delete':
                  _showDeleteDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Planı Sil', style: TextStyle(color: Colors.red)),
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
                      _buildPlanHeader(theme, themeProvider),
                      SizedBox(height: screenSize.height * 0.03),
                      if (_parsedPlan != null) ...[
                        _buildPlanContent(theme, themeProvider),
                        SizedBox(height: screenSize.height * 0.03),
                        _buildTipsAndCriteria(theme, themeProvider),
                      ] else
                        _buildRawContent(theme),
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

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Bugün';
    } else if (difference.inDays == 1) {
      return 'Dün';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks hafta önce';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _sharePlan() {
    final shareText = '''
${widget.plan.title}

${widget.plan.description}

Tema: ${widget.plan.theme}
Süre: ${widget.plan.duration}
Günlük Zaman: ${widget.plan.dailyTime}

Plan İçeriği:
${widget.plan.content}

Pusulam uygulaması ile oluşturuldu.
''';
    
    // Platform share işlemi burada implement edilebilir
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plan panoya kopyalandı!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _copyPlanContent() {
    Clipboard.setData(ClipboardData(text: widget.plan.content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Plan içeriği panoya kopyalandı!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Planı Sil'),
        content: Text(
          '"${widget.plan.title}" planını kalıcı olarak silmek istediğinizden emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deletePlan();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlan() async {
    try {
      final success = await _storageService.deletePlan(widget.plan.id);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plan başarıyla silindi!'),
              backgroundColor: Colors.green,
            ),
          );
          
          widget.onPlanDeleted?.call();
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Plan silinirken bir hata oluştu!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildPlanHeader(ThemeData theme, ThemeProvider themeProvider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            themeProvider.seedColor,
            themeProvider.seedColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: themeProvider.seedColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.plan.theme.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(widget.plan.createdAt),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            widget.plan.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.plan.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildHeaderInfoChip(Icons.schedule, widget.plan.duration),
              const SizedBox(width: 12),
              _buildHeaderInfoChip(Icons.access_time, widget.plan.dailyTime),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanContent(ThemeData theme, ThemeProvider themeProvider) {
    final plan = _parsedPlan!['plan'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan Detayları',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: themeProvider.seedColor,
          ),
        ),
        const SizedBox(height: 16),
        ...plan.entries.map((entry) {
          final weekName = entry.key;
          final weekPlan = entry.value as List<dynamic>;
          
          return _buildWeekSection(theme, themeProvider, weekName, weekPlan);
        }).toList(),
      ],
    );
  }

  Widget _buildWeekSection(ThemeData theme, ThemeProvider themeProvider, String weekName, List<dynamic> weekPlan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            themeProvider.seedColor.withOpacity(0.05),
            Colors.white,
          ],
        ),
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
        children: weekPlan.map<Widget>((dayPlan) {
          return _buildDayCard(theme, dayPlan as Map<String, dynamic>);
        }).toList(),
      ),
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
          if (konu.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              konu,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (aciklama.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              aciklama,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
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
            ...gorevler.map<Widget>((gorev) {
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
            ExpansionTile(
              title: Text(
                'Kaynaklar (${kaynaklar.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.secondary,
                ),
              ),
              leading: Icon(
                Icons.link,
                size: 20,
                color: theme.colorScheme.secondary,
              ),
              initiallyExpanded: false,
              children: kaynaklar.map<Widget>((kaynak) {
                return Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
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
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResourcesSection(ThemeData theme, ThemeProvider themeProvider, List<dynamic> kaynaklar) {
    return ExpansionTile(
      title: Text(
        'Kaynaklar (${kaynaklar.length})',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.secondary,
        ),
      ),
      leading: Icon(
        Icons.link,
        size: 20,
        color: theme.colorScheme.secondary,
      ),
      initiallyExpanded: false,
      children: kaynaklar.map<Widget>((kaynak) {
        return Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.arrow_right,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  kaynak.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTipsAndCriteria(ThemeData theme, ThemeProvider themeProvider) {
    final genelIpuclari = _parsedPlan!['genel_ipuclari'] as List<dynamic>? ?? [];
    final basariKriterleri = _parsedPlan!['basari_kriterleri'] as List<dynamic>? ?? [];

    if (genelIpuclari.isEmpty && basariKriterleri.isEmpty) {
      return const SizedBox.shrink();
    }

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
          ...items.map<Widget>((item) {
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

  Widget _buildRawContent(ThemeData theme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Plan İçeriği',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              widget.plan.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
