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

## ۳. کار در جریان — 🔄 push نشده

### 📝 یادداشت سریع (design.md §12.1)
**وضعیت: کد نوشته شده، `flutter analyze` پاک، ولی `flutter test` هرگز سبز تأیید نشده است.**

تغییرات محلی (uncommitted):
```
M  lib/core/l10n/fa.arb            ۱۰ کلید home_quickNote_*
M  lib/core/l10n/en.arb            همان ۱۰ کلید
M  lib/core/l10n/generated/*       با flutter gen-l10n بازتولید شد
M  lib/features/home/home_page.dart  افزودن QuickNoteCard
?? lib/features/home/quick_note.dart
?? test/quick_note_test.dart       ۵ تست
```

**دو باگی که خودم پیدا و اصلاح کردم (ولی اثبات نشده):**
1. `ref.listen` در `initState` غلط بود (`debugDoingBuild` assertion) → با `_loadIntoField()` جایگزین شد.
2. `_onChanged` بدون `setState` بود → دکمهٔ ذخیره هیچ‌وقت فعال نمی‌شد → `setState({})` اضافه شد.
3. ردیف دکمه‌ها با `Row`+`Spacer` می‌داد `RenderFlex overflowed by 18 pixels` → با `Wrap` جایگزین شد.

**⚠️ مهم‌ترین کار باقی‌مانده:**
```bash
export PATH="/root/flutter/bin:$PATH"; cd /root/payayar
flutter test          # آخرین اجرای کامل ناتمام ماند (در تست ۱۹ قطع شد)
flutter analyze
```
اگر سبز شد → commit + push. اگر نه → خطاهای `quick_note_test.dart` را ببین.

**نکات تستی که باید رعایت کنی:**
- `find.byType(TextField)` در تست کامل اپ بیش از یک نتیجه می‌ده (جست‌وجوی بالا) → یا `.last` بگیر یا در هارنس حداقلی تست کن.
- دکمهٔ تأیید دیالوگ هم متن `پاک کردن` دارد → هنگام tap از `.last` استفاده کن.
- هرگز `await container.dispose()` ننویس (مقدار `void` است → خطای analyzer).

---

## ۴. نقشه راه (اولویت‌دار) برای ایجنت بعدی

### فوری — قبل از هر چیز
- [ ] **سبز کردن و push کردن یادداشت سریع** (بخش ۳ بالا). این تنها کار ناتمام است.
- [ ] `git pull --rebase origin main` قبل از هر push (کرون همزمان کار می‌کند).

### مرحله بعدی — قابلیت‌های باقی‌ماندهٔ AGENTS.md
| # | قابلیت | بخش | توضیح |
|---|---|---|---|
| 1 | 🔔 نوتیفیکیشن محلی | §43.1 | جدول SQLite (نه push server)، آیکون زنگ در TopBar با badge، پنل تاریخچه، اکشن «انجام وظیفه» که حتماً وضعیت فعلی task را دوباره چک کند. چرخه: `created → unread → read → actioned/dismissed` |
| 2 | 🤖 AI بخش‌به‌بخش | §7.A | الان فقط مشاور مستقل داریم (`ai_advisor_page`). دکمهٔ «کمک AI/تحلیل با AI» در برنامه‌ریزی، مطالعه، آزمون، گزارش‌ها با **حداقل context** (§7.1) و خروجی ساخت‌یافتهٔ قابل رد شدن (§8.1) |
| 3 | 🃏 فلش‌کارت و مرور | §45 | جدول‌های `flashcards` + `review_items` (نیازمند migration)، تولید با AI فقط به‌صورت پیش‌نویس (§45.1) |
| 4 | ⏱️ نمایشگر فشردهٔ زمان‌سنج | §44.4 | خودِ وضعیت اپ-اسکوپ هست ولی فقط در صفحهٔ مطالعه دیده می‌شود |
| 5 | KI-01 (snake_case) | BUGS.md قدیمی | آخرین بازبینی: **صفر** فراخوانی `invoke(` در `lib/` ⇒ احتمالاً منسوخ. فقط تأیید نهایی مانده. |

### دوره‌ای
- [ ] اجرای کامل `flutter analyze` + `flutter test` قبل از هر push (Definition of Done در AGENTS §38).
- [ ] چک کردن آرتیفکت‌های CI بعد از push: https://github.com/fbfbdfdffv/payayar/actions

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
