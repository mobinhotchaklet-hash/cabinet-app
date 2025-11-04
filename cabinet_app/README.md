راهنمای ساخت APK (روی سیستم خودت) — به زبان فارسی
-------------------------------------------------
این پروژه یک MVP Flutter است که از Firebase برای احراز هویت و همگام‌سازی Firestore استفاده می‌کند.

گزینه A — ساخت محلی با Android Studio (ساده‌ترین راه)
1. Flutter و Android Studio را نصب کن (https://flutter.dev/docs/get-started/install).
2. مخزن را باز کن یا این پوشه را در Android Studio 'Open' کن.
3. فایل android/app/google-services.json را از Firebase Console دانلود و داخل android/app قرار بده.
4. در Firebase Console، Authentication (Email/Password) و Firestore را فعال کن.
5. از منوی 'Tools > Flutter > Flutter Pub Get' اجرا کن.
6. Run > Build > Build Bundle(s) / APK(s) > Build APK(s).
7. فایل APK در build/app/outputs/flutter-apk/app-release.apk یا app-debug.apk قرار می‌گیرد.

گزینه B — ساخت خودکار با GitHub Actions
در این پوشه یک workflow نمونه قرار دارد (.github/workflows/build.yml). اگر پروژه را به GitHub پوش کنی، Actions می‌تواند APK را بسازد و artifact خروجی را ارائه دهد.

نکته مهم:
- من در این محیط (ChatGPT) دسترسی به SDK یا ماشین ساخت ندارم، بنابراین APK آماده را نمی‌توانم خودم تولید کنم. اما کل پروژه و workflow را همین‌الان برات آماده کردم تا خودت یا شخص دیگری روی ماشین محلی یا CI آن را بسازد.