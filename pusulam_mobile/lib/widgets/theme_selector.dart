import 'package:flutter/material.dart';
import '../themes/app_themes.dart';

class ThemeSelector extends StatelessWidget {
  final Color currentTheme;
  final Function(Color) onThemeChanged;

  const ThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tema Seçin',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: AppThemes.themes.map((theme) {
            final isSelected = theme.seedColor.value == currentTheme.value;
            
            return GestureDetector(
              onTap: () => onThemeChanged(theme.seedColor),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: CustomColors.cardGradient(theme.seedColor),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? theme.seedColor : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.seedColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.seedColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        theme.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      theme.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: theme.seedColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      theme.description,
                      style: TextStyle(
                        fontSize: 10,
                        color: theme.seedColor.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class ThemePreview extends StatelessWidget {
  final Color seedColor;

  const ThemePreview({
    super.key,
    required this.seedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: CustomColors.cardGradient(seedColor),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: seedColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: seedColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.compass_calibration,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pusulam',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: seedColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Bu tema ile uygulamanız böyle görünecek.',
              style: TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: seedColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Text(
                      'Birincil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 32,
                  decoration: BoxDecoration(
                    color: seedColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: seedColor),
                  ),
                  child: Center(
                    child: Text(
                      'İkincil',
                      style: TextStyle(
                        color: seedColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
