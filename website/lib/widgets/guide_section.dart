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

              const SizedBox(height: 44),

              // --- 4 SETUP STEPS ---
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
                              const SizedBox(height: 20),
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
                        const SizedBox(width: 20),
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
                              const SizedBox(height: 20),
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
                        const SizedBox(height: 16),
                        _stepCard(
                          step: I18n.get('guide_step2_num'),
                          title: I18n.get('guide_step2_title'),
                          desc: I18n.get('guide_step2_desc'),
                          icon: Icons.key,
                          iconColor: AppTheme.accentPurple,
                          actionBtnTitle: I18n.get('guide_step2_btn'),
                          actionUrl: AppConstants.geminiApiKeyUrl,
                        ),
                        const SizedBox(height: 16),
                        _stepCard(
                          step: I18n.get('guide_step3_num'),
                          title: I18n.get('guide_step3_title'),
                          desc: I18n.get('guide_step3_desc'),
                          icon: Icons.settings,
                          iconColor: AppTheme.warningAmber,
                        ),
                        const SizedBox(height: 16),
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

              const SizedBox(height: 60),

              // --- SUBSECTION: ALL 4 AI FUNCTIONS ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.3)),
                ),
                child: Text(
                  I18n.get('guide_fn_header'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryBlue,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                I18n.get('guide_fn_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                I18n.get('guide_fn_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // 4 AI Functions Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 850;
                  final cards = [
                    _fnCard(
                      hotkeyKey: 'Alt + T',
                      title: I18n.get('guide_fn_t_title'),
                      desc: I18n.get('guide_fn_t_desc'),
                      icon: Icons.translate,
                      accentColor: AppTheme.secondaryBlue,
                    ),
                    _fnCard(
                      hotkeyKey: 'Alt + G',
                      title: I18n.get('guide_fn_g_title'),
                      desc: I18n.get('guide_fn_g_desc'),
                      icon: Icons.spellcheck,
                      accentColor: AppTheme.successGreen,
                    ),
                    _fnCard(
                      hotkeyKey: 'Alt + S',
                      title: I18n.get('guide_fn_s_title'),
                      desc: I18n.get('guide_fn_s_desc'),
                      icon: Icons.summarize,
                      accentColor: AppTheme.accentPurple,
                    ),
                    _fnCard(
                      hotkeyKey: 'Alt + E',
                      title: I18n.get('guide_fn_e_title'),
                      desc: I18n.get('guide_fn_e_desc'),
                      icon: Icons.psychology,
                      accentColor: AppTheme.warningAmber,
                    ),
                  ];

                  if (isWide) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: cards[0]),
                            const SizedBox(width: 20),
                            Expanded(child: cards[1]),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: cards[2]),
                            const SizedBox(width: 20),
                            Expanded(child: cards[3]),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        cards[0],
                        const SizedBox(height: 16),
                        cards[1],
                        const SizedBox(height: 16),
                        cards[2],
                        const SizedBox(height: 16),
                        cards[3],
                      ],
                    );
                  }
                },
              ),

              const SizedBox(height: 60),

              // --- SUBSECTION: PRO TIPS & CONTROLS ---
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.accentPurple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
                ),
                child: Text(
                  I18n.get('guide_pro_header'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentPurple,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                I18n.get('guide_pro_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 32),

              // 4 Pro Features Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 850;
                  final proCards = [
                    _proCard(
                      title: I18n.get('guide_pro_c1_title'),
                      desc: I18n.get('guide_pro_c1_desc'),
                      icon: Icons.copy_all,
                      iconColor: AppTheme.secondaryBlue,
                      tag: 'Ctrl + V',
                    ),
                    _proCard(
                      title: I18n.get('guide_pro_c2_title'),
                      desc: I18n.get('guide_pro_c2_desc'),
                      icon: Icons.open_with,
                      iconColor: AppTheme.accentPurple,
                      tag: 'Drag HUD',
                    ),
                    _proCard(
                      title: I18n.get('guide_pro_c3_title'),
                      desc: I18n.get('guide_pro_c3_desc'),
                      icon: Icons.cancel_outlined,
                      iconColor: AppTheme.textSecondary,
                      tag: 'Esc',
                    ),
                    _proCard(
                      title: I18n.get('guide_pro_c4_title'),
                      desc: I18n.get('guide_pro_c4_desc'),
                      icon: Icons.tune,
                      iconColor: AppTheme.warningAmber,
                      tag: 'Tray Menu',
                    ),
                  ];

                  if (isWide) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: proCards[0]),
                            const SizedBox(width: 20),
                            Expanded(child: proCards[1]),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: proCards[2]),
                            const SizedBox(width: 20),
                            Expanded(child: proCards[3]),
                          ],
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        proCards[0],
                        const SizedBox(height: 16),
                        proCards[1],
                        const SizedBox(height: 16),
                        proCards[2],
                        const SizedBox(height: 16),
                        proCards[3],
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
      padding: const EdgeInsets.all(22),
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: iconColor.withOpacity(0.3)),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 20),
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
                    const SizedBox(height: 2),
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
            const SizedBox(height: 14),
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

  Widget _fnCard({
    required String hotkeyKey,
    required String title,
    required String desc,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Keycap Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: accentColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 15, color: accentColor),
                    const SizedBox(width: 6),
                    Text(
                      hotkeyKey,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textSecondary,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _proCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color iconColor,
    required String tag,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: iconColor, size: 19),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.bgCardHover,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
