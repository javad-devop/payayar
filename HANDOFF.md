# HANDOFF.md — گزارش تحویل برای ایجنت بعدی

> این فایل خلاصهٔ دقیق وضعیت پروژهٔ **پایا‌یار (PAYAYAR)** تا ۲۰۲۶-۱۰-۰۳ است.
> قبل از هر کاری `AGENTS.md` (معماری) و `design.md` (طراحی) را بخوان؛ این فایل فقط وضعیت را می‌گوید، جایگزین آن دو نیست.

---

## ۱. محیط توسعه (آماده و کارکرده)

| مورد | مقدار |
|---|---|
| Flutter | 3.47.6 stable در `/root/flutter/bin` |
| Dart | 3.13.5 |
| مسیر | `export PATH="/root/flutter/bin:$PATH"` (در هر shell دستی لازم است) |
| Git identity | `fbfbdfdffv <eddbrgbrg@atomicmail.io>` (فقط در این ریپو) |
| GitHub auth | `gh` لوگین است؛ credential helper با `gh auth setup-git` تنظیم شد |
| Android SDK | ⚠️ فقط `cmdline-tools` در `/root/Android/sdk` — `platforms`/`build-tools` نصب **نشده** و license پذیرفته نشده ⇒ `flutter build apk` محلی ممکن نیست |
| بیلد محلی لینوکس | ❌ (clang/ninja/GTK نصب نیست) — لازم هم نیست |

**دستورات کلیدی:**
```bash
export PATH="/root/flutter/bin:$PATH"
cd /root/payayar
flutter pub get && flutter analyze && flutter test
flutter gen-l10n          # بعد از هر تغییر در fa.arb / en.arb
```

---

## ۲. کارهای انجام‌شده (تأییدشده)

### ۲.۱ رفع هر ۳ باگ `BUGS.md` — ✅ کامل
- **باگ ۱** (درس جدید ذخیره نمی‌شد): `onChanged` + `setState` به دیالوگ اضافه شد؛ خطا با SnackBar نمایش داده می‌شود. کامیت `d9f3bda`.
- **باگ ۲** (آزمون جدید ذخیره نمی‌شد): هم‌ریشه با باگ ۱؛ رفع کدی در `d9f3bda` و `7a7a616`.
- **باگ ۳** (نمودار خواب/ورزش/تست نبود): سه کارت در `reports_page.dart`. کامیت `6a12ea8`.
- **`BUGS.md` از مخزن حذف شد** و وضعیت در `ROADMAP.md` ثبت شد. کامیت `3037e40`.

### ۲.۲ ریشه‌یابی هنگ تست باگ ۲ — ✅ (درس آموخته‌شده)
دو اشکال در **خودِ تست** بود، نه در کد محصول:
1. `watchExams().first` (استریم) باعث هنگ `pumpWidget` در teardown می‌شد → با خواندن آینده‌ای `db.select(db.exams).get()` جایگزین شد.
2. صفحهٔ برنامه‌ریزی **تب‌بندی** است؛ دکمهٔ «ثبت آزمون آزمایشی» در تب چهارم (`_MockExamView`) بود و تست به تب نمی‌رفت.

> ⚠️ **قانون برای ایجنت بعدی:** در تست‌های این پروژه از خواندن استریم Drift قبل از `pumpWidget`/teardown استفاده **نکن**. از query آینده‌ای استفاده کن.

### ۲.۳ ⏱️ پومودورو / تایمر تمرکز (AGENTS §44) — ✅ کامل و push شده
کامیت `0afb2ad`. فایل‌ها:
- `lib/features/study/focus_timer.dart` — `FocusTimerNotifier` با state اپ-اسکوپ
- `lib/features/study/focus_timer_card.dart` — کارت با `ProgressRing` در صفحهٔ مطالعه
- `test/focus_timer_test.dart` — ۹ تست

نکات پیاده‌سازی (اگر می‌خواهی ادامه بده/تست بزنی):
- `tick()` **async و عمومی** است تا تست‌ها ساعت را دستی پیش ببرند (بدون وابستگی به زمان واقعی).
- ثبت جلسه فقط از طریق `StudyRepository.addSession` (منبع دوم ساخته نشده).
- `notes`: `pomodoro completed` در برابر `pomodoro partial` (تفکیک §44.3).
- جلسهٔ رهاشده **بدون تأیید هرگز** نوشته نمی‌شود.
- `AppRadius.icon = 14` به `tokens.dart` اضافه شد (design §15.1).
- `AppSettings.focusMinutes` + `setFocusMinutes` با clamp ۵..۱۸۰.

### ۲.۴ CI گیت‌هاب — ✅ کامل و کارکرده
- `.github/workflows/android-build.yml` — analyze + test + `flutter build apk --release` → Artifact + Release.
- `.github/workflows/windows-build.yml` — analyze + test + `flutter build windows` + **ساخت setup.exe با Inno Setup** (`windows/installer/payayar.iss`) → zip + setup.exe در Release.
- هر دو `paths`-فیلتر و `concurrency: cancel-in-progress` دارند.
- **نکته:** flutter از لینوکس به ویندوز بیلد نمی‌زند؛ پس بیلد ویندوز **فقط** از طریق CI ممکن است.

