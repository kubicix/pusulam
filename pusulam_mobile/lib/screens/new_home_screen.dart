import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/theme_selector.dart';
import '../models/plan.dart';
import '../services/plan_storage_service.dart';
import '../constants.dart';
import 'plan_creation_screen.dart';
import 'plan_detail_screen.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storageService = PlanStorageService();
  List<Plan> _savedPlans = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
    _testConnection();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    try {
      final plans = await _storageService.getAllPlans();
      setState(() {
        _savedPlans = plans;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Plan yükleme hatası: $e');
    }
  }

  Future<void> _testConnection() async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    await chatProvider.testConnection();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pusulam',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatScreen(),
                ),
              );
            },
            tooltip: 'Sohbet',
          ),
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showThemeDialog,
            tooltip: 'Tema Ayarları',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  _loadPlans();
                  break;
                case 'clear_all':
                  _showClearAllDialog();
                  break;
                case 'about':
                  _showAboutDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Yenile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Tüm Planları Temizle', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 8),
                    Text('Hakkında'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPlans,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _savedPlans.isEmpty
                ? _buildWelcomeScreen(themeProvider)
                : _buildPlansScreen(themeProvider),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PlanCreationScreen(),
            ),
          );
          
          if (result == true) {
            _loadPlans(); // Yeni plan oluşturulduysa listeyi yenile
          }
        },
        backgroundColor: themeProvider.seedColor,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.auto_awesome),
        label: const Text(
          'Plan Oluştur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildWelcomeScreen(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          
          // Logo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.seedColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset(
                'assets/images/pusulam_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Hoş geldiniz metni
          Text(
            'Hoş geldiniz!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: themeProvider.seedColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Uygulama açıklaması
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 48,
                  color: themeProvider.seedColor.withOpacity(0.7),
                ),
                const SizedBox(height: 16),
                const Text(
                  AppConstants.appDescription,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Yapay zeka destekli kişiselleştirilmiş planlarla hedeflerinize ulaşın. Eğitim, sağlık, sürdürülebilirlik ve turizm alanlarında size özel planlar oluşturun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // İlk plan oluştur kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.seedColor.withOpacity(0.1),
                  themeProvider.seedColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: themeProvider.seedColor.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rocket_launch,
                  size: 40,
                  color: themeProvider.seedColor,
                ),
                const SizedBox(height: 12),
                Text(
                  'İlk Planınızı Oluşturun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.seedColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hemen başlamak için aşağıdaki "Plan Oluştur" butonuna tıklayın',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 100), // FAB için boşluk
        ],
      ),
    );
  }

  Widget _buildPlansScreen(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // İstatistik kartı
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  themeProvider.seedColor,
                  themeProvider.seedColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.seedColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Toplam Plan Sayısı',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_savedPlans.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getThemeDistribution(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Geçmiş planlar başlığı
          Row(
            children: [
              Icon(
                Icons.history,
                color: themeProvider.seedColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Geçmiş Planlarınız',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _loadPlans,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Yenile'),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Planlar listesi
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _savedPlans.length,
            itemBuilder: (context, index) {
              final plan = _savedPlans[index];
              return _buildPlanCard(plan, themeProvider);
            },
          ),
          
          const SizedBox(height: 100), // FAB için boşluk
        ],
      ),
    );
  }

  Widget _buildPlanCard(Plan plan, ThemeProvider themeProvider) {
    final themeColor = _getThemeColor(plan.theme);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlanDetailScreen(
                  plan: plan,
                  onPlanDeleted: _loadPlans,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        plan.theme.toUpperCase(),
                        style: TextStyle(
                          color: themeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(plan.createdAt),
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  plan.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  plan.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      plan.duration,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      plan.dailyTime,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getThemeColor(String theme) {
    switch (theme.toLowerCase()) {
      case 'eğitim':
        return Colors.blue;
      case 'sağlık':
        return Colors.green;
      case 'sürdürülebilirlik':
        return Colors.teal;
      case 'turizm':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getThemeDistribution() {
    if (_savedPlans.isEmpty) return 'Henüz plan yok';
    
    final themeCount = <String, int>{};
    for (final plan in _savedPlans) {
      themeCount[plan.theme] = (themeCount[plan.theme] ?? 0) + 1;
    }
    
    final mostUsedTheme = themeCount.entries.reduce(
      (a, b) => a.value > b.value ? a : b,
    );
    
    return '${mostUsedTheme.key}: ${mostUsedTheme.value}';
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

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Icon(Icons.palette),
                  const SizedBox(width: 8),
                  const Text(
                    'Tema Ayarları',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Column(
                    children: [
                      ThemeSelector(
                        currentTheme: themeProvider.seedColor,
                        onThemeChanged: (color) {
                          themeProvider.setSeedColor(color);
                        },
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.brightness_6),
                          const SizedBox(width: 8),
                          const Text(
                            'Karanlık Mod',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          Switch(
                            value: themeProvider.themeMode == ThemeMode.dark,
                            onChanged: (value) {
                              themeProvider.setThemeMode(
                                value ? ThemeMode.dark : ThemeMode.light,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () {
                          themeProvider.useSystemTheme();
                        },
                        icon: const Icon(Icons.phone_android),
                        label: const Text('Sistem Temasını Kullan'),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          themeProvider.resetToDefault();
                        },
                        icon: const Icon(Icons.restore),
                        label: const Text('Varsayılana Sıfırla'),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tüm Planları Temizle'),
        content: Text(
          'Toplam ${_savedPlans.length} planı kalıcı olarak silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllPlans();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Tümünü Sil'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllPlans() async {
    try {
      final success = await _storageService.clearAllPlans();
      
      if (success) {
        setState(() => _savedPlans.clear());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tüm planlar başarıyla silindi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Planlar silinirken bir hata oluştu!'),
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pusulam Hakkında'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pusulam - AI Asistan'),
            SizedBox(height: 8),
            Text('Sürüm: ${AppConstants.appVersion}'),
            SizedBox(height: 8),
            Text('Geliştirildi: Flutter & FastAPI'),
            SizedBox(height: 8),
            Text('Gemini AI ile güçlendirilmiştir.'),
            SizedBox(height: 16),
            Text(AppConstants.appDescription),
          ],
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
}
