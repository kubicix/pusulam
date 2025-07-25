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
    'eğitim',
    'sağlık',
    'sürdürülebilirlik',
    'turizm',
    'yazılım geliştirme',
    'iş geliştirme',
    'kişisel gelişim',
    'sanat ve yaratıcılık',
  ];

  String? _selectedTheme;
  bool _useCustomTheme = false;
  int _weekCount = 1;
  int _dailyHours = 1;
  bool _isLoading = false;

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
                ? Row(
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
                      const SizedBox(width: 12),
                      const Text(
                        'Plan Oluşturuluyor...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
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
    });

    try {
      final chatProvider = Provider.of<ChatProvider>(context, listen: false);
      
      final planRequest = {
        'goal': _goalController.text.trim(),
        'theme': _useCustomTheme 
            ? _customThemeController.text.trim()
            : _selectedTheme!,
        'duration': '$_weekCount hafta',
        'daily_time': '$_dailyHours saat',
      };

      final response = await chatProvider.generatePlan(planRequest);

      if (mounted) {
        if (response['success'] == true) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlanResultScreen(
                planData: response['generated_plan'],
                timestamp: response['timestamp'],
              ),
            ),
          );
        } else {
          _showErrorDialog('Plan oluşturulurken bir hata oluştu. Lütfen tekrar deneyin.');
        }
      }
    } catch (e) {
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
