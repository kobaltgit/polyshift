import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';

class GuideSection extends StatelessWidget {
  const GuideSection({super.key});

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
              // Section Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.successGreen.withOpacity(0.3)),
                ),
                child: Text(
                  I18n.get('guide_tag'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successGreen,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title
              Text(
                I18n.get('guide_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                I18n.get('guide_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 48),

              // 4 Steps Cards Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 850;
                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _stepCard(
                                step: I18n.get('guide_step1_num'),
                                title: I18n.get('guide_step1_title'),
                                desc: I18n.get('guide_step1_desc'),
                                icon: Icons.download_done,
                                iconColor: AppTheme.primaryBlue,
                              ),
                              const SizedBox(height: 24),
                              _stepCard(
                                step: I18n.get('guide_step3_num'),
                                title: I18n.get('guide_step3_title'),
                                desc: I18n.get('guide_step3_desc'),
                                icon: Icons.settings,
                                iconColor: AppTheme.warningAmber,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            children: [
                              _stepCard(
                                step: I18n.get('guide_step2_num'),
                                title: I18n.get('guide_step2_title'),
                                desc: I18n.get('guide_step2_desc'),
                                icon: Icons.key,
                                iconColor: AppTheme.accentPurple,
                                actionBtnTitle: I18n.get('guide_step2_btn'),
                                actionUrl: AppConstants.geminiApiKeyUrl,
                              ),
                              const SizedBox(height: 24),
                              _stepCard(
                                step: I18n.get('guide_step4_num'),
                                title: I18n.get('guide_step4_title'),
                                desc: I18n.get('guide_step4_desc'),
                                icon: Icons.keyboard,
                                iconColor: AppTheme.successGreen,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        _stepCard(
                          step: I18n.get('guide_step1_num'),
                          title: I18n.get('guide_step1_title'),
                          desc: I18n.get('guide_step1_desc'),
                          icon: Icons.download_done,
                          iconColor: AppTheme.primaryBlue,
                        ),
                        const SizedBox(height: 18),
                        _stepCard(
                          step: I18n.get('guide_step2_num'),
                          title: I18n.get('guide_step2_title'),
                          desc: I18n.get('guide_step2_desc'),
                          icon: Icons.key,
                          iconColor: AppTheme.accentPurple,
                          actionBtnTitle: I18n.get('guide_step2_btn'),
                          actionUrl: AppConstants.geminiApiKeyUrl,
                        ),
                        const SizedBox(height: 18),
                        _stepCard(
                          step: I18n.get('guide_step3_num'),
                          title: I18n.get('guide_step3_title'),
                          desc: I18n.get('guide_step3_desc'),
                          icon: Icons.settings,
                          iconColor: AppTheme.warningAmber,
                        ),
                        const SizedBox(height: 18),
                        _stepCard(
                          step: I18n.get('guide_step4_num'),
                          title: I18n.get('guide_step4_title'),
                          desc: I18n.get('guide_step4_desc'),
                          icon: Icons.keyboard,
                          iconColor: AppTheme.successGreen,
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _stepCard({
    required String step,
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
    String? actionBtnTitle,
    String? actionUrl,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 22),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ШАГ $step',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.55,
            ),
          ),
          if (actionBtnTitle != null && actionUrl != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => launchUrl(Uri.parse(actionUrl)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.secondaryBlue,
                side: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.open_in_new, size: 14),
              label: Text(
                actionBtnTitle,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
