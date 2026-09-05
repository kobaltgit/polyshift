import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';

class Navbar extends StatelessWidget {
  final VoidCallback onLanguageToggle;
  final Function(String) onNavClick;

  const Navbar({
    super.key,
    required this.onLanguageToggle,
    required this.onNavClick,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppTheme.bgBase.withValues(alpha: 0.85),
        border: const Border(
          bottom: BorderSide(color: AppTheme.borderSubtle, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Row(
            children: [
              // Logo & App Name
              InkWell(
                onTap: () => onNavClick('hero'),
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x663B82F6),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppConstants.appName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                      ),
                      child: const Text(
                        'v2.0',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Desktop Navigation Links
              if (isDesktop) ...[
                _navItem(I18n.get('nav_guide'), () => onNavClick('guide')),
                _navItem(I18n.get('nav_demo'), () => onNavClick('demo')),
                _navItem(I18n.get('nav_features'), () => onNavClick('features')),
                _navItem(I18n.get('nav_faq'), () => onNavClick('faq')),
                const SizedBox(width: 16),
              ],

              // Language Toggle Button
              TextButton.icon(
                onPressed: onLanguageToggle,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: AppTheme.borderSubtle),
                  ),
                ),
                icon: const Icon(Icons.language, size: 16, color: AppTheme.textSecondary),
                label: Text(
                  I18n.isRussian ? 'EN' : 'RU',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // GitHub Button
              IconButton(
                onPressed: () => launchUrl(Uri.parse(AppConstants.githubUrl)),
                icon: const Icon(Icons.code, color: AppTheme.textSecondary, size: 20),
                tooltip: 'GitHub',
              ),

              const SizedBox(width: 12),

              // Download CTA
              ElevatedButton.icon(
                onPressed: () => onNavClick('download'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0x803B82F6),
                ),
                icon: const Icon(Icons.download, size: 16),
                label: Text(
                  I18n.get('nav_download'),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.textSecondary,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
