import 'package:flutter/material.dart';
import '../theme.dart';

class ComparisonTable extends StatelessWidget {
  const ComparisonTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              const Text(
                'Сравнение с аналогами',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Почему нативное Win32-приложение на Rust на голову опережает веб-сервисы и Electron',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 36),

              Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderSubtle),
                ),
                child: Table(
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FlexColumnWidth(2.2),
                    1: FlexColumnWidth(1.4),
                    2: FlexColumnWidth(1.4),
                    3: FlexColumnWidth(1.4),
                  },
                  children: [
                    _headerRow(),
                    _dataRow('Скорость открытия', '< 5 мс (Мгновенно)', '2-5 сек (Вкладка)', '0.5-1.5 сек'),
                    _dataRow('Потребление RAM', '~15 МБ', '~300-600 МБ', '~250-450 МБ'),
                    _dataRow('Стриминг перевода', 'Да (SSE потоки)', 'Редко', 'Да'),
                    _dataRow('Шифрование ключа', 'Да (Windows DPAPI)', 'Куки браузера', 'Открытый JSON'),
                    _dataRow('Без сторонних прокси', 'Да (Прямой Google)', 'Нет (Свои серверы)', 'Нет'),
                    _dataRow('Цена и подписки', 'Бесплатно (Free)', 'Подписка / Реклама', 'Подписка'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _headerRow() {
    return TableRow(
      decoration: const BoxDecoration(
        color: Color(0x600F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      children: [
        _cell('Параметр', isHeader: true),
        _cell('PolyShift v2', isHeader: true, highlight: true),
        _cell('Веб-переводчики', isHeader: true),
        _cell('Electron утилиты', isHeader: true),
      ],
    );
  }

  TableRow _dataRow(String label, String v1, String v2, String v3) {
    return TableRow(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderSubtle, width: 0.5)),
      ),
      children: [
        _cell(label, isBold: true),
        _cell(v1, isSuccess: true),
        _cell(v2),
        _cell(v3),
      ],
    );
  }

  Widget _cell(String text, {bool isHeader = false, bool highlight = false, bool isSuccess = false, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        textAlign: isHeader ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
          color: highlight
              ? AppTheme.primaryBlue
              : (isSuccess ? AppTheme.secondaryBlue : (isHeader ? AppTheme.textPrimary : AppTheme.textSecondary)),
        ),
      ),
    );
  }
}
