class I18n {
  static bool isRussian = true;

  static String get(String key) {
    if (isRussian) {
      return _ru[key] ?? key;
    }
    return _en[key] ?? key;
  }

  static const Map<String, String> _ru = {
    'nav_features': 'Возможности',
    'nav_guide': 'Инструкция для чайников',
    'nav_demo': 'Интерактивное Демо',
    'nav_hotkeys': 'Горячие клавиши',
    'nav_faq': 'Частые вопросы',
    'nav_download': 'Скачать',

    'hero_badge': '⚡ Релиз v2.0.0 • Rust + Tauri v2 + SvelteKit',
    'hero_title': 'Мгновенный ИИ-перевод и анализ текста прямо под курсором',
    'hero_subtitle': 'Выделите любой текст в любой программе Windows и нажмите Alt+T. Никаких переключений в браузер и ожидания. Стриминг перевода за 200 мс прямо у курсора при потреблении всего ~15 МБ памяти.',
    'hero_btn_install': 'Скачать установщик (.exe)',
    'hero_btn_portable': 'Портабельная версия (.zip)',
    'hero_btn_github': 'GitHub репозиторий',
    'hero_specs': 'Windows 10 / 11 (x64) • Вес ~3 МБ • Бесплатно и без рекламы',

    // Beginner guide
    'guide_tag': 'ОТ А ДО Я',
    'guide_title': 'Пошаговая инструкция для чайников',
    'guide_subtitle': 'Никогда раньше не пользовались подобными программами? Настройка займёт всего 2 минуты и делается один раз в жизни!',

    'guide_step1_num': '01',
    'guide_step1_title': 'Скачайте и запустите',
    'guide_step1_desc': 'Скачайте установщик (.exe) или распакуйте портабельный архив (.zip) в любую папку. При запуске PolyShift тихо появится в системном трее Windows (возле часов в правом нижнем углу).',

    'guide_step2_num': '02',
    'guide_step2_title': 'Получите бесплатный ключ Gemini',
    'guide_step2_desc': 'Перейдите на официальный сайт Google AI Studio (aistudio.google.com/app/apikey), войдите в свой Google аккаунт и нажмите «Create API key». Ключ выдаётся бесплатно и без привязки карт.',
    'guide_step2_btn': 'Открыть Google AI Studio',

    'guide_step3_num': '03',
    'guide_step3_title': 'Вставьте ключ в Настройки',
    'guide_step3_desc': 'Нажмите правой кнопкой мыши по иконке PolyShift возле часов и выберите «Настройки». Вставьте ваш ключ, нажмите «Проверить» (появится зелёная галочка) и нажмите «Сохранить».',

    'guide_step4_num': '04',
    'guide_step4_title': 'Выделяйте текст и жмите Alt + T',
    'guide_step4_desc': 'Готово! Выделите любое предложение в браузере, коде или документе и нажмите Alt + T. Прямо у курсора побегут строчки перевода, который автоматически скопируется в буфер обмена.',

    // Interactive Demo
    'demo_title': 'Попробуйте PolyShift в действии прямо сейчас',
    'demo_subtitle': 'Нажмите на любое действие ниже, чтобы увидеть живую эмуляцию плавающего оверлея:',
    'demo_tab_t': 'Alt + T (Перевод)',
    'demo_tab_g': 'Alt + G (Грамматика)',
    'demo_tab_s': 'Alt + S (Суммаризация)',
    'demo_tab_e': 'Alt + E (Объяснение)',
    'demo_hud_title': 'PolyShift HUD',
    'demo_source_label': 'Исходный текст:',
    'demo_copied': 'Скопировано в буфер!',

    // Features
    'feat_title': 'Почему PolyShift лучше обычных переводчиков?',
    'feat_subtitle': 'Спроектирован инженерами с нуля для максимальной скорости и уважения к ресурсам вашего ПК.',
    'feat_1_title': 'Сверхбыстрый отклик (< 5 мс)',
    'feat_1_desc': 'Окно HUD предзагружено в памяти и мгновенно появляется прямо возле курсора мыши при нажатии хоткея.',
    'feat_2_title': 'Всего ~15 МБ RAM',
    'feat_2_desc': 'Нативное ядро на Rust. Никаких тяжелых браузеров в фоне, которые тормозят компьютер.',
    'feat_3_title': 'Прямой SSE Стриминг',
    'feat_3_desc': 'Токены генерации выводятся в реальном времени по мере ответа нейросети без ожидания полного ответа.',
    'feat_4_title': 'Шифрование Windows DPAPI',
    'feat_4_desc': 'Ваш ключ Gemini защищён мастер-ключом вашей учетной записи Windows через системный CryptProtectData.',
    'feat_5_title': 'Абсолютная приватность',
    'feat_5_desc': 'Прямое HTTPS-соединение между вашим ПК и серверами Google. Никаких прокси, баз данных или сторонних серверов.',
    'feat_6_title': 'Автокопирование перевода',
    'feat_6_desc': 'Результат сразу попадает в буфер обмена — достаточно нажать Ctrl+V в любом чате или документе.',

    // FAQ
    'faq_title': 'Часто задаваемые вопросы',
    'faq_q1': 'Это действительно бесплатно?',
    'faq_a1': 'Да! Сам PolyShift абсолютно бесплатен и имеет открытый исходный код под лицензией MIT. Google Gemini API предоставляет щедрый бесплатный лимит для личного использования (Free Tier), которого хватает на сотни запросов в день без оплаты.',
    'faq_q2': 'Кто-то может перехватить мои переводы?',
    'faq_a2': 'Нет. У проекта вообще нет промежуточных серверов. Приложение общается напрямую с сервером Google по шифрованному TLS-каналу. Никакой истории или логов не ведётся.',
    'faq_q3': 'Где найти программу после запуска?',
    'faq_a3': 'Программа тихо сворачивается в системный трей Windows (в правом нижнем углу возле часов). Если значок спрятан, нажмите стрелочку «^» в панели задач.',
    'faq_q4': 'Как скрыть всплывающее окно?',
    'faq_a4': 'Просто нажмите клавишу Esc на клавиатуре или кликните на крестик в шапке окна.',

    // CTA & Footer
    'cta_title': 'Ускорьте свою работу с текстом уже сегодня',
    'cta_subtitle': 'Скачайте PolyShift прямо сейчас и забудьте о рутинном переключении в браузер.',
    'footer_text': '© 2026 PolyShift • Создано на Rust, Tauri v2 и SvelteKit • Свободная лицензия MIT',
  };

