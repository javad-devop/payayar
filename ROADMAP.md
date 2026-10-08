# ROADMAP.md — راهنمای مسیر پیشرفت پایا‌یار

> این فایل «راهنمای مسیر» پروژه است و توسط کرون‌جاب به‌روزرسانی
> و همراه کدها در مخزن منتشر می‌شود.
>
> منبع حقیقت قوانین پروژه: `AGENTS.md` (معماری) و `design.md` (طراحی).
> `BUGS.md` حذف شد — هر سه باگ بسته شدند و با کد تطبیق داده شدند (بخش ۳).

**آخرین به‌روزرسانی:** 2026-10-03 18:10 UTC

---

## ۱. وضعیت کلی

| مرحله | وضعیت |
|---|---|
| راه‌اندازی محیط توسعه (Flutter 3.47.6 / Dart 3.13.5) | ✅ انجام شد |
| دریافت وابستگی‌ها (`flutter pub get`) | ✅ انجام شد |
| رفع باگ‌های `BUGS.md` (هر ۳ باگ) | ✅ انجام شد — `BUGS.md` حذف شد |
| `flutter analyze` | ✅ No issues found |
| `flutter test` (کل مجموعه) | ✅ ۳۱ تست، همه پاس |
| ⚙️ CI اندروید (بیلد APK + انتشار Release) | ✅ راه‌اندازی شد — ۲ نسخه منتشرشده |
| 🪟 CI ویندوز (setup.exe با Inno Setup) | ✅ راه‌اندازی شد — ۳ نسخه منتشرشده |
| ⏱️ پومودورو / تایمر تمرکز (AGENTS §44) | ✅ انجام شد |
| 🔔 نوتیفیکیشن محلی (AGENTS §43.1) | ⏳ در نوبت |
| 📝 یادداشت سریع (design §12.1) | 🔨 در دستِ کار (WIP غیرcommitted، بخش ۱.۱) |
| 🤖 AI بخش‌به‌بخش (AGENTS §7.A) | ⏳ در نوبت |
| 🃏 فلش‌کارت و مرور (AGENTS §45) | ⏳ در نوبت |
| تکمیل توسعه بخش‌ها | ⏳ در نوبت |

**وضعیت مخزن (خوانده شد، نه حدس — در همین اجرا):**
- کامیتِ مبنای این نسخه: `0afb2ad` — `feat(study): add Pomodoro focus timer (AGENTS.md §44)`؛ در لحظهٔ بررسی، `git ls-remote origin main` هم روی `0afb2ad` بود ⇒ همگام. (انتشارِ خودِ همین فایل، کامیتِ بعدی با پیشوند `chore: auto roadmap publish` است؛ HEAD واقعی را همیشه با `git log -1` ببینید.)
- ۵ کامیتِ آخر پیش از این انتشار: `0afb2ad`، `ee238d0`، `1500a85`، `92574eb`، `7c23a7b`.
- کامیت‌های تازه نسبت به آخرین انتشار رودمپ: `92574eb` (CI اندروید)، `1500a85` (CI ویندوز)، `ee238d0` (نصب‌کنندهٔ واقعی ویندوز)، `0afb2ad` (پومودورو).
- `test/` شامل **۶ فایل رسمی** است (به `focus_timer_test.dart` اضافه شد)؛ `BUGS.md` نه در درخت کاری هست و نه در فهرست git (`git ls-files`)؛ `docs/known-issues.md` هم وجود ندارد.
- **اجرای واقعی در این نوبت (روی کلون تمیز از همین HEAD، تا اثر کارِ موازی دخالت نکند):**
  - `flutter analyze` → `No issues found!` (۱۱.۴ ثانیه)
  - `flutter test` → **۳۱ تست، همه پاس** (۵۷ ثانیه)
- درخت کاریِ اصلی در لحظهٔ انتشار تمیز **نبود** — بخش ۱.۱ را ببینید.

### ۱.۱. کارِ موازیِ در جریان (غیرcommitted)

هنگام اجرای این نوبت، یک جلسهٔ موازی دیگر روی همین مخزن کار می‌کرد و این تغییرها را
**هنوز commit نکرده** بود (وضعیت `git status` در ۱۸:۰۸ UTC):

