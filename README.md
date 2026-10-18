<div align="center">
  <img src="assets/logo.png" alt="لوگوی پایا‌یار" width="150" />
  <h1>پایا‌یار (PAYAYAR)</h1>
  <p><strong>دستیار هوشمند و آفلاین برنامه‌ریزی درسی برای داوطلبان کنکور</strong></p>

  [![Flutter](https://img.shields.io/badge/Flutter-3.47.6-blue.svg?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.13.5-blue.svg?logo=dart)](https://dart.dev)
  [![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Android-lightgrey.svg)]()
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
  [![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)
</div>

---

## 📖 درباره پایا‌یار

**پایا‌یار** یک نرم‌افزار **Windows و Android** با رویکرد **Local-first** (داده‌های محلی) است که برای مدیریت کامل چرخه مطالعه دانش‌آموزان کنکوری طراحی شده است. 

فلسفه اصلی این پروژه بر پایه **مالکیت کامل کاربر بر داده‌هایش** بنا شده است. هیچ داده‌ای به سرور ارسال نمی‌شود، نیازی به ثبت‌نام یا حساب کاربری نیست و برنامه کاملاً آفلاین کار می‌کند.

> **اصل محصول:** `Plan → Execute → Record → Analyze → Improve`
> (برنامه‌ریزی ← اجرا ← ثبت ← تحلیل ← بهبود)

---

## ✨ امکانات کلیدی

- **📅 برنامه‌ریزی هوشمند:** مدیریت سطوح مختلف برنامه‌ریزی (چرخه آزمون، هفتگی، روزانه) با قابلیت کشیدن و رها کردن (Drag & Drop).
- **⏱️ تایمر تمرکز (Pomodoro):** ثبت خودکار جلسات مطالعه به همراه تایمر تمرکز و حالت Focus Mode.
- **📝 ثبت مطالعه و تست:** ثبت دقیق زمان مطالعه، تعداد تست‌های صحیح، غلط و نزده برای هر درس.
- **📊 گزارش‌ها و نمودارها:** مشاهده روند پیشرفت، ساعت خواب، ورزش و مطالعه به صورت نمودارهای خطی و میله‌ای.
- **🤖 مشاور هوش مصنوعی (AI):** دریافت تحلیل و پیشنهاد از Gemini API (بدون ارسال کل دیتابیس به سرور و با تأیید صریح کاربر).
- **🌱 ردیابی سبک زندگی:** ثبت خواب، تغذیه، ورزش و حال روز با نمایش Ring Chart.
- **🎨 رابط کاربری مدرن:** پشتیبانی از تم تاریک/روشن، ۶ پالت رنگی متفاوت، فونت شبنم و افکت‌های شیشه‌ای (Glassmorphism).

---

## 🛠 تکنولوژی‌ها و معماری

پروژه با استفاده از تکنولوژی‌های مدرن و بهینه توسعه یافته است:

*   **فریم‌ورک اصلی:** Flutter / Dart
*   **مدیریت وضعیت:** Riverpod
*   **دیتابیس محلی:** SQLite (با استفاده از Drift ORM)
*   **هوش مصنوعی:** Gemini API (کلید از خود کاربر)
*   **معماری:** Clean Architecture و Local-first (بدون Backend، بدون Cloud)

---

## 🚀 راه‌اندازی و نصب (برای توسعه‌دهندگان)

### پیش‌نیازها
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (نسخه 3.47.6 یا بالاتر)
*   [Android Studio](https://developer.android.com/studio) (برای بیلد اندروید)
*   [Visual Studio](https://visualstudio.microsoft.com/) (برای بیلد ویندوز با C++ Desktop Development)

### مراحل نصب

```bash
# ۱. کلون کردن مخزن
git clone https://github.com/javadsayyadi1387/payayar.git
cd payayar

# ۲. دریافت پکیج‌ها
flutter pub get

# ۳. اجرای تست‌ها و بررسی خطاها
flutter analyze
flutter test

# ۴. اجرای برنامه (ویندوز)
flutter run -d windows

# ۵. ساخت نسخه نهایی (Release)
flutter build windows
flutter build apk --release