  static const Map<String, String> _en = {
    'nav_features': 'Features',
    'nav_guide': 'Beginner Guide',
    'nav_demo': 'Interactive Demo',
    'nav_hotkeys': 'Hotkeys',
    'nav_faq': 'FAQ',
    'nav_download': 'Download',

    'hero_badge': '⚡ v2.0.0 Release • Rust + Tauri v2 + SvelteKit',
    'hero_title': 'Instant AI Translation & Text Analysis Right at Your Cursor',
    'hero_subtitle': 'Select any text in any Windows application and press Alt+T. No browser switching, no waiting. Real-time streaming at ~15 MB RAM usage.',
    'hero_btn_install': 'Download Installer (.exe)',
    'hero_btn_portable': 'Portable Version (.zip)',
    'hero_btn_github': 'GitHub Repository',
    'hero_specs': 'Windows 10 / 11 (x64) • Size ~3 MB • Free & Ad-free',

    // Beginner guide
    'guide_tag': 'STEP BY STEP',
    'guide_title': 'Complete Beginner Guide (From A to Z)',
    'guide_subtitle': 'Never used API keys or tools like this? Setup takes just 2 minutes and is done only once!',

    'guide_step1_num': '01',
    'guide_step1_title': 'Download and Launch',
    'guide_step1_desc': 'Download the installer (.exe) or extract the portable archive (.zip). Upon launch, PolyShift quietly docks in the Windows system tray near the clock.',

    'guide_step2_num': '02',
    'guide_step2_title': 'Get a Free Gemini API Key',
    'guide_step2_desc': 'Go to Google AI Studio (aistudio.google.com/app/apikey), sign in with your Google account and click "Create API key". Completely free, no credit card required.',
    'guide_step2_btn': 'Open Google AI Studio',

    'guide_step3_num': '03',
    'guide_step3_title': 'Paste Key in Settings',
    'guide_step3_desc': 'Right-click the PolyShift icon near the clock and choose "Settings". Paste your key, click "Check" (a green checkmark will appear), and click "Save".',

    'guide_step4_num': '04',
    'guide_step4_title': 'Select Text & Press Alt + T',
    'guide_step4_desc': 'You are all set! Select any sentence in your browser, IDE, or document and press Alt + T. A glass HUD appears streaming the translation, auto-copied to clipboard.',

    // Interactive Demo
    'demo_title': 'Experience PolyShift Live',
    'demo_subtitle': 'Click an action below to view an interactive simulation of the floating HUD:',
    'demo_tab_t': 'Alt + T (Translate)',
    'demo_tab_g': 'Alt + G (Grammar)',
    'demo_tab_s': 'Alt + S (Summarize)',
    'demo_tab_e': 'Alt + E (Explain)',
    'demo_hud_title': 'PolyShift HUD',
    'demo_source_label': 'Source snippet:',
    'demo_copied': 'Copied to clipboard!',

    // Features
    'feat_title': 'Why PolyShift Outperforms Traditional Translators',
    'feat_subtitle': 'Built from scratch for peak performance and minimal computer resource consumption.',
    'feat_1_title': 'Blazing Response (< 5 ms)',
    'feat_1_desc': 'The HUD window is preloaded in memory and pops up right beside your mouse pointer instantly.',
    'feat_2_title': 'Only ~15 MB RAM',
    'feat_2_desc': 'Native Rust Win32 backend. No sluggish background browsers consuming gigabytes of RAM.',
    'feat_3_title': 'Direct SSE Streaming',
    'feat_3_desc': 'Tokens render live as they are generated by Gemini without waiting for full completion.',
    'feat_4_title': 'Windows DPAPI Encryption',
    'feat_4_desc': 'Your API key is protected by Windows hardware CryptProtectData tied to your local account.',
    'feat_5_title': 'Absolute Privacy',
    'feat_5_desc': 'Direct encrypted TLS connection to Google API. Zero telemetry, zero proxy servers.',
    'feat_6_title': 'Auto-copy to Clipboard',
    'feat_6_desc': 'Translated text lands straight in your clipboard ready for Ctrl+V.',

    // FAQ
    'faq_title': 'Frequently Asked Questions',
    'faq_q1': 'Is it really free?',
    'faq_a1': 'Yes! PolyShift is free and open source under the MIT license. Google Gemini API offers a generous Free Tier for personal use sufficient for hundreds of daily requests.',
    'faq_q2': 'Can anyone see my translations?',
    'faq_a2': 'No. PolyShift has no middleman servers. Communication is strictly direct from your PC to Google servers via HTTPS.',
    'faq_q3': 'Where is the app after launching?',
    'faq_a3': 'PolyShift runs silently in the Windows system tray near the clock. If hidden, click the "^" arrow on the taskbar.',
    'faq_q4': 'How do I close the floating window?',
    'faq_a4': 'Simply press the Esc key on your keyboard or click the close button.',

    // CTA & Footer
    'cta_title': 'Elevate Your Reading and Writing Speed Today',
    'cta_subtitle': 'Download PolyShift now and eliminate tedious copy-pasting forever.',
    'footer_text': '© 2026 PolyShift • Built with Rust, Tauri v2 and SvelteKit • MIT License',
  };
}