- `lib/features/home/quick_note.dart` (جدید، ۲۰۹ خط) + اتصال در `home_page.dart` (`QuickNoteCard` طبق `design.md §12.1`)
- `test/quick_note_test.dart` (جدید)
- ۱۰ کلید l10n جدید `home_quickNote_*` در `fa.arb`/`en.arb` + فایل‌های `generated/` بازتولیدشده

این موارد در شمارش‌های این فایل **محسوب نشده‌اند** (شمارش‌ها از HEAD کامیت‌شده است).
یک اجرای موقت `flutter test` روی این درختِ نیمه‌کاره ۳ شکست گذرا دید (هم‌زمانی هنگام
بازنویسی فایل‌های l10n)؛ اجرای مجدد همان تست‌ها پاس شد و روی HEAD تمیز هم هیچ شکستی نیست.

---

## ۲. پیشرفت بخش‌های محصول

اعداد از شمارش مستقیمِ کدِ کامیت‌شده (HEAD): **۴۲ فایل `.dart` در `lib/`**، **۱۳ فایل در
`lib/features/`**، **۸ کلاس `*Page`**، **۶ فایل تست** با مجموع **۳۱ تست**، **۲۹۸ کلید پیام**
در هر فایل arb.

| بخش | وضعیت | واقعیت کد |
|---|---|---|
| خانه (Dashboard) | ✅ موجود | `lib/features/home/home_page.dart` + `mini_calendar.dart` |
| برنامه‌ریزی | ✅ موجود | `lib/features/planning/planning_page.dart` (+ `planning_dashboard`، `task_dialog`) |
| مطالعه (درس/موضوع/جلسه) | ✅ موجود + **تایمر تمرکز/پومودورو** | `lib/features/study/study_page.dart`، `focus_timer.dart`، `focus_timer_card.dart` |
| آزمون‌ها | ✅ موجود | `lib/features/exams/exams_page.dart` |
| گزارش‌ها | ✅ ۸ کارت، ۳ تای آن نو (رفع باگ ۳) | `lib/features/reports/reports_page.dart` |
| سبک زندگی | ✅ موجود | `lib/features/lifestyle/lifestyle_page.dart` |
| مشاور AI | ✅ موجود | `lib/features/ai_advisor/ai_advisor_page.dart` |
| تنظیمات | ✅ موجود | `lib/features/settings/settings_page.dart` |

**جزئیات گزارش‌ها:** ۸ کارت در صفحه — مطالعه، خواب (خطی)، ورزش (میله‌ای)، تعداد تست (میله‌ای)،
توزیع درس‌ها، برنامه‌ریزی، تسلط، روند نمرات آزمون. سه کارت اخیر نو هستند و هر سه روی
`_TrendCard` مشترک ساخته شده‌اند (کامیت `6a12ea8`).

**ترجمه:** شمارش مستقیم در HEAD: **۲۹۸ کلید پیام** در `lib/core/l10n/fa.arb` و همان تعداد در
`en.arb` (مجموعهٔ کلیدها یکسان است؛ به‌علاوهٔ `@@locale`). رشد کلیدها: ۲۷۴ (پایه) + ۲۴ (پومودورو)
= ۲۹۸.

**تست‌ها (۶ فایل، ۳۱ تست):**

| فایل | تعداد |
|---|---|
| `test/database_test.dart` | ۸ |
| `test/widget_test.dart` | ۹ |
| `test/focus_timer_test.dart` | ۹ |
| `test/bug1_subject_dialog_test.dart` | ۱ |
| `test/bug2_exam_dialog_test.dart` | ۲ |
| `test/bug3_reports_charts_test.dart` | ۲ |

اجرای واقعی این نوبت روی کلون تمیز HEAD: **۳۱/۳۱ پاس** و `flutter analyze` بدون مشکل.

---

## ۲.۱. انتشار خودکار (GitHub Actions)

دو workflow در `.github/workflows/`، هر دو با `paths`-filter تا فقط تغییرات مرتبط بیلد شوند و با
`concurrency` تا بیلد هم‌پوشان کنسل شود؛ هر دو `flutter analyze` و `flutter test` را **قبل از**
بیلد اجرا می‌کنند (یعنی CI خودش دروازهٔ کیفیت است):

