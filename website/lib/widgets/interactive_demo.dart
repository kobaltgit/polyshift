import 'dart:async';
import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';

class InteractiveDemo extends StatefulWidget {
  const InteractiveDemo({super.key});

  @override
  State<InteractiveDemo> createState() => _InteractiveDemoState();
}

class _InteractiveDemoState extends State<InteractiveDemo> {
  int _selectedTabIndex = 0;
  String _currentOutput = '';
  Timer? _typingTimer;
  bool _isCopied = false;

  final List<Map<String, String>> _demoScenarios = [
    {
      'title': 'Умный перевод',
      'badge': 'Alt + T',
      'source': 'PolyShift is a blazing-fast, native AI companion for Windows built with Rust and SvelteKit.',
      'output': 'PolyShift — это молниеносный нативный ИИ-помощник для Windows, созданный на связке Rust и SvelteKit.',
    },
    {
      'title': 'Грамматика и стиль',
      'badge': 'Alt + G',
      'source': 'i has received your letter yesterday and wants to tell that we agree with all terms.',
      'output': 'I received your letter yesterday and would like to confirm that we agree with all the terms.',
    },
    {
      'title': 'Суммаризация (Выжимка)',
      'badge': 'Alt + S',
      'source': 'The Rust programming language provides memory safety guarantees without garbage collection through its strict ownership model. This makes it an ideal choice for high-performance desktop utilities.',
      'output': '• Rust гарантирует безопасность памяти без сборщика мусора через модель владения.\n• Обеспечивает максимальную производительность для нативных системных утилит Windows.',
    },
    {
      'title': 'Анализ и объяснение',
      'badge': 'Alt + E',
      'source': 'panic: runtime error: invalid memory address or nil pointer dereference',
      'output': 'Ошибка означает попытку обращения к объекту, который равен nil (нулевой указатель).\nПричина: переменная не была инициализирована перед вызовом метода.\nРешение: добавить проверку `if ptr != nil` перед обращением.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTypingAnimation(0);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  void _startTypingAnimation(int index) {
    _typingTimer?.cancel();
    setState(() {
      _selectedTabIndex = index;
      _currentOutput = '';
      _isCopied = false;
    });

    final fullText = _demoScenarios[index]['output']!;
    int charIndex = 0;

    _typingTimer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (charIndex < fullText.length) {
        charIndex += 2;
        if (charIndex > fullText.length) charIndex = fullText.length;
        setState(() {
          _currentOutput = fullText.substring(0, charIndex);
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _copyResult() {
    setState(() {
      _isCopied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final active = _demoScenarios[_selectedTabIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Text(
                I18n.get('demo_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                I18n.get('demo_subtitle'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Action Tabs
              Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _tabBtn(0, I18n.get('demo_tab_t')),
                  _tabBtn(1, I18n.get('demo_tab_g')),
                  _tabBtn(2, I18n.get('demo_tab_s')),
                  _tabBtn(3, I18n.get('demo_tab_e')),
                ],
              ),

              const SizedBox(height: 36),

              // Glass HUD Window Mockup
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 620),
                decoration: BoxDecoration(
                  color: const Color(0xEB0B1120),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.borderHighlight, width: 1.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66000000),
                      blurRadius: 35,
                      offset: Offset(0, 15),
                    ),
                    BoxShadow(
                      color: Color(0x333B82F6),
                      blurRadius: 25,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HUD Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0x800F172A),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        border: Border(bottom: BorderSide(color: AppTheme.borderSubtle)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Center(
                              child: Icon(Icons.auto_awesome, color: Colors.white, size: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            active['title']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.4)),
                            ),
                            child: Text(
                              active['badge']!,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryBlue,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _copyResult,
                            icon: Icon(
                              _isCopied ? Icons.check : Icons.copy,
                              size: 15,
                              color: _isCopied ? AppTheme.successGreen : AppTheme.textSecondary,
                            ),
                            tooltip: 'Копировать (Ctrl+C)',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.close, size: 16, color: AppTheme.textMuted),
                        ],
                      ),
                    ),

                    // Source Snippet
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: const Color(0x400F172A),
                      child: Row(
                        children: [
                          Text(
                            I18n.get('demo_source_label'),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              active['source']!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Main Output (Streaming)
                    Container(
                      padding: const EdgeInsets.all(18),
                      constraints: const BoxConstraints(minHeight: 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentOutput,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // HUD Footer
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: const BoxDecoration(
                        color: Color(0x600F172A),
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                        border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppTheme.successGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isCopied ? I18n.get('demo_copied') : 'Готово • Gemini 2.5 Flash',
                            style: TextStyle(
                              fontSize: 11,
                              color: _isCopied ? AppTheme.successGreen : AppTheme.textMuted,
                              fontWeight: _isCopied ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            'Esc чтобы скрыть',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabBtn(int index, String label) {
    final isSelected = _selectedTabIndex == index;
    return InkWell(
      onTap: () => _startTypingAnimation(index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x663B82F6),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
