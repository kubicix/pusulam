import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_themes.dart';
import 'plan_result_screen.dart';

class PlanCreationScreen extends StatefulWidget {
  const PlanCreationScreen({super.key});

  @override
  State<PlanCreationScreen> createState() => _PlanCreationScreenState();
}

class _PlanCreationScreenState extends State<PlanCreationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _goalController = TextEditingController();
  final _customThemeController = TextEditingController();

  // Predefined themes
  final List<String> _predefinedThemes = [
    'Eğitim',
    'Sağlık',
    'Sürdürülebilirlik',
    'Turizm',
    'Yazılım Geliştirme',
    'İş Geliştirme',
    'Kişisel Gelişim',
    'Sanat ve Yaratıcılık',
    'Sosyal Medya Yönetimi',
    'Finansal Okuryazarlık',
    'Dijital Pazarlama',
    'Spor ve Fitness',
    'Psikoloji ve Zihin Sağlığı',
  ];

  String? _selectedTheme;
  bool _useCustomTheme = false;
  int _weekCount = 1;
  int _dailyHours = 1;
  bool _isLoading = false;
  
  // Loading dialog için değişkenler
  int _currentStep = 0;
  double _progress = 0.0;
  final List<String> _loadingSteps = [
    'Yapay zeka ile iletişime geçiliyor...',
    'Hedefiniz analiz ediliyor...',
    'Kişiselleştirilmiş plan oluşturuluyor...',
    'Plan detaylandırılıyor...'
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selectedTheme = _predefinedThemes[0];
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _goalController.dispose();
    _customThemeController.dispose();
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
          'Plan Oluştur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
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
                    maxWidth: isTablet ? 600 : double.infinity,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(theme),
                        SizedBox(height: screenSize.height * 0.03),
                        _buildGoalSection(theme),
                        SizedBox(height: screenSize.height * 0.025),
                        _buildThemeSection(theme),
                        SizedBox(height: screenSize.height * 0.025),
                        _buildDurationSection(theme),
                        SizedBox(height: screenSize.height * 0.025),
                        _buildDailyTimeSection(theme),
                        SizedBox(height: screenSize.height * 0.04),
                        _buildCreateButton(theme, screenSize),
                        SizedBox(height: screenSize.height * 0.02),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: CustomColors.cardGradient(themeProvider.seedColor),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeProvider.seedColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProvider.seedColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AI ile Kişisel Planınızı Oluşturun',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeProvider.seedColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Hedefinizi belirtin, sürenizi ayarlayın ve size özel detaylı bir plan alın.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalSection(ThemeData theme) {
    return _buildSection(
      title: 'Hedefiniz',
      icon: Icons.flag,
      child: TextFormField(
        controller: _goalController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Örnek: 3 haftada başlangıç seviyesi Python öğrenmek istiyorum',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Lütfen hedefinizi belirtin';
          }
          if (value.trim().length < 10) {
            return 'Hedefinizi daha detaylı açıklayın (en az 10 karakter)';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildThemeSection(ThemeData theme) {
    return _buildSection(
      title: 'Tema',
      icon: Icons.category,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Hazır Tema'),
                  value: false,
                  groupValue: _useCustomTheme,
                  onChanged: (value) {
                    setState(() {
                      _useCustomTheme = value!;
                    });
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Özel Tema'),
                  value: true,
                  groupValue: _useCustomTheme,
                  onChanged: (value) {
                    setState(() {
                      _useCustomTheme = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!_useCustomTheme)
            DropdownButtonFormField<String>(
              value: _selectedTheme,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              items: _predefinedThemes.map((theme) {
                return DropdownMenuItem(
                  value: theme,
                  child: Text(theme),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value;
                });
              },
            )
          else
            TextFormField(
              controller: _customThemeController,
              decoration: InputDecoration(
                hintText: 'Örnek: müzik prodüksiyonu, girişimcilik, spor',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              validator: _useCustomTheme
                  ? (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Lütfen özel temanızı belirtin';
                      }
                      return null;
                    }
                  : null,
            ),
        ],
      ),
    );
  }

  Widget _buildDurationSection(ThemeData theme) {
    return _buildSection(
      title: 'Süre',
      icon: Icons.schedule,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_weekCount Hafta',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _weekCount > 1
                      ? () {
                          setState(() {
                            _weekCount--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_weekCount',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _weekCount < 4
                      ? () {
                          setState(() {
                            _weekCount++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTimeSection(ThemeData theme) {
    return _buildSection(
      title: 'Günlük Çalışma Süresi',
      icon: Icons.access_time,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_dailyHours Saat',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _dailyHours > 1
                      ? () {
                          setState(() {
                            _dailyHours--;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_dailyHours',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _dailyHours < 8
                      ? () {
                          setState(() {
                            _dailyHours++;
                          });
                        }
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildCreateButton(ThemeData theme, Size screenSize) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _createPlan,
            style: ElevatedButton.styleFrom(
              backgroundColor: themeProvider.seedColor,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: themeProvider.seedColor.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Plan Oluşturuluyor...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'AI ile Plan Oluştur',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Future<void> _createPlan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _currentStep = 0;
      _progress = 0.0;
    });

    // Loading dialog'unu göster
    _showLoadingDialog();

    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      // Tema değerini belirle
      final selectedTheme = _useCustomTheme 
          ? _customThemeController.text.trim()
          : _selectedTheme!;

      final planRequest = {
        'goal': _goalController.text.trim(),
        'theme': selectedTheme,
        'duration': '$_weekCount hafta',
        'daily_time': '$_dailyHours saat',
      };

      // İlerleme simülasyonu
      await _simulateProgress();

      final response = await chatProvider.generatePlan(planRequest);

      // Dialog'u kapat
      if (mounted) {
        Navigator.pop(context);
      }

      if (mounted) {
        if (response['success'] == true) {
          // Plan verisine tema bilgisini ekle
          final planDataWithTheme = Map<String, dynamic>.from(response['generated_plan']);
          planDataWithTheme['theme'] = selectedTheme;
          planDataWithTheme['goal'] = _goalController.text.trim();
          planDataWithTheme['duration'] = '$_weekCount hafta';
          planDataWithTheme['daily_time'] = '$_dailyHours saat';
          
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanResultScreen(
                planData: planDataWithTheme,
                timestamp: response['timestamp'],
              ),
            ),
          );
          
          // Plan oluşturulduysa home screen'e true döndür
          if (result == true || result == null) {
            Navigator.pop(context, true);
          }
        } else {
          _showErrorDialog('Plan oluşturulurken bir hata oluştu. Lütfen tekrar deneyin.');
        }
      }
    } catch (e) {
      // Dialog'u kapat
      if (mounted) {
        Navigator.pop(context);
      }
      
      if (mounted) {
        _showErrorDialog('Bağlantı hatası: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _simulateProgress() async {
    const stepDuration = Duration(milliseconds: 3000); // Her adım 3 saniye
    
    for (int i = 0; i < _loadingSteps.length; i++) {
      setState(() {
        _currentStep = i;
      });
      
      // Her adım için animasyonlu progress artırma
      final targetProgress = (i + 1) / _loadingSteps.length * 0.9; // %90'a kadar
      await _animateProgress(targetProgress, stepDuration);
      
      // Son adım değilse biraz bekle
      if (i < _loadingSteps.length - 1) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
    }
  }

  Future<void> _animateProgress(double targetProgress, Duration duration) async {
    final startProgress = _progress;
    final progressDifference = targetProgress - startProgress;
    const frameRate = 60; // 60 FPS
    final totalFrames = (duration.inMilliseconds / (1000 / frameRate)).round();
    
    for (int frame = 0; frame <= totalFrames; frame++) {
      final animationProgress = frame / totalFrames;
      // Easing function - yavaş başla, hızlan, sonra yavaşla
      final easedProgress = _easeInOutCubic(animationProgress);
      
      setState(() {
        _progress = startProgress + (progressDifference * easedProgress);
      });
      
      await Future.delayed(Duration(milliseconds: (1000 / frameRate).round()));
    }
  }

  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return StatefulBuilder(
            builder: (context, setDialogState) {
              // Dialog state'ini güncellemek için dinleyici
              Future.microtask(() {
                if (mounted) {
                  setDialogState(() {});
                }
              });

              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        themeProvider.seedColor.withOpacity(0.05),
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Ana icon - Pulse animasyonu
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1500),
                        tween: Tween<double>(begin: 1.0, end: 1.1),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: themeProvider.seedColor,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeProvider.seedColor.withOpacity(0.3),
                                    blurRadius: 15 * scale,
                                    offset: const Offset(0, 5),
                                  ),
                                  BoxShadow(
                                    color: themeProvider.seedColor.withOpacity(0.1),
                                    blurRadius: 30 * scale,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                          );
                        },
                        onEnd: () {
                          // Animasyonu tekrarla
                          Future.microtask(() {
                            if (mounted) {
                              setDialogState(() {});
                            }
                          });
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Başlık
                      Text(
                        'Planınız Oluşturuluyor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.seedColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Alt başlık
                      Text(
                        'AI size özel bir plan hazırlıyor...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Circular Progress Indicator - Animasyonlu
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              tween: Tween<double>(
                                begin: 0,
                                end: _progress,
                              ),
                              builder: (context, value, _) => CircularProgressIndicator(
                                value: value,
                                strokeWidth: 6,
                                backgroundColor: themeProvider.seedColor.withOpacity(0.2),
                                color: themeProvider.seedColor,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                          ),
                          TweenAnimationBuilder<int>(
                            duration: const Duration(milliseconds: 300),
                            tween: IntTween(
                              begin: 0,
                              end: (_progress * 100).toInt(),
                            ),
                            builder: (context, value, _) => Text(
                              '$value%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: themeProvider.seedColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Linear Progress Bar - Animasyonlu
                      Container(
                        width: double.infinity,
                        height: 8,
                        decoration: BoxDecoration(
                          color: themeProvider.seedColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progress,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      themeProvider.seedColor,
                                      themeProvider.seedColor.withOpacity(0.8),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeProvider.seedColor.withOpacity(0.3),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Adım indicator - Animasyonlu
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: themeProvider.seedColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: themeProvider.seedColor.withOpacity(0.2),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: themeProvider.seedColor.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: themeProvider.seedColor,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: themeProvider.seedColor.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${_currentStep + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _currentStep < _loadingSteps.length 
                                      ? _loadingSteps[_currentStep]
                                      : 'Tamamlanıyor...',
                                  key: ValueKey(_currentStep),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: themeProvider.seedColor.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // İptal butonu (opsiyonel)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        child: Text(
                          'İptal',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
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