- **`android-build.yml`** — روی `ubuntu-latest`، Java 17، Flutter 3.47.6: `analyze` ← `test` ←
  `build apk --release` ← آپلود artifact ← انتشار روی Release با تگ `android-build-<sha7>`.
  علاوه بر push، هر ساعت (`17 * * * *`) هم اجرا می‌شود.
- **`windows-build.yml`** — روی `windows-latest`: `analyze` ← `test` ← `build windows --release` ←
  کامپایل نصب‌کننده با **Inno Setup** (`windows/installer/payayar.iss`) ← `PAYAYAR-Setup-<sha7>.exe`
  + `PAYAYAR-windows-<sha7>.zip` ← انتشار روی Release با تگ `windows-build-<sha7>`.

**شواهد واقعی از ریموت (`git ls-remote --tags origin` در این نوبت):**
- تگ‌های اندروید: `android-build-92574eb`، `android-build-ee238d0` ← **۲ نسخه APK**
- تگ‌های ویندوز: `windows-build-1500a85`، `windows-build-ee238d0`، `windows-build-0afb2ad` ← **۳ نسخه setup.exe**

(تگ `android-build-0afb2ad` هنوز دیده نمی‌شد؛ یا در صف/اجرای CI است یا باید دوباره بررسی شود.)

---

## ۳. باگ‌های رفع‌شده

وضعیت با اجرای واقعی تست‌ها و خواندن کدِ پیاده‌سازی در همین نوبت تطبیق داده شد.

### باگ ۱ — ذخیره‌نشدن درس جدید ✅ رفع شد
- **ریشه:** `onPressed: _name.text.isEmpty ? null : _save` بدون `onChanged`/`setState` → دکمهٔ ذخیره برای همیشه غیرفعال می‌ماند.
- **رفع:** افزودن `onChanged: (_) => setState(() {})` به TextField و نمایش خطای دیتابیس با SnackBar به‌جای بلعیدن بی‌صدا (کامیت `d9f3bda`).
- **تست:** `test/bug1_subject_dialog_test.dart` (۱ تست) — ✅ پاس در اجرای این نوبت.

### باگ ۲ — ذخیره‌نشدن آزمون جدید ✅ رفع شد
- **ریشه:** هم‌ریشه با باگ ۱ در چهار جا: `exams_page`، `planning_page` (`_MockExamDialog`)، `study_page` (`_SubjectDialog` + `_TopicDialog`).
- **رفع کدی:** افزودن `onChanged` + نمایش خطا با SnackBar (کامیت‌های `d9f3bda` و `7a7a616`).
- **رفع تست:** دو مشکل در خودِ تست بود، نه در کد محصول:
  1. **هنگ:** `watchExams().first` (استریم) مانع از اتمام teardown می‌شد؛ با خواندن آینده‌ای `db.select(db.exams).get()` جایگزین شد.
  2. **پیدا نشدن دکمه:** صفحهٔ برنامه‌ریزی تب‌بندی است؛ تست اول تب «آزمون آزمایشی» را می‌زند تا `_MockExamView` رندر شود.
- **تست:** `test/bug2_exam_dialog_test.dart` (۲ تست) — ✅ هر دو پاس در اجرای این نوبت.

### باگ ۳ — نمودارهای خواب/ورزش/تست در گزارش‌ها ✅ رفع شد
- **کد:** سه کارت در `reports_page.dart`: `_SleepReport` (خطی)، `_ExerciseReport` (میله‌ای)، `_TestCountReport` (میله‌ای) + `_TrendCard` مشترک (کامیت `6a12ea8`).
- **منبع داده واقعی (تصحیح حدس `BUGS.md`):** خواب ← `lifestyle_entries.sleep_minutes`؛ ورزش ← `lifestyle_entries.exercise_minutes`؛ تست ← `study_sessions.type == test`. ⚠️ جدول `test_sessions` که `BUGS.md` حدس زده بود در شمای فعلی وجود ندارد؛ شمارش، تعداد **جلسهٔ** تست است نه تعداد سؤال.
- **ترجمه:** ۶ کلید به هر دو arb اضافه شد.
- **تست:** `test/bug3_reports_charts_test.dart` (۲ تست) — ✅ هر دو پاس در اجرای این نوبت.

