import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';

class FeaturesGrid extends StatelessWidget {
  const FeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Text(
                I18n.get('feat_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                I18n.get('feat_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 48),

              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 900;
                  final count = isWide ? 3 : (constraints.maxWidth >= 600 ? 2 : 1);
                  return GridView.count(
                    crossAxisCount: count,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: isWide ? 1.35 : 1.5,
                    children: [
                      _card(Icons.bolt, AppTheme.primaryBlue, I18n.get('feat_1_title'), I18n.get('feat_1_desc')),
                      _card(Icons.memory, AppTheme.successGreen, I18n.get('feat_2_title'), I18n.get('feat_2_desc')),
                      _card(Icons.stream, AppTheme.secondaryBlue, I18n.get('feat_3_title'), I18n.get('feat_3_desc')),
                      _card(Icons.security, AppTheme.accentPurple, I18n.get('feat_4_title'), I18n.get('feat_4_desc')),
                      _card(Icons.privacy_tip, AppTheme.warningAmber, I18n.get('feat_5_title'), I18n.get('feat_5_desc')),
                      _card(Icons.content_copy, AppTheme.primaryBlue, I18n.get('feat_6_title'), I18n.get('feat_6_desc')),
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

  Widget _card(IconData icon, Color color, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Icon(icon, color: color, size: 20),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              desc,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
