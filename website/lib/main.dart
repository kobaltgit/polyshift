import 'package:flutter/material.dart';
import 'i18n.dart';
import 'theme.dart';
import 'widgets/hero_section.dart';
import 'widgets/guide_section.dart';
import 'widgets/interactive_demo.dart';
import 'widgets/features_grid.dart';
import 'widgets/comparison_table.dart';
import 'widgets/faq_section.dart';
import 'widgets/download_cta.dart';
import 'package:kobalt_ui/kobalt_ui.dart';

void main() {
  runApp(const PolyShiftWebsiteApp());
}

class PolyShiftWebsiteApp extends StatefulWidget {
  const PolyShiftWebsiteApp({super.key});

  @override
  State<PolyShiftWebsiteApp> createState() => _PolyShiftWebsiteAppState();
}

class _PolyShiftWebsiteAppState extends State<PolyShiftWebsiteApp> {
  void _toggleLanguage() {
    setState(() {
      I18n.isRussian = !I18n.isRussian;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PolyShift — Instant AI Translator for Windows',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: LandingPage(onLanguageToggle: _toggleLanguage),
    );
  }
}

class LandingPage extends StatefulWidget {
  final VoidCallback onLanguageToggle;

  const LandingPage({super.key, required this.onLanguageToggle});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _guideKey = GlobalKey();
  final GlobalKey _demoKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _downloadKey = GlobalKey();

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Glow
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            height: 500,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.heroGlowGradient,
              ),
            ),
          ),

          // Main Column layout with fixed KobaltNavBar
          Column(
            children: [
              KobaltNavBar(
                project: KobaltProjectId.polyShift,
                version: 'v1.0.0',
                isRussian: I18n.isRussian,
                onLanguageToggle: widget.onLanguageToggle,
                accentColor: AppTheme.primaryBlue,
                navLinks: [
                  KobaltNavLink(
                    label: I18n.get('nav_features'),
                    onTap: () => _scrollToKey(_featuresKey),
                  ),
                  KobaltNavLink(
                    label: I18n.get('nav_demo'),
                    onTap: () => _scrollToKey(_demoKey),
                  ),
                  KobaltNavLink(
                    label: I18n.get('nav_guide'),
                    onTap: () => _scrollToKey(_guideKey),
                  ),
                  KobaltNavLink(
                    label: I18n.get('nav_faq'),
                    onTap: () => _scrollToKey(_faqKey),
                  ),
                ],
                onDownloadTap: () => _scrollToKey(_downloadKey),
              ),

              // Main Scrollable Page
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      HeroSection(
                        onGuideClick: () => _scrollToKey(_guideKey),
                        onDownloadClick: () => _scrollToKey(_downloadKey),
                      ),
                      InteractiveDemo(key: _demoKey),
                      GuideSection(key: _guideKey),
                      FeaturesGrid(key: _featuresKey),
                      const ComparisonTable(),
                      FaqSection(key: _faqKey),
                      DownloadCta(key: _downloadKey),
                      KobaltFooter(
                        project: KobaltProjectId.polyShift,
                        version: 'v1.0.0',
                        isRussian: I18n.isRussian,
                        accentColor: AppTheme.primaryBlue,
                        onBackToTop: () {
                          _scrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeInOutCubic,
                          );
                        },
                      ),
                    ],
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