### وضعیت نهایی
> `BUGS.md` از مخزن **حذف شد** (کامیت `3037e40`) و در این نوبت دوباره بررسی شد: نه در درخت
> کاری هست و نه در `git ls-files` ⇒ سه باگ واقعاً بسته شده‌اند و هر ۵ تستشان پاس است.
>
> **بازبینی KI-01:** در `lib/` هیچ فراخوانی `invoke(` نیست؛ رشته‌های snake_case فقط در فایل‌های
> `.g.dart` (نام ستون‌های drift)، دو کد خطای رابط کاربری (`invalid_key`، `network`) و فیلد JSON
> پیشنهاد وظیفه (`task_title`) آمده‌اند. پس ادعای «۹ فراخوانی snake_case» مربوط به پروژهٔ قدیمی
> Tauri بود و در کد فعلی Flutter یافت **نشد**.

---

## ۳.۱. پومودورو / تایمر تمرکز (AGENTS.md §44) ✅

**فایل‌ها:** `lib/features/study/focus_timer.dart` (منطق)، `lib/features/study/focus_timer_card.dart` (UI)، `test/focus_timer_test.dart` (۹ تست). کامیت `0afb2ad`.

| قاعدهٔ AGENTS | پیاده‌سازی |
|---|---|
| §44.1 مدت پیش‌فرض ۲۵ دقیقه، قابل تغییر | `allowedMinutes = [15,25,45,60]` + `ChoiceChip`؛ انتخاب در `AppSettings.focusMinutes` ذخیره و بازیابی می‌شود |
| §44.1 انتخاب درس و مبحث | دیالوگ راه‌اندازی: `DropdownButtonFormField` درس + مبحث (مبحث فقط وقتی درس داشته باشد) |
| §44.1 پایان خودکار + هشدار | با رسیدن به زمان، جلسه خودکار ثبت و `SystemSound.alert` + `HapticFeedback` زده می‌شود (بهترین تلاش؛ بدون وابستگی جدید) |
| §44.2 ثبت در `study_sessions` | از همان `StudyRepository.addSession` استفاده می‌شود — منبع دومی ساخته نشد |
| §44.3 جلسهٔ رهاشده ثبت نمی‌شود | پایان زودهنگام ۳ گزینه دارد: ثبت / بدون ثبت / انصراف. بدون تأیید هیچ ردیفی نوشته نمی‌شود |
| §44.3 تفکیک ناقص از کامل | `notes`: `pomodoro completed` در برابر `pomodoro partial` |
| §44.4 زمان‌سنج با ناوبری نمی‌میرد | وضعیت در `focusTimerProvider` (app-scoped) نه در ویجت |

**نکتهٔ طراحی:** آیکون ۴۴×۴۴ با گوشهٔ ۱۴px از `design.md §15.1` بود که توکنش نبود → `AppRadius.icon` به `tokens.dart` اضافه شد (توکنِ جدید، نه مقدار hard-code).

**تأیید (این نوبت، روی کلون تمیز HEAD):** `flutter analyze` → No issues found؛ `flutter test` → **۳۱ تست پاس**.

**باقی‌ماندهٔ این قابلیت:** نمایشگر فشردهٔ زمان‌سنج در سایر صفحه‌ها (الان فقط کارت صفحهٔ مطالعه؛ خودِ وضعیت ولی در همه‌جا زنده است).

---

## ۴. مراحل بعدی

1. 📝 یادداشت سریع (design §12.1) — 🔨 در جریان است (WIP غیرcommitted در درخت کاری؛ بخش ۱.۱). تمام کردنش و commit کردن اولویت اول نوبت بعدی است.
2. 🔔 نوتیفیکیشن محلی (AGENTS §43.1) — نوار بالا + پنل تاریخچه.
3. 🤖 AI بخش‌به‌بخش (AGENTS §7.A) — «کمک AI» در برنامه‌ریزی/مطالعه/آزمون/گزارش‌ها.
4. 🃏 فلش‌کارت و مرور (AGENTS §45).
5. نمایشگر فشردهٔ تایمر تمرکز در صفحه‌های دیگر (باقی‌ماندهٔ §44).
6. بررسی CI: تأیید اینکه `android-build-0afb2ad` ساخته شد و تگ/Release آن ثبت شده است.

