import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback onGuideClick;
  final VoidCallback onDownloadClick;

  const HeroSection({
    super.key,
    required this.onGuideClick,
    required this.onDownloadClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 70),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              // Version Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.35)),
                ),
                child: Text(
                  I18n.get('hero_badge'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryBlue,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Hero Title
              Text(
                I18n.get('hero_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.15,
                  letterSpacing: -1,
                ),
              ),

              const SizedBox(height: 20),

              // Subtitle
              Text(
                I18n.get('hero_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 36),

              // Action Buttons
              Wrap(
                spacing: 14,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: onDownloadClick,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0x993B82F6),
                    ),
                    icon: const Icon(Icons.download, size: 20),
                    label: Text(
                      I18n.get('hero_btn_install'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: onGuideClick,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimary,
                      side: const BorderSide(color: AppTheme.borderSubtle, width: 1.5),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.help_outline, size: 20, color: AppTheme.secondaryBlue),
                    label: Text(
                      I18n.get('nav_guide'),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => launchUrl(Uri.parse(AppConstants.githubUrl)),
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppTheme.borderSubtle),
                      ),
                    ),
                    icon: const Icon(Icons.code, color: AppTheme.textSecondary, size: 22),
                    tooltip: 'GitHub',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Small Specs Info
              Text(
                I18n.get('hero_specs'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