**آخرین Releaseها:**
- `windows-build-0afb2ad` (setup.exe + zip)
- `android-build-ee238d0` (APK)

### ۲.۵ کرون ۳۰ دقیقه‌ای — ✅ فعال
job `payayar-roadmap-publish` (id `653092822642`):
هر ۳۰ دقیقه `ROADMAP.md` را به‌روز می‌کند و با پیشوند `chore: auto roadmap publish` به `origin/main` push می‌کند.
> ⚠️ این job **فقط** `ROADMAP.md` را ویرایش می‌کند و اجازهٔ تغییر کد/تست ندارد. هنگام کار موازی ممکن است با شما conflict بدهد → قبل از push: `git pull --rebase origin main`.

---

## ۳. کار در جریان — ✅ چیزی push‌نشده نمانده

**وضعیت (۲۰۲۶-۱۰-۰۹): همهٔ قابلیت‌های بالا در `main` ادغام و سبز شده‌اند.**
یادداشت سریع، نوتیفیکیشن‌ها، فلش‌کارت‌ها و «کمک AI» بخش‌به‌بخش همگی با CI سبز (analyze + تست) روی `main` هستند.

**نکات تستی که باید رعایت کنی:**
- `find.byType(TextField)` در تست کامل اپ بیش از یک نتیجه می‌ده (جست‌وجوی بالا) → یا `.last` بگیر یا در هارنس حداقلی تست کن.
- دکمهٔ تأیید دیالوگ هم متن `پاک کردن` دارد → هنگام tap از `.last` استفاده کن.
- هرگز `await container.dispose()` ننویس (مقدار `void` است → خطای analyzer).
- تست UI که `pumpWidget` کامل اپ را بالا می‌آورد باید بعد از enterText یک `await tester.pump()` بزند تا دکمهٔ ذخیره به‌روز شود.
- **حلقهٔ کاری فعلی:** تحلیل+تست در کداسپیس (~۴۰ ثانیه) و دروازهٔ نهایی CI گیت‌هاب؛ انتقال کد بین دو محیط با `git bundle` (بدون هیچ توکنی).

---

## ۴. نقشه راه (اولویت‌دار) برای ایجنت بعدی

### فوری — قبل از هر چیز
- [x] ~~سبز کردن و push کردن یادداشت سریع~~ — انجام شد (بخش ۳ بالا را ببین).
- [ ] `git pull --rebase origin main` قبل از هر push (کرون همزمان کار می‌کند).

### مرحله بعدی — قابلیت‌های باقی‌ماندهٔ AGENTS.md
| # | قابلیت | بخش | توضیح |
|---|---|---|---|
| 1 | 🔔 نوتیفیکیشن محلی | §43.1 | ✅ انجام شد — جدول SQLite، پنل تاریخچه داخلی (به‌جای زنگ TopBar)، چرخهٔ `created → unread → read → actioned/dismissed`. ۴۹+۴ تست سبز |
| 2 | 🤖 AI بخش‌به‌بخش | §7.A | ✅ انجام شد — `AiAssistAction` در برنامه‌ریزی/آزمون/گزارش‌ها/مطالعه با حداقل context و پاسخ فقط‌خواندنی (بدون جهش به صفحات) |
| 3 | 🃏 فلش‌کارت و مرور | §45 | ✅ انجام شد — جداول + migration نسخهٓ ۳، UI کارت/دیالوگ/شیت مرور، ۶۳ تست سبز |
| 4 | ⏱️ نمایشگر فشردهٔ زمان‌سنج | §44.4 | ⏳ باقی‌مانده — وضعیت اپ-اسکوپ هست ولی فقط در صفحهٔ مطالعه دیده می‌شود |
| 5 | KI-01 (snake_case) | BUGS.md قدیمی | آخرین بازبینی: **صفر** فراخوانی `invoke(` در `lib/` ⇒ احتمالاً منسوخ. فقط تأیید نهایی مانده. |

### دوره‌ای
- [ ] اجرای کامل `flutter analyze` + `flutter test` قبل از هر push (Definition of Done در AGENTS §38).
- [ ] چک کردن آرتیفکت‌های CI بعد از push: https://github.com/javadsayyadi1387/payayar/actions

---

## ۵. قواعد سخت که نباید شکسته شوند

1. **بدون بک‌اند/کلود/حساب کاربری** — SQLite محلی فقط. (AGENTS §31)
2. **فلتر و SQLite عوض نشوند** بدون اجازهٔ صریح کاربر.
3. **AI هرگز دادهٔ مهم را بدون تأیید کاربر تغییر نمی‌دهد** (§8.1) و خروجی‌اش «دادهٔ پیشنهادیِ اثبات‌نشده» است (§9).
4. **هرگز کل/صفحهٔ دیتابیس را برای AI نفرست** — حداقل context (§37).
5. **کلید API در سورس ممنوع.**
6. **UI فقط با `design.md`**: توکن به‌جای مقدار hard-code، فونت Vazirmatn، RTL فارسی، رنگ‌های معنایی.
7. **هر تغییر UI باید چهار حالت را ببیند:** Windows + Mobile، Dark + Light، فارسی + انگلیسی.
8. موفقیتِ build = پایان کار **نیست**؛ باید تست + بازرسی بصری هم سبز باشد (design §31).