---

## ۵. لاگ به‌روزرسانی‌ها

- 2026-10-03 — راه‌اندازی محیط، نصب Flutter و وابستگی‌ها؛ شروع رفع باگ‌ها.
- 2026-10-03 12:05 UTC — نصب `flutter/agent-plugins` (۲۵ مهارت + `dart mcp-server`)؛ پیاده‌سازی کد باگ ۳ + تست آن؛ `flutter analyze` پاک؛ تست باگ ۱ پاس؛ تست باگ ۲ hang شد و در ریشه‌یابی است.
- 2026-10-03 13:12 UTC — همگام‌سازی با `origin/main` (بدون تداخل، HEAD=`24f09be`)؛ بازخوانی `BUGS.md` و شمارش کد: ۸ بخش/۸ صفحه، ۴۰ فایل dart در lib، ۸ فایل تست؛ تأیید رندر ۳ کارت نو گزارش و ۶ کلید l10n در هر دو arb؛ ثبت اینکه تست باگ ۳ در کامیت اخیر viewport گرفته ولی نتیجه‌اش تأیید نشده، و اینکه `BUGS.md` با کد ناهماهنگ است.
- 2026-10-03 16:40 UTC — **بستن هر سه باگ.** ریشه‌یابی کامل هنگ تست باگ ۲ (۵ فایل تشخیصی موقت ساخته و سپس حذف شد): عامل هنگ `watchExams().first` بود، نه کد محصول؛ با خواندن آینده‌ای جایگزین شد. مشکل دوم: دکمهٔ «ثبت آزمون آزمایشی» در تب چهارم صفحهٔ برنامه‌ریزی است و تست به تب نمی‌رفت. نتیجهٔ نهایی: `flutter test` → **۲۲ تست پاس**، `flutter analyze` → **No issues found**. `BUGS.md` از مخزن حذف شد.
- 2026-10-03 16:50 UTC — راستی‌آزمایی قبلی: اجرای کامل (۲۲/۲۲ پاس)؛ آزمون A/B روی تست باگ ۲ تأیید کرد نسخهٔ قدیمی (`watchExams().first`) واقعاً hang می‌کند. شمارش مستقیم l10n: **۲۷۴** کلید در هر arb؛ بازبینی KI-01: صفر فراخوانی `invoke(` در `lib/`.
- 2026-10-03 17:45 UTC — **پومودورو (AGENTS §44) اضافه شد.** `focus_timer.dart` (state اپ-اسکوپ، ثبت از طریق `study_sessions`) + `focus_timer_card.dart` (کارت در صفحهٔ مطالعه با `ProgressRing`) + ۹ تست در `focus_timer_test.dart`. ۲۴ کلید l10n در fa/en، `AppRadius.icon` به توکن‌ها اضافه شد، `AppSettings.focusMinutes` ذخیره می‌شود. نتیجه: `flutter analyze` → No issues found؛ `flutter test` → **۳۱ تست پاس**.
- 2026-10-03 18:10 UTC — **به‌روزرسانی و انتشار رودمپ پس از ۴ کامیت جدید** (`92574eb` CI اندروید، `1500a85` CI ویندوز، `ee238d0` نصب‌کنندهٔ Inno Setup، `0afb2ad` پومودورو). راستی‌آزمایی روی کلون تمیز HEAD: `flutter analyze` → No issues found، `flutter test` → **۳۱/۳۱ پاس**؛ شمارش مستقیم کد: ۴۲ فایل dart در `lib/`، ۱۳ فایل در `lib/features/`، ۸ کلاس `*Page`، ۶ فایل تست/۳۱ تست، **۲۹۸** کلید l10n در هر arb (کلیدهای fa و en یکسان). تأیید شد `BUGS.md` نه در درخت هست نه در `git ls-files`. شواهد CI از ریموت: ۲ تگ `android-build-*` و ۳ تگ `windows-build-*` (۵ Release). ثبت شد که یک جلسهٔ موازی WIP یادداشت سریع (design §12.1) را غیرcommitted در درخت کاری گذاشته و در شمارش‌ها لحاظ نشده است.
