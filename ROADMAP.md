# ROADMAP.md — راهنمای مسیر پیشرفت پایا‌یار

> این فایل «راهنمای مسیر» پروژه است و توسط کرون‌جاب به‌روزرسانی
> و همراه کدها در مخزن منتشر می‌شود.
>
> منبع حقیقت قوانین پروژه: `AGENTS.md` (معماری) و `design.md` (طراحی).
> `BUGS.md` حذف شد — هر سه باگ بسته شدند و با کد تطبیق داده شدند (بخش ۳).

**آخرین به‌روزرسانی:** 2026-10-09 02:32 UTC

---

## ۱. وضعیت کلی

| مرحله | وضعیت |
|---|---|
| راه‌اندازی محیط توسعه (Flutter 3.47.6 / Dart 3.13.5) | ✅ انجام شد |
| دریافت وابستگی‌ها (`flutter pub get`) | ✅ انجام شد |
| رفع باگ‌های `BUGS.md` (هر ۳ باگ) | ✅ انجام شد — `BUGS.md` حذف شد |
| `flutter analyze` | ✅ روی `feat/flashcards`/`73c94dd` سبز شد (اجرای `37845407209` در ۲۱:۱۶ UTC با پیام `No issues found!`؛ هشدار `prefer_initializing_formals`ِ `d1d5de8` پیش‌تر با `b5e0331` برطرف شد)؛ **اکنون روی `main`/`2a2071c` هم سبز است** — پلهٔ `Static analysis` در هر دو بیلد pushِ ۰۲:۰۹:۱۵ UTC (`37873204609` اندروید و `37873204616` ویندوز) ✓ شد |
| `flutter test` (کل مجموعه) | ✅ **۱۱ فایل، ۶۰ تست**؛ آخرین اجرای CI روی `73c94dd` (`37845407209`، ۲۱:۱۷ UTC): **۶۰ پاس / ۰ شکست** — هَنگ ۱۰ دقیقه‌ای تست `management list shows box and deletes a card` با `73c94dd` برطرف شد (روی `b5e0331` پیش‌تر ۵۹/۱ بود)؛ **روی `main`/`2a2071c` هم پلهٔ `Run tests` در هر دو بیلد pushِ ۰۲:۰۹–۰۲:۱۹ UTC سبز بود** |
| ⚙️ CI اندروید (بیلد APK + انتشار Release) | ✅ راه‌اندازی شد — **۷ نسخه منتشرشده**؛ آخرین اجرا `Android Build` پس از push شدن ادغام فلش‌کارت به `main` (`37873204609` روی `2a2071c`، ۰۲:۰۹:۱۵–۰۲:۱۹:۴۴ UTC) **سبز تمام شد** (همه پله‌ها ✓ تا `Publish to Release`) و `android-build-2a2071c` (`PAYAYAR build 2a2071c`) را در ۰۲:۱۹:۳۹ UTC ثبت کرد ⇒ **۷ نسخهٔ اندروید = ۱۳ Release** |
| 🪟 CI ویندوز (setup.exe با Inno Setup) | ✅ راه‌اندازی شد — **۶ نسخه منتشرشده**؛ آخرین اجرا `Windows Build` (`37873204616` روی `main`/`2a2071c`، ۰۲:۰۹:۱۵–۰۲:۱۶:۲۳ UTC) سبز تمام شد و `windows-build-2a2071c` (`PAYAYAR Windows 2a2071c`) را در ۰۲:۱۶:۱۶ UTC ثبت کرد |
| ⏱️ پومودورو / تایمر تمرکز (AGENTS §44) | ✅ انجام شد |
| 🔔 نوتیفیکیشن محلی (AGENTS §43.1) | ✅ انجام شد — ۹ کامیت، سبز در CI (بخش ۳.۲) |
| 📝 یادداشت سریع (design §12.1) | ✅ انجام شد و کامیت شد (بخش ۳.۳) |
| 🤖 AI بخش‌به‌بخش (AGENTS §7.A) | ✅ **انجام شد** — دکمهٔ «کمک AI» در ۴ صفحه (برنامه‌ریزی/آزمون/گزارش‌ها/مطالعه)، پاسخ فقط‌خواندنی در شیت پایین صفحه، حداقل context هر بخش (§7.A/§24)، بدون جهش خودکار به صفحات. کداسپیس: analyze پاک + **۶۳/۶۳ تست**؛ CI شاخه `feat/ai-contextual` سبز (`37876024278`)؛ ادغام روی `main` با fast-forward (`d2e937e`) |
| 🃏 فلش‌کارت و مرور (AGENTS §45) | ✅ **ادغام شده روی `main`** — شاخهٔ `feat/flashcards` با fast-forward تا `2a2071c` در ۰۲:۰۹:۱۵ UTC روی `main` رفت (بدون merge-commit)؛ CI شاخه 🟢 سبز (analyze + ۶۰/۶۰ تست) و پله‌های `Static analysis`/`Run tests` هر دو بیلد `main` هم سبز شد؛ **۲ Release تازه** (بخش ۳.۴) |
| تکمیل توسعه بخش‌ها | ⏳ در نوبت |

**وضعیت مخزن (خوانده شد، نه حدس — در همین اجرا):**
- شاخهٔ کاری اکنون **`main`** است (پیش‌تر `feat/flashcards` بود): HEAD=`10c1373` (`docs(roadmap): flashcards merged to main — status flip to done`، ۰۲:۱۰:۴۲ UTC — خارج از این نوبت و فقط با `ROADMAP.md` ثبت شد) و `origin/main` هم روی `10c1373` ⇒ **ریموت هم‌تراز** (`git merge-base HEAD origin/main` = خودِ HEAD)؛ `git status --short` خالی است (درخت کاری تمیز) و در این نوبت جز `ROADMAP.md` فایلی عوض نشد. `origin/feat/flashcards` اکنون `2a2071c` است یعنی **یک کامیت عقب‌تر از `main`**؛ `git log --merges` خالی است یعنی ادغام با **fast-forward** انجام شد، نه merge-commit.
- مجموع **۳۷ کامیت** در HEAD = **۲۱ کامیت کد/بازتولید** (۸ کامیت کدِ فلش‌کارت + `a64de84` + ۹ کامیت نوتیفیکیشن + `d39ef94` + `eb8d36c` + `fe5f5d1`) + **۱۵ کامیت `chore: auto roadmap publish`** + ۱ کامیت مستنداتی `10c1373`. **از نوبت پیش (۰۱:۵۴ UTC) فقط ۱ کامیت تازه ثبت شده: `10c1373` (۰۲:۱۰:۴۲ UTC، فقط `ROADMAP.md`)؛ کامیت کدِ تازه‌ای نیست.** در همین بازه `main` از `d8315e2` تا `2a2071c` fast-forward شد (یعنی کل شاخهٔ فلش‌کارت حالا در `main` است) و `10c1373` روی آن نشست.
- ⚠️ **تاریخچهٔ مخزن بازنویسی/واردات شده است:** پایه، `fe5f5d1` (`chore: import payayar snapshot for CI verification`، ۲۰۲۶-۱۰-۰۸) است. کامیت‌هایی که در نسخه‌های قبلیِ همین فایل آمده‌اند (`0afb2ad`، `92574eb`، `1500a85`، `ee238d0`، `d9f3bda`، `6a12ea8`، `3037e40` و…) دیگر در تاریخچه نیستند؛ ارجاع‌هایشان به‌عنوان **بایگانی تاریخی** بخوانید.
- شمارش مستقیم از HEAD: **۴۸ فایل `.dart` در `lib/`** (۴۷ منبع + ۱ `.g.dart`)، **۹ پوشه در `lib/features/`** (فلش‌کارت زیر `study/` است، پوشهٔ جدا نساخت)، **۸ کلاس `*Page`**، **۱۱ فایل تست با مجموع ۶۰ تست**، **۳۳۷ کلید پیام** در هر فایل arb (هر دو مجموعه یکسان؛ `flashcard_*`).
- **اجرا همچنان محلی ممکن نیست؛ دروازهٔ کیفیت CI است** — و آخرین تصویر CI چنین است: **۸ اجرای `Codegen` (workflow دستی) روی شاخه: ۷ شکست پیاپی (۱۹:۱۳ تا ۲۰:۰۶ UTC) و سرانجام ۱ اجرای سبز** — `37845407209` روی `73c94dd` (۲۱:۱۴:۵۲ تا ۲۱:۱۷:۳۹ UTC) که هر سه پله را سبز رد کرد: `Generate drift code`، `Static analysis` (`No issues found!` در ۲۱:۱۶:۵۲) و `Tests` (**۶۰ پاس / ۰ شکست** در ۲۱:۱۷:۳۴)؛ چون `app_database.g.dart` بازتولید شد، رباتِ همان اجرا کامیت `a64de84` را روی شاخه گذاشت. روی `main` هم اجرای زمان‌بندی‌شدهٔ `Android Build` (`37841301191` روی `d8315e2`، ۲۰:۴۱–۲۰:۵۱ UTC) سبز تمام شد و **Release `android-build-d8315e2`** ثبت شد. **نو در این نوبت (۰۱:۵۴ UTC): اجرای زمان‌بندی‌شدهٔ `Android Build` سبز تمام شد** — `37868655420` روی `main`/`d8315e2` از ۰۱:۱۲:۴۱ تا ۰۱:۲۳:۲۲ UTC همهٔ پله‌ها را ✓ رد کرد (`Static analysis`، `Run tests`، `Build release APK`، `Upload APK artifact` و `Publish to Release`) و artifact `PAYAYAR-apk` را گذاشت؛ چون SHA همان `d8315e2` است که Releaseاش ساعت ۲۰:۵۱ UTC ساخته شده، تگ/Release تازه‌ای ثبت نشد ⇒ شمار Releaseها **۱۱** ماند. نخستین ردیف `gh run list` همین اجرای سبز است و ردیف دوم `Codegen` سبزِ `37845407209` روی `73c94dd` در ۲۱:۱۴:۵۲ UTC. شاخهٔ کاری همچنان 🟢 سبز است. ریشهٔ ناتوانی محلی همچنان سقف حافظهٔ همین کانتینر است (`/sys/fs/cgroup/memory.max` ≈ **۱ گیگابایت** و `memory.peak` از آن گذشته ⇒ OOM با `analysis server exited with code -9` / «The Dart compiler exited unexpectedly»).

- **نو در این نوبت (2026-10-09 02:32 UTC): ادغام فلش‌کارت به `main` عملی شد و هر دو بیلد پس از push سبز شدند.** pushِ `2a2071c` (fast-forward شاخهٔ `feat/flashcards` تا نوکش روی `main`) در ۰۲:۰۹:۱۵ UTC چون `lib/**` را عوض کرد از فیلتر `paths` گذشت و هر دو workflow را هم‌زمان اجرا کرد: `Android Build` `37873204609` (۰۲:۰۹:۱۵–۰۲:۱۹:۴۴ UTC، **success**، همه پله‌ها ✓ شامل `Static analysis` و `Run tests`) و `Windows Build` `37873204616` (۰۲:۰۹:۱۵–۰۲:۱۶:۲۳ UTC، **success**، همه پله‌ها ✓)؛ حاصل **۲ Release تازه**: `android-build-2a2071c` (۰۲:۱۹:۳۹ UTC، اکنون «Latest») و `windows-build-2a2071c` (۰۲:۱۶:۱۶ UTC) ⇒ مجموع **۱۳ Release** (۷ اندروید + ۶ ویندوز). کامیت بعدی `10c1373` فقط `ROADMAP.md` را عوض کرد و از همان فیلتر `paths` نگذشت ⇒ اجرای تازه‌ای نگرفت. نکته: هر دو تگ جدید به `10c1373` اشاره می‌کنند نه `2a2071c` چون `gh release create` بدون `--target` تگ را روی نوکِ لحظه‌ای شاخهٔ پیش‌فرض می‌زند و `10c1373` (۰۲:۱۰:۴۲ UTC) وسطِ اجرا push شده بود؛ عنوان Release اما از `GITHUB_SHA` (= `2a2071c`) می‌آید.

### ۱.۱. کارِ موازیِ در جریان (غیرcommitted)

**دیگر موردی نیست:** `git status --short` در این نوبت خالی است. یادداشت سریع که قبلاً WIP بود،
واردات `fe5f5d1` آن را کامیت کرد و اکنون در HEAD هست (بخش ۳.۳)؛ نوتیفیکیشن هم کامل کامیت شد.

---

## ۲. پیشرفت بخش‌های محصول

اعداد از شمارش مستقیمِ کدِ کامیت‌شده (HEAD): **۴۸ فایل `.dart` در `lib/`**، **۹ پوشه در
`lib/features/`**، **۸ کلاس `*Page`**، **۱۱ فایل تست** با مجموع **۶۰ تست**، **۳۳۷ کلید پیام**
در هر فایل arb.

| بخش | وضعیت | واقعیت کد |
|---|---|---|
| خانه (Dashboard) | ✅ موجود + **یادداشت سریع** | `lib/features/home/home_page.dart`، `mini_calendar.dart`، `quick_note.dart` |
| برنامه‌ریزی | ✅ موجود + اعلان وظیفهٔ امروز | `lib/features/planning/planning_page.dart` (+ `planning_dashboard`، `task_dialog`) |
| مطالعه (درس/موضوع/جلسه) | ✅ موجود + **تایمر تمرکز/پومودورو** | `lib/features/study/study_page.dart`، `focus_timer.dart`، `focus_timer_card.dart` |
| آزمون‌ها | ✅ موجود | `lib/features/exams/exams_page.dart` |
| گزارش‌ها | ✅ ۸ کارت، ۳ تای آن نو (رفع باگ ۳) | `lib/features/reports/reports_page.dart` |
| سبک زندگی | ✅ موجود | `lib/features/lifestyle/lifestyle_page.dart` |
| مشاور AI | ✅ موجود | `lib/features/ai_advisor/ai_advisor_page.dart` |
| تنظیمات | ✅ موجود | `lib/features/settings/settings_page.dart` |
| 🔔 نوتیفیکیشن | ✅ موجود (بدون Page؛ در هدر پوسته) | `lib/features/notifications/bell_button.dart`، `notification_history_panel.dart` + `lib/app/shell.dart:107` |
| 🃏 فلش‌کارت و مرور | ✅ در `main` ادغام شد | `lib/features/study/flashcards_card.dart`، `flashcard_dialog.dart`، `flashcard_review_sheet.dart` + جدول/پرسش‌ها در `tables.dart` و `repositories.dart` |

**جزئیات گزارش‌ها:** ۸ کارت در صفحه — مطالعه، خواب (خطی)، ورزش (میله‌ای)، تعداد تست (میله‌ای)،
توزیع درس‌ها، برنامه‌ریزی، تسلط، روند نمرات آزمون. سه کارت اخیر نو هستند و هر سه روی
`_TrendCard` مشترک ساخته شده‌اند.

**ترجمه:** شمارش مستقیم در HEAD: **۳۳۷ کلید پیام** در `lib/core/l10n/fa.arb` و همان تعداد در
`en.arb` (مجموعهٔ کلیدها یکسان است؛ به‌علاوهٔ `@@locale`). آخرین رشد: **۲۰ کلید `flashcard_*`**
نو نسبت به `d8315e2` (۳۱۷ → ۳۳۷، هیچ کلیدی حذف/ادغام نشد). پیش‌ترها ۱۱ کلید `notif_*` و
۱۰ کلید `home_quickNote_*` اضافه شده بود (پایهٔ قدیمی‌تر: ۲۹۸).

**تست‌ها (۱۱ فایل، ۶۰ تست):**

| فایل | تعداد |
|---|---|
| `test/database_test.dart` | ۸ |
| `test/widget_test.dart` | ۹ |
| `test/focus_timer_test.dart` | ۹ |
| `test/notifications_test.dart` | ۹ |
| `test/notifications_ui_test.dart` | ۴ |
| `test/quick_note_test.dart` | ۵ |
| `test/flashcards_test.dart` | ۷ |
| `test/flashcards_ui_test.dart` | ۴ |
| `test/bug1_subject_dialog_test.dart` | ۱ |
| `test/bug2_exam_dialog_test.dart` | ۲ |
| `test/bug3_reports_charts_test.dart` | ۲ |

اجرا و تأیید این تست‌ها از مسیر **CI** می‌آید: روی `feat/flashcards` آخرین اجرای CI
(`37845407209` روی `73c94dd`، ۲۱:۱۴–۲۱:۱۷ UTC) **۶۰ پاس / ۰ شکست** دارد — هَنگِ قبلیِ
`test/flashcards_ui_test.dart` با `73c94dd` بسته شد؛ روی `main`/`cb0ee8a` هم کل مجموعه سبز بود
(جزئیات در بخش ۲.۱). اجرای محلی زیر سقف ۱ گیگابایتی cgroup ممکن نیست (بخش ۱).

---

## ۲.۱. انتشار خودکار (GitHub Actions)

سه workflow در `.github/workflows/`:

- **`android-build.yml`** — روی `ubuntu-latest`، Java 17، Flutter 3.47.6: `analyze` ← `test` ←
  `build apk --release` ← آپلود artifact ← انتشار روی Release با تگ `android-build-<sha7>`.
  علاوه بر push، هر ساعت (`17 * * * *`) هم اجرا می‌شود.
- **`windows-build.yml`** — روی `windows-latest`: `analyze` ← `test` ← `build windows --release` ←
  کامپایل نصب‌کننده با **Inno Setup** (`windows/installer/payayar.iss`) ← `PAYAYAR-Setup-<sha7>.exe`
  + `PAYAYAR-windows-<sha7>.zip` ← انتشار روی Release با تگ `windows-build-<sha7>`.
- **`codegen.yml`** (کامیت `d39ef94`) — بازتولید drift به‌صورت دستی (`workflow_dispatch`)؛
  برای وقتی که شمای دیتابیس عوض شده و باید کدِ `.g.dart` محلی بازتولید شود.

**شواهد واقعی در این نوبت:**
- `git ls-remote --tags origin`: **۷ تگ `android-build-*`** (`fe5f5d1`، `eb8d36c`، `f3f4b94`، `b7d32a1`، `cb0ee8a`، `d8315e2`، `2a2071c`) و **۶ تگ `windows-build-*`** (همان‌ها به‌جز `d8315e2`، به‌علاوهٔ `2a2071c`) ⇒ **۱۳ Release**؛ `gh release list` هم همین‌ها را نشان می‌دهد و «Latest» برابر `PAYAYAR build 2a2071c` (۰۲:۱۹:۳۹ UTC) است.
- `gh run list --limit 5..10` (این نوبت): دو ردیف نخست **`Windows Build`/`success` (`37873204616`) و `Android Build`/`success` (`37873204609`) روی `main`/`2a2071c`، هر دو از pushِ ادغام در ۰۲:۰۹:۱۵ UTC** هستند؛ پس از آن `Android Build` زمان‌بندی‌شدهٔ `main` (`37868655420`، ۰۱:۱۲:۴۱–۰۱:۲۳:۲۲ UTC) و سپس **۸ اجرای `Codegen` روی `feat/flashcards`** — ۷ تای اول `completed/failure` (workflow دستی، ۱۹:۱۳ تا ۲۰:۰۶ UTC) و **نفر آخر `37845407209` روی `73c94dd` سبز است** (۲۱:۱۴:۵۲–۲۱:۱۷:۳۹ UTC). از آن ۷ شکست، ۵ تا در پلهٔ «Static analysis» ایستادند (`37830363186`، `37830809886`، `37830939518`، `37831499223` و `37834515741` روی `d1d5de8`) و ۲ تای آخر (`37832499609` روی `a24b2bf` و `37835423560` روی `b5e0331`) از analyze گذشتند ولی در پلهٔ «Tests» ایستادند. **نو در این نوبت:** pushِ `2a2071c` همین دو بیلد سبز را ساخت و دو Release تازه ثبت کرد؛ بیلدهای سبزِ `push` پیشین (`main`/`cb0ee8a` در ۱۷:۵۲ UTC) جای خود را به این‌ها دادند.
- تاریخچهٔ analyze: `flutter analyze` ابتدا سه هشدار می‌داد — `unused_import` در `lib/features/study/study_page.dart:15`، `unnecessary_null_comparison` در `test/flashcards_test.dart:83`، `unused_local_variable` در `test/flashcards_ui_test.dart:112` — که `a24b2bf` (۱۹:۳۰ UTC) هر سه را بست؛ اجرای بعدی روی `d1d5de8` با یک lint تازه ایستاد (`prefer_initializing_formals` در `lib/features/study/flashcard_review_sheet.dart:18:9`) که `b5e0331` آن را برطرف کرد. نتیجه: **analyze روی HEAD سبز است.**
- ریشهٔ شکست‌های بسته‌شده (از `gh run view 37835423560 --log-failed`): آخرین شکستِ باقی‌مانده assertion نیست:
  1. `test/flashcards_ui_test.dart` — «management list shows box and deletes a card»: `TimeoutException after 0:10:00.000000: Test timed out after 10 minutes` ⇒ تست **آویزان می‌شد** (پمپ/ریندرش تمام نمی‌شد)، نه اینکه مقدار غلط ببیند. سه تست دیگرِ همین فایل (empty state، add dialog، review sheet) سبز شدند.
  2. سه شکستِ قبلیِ `a24b2bf` با `d1d5de8` بسته شدند: «add dialog creates a card and the card count appears»، «review sheet flips the card and finishes the session» و ««knew it» advances the box and schedules the next review» — هر سه در اجرای `37835423560` ✅ شدند.
  ← **`73c94dd` (۲۱:۱۴ UTC) آخرین هَنگ را هم بست** (فیلتر «الان» در `repositories.dart` + teardown قطعی در `flashcards_ui_test.dart`) و اجرای `37845407209` با پیام **«🎉 60 tests passed»** تمام شد ⇒ اکنون **هیچ شکستِ بازی روی شاخه نیست.**
- بیلدهای اندروید/ویندوز فقط روی `push` به `main` (با `paths` محدود به کد/دارایی/پاب‌فایل — `ROADMAP.md` داخل آن نیست) + ساعتی + دستی اجرا می‌شوند؛ پس کامیت‌های صرفاً رودمپی بیلد نمی‌گیرند (`10c1373` هم اجرا نگرفت) و کامیت‌های `feat/flashcards` هم تا پیش از ادغام اصلاً بیلد نشده بودند. آخرین اجرای سبز: `Windows Build` و `Android Build` روی `main`/`2a2071c` در **۰۲:۰۹:۱۵–۰۲:۱۹:۴۴ UTC** (هر دو `success`).
- جزئیات سطح پله‌ها روی `cb0ee8a` (`gh run view 37819944854 --job 113458086897`): `Static analysis ✓`، `Run tests ✓`، `Build release APK ✓`، `Publish to Release ✓`.
- **نو در این نوبت (۰۱:۵۴ UTC):** همان اجرای زمان‌بندی‌شدهٔ `Android Build` (`37868655420` روی `main`/`d8315e2`) حالا **`completed/success`** است (۰۱:۱۲:۴۱–۰۱:۲۳:۲۲ UTC، ۱۰m41s) و تمام پله‌های job را ✓ دارد: `Static analysis ✓`، `Run tests ✓`، `Build release APK ✓`، `Rename artifact ✓`، `Upload APK artifact ✓`، `Publish to Release (main only) ✓`. `gh release list` + `git ls-remote --tags` **بدون تغییر: ۱۱ Release** (۶ `android-build-*` + ۵ `windows-build-*`) و «Latest» همچنان `PAYAYAR build d8315e2` (۲۰:۵۱ UTC) — یعنی پلهٔ انتشار چیز تازه‌ای نساخت چون تگ `android-build-d8315e2` از قبل موجود است.
- **نو در این نوبت (2026-10-09 02:32 UTC):** pushِ ادغام فلش‌کارت (`2a2071c`) دو اجرای تازهٔ ساخت ساخت — `Windows Build` `37873204616` (۰۲:۰۹:۱۵–۰۲:۱۶:۲۳ UTC) و `Android Build` `37873204609` (۰۲:۰۹:۱۵–۰۲:۱۹:۴۴ UTC)، هر دو `success` با همهٔ پله‌ها ✓ (شامل `Static analysis` و `Run tests` روی `2a2071c` ⇒ analyze و ۶۰ تست روی `main` هم سبز است) و هر دو `Publish to Release` شان تگ تازه زد: `windows-build-2a2071c` و `android-build-2a2071c`. کامیت بعدی `10c1373` فقط `ROADMAP.md` را عوض کرد و از فیلتر `paths` نگذشت.
- ⚠️ دو هشدار قدیمیِ CI: `actions/checkout@v4` و `setup-java@v4` روی Node.js 20 منسوخ شده‌اند (فقط هشدار است)؛ و `ubuntu-latest` از ۲۰۲۶-۱۰-۱۹ به Ubuntu 26 مهاجرت می‌کند.

---

## ۳. باگ‌های رفع‌شده

وضعیت با اجرای واقعی تست‌ها و خواندن کدِ پیاده‌سازی تطبیق داده شده و اکنون از مسیر CI هم سبز است.

### باگ ۱ — ذخیره‌نشدن درس جدید ✅ رفع شد
- **ریشه:** `onPressed: _name.text.isEmpty ? null : _save` بدون `onChanged`/`setState` → دکمهٔ ذخیره برای همیشه غیرفعال می‌ماند.
- **رفع:** افزودن `onChanged: (_) => setState(() {})` به TextField و نمایش خطای دیتابیس با SnackBar به‌جای بلعیدن بی‌صدا.
- **تست:** `test/bug1_subject_dialog_test.dart` (۱ تست).

### باگ ۲ — ذخیره‌نشدن آزمون جدید ✅ رفع شد
- **ریشه:** هم‌ریشه با باگ ۱ در چهار جا: `exams_page`، `planning_page` (`_MockExamDialog`)، `study_page` (`_SubjectDialog` + `_TopicDialog`).
- **رفع کدی:** افزودن `onChanged` + نمایش خطا با SnackBar.
- **رفع تست:** دو مشکل در خودِ تست بود، نه در کد محصول:
  1. **هنگ:** `watchExams().first` (استریم) مانع از اتمام teardown می‌شد؛ با خواندن آینده‌ای `db.select(db.exams).get()` جایگزین شد.
  2. **پیدا نشدن دکمه:** صفحهٔ برنامه‌ریزی تب‌بندی است؛ تست اول تب «آزمون آزمایشی» را می‌زند تا `_MockExamView` رندر شود.
- **تست:** `test/bug2_exam_dialog_test.dart` (۲ تست).

### باگ ۳ — نمودارهای خواب/ورزش/تست در گزارش‌ها ✅ رفع شد
- **کد:** سه کارت در `reports_page.dart`: `_SleepReport` (خطی)، `_ExerciseReport` (میله‌ای)، `_TestCountReport` (میله‌ای) + `_TrendCard` مشترک.
- **منبع داده واقعی:** خواب ← `lifestyle_entries.sleep_minutes`؛ ورزش ← `lifestyle_entries.exercise_minutes`؛ تست ← `study_sessions.type == test`. ⚠️ جدول `test_sessions` در شمای فعلی وجود ندارد؛ شمارش، تعداد **جلسهٔ** تست است نه تعداد سؤال.
- **ترجمه:** ۶ کلید به هر دو arb اضافه شد.
- **تست:** `test/bug3_reports_charts_test.dart` (۲ تست).

### وضعیت نهایی
> `BUGS.md` از مخزن **حذف شد** و در هر نوبت دوباره بررسی می‌شود: نه در درخت کاری هست و نه در
> `git ls-files` ⇒ سه باگ واقعاً بسته‌اند و ۵ تستشان در میان ۶۰ تست HEAD است (اجرای کامل روی `main`/`cb0ee8a` سبز بود).
>
> **بازبینی KI-01:** در `lib/` هیچ فراخوانی `invoke(` نیست؛ رشته‌های snake_case فقط در فایل‌های
> `.g.dart` (نام ستون‌های drift)، دو کد خطای رابط کاربری (`invalid_key`، `network`) و فیلد JSON
> پیشنهاد وظیفه (`task_title`) آمده‌اند. پس ادعای «۹ فراخوانی snake_case» مربوط به پروژهٔ قدیمی
> Tauri بود و در کد فعلی Flutter یافت **نشد**.

---

## ۳.۱. پومودورو / تایمر تمرکز (AGENTS.md §44) ✅

**فایل‌ها:** `lib/features/study/focus_timer.dart` (منطق)، `lib/features/study/focus_timer_card.dart` (UI)، `test/focus_timer_test.dart` (۹ تست).

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

**تأیید:** تست‌های `focus_timer_test.dart` (۹ تست) در میان اجرای سبز CI روی HEAD.

**باقی‌ماندهٔ این قابلیت:** نمایشگر فشردهٔ زمان‌سنج در سایر صفحه‌ها (الان فقط کارت صفحهٔ مطالعه؛ خودِ وضعیت ولی در همه‌جا زنده است).

---

## ۳.۲. نوتیفیکیشن محلی (AGENTS.md §43.1 / HANDOFF §43.1) ✅

**۹ کامیت** از `9bbd174` تا `cb0ee8a` (۲۰۲۶-۱۰-۰۸) — همه در `main` و سبز در CI.

| قاعده | پیاده‌سازی |
|---|---|
| جدول SQLite، نه push server | `Notifications` در `lib/core/database/tables.dart` (id, title 1..200, body nullable, `status`, `taskId` ← `PlanTasks`, createdAt/updatedAt) |
| مهاجرت بدون از دست رفتن داده (§21) | `schemaVersion = 2` و `onUpgrade: if (from < 2) createTable(notifications)` در `app_database.dart` |
| چرخهٔ وضعیت `created → unread → read → actioned/dismissed` | `enum AppNotificationStatus` + متد‌های `NotificationRepository` در `lib/core/data/repositories.dart`: `watchActive`، `watchHistory`، `addNotification`، `markRead`، `dismiss`، `markAllRead`، `actionTask` |
| اکشن «انجام وظیفه» حتماً وضعیت فعلی task را دوباره چک کند | `actionTask(id)`: وظیفه را از نو می‌خواند؛ وظیفه ناموجود → `null`؛ انجام‌نشده → `unread`؛ انجام‌شده → `actioned` (بدون تغییر دروغین) |
| آیکون زنگ در TopBar با badge + پنل تاریخچه | `lib/features/notifications/bell_button.dart` + `notification_history_panel.dart`، متصل در `lib/app/shell.dart` |
| تولیدکننده‌ها (کامیت `cb0ee8a`) | `planning/task_dialog.dart` (یادآور وظیفهٔ امروز)، `study/focus_timer_card.dart` (پایان تایمر)، `study/study_page.dart` (ثبت جلسه) |
| بدون وابستگی جدید | فقط drift/Riverpodِ موجود؛ `flutter_local_notifications` اضافه نشد |

**تست:** `test/notifications_test.dart` (۹ تست: lifecycle + `actionTask`) و `test/notifications_ui_test.dart` (۴ تست: زنگ، پنل، نشانهٔ badge).
**ترجمه:** کلیدهای `notif*` به هر دو arb اضافه شد (در آن زمان جمع کلیدها ۳۱۷ بود؛ اکنون ۳۳۷).
**در CI:** بیلدهای `5135297` تا `cb0ee8a` سبزند؛ Releaseهای آن زمان `PAYAYAR build cb0ee8a` و `PAYAYAR Windows cb0ee8a` بود.

---

## ۳.۳. یادداشت سریع (design.md §12.1) ✅

قبلاً WIPِ غیرcommitted بود؛ الان در HEAD است (وارد شده در `fe5f5d1`، درخت کاری تمیز).

- **کد:** `lib/features/home/quick_note.dart` (۲۲۱ خط): `QuickNoteNotifier` (state app-scoped) + `QuickNoteCard` که در `home_page.dart:129` به‌عنوان کارت خانه رندر می‌شود.
- **تست:** `test/quick_note_test.dart` (۵ تست).
- **ترجمه:** ۱۰ کلید `home_quickNote_*` در `fa.arb`/`en.arb`.

---

## ۳.۴. فلش‌کارت و مرور (AGENTS.md §45) ✅ تکمیل و ادغام شد

**۸ کامیت کد + ۱ کامیت بازتولید خودکار** (۲۰۲۶-۱۰-۰۸، ۱۹:۱۳ تا ۲۱:۱۷ UTC) — همگی اکنون در `main` هستند: شاخهٔ `feat/flashcards` در ۰۲:۰۹:۱۵ UTC با fast-forward تا `2a2071c` روی `main` رفت و push شد (هیچ merge-commitی ساخته نشد):

| کامیت | محتوا |
|---|---|
| `6a4d374` | لایهٔ دادهٔ مرور پراکنده (SM-2 lite) |
| `08c93f2` | کارت صفحهٔ درس، جلسهٔ مرور، UI افزودن/مدیریت (HANDOFF §45) |
| `e28b810` | ثبت `Flashcards`/`ReviewItems` در آنتیشن `@DriftDatabase` |
| `2abdb23` | نوع `orderBy` + `ListView` غیر-const در هارنس تست |
| `a24b2bf` | برطرف کردن ۳ هشدار `flutter analyze` (import بلااستفاده، مقایسهٔ null، متغیر بلااستفاده) |
| `d1d5de8` | قطعی‌سازی UI: پاس دادن صف مرور به sheet، `pop` پیش از persist، ارقام غربی در انتظار تست‌ها (۳ تست شکست‌خورده را بست) |
| `b5e0331` | initializing-formal برای رفع lint `prefer_initializing_formals` در `flashcard_review_sheet.dart` |
| `73c94dd` | فیلتر «الان»ی مرور (`fresh now`) در `repositories.dart` + teardown قطعی تست UI؛ ابتدا در codespace و سپس در CI تأیید شد |
| `a64de84` | بازتولید `app_database.g.dart` توسط ربات CI (۴۶۵۹+/۲۸۷۷−) |

**فایل‌ها:** `lib/features/study/flashcards_card.dart`، `flashcard_dialog.dart`، `flashcard_review_sheet.dart`؛ شمای جدول در `lib/core/database/tables.dart` و `app_database.dart`؛ منطق در `lib/core/data/repositories.dart` + `providers.dart`.
**تست:** `test/flashcards_test.dart` (۷ تست) و `test/flashcards_ui_test.dart` (۴ تست) — در مجموع ۱۱ تست نو.
**ترجمه:** ۲۰ کلید `flashcard_*` به هر دو arb اضافه شد (۳۱۷ → ۳۳۷).
**وضعیت CI: 🟢 سبز** — آخرین اجرای `Codegen` (`37845407209` روی `73c94dd`، ۲۱:۱۴–۲۱:۱۷ UTC) هر سه پله را سبز رد کرد: `Static analysis` با `No issues found!` و `Tests` با **۶۰ پاس / ۰ شکست**؛ رباتِ همان اجرا `app_database.g.dart` را هم بازتولید و کامیت کرد (`a64de84`). ادغام انجام شد: همان pushِ ۰۲:۰۹:۱۵ UTC هر دو بیلد را سبز اجرا کرد (`Static analysis` + `Run tests` روی `main` هم ✓) و دو Release تازه ساخت.

---

## ۴. مراحل بعدی

1. 🤖 AI بخش‌به‌بخش (AGENTS §7.A) — ✅ **انجام شد و روی `main` ادغام شد** (`d2e937e`)؛ «کمک AI» در برنامه‌ریزی/مطالعه/آزمون/گزارش‌ها، پاسخ فقط‌خواندنی، حداقل context. قدم بعدی: نمایشگر فشردهٔ زمان‌سنج (§44.4) و بقیهٔ موارد جدول بالا.
2. 🃏 فلش‌کارت و مرور (AGENTS §45) — ✅ **انجام شد**: ادغام با fast-forward روی `main` (نوک `2a2071c`، push در ۰۲:۰۹:۱۵ UTC)، CI سبز (analyze پاک + ۶۰/۶۰ تست) و هر دو بیلد Android/Windows سبز با ۲ Release تازه. قدم بعدی ردیف ۳.
3. نمایشگر فشردهٔ تایمر تمرکز در صفحه‌های دیگر (باقی‌ماندهٔ §44).
4. به‌روزرسانی `HANDOFF.md` — بخش ۳ آن هنوز می‌گوید «یادداشت سریع push نشده» که دیگر درست نیست.
5. رفع هشدار منسوخ‌شدن `actions/checkout@v4` / `setup-java@v4` (Node.js 20) در workflowها.
6. روال دوره‌ای: بعد از هر push، سبز بودن Android/Windows Build و ثبت Release را با `gh run list` چک کردن.

---

## ۵. لاگ به‌روزرسانی‌ها

> ⚠️ تاریخچهٔ گیت در ۲۰۲۶-۱۰-۰۸ بازنویسی شد (پایه: `fe5f5d1`)؛ کامیت‌های این لاگ پیش از آن
> تاریخ، دیگر در `git log` دیده نمی‌شوند و فقط به‌عنوان سابقهٔ کار هستند.

- 2026-10-03 — راه‌اندازی محیط، نصب Flutter و وابستگی‌ها؛ شروع رفع باگ‌ها.
- 2026-10-03 12:05 UTC — نصب `flutter/agent-plugins` (۲۵ مهارت + `dart mcp-server`)؛ پیاده‌سازی کد باگ ۳ + تست آن؛ `flutter analyze` پاک؛ تست باگ ۱ پاس؛ تست باگ ۲ hang شد و در ریشه‌یابی است.
- 2026-10-03 13:12 UTC — همگام‌سازی با `origin/main` (بدون تداخل، HEAD=`24f09be`)؛ بازخوانی `BUGS.md` و شمارش کد: ۸ بخش/۸ صفحه، ۴۰ فایل dart در lib، ۸ فایل تست؛ تأیید رندر ۳ کارت نو گزارش و ۶ کلید l10n در هر دو arb؛ ثبت اینکه تست باگ ۳ در کامیت اخیر viewport گرفته ولی نتیجه‌اش تأیید نشده، و اینکه `BUGS.md` با کد ناهماهنگ است.
- 2026-10-03 16:40 UTC — **بستن هر سه باگ.** ریشه‌یابی کامل هنگ تست باگ ۲ (۵ فایل تشخیصی موقت ساخته و سپس حذف شد): عامل هنگ `watchExams().first` بود، نه کد محصول؛ با خواندن آینده‌ای جایگزین شد. مشکل دوم: دکمهٔ «ثبت آزمون آزمایشی» در تب چهارم صفحهٔ برنامه‌ریزی است و تست به تب نمی‌رفت. نتیجهٔ نهایی: `flutter test` → **۲۲ تست پاس**، `flutter analyze` → **No issues found**. `BUGS.md` از مخزن حذف شد.
- 2026-10-03 16:50 UTC — راستی‌آزمایی قبلی: اجرای کامل (۲۲/۲۲ پاس)؛ آزمون A/B روی تست باگ ۲ تأیید کرد نسخهٔ قدیمی (`watchExams().first`) واقعاً hang می‌کند. شمارش مستقیم l10n: **۲۷۴** کلید در هر arb؛ بازبینی KI-01: صفر فراخوانی `invoke(` در `lib/`.
- 2026-10-03 17:45 UTC — **پومودورو (AGENTS §44) اضافه شد.** `focus_timer.dart` (state اپ-اسکوپ، ثبت از طریق `study_sessions`) + `focus_timer_card.dart` (کارت در صفحهٔ مطالعه با `ProgressRing`) + ۹ تست در `focus_timer_test.dart`. ۲۴ کلید l10n در fa/en، `AppRadius.icon` به توکن‌ها اضافه شد، `AppSettings.focusMinutes` ذخیره می‌شود. نتیجه: `flutter analyze` → No issues found؛ `flutter test` → **۳۱ تست پاس**.
- 2026-10-03 18:10 UTC — **به‌روزرسانی و انتشار رودمپ پس از ۴ کامیت جدید** (`92574eb` CI اندروید، `1500a85` CI ویندوز، `ee238d0` نصب‌کنندهٔ Inno Setup، `0afb2ad` پومودورو). راستی‌آزمایی روی کلون تمیز HEAD: `flutter analyze` → No issues found، `flutter test` → **۳۱/۳۱ پاس**؛ شمارش مستقیم کد: ۴۲ فایل dart در `lib/`، ۱۳ فایل در `lib/features/`، ۸ کلاس `*Page`، ۶ فایل تست/۳۱ تست، **۲۹۸** کلید l10n در هر arb. تأیید شد `BUGS.md` نه در درخت است نه در `git ls-files`. شواهد CI از ریموت: ۲ تگ `android-build-*` و ۳ تگ `windows-build-*` (۵ Release). ثبت شد که یک جلسهٔ موازی WIP یادداشت سریع را غیرcommitted گذاشته است.
- 2026-10-08 18:20 UTC — **بازخوانی واقعیت پس از بازنویسی تاریخچه + تکمیل نوتیفیکیشن.** خواندن `git log` (۱۲ کامیت، HEAD=`cb0ee8a` هم‌تراز `origin/main`، درخت تمیز)، `git status` (خالی)، `gh run list` (۵ اجرای اخیر همه `success`). شمارش مستقیم HEAD: ۴۵ فایل dart در `lib/`، ۹ پوشه `features`، ۸ `*Page`، **۹ فایل تست / ۴۹ تست**، **۳۱۷ کلید** l10n در هر arb (دو مجموعه یکسان). شواهد ریموت: **۵ تگ اندروید + ۵ تگ ویندوز = ۱۰ Release**؛ سطح پله‌ها روی `cb0ee8a`: `Static analysis ✓`، `Run tests ✓`. اجرای محلی `flutter analyze`/`flutter test` در این نوبت ممکن نشد: هر دو زیر سقف حافظهٔ کانتینر (`memory.max` ≈ ۱ گیگابایت، `memory.peak` از آن گذشت) با exit -9 / «compiler exited unexpectedly» مردند ⇒ طبق روال، CI دروازهٔ کیفیت است. بخش‌های نو: ۳.۲ نوتیفیکیشن، ۳.۳ یادداشت سریع؛ جدول وضعیت کلی همگام شد (نوتیفیکیشن و یادداشت سریع از «در نوبت» به ✅ رفتند).
- 2026-10-08 18:56 UTC — **به‌روزرسانی دوره‌ای رودمپ.** خواندن واقعیت: `git log --oneline -8` (HEAD=`151bce0` ← `cb0ee8a`، ۱۳ کامیت)، `git status --short` (خالی)، `gh run list --limit 5` (هر ۵ تا `completed/success`؛ آخرین‌ها Android/Windows Build روی `cb0ee8a` در ۱۷:۵۲ UTC)، `gh release list` + `git ls-remote --tags` (۱۰ Release، آخرین‌ها `PAYAYAR build/Windows cb0ee8a` در ۱۸:۰۱/۱۸:۰۰ UTC). `git ls-remote origin main` روی `151bce0` ⇒ همگام. تغییرات این نوبت: خط «آخرین به‌روزرسانی»، بولت‌های وضعیت مخزن (۱۳ کامیت + `151bce0`) و شواهد CI؛ جدول وضعیت کلی بدون تغییر (کدی از `cb0ee8a` به بعد عوض نشده). اجرای محلی لازم نبود چون کد تغییری نکرده است.
- 2026-10-08 19:35 UTC — **به‌روزرسانی دوره‌ای رودمپ در میان کار فلش‌کارت.** خواندن واقعیت: `git log --oneline -8` (HEAD در شروع نوبت `2abdb23` روی شاخهٔ `feat/flashcards`؛ `origin/main` روی `d8315e2`)، `git status --short` (خالی)، `gh run list --limit 12` (۵ اجرای اخیر `Codegen` روی `feat/flashcards` همه `failure`؛ آخرین بیلدهای سبز Android/Windows روی `main`/`cb0ee8a` در ۱۷:۵۲ UTC)، `gh run view --log-failed` و `gh run view 37832499609 --log` (ریشهٔ شکست‌ها: ۳ هشدار `flutter analyze` در `study_page.dart:15`، `flashcards_test.dart:83`، `flashcards_ui_test.dart:112`، و سپس «56 tests passed, 4 failed»). **همزمانی:** کامیت `a24b2bf` (۱۹:۳۰ UTC) همان سه هشدار را برطرف کرد و قبل از push این نوبت وارد تاریخچه شد؛ نتیجه اینکه analyze اکنون سبز ولی پلهٔ «Tests» با ۴ شکست قرمز است. شمارش مستقیم HEAD: **۴۸ فایل dart در `lib/`**، ۹ پوشه `features`، ۸ `*Page`، **۱۱ فایل تست / ۶۰ تست**، **۳۳۷ کلید** l10n در هر arb (+۲۰ کلید `flashcard_*`). تگ‌ها/Releaseها بدون تغییر (۵ + ۵ = ۱۰). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ جدول وضعیت کلی (ردیف‌های analyze/test بازنویسی شدند، ردیف فلش‌کارت از «در نوبت» به 🔄 رفت، تاریخ سبز بیلدها افزوده شد)؛ بولت‌های وضعیت مخزن (۲۰ کامیت، ۵ کامیت نو، آخرین وضعیت CI)؛ شمارش‌های بخش ۲، جدول محصول (ردیف فلش‌کارت)، جدول تست‌ها (+۲ فایل)، بخش ترجمه؛ شواهد CI (بخش ۲.۱، با فهرست ۴ تست شکست‌خورده)؛ بخش نوی ۳.۴؛ مراحل بعدی. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نبود. انتشار: commit `01db0f4` و ادامهٔ همین به‌روزرسانی، هر دو روی `feat/flashcards` (چون HEAD روی این شاخه است؛ `main` هنوز `d8315e2` را دارد).
- 2026-10-08 20:10 UTC — **به‌روزرسانی دوره‌ای رودمپ.** خواندن واقعیت: `git log --oneline -8` (HEAD=`b5e0331`، مجموع ۲۳ کامیت، ۹ تا بعد از نوک `main`)، `git status --short` (خالی)، `gh run list --limit 8` (۷ اجرای `Codegen` روی `feat/flashcards` همه `failure`؛ آخرین اجرای سبز Android/Windows همچنان `main`/`cb0ee8a` در ۱۷:۵۲ UTC)، `gh run view 37834515741 --log-failed` و `gh run view 37835423560 --log-failed` (ریشه‌ها: lint تازهٔ `prefer_initializing_formals` در `flashcard_review_sheet.dart:18:9` روی `d1d5de8`، و سپس «59 tests passed, 1 failed» با `TimeoutException after 0:10:00` روی «management list shows box and deletes a card»). **۲ کامیت کدِ نو** نسبت به نوبت پیش: `d1d5de8` (۱۹:۴۶ UTC) و `b5e0331` (۱۹:۵۴ UTC). شمارش مستقیم HEAD بدون تغییر: **۴۸ فایل dart در `lib/`**، **۹ پوشه `features`**، **۸ `*Page`**، ۱۱ فایل تست / ۶۰ تست، **۳۳۷ کلید** l10n در هر arb؛ تگ‌ها/Releaseها بدون تغییر (۵ + ۵ = ۱۰). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ جدول وضعیت کلی (ردیف‌های `analyze`/`flutter test` و ردیف فلش‌کارت)؛ بولت‌های وضعیت مخزن (۲۳ کامیت، ۲ کامیت نو، ۷ اجرای CI)؛ روایت تست‌های بخش ۲؛ شواهد CI در بخش ۲.۱ (بازنویسی به ۵۹/۱ و فهرست شکست باقی‌مانده)؛ بخش ۳.۴ (+۲ ردیف کامیت و وضعیت CI)؛ مراحل بعدی. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نبود ⇒ طبق روال، CI دروازهٔ کیفیت است.
- 2026-10-08 20:49 UTC — **به‌روزرسانی دوره‌ای رودمپ (بدون کامیت کدِ نو).** خواندن واقعیت: `git log --oneline -8` (HEAD=`63b5c23` = انتشار خودکارِ نوبت پیش، مجموع ۲۴ کامیت، ۱۰ تا بعد از نوک `main`/`d8315e2`)، `git status --short` (خالی)، `git ls-remote` (`origin/feat/flashcards`=HEAD ⇒ همگام؛ `origin/main`=`d8315e2`)، `gh run list --limit 12` و `gh run view 37841301191` (۷ اجرای `Codegen` روی شاخه همچنان همه `failure` و بدون اجرای تازه؛ **نو:** اجرای زمان‌بندی‌شدهٔ `Android Build` روی `main`/`d8315e2` از ۲۰:۴۱ UTC در جریان است و تا لحظهٔ نوشتن `Static analysis ✓`، `Run tests ✓` را سبز رد کرده و در `Build release APK` است)، `gh release list` + `git ls-remote --tags` (۱۰ Release، بدون تغییر؛ آخرین‌ها `PAYAYAR build/Windows cb0ee8a`). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ ردیف CI اندروید در جدول وضعیت کلی (+اجرای در جریان)؛ بولت‌های وضعیت مخزن (۲۴ کامیت، بدون کامیت کدِ نو)؛ بولت CI در همان بخش (افزودن اجرای زمان‌بندی‌شده)؛ شواهد CI در بخش ۲.۱ (بازنویسی به `--limit 12` + اجرای در جریان)؛ همین لاگ. ردیف‌های دیگر جدول وضعیت کلی بدون تغییر ماندند چون کد از `b5e0331` به بعد عوض نشده است.
- 2026-10-08 21:28 UTC — **به‌روزرسانی دوره‌ای رودمپ (۲ کامیت تازه و سبزشدن CI شاخه).** خواندن واقعیت: `git log --oneline -8` (HEAD=`73c94dd`، مجموع ۲۶ کامیت، ۱۲ تا بعد از نوکِ `main`/`d8315e2`؛ `origin/feat/flashcards` روی `a64de84` ⇒ ریموت ۱ کامیت جلوتر)، `git status --short` (خالی)، `gh run list --limit 12` + `gh run view 37845407209` + `gh run view 37841301191` (نخستین `Codegen` سبز روی شاخه: `No issues found!` و **۶۰/۶۰ تست** روی `73c94dd` در ۲۱:۱۷ UTC، و رباتِ همان اجرا `a64de84` را گذاشت؛ `Android Build` زمان‌بندی‌شدهٔ `main`/`d8315e2` سبز در ۲۰:۴۱–۲۰:۵۱ UTC)، `gh release list` + `git ls-remote --tags` (**۱۱ Release**: ۶ اندروید + ۵ ویندوز؛ Latest = `PAYAYAR build d8315e2`). **۲ کامیت تازه نسبت به نوبت پیش:** `73c94dd` (کد) و `a64de84` (بازتولید `.g.dart`)؛ شمارش‌های HEAD بدون تغییر (۴۸ فایل `.dart` در `lib/`، ۹ پوشه `features`، ۱۱ فایل تست / ۶۰ تست، ۳۳۷ کلید l10n). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ جدول وضعیت کلی (ردیف‌های `analyze` و `flutter test` از ❌ به ✅، ردیف CI اندروید با Release ششم و پایان‌یافتن اجرای در جریان، ردیف فلش‌کارت با CI سبز)؛ بولت‌های وضعیت مخزن (۲۶/۲۷ کامیت، ۲ کامیت نو، بازنویسی بولت CI)؛ روایت تست‌های بخش ۲؛ شواهد CI در بخش ۲.۱ (۱۱ Release، اجرای سبز، بستنِ هَنگ)؛ بخش ۳.۴ (+۲ ردیف کامیت و وضعیت 🟢)؛ مراحل بعدی؛ همین لاگ. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نیست ⇒ طبق روال، CI دروازهٔ کیفیت است.
- 2026-10-08 22:00 UTC — **به‌روزرسانی دوره‌ای رودمپ (بدون هیچ کامیت یا اجرای تازه).** خواندن واقعیت: `git log --oneline -8` (HEAD=`711af07` = انتشار خودکارِ نوبت پیش در ۲۱:۲۹ UTC، مجموع ۲۸ کامیت، ۱۴ تا بعد از نوکِ `main`/`d8315e2` شامل ۵ کامیت رودمپ ⇒ ۹ کامیت کد/بازتولید)، `git status --short` (خالی)، `git ls-remote origin` (`origin/feat/flashcards`=`711af07` ⇒ **هم‌تراز با محلی**؛ `origin/main`=`d8315e2` بدون تغییر)، `gh run list --limit 10` + `gh release list` + `git ls-remote --tags` (**هیچ اجرای تازه‌ای از ۲۱:۱۷ UTC**؛ همان ۸ اجرای `Codegen` روی شاخه (۷ شکست + ۱ سبز `37845407209`)، `Android Build` سبزِ `main`/`d8315e2` در ۲۰:۴۱–۲۰:۵۱ UTC، و **۱۱ Release** بدون تغییر). شمارش‌های HEAD بدون تغییر (۴۸ فایل `.dart` در `lib/`، ۹ پوشه `features`، ۱۱ فایل تست / ۶۰ تست، ۳۳۷ کلید l10n). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ بولت‌های وضعیت مخزن (HEAD=`711af07`، هم‌ترازی ریموت به‌جای «۱ کامیت جلوتر»، ۲۸/۱۴ کامیت، ثبتِ اینکه کامیت تازه‌ای نیست)؛ بولت CI در همان بخش (+بی‌تحرکی از ۲۱:۱۷ UTC)؛ شواهد CI در بخش ۲.۱ (+یک بولت نو)؛ همین لاگ. جدول‌های وضعیت کلی، محصول و تست‌ها بدون تغییر ماندند چون کد از `73c94dd` به بعد عوض نشده است. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نیست ⇒ طبق روال، CI دروازهٔ کیفیت است.
- 2026-10-08 22:33 UTC — **به‌روزرسانی دوره‌ای رودمپ (بدون هیچ کامیت کد یا اجرای تازه).** خواندن واقعیت: `git log --oneline -8` (HEAD=`3090e7c` = انتشار خودکارِ نوبت پیش در ۲۲:۰۲ UTC، مجموع ۲۹ کامیت، ۱۵ تا بعد از نوکِ `main`/`d8315e2` شامل ۶ کامیت رودمپ ⇒ ۹ کامیت کد/بازتولید)، `git status --short` (خالی)، `git merge-base HEAD origin/main` (= `d8315e2` ⇒ شاخه بدون واگرایی روی نوکِ `main` سوار است) و `git ls-remote origin` (`origin/feat/flashcards`=`3090e7c` ⇒ **هم‌تراز با محلی**؛ `origin/main`=`d8315e2` بدون تغییر)، `gh run list --limit 10` + `gh release list` + `git ls-remote --tags` (**هیچ اجرای تازه‌ای از ۲۱:۱۷ UTC**؛ همان ۸ اجرای `Codegen` روی شاخه (۷ شکست + ۱ سبز `37845407209` در ۲۱:۱۴:۵۲–۲۱:۱۷:۳۹ UTC)، `Android Build` سبزِ `main`/`d8315e2` در ۲۰:۴۱–۲۰:۵۱ UTC، و **۱۱ Release** بدون تغییر؛ «Latest» = `PAYAYAR build d8315e2`). شمارش‌های HEAD بدون تغییر (۴۸ فایل `.dart` در `lib/`، ۹ پوشه `features`، ۱۱ فایل تست / ۶۰ تست، ۳۳۷ کلید l10n). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ بولت‌های وضعیت مخزن (HEAD=`3090e7c`، ۲۹/۱۵ کامیت، ۶ کامیت رودمپ، افزودنِ merge-base، ثبتِ اینکه کامیت تازه‌ای نیست)؛ بولت CI در همان بخش و بولت «نو» در بخش ۲.۱ (زمان به ۲۲:۳۳ + افزودن نخستین ردیف `gh run list`)؛ همین لاگ. جدول‌های وضعیت کلی، محصول و تست‌ها و بخش‌های ۳.۱–۳.۴ بدون تغییر ماندند چون کد از `73c94dd` به بعد عوض نشده است. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نیست ⇒ طبق روال، CI دروازهٔ کیفیت است.
- 2026-10-08 23:06 UTC — **به‌روزرسانی دوره‌ای رودمپ (باز هم بدون هیچ کامیت کد یا اجرای تازه).** خواندن واقعیت: `git log --oneline -8` + `git log -3 --format` (HEAD=`4e85561` = انتشار خودکارِ نوبت پیش در ۲۲:۳۵ UTC، مجموع ۳۰ کامیت، ۱۶ تا بعد از نوکِ `main`/`d8315e2` شامل ۷ کامیت رودمپ ⇒ ۹ کامیت کد/بازتولید)، `git status --short` (خالی)، `git merge-base HEAD origin/main` (= `d8315e2`) و `git ls-remote origin feat/flashcards main` (`origin/feat/flashcards`=`4e85561` ⇒ **هم‌تراز با محلی**؛ `origin/main`=`d8315e2` بدون تغییر)، `gh run list --limit 10` و `gh release list` (**هیچ اجرای تازه‌ای از ۲۱:۱۷ UTC**؛ نخستین ردیف همچنان `Codegen`/`success` روی `73c94dd` در ۲۱:۱۴:۵۲ UTC، `Android Build` سبزِ `main`/`d8315e2` در ۲۰:۴۱–۲۰:۵۱ UTC، و **۱۱ Release** بدون تغییر؛ «Latest» = `PAYAYAR build d8315e2`). شمارش‌های HEAD بدون تغییر (۴۸ فایل `.dart` در `lib/`، ۹ پوشه `features`، ۱۱ فایل تست / ۶۰ تست، ۳۳۷ کلید l10n). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ بولت‌های وضعیت مخزن (HEAD=`4e85561`، ۳۰/۱۶ کامیت، ۷ کامیت رودمپ، ثبتِ اینکه کامیت تازه‌ای نیست)؛ بولت CI در همان بخش و بولت «نو» در بخش ۲.۱ (زمان به ۲۳:۰۶)؛ همین لاگ. جدول‌های وضعیت کلی، محصول و تست‌ها و بخش‌های ۳.۱–۳.۴ بدون تغییر ماندند چون کد از `73c94dd` به بعد عوض نشده است. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نیست ⇒ طبق روال، CI دروازهٔ کیفیت است.
- 2026-10-08 23:40 UTC — **به‌روزرسانی دوره‌ای رودمپ (باز هم بدون هیچ کامیت کد یا اجرای تازه).** خواندن واقعیت: `git log --oneline -8` + `git log -1 --format='%ci %H'` (HEAD=`1553fe1` = انتشار خودکارِ نوبت پیش در ۲۳:۰۷:۴۷ UTC، مجموع ۳۱ کامیت، ۱۷ تا بعد از نوکِ `main`/`d8315e2` شامل ۸ کامیت رودمپ ⇒ ۹ کامیت کد/بازتولید)، `git status --short` (خالی)، `git merge-base HEAD origin/main` (= `d8315e2`) و `git ls-remote origin feat/flashcards main` (`origin/feat/flashcards`=`1553fe1` ⇒ **هم‌تراز با محلی**؛ `origin/main`=`d8315e2` بدون تغییر)، `gh run list --limit 10` و `gh release list` (**هیچ اجرای تازه‌ای از ۲۱:۱۷ UTC**؛ نخستین ردیف همچنان `Codegen`/`success` روی `73c94dd` در ۲۱:۱۴:۵۲ UTC، `Android Build` سبزِ `main`/`d8315e2` در ۲۰:۴۱–۲۰:۵۱ UTC، و **۱۱ Release** بدون تغییر؛ «Latest» = `PAYAYAR build d8315e2`). شمارش‌های HEAD بدون تغییر (۴۸ فایل `.dart` در `lib/`، ۹ پوشه `features`، ۱۱ فایل تست / ۶۰ تست، ۳۳۷ کلید l10n). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ بولت‌های وضعیت مخزن (HEAD=`1553fe1`، ۳۱/۱۷ کامیت، ۸ کامیت رودمپ، ثبتِ اینکه کامیت تازه‌ای نیست)؛ بولت CI در همان بخش و بولت «نو» در بخش ۲.۱ (زمان به ۲۳:۴۰)؛ همین لاگ. جدول‌های وضعیت کلی، محصول و تست‌ها و بخش‌های ۳.۱–۳.۴ بدون تغییر ماندند چون کد از `73c94dd` به بعد عوض نشده است. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نیست ⇒ طبق روال، CI دروازهٔ کیفیت است.
- 2026-10-09 00:13 UTC — **به‌روزرسانی دوره‌ای رودمپ (باز هم بدون هیچ کامیت کد یا اجرای تازه).** خواندن واقعیت: `git log --oneline -8` + `git log -1 --format='%ci %H'` (HEAD=`ae26b40` = انتشار خودکارِ نوبت پیش در ۲۳:۴۱:۲۶ UTC، مجموع ۳۲ کامیت، ۱۸ تا بعد از نوکِ `main`/`d8315e2` شامل ۹ کامیت رودمپ ⇒ ۹ کامیت کد/بازتولید)، `git status --short` (خالی)، `git merge-base HEAD origin/main` (= `d8315e2`) و `git ls-remote origin feat/flashcards main` (`origin/feat/flashcards`=`ae26b40` ⇒ **هم‌تراز با محلی**؛ `origin/main`=`d8315e2` بدون تغییر)، `gh run list --limit 10` + `gh release list` + `git ls-remote --tags` (**هیچ اجرای تازه‌ای از ۲۱:۱۷ UTC**؛ نخستین ردیف همچنان `Codegen`/`success` روی `73c94dd` در ۲۱:۱۴:۵۲ UTC، `Android Build` زمان‌بندی‌شدهٔ `main`/`d8315e2` در ۲۰:۴۱–۲۰:۵۱ UTC، و **۱۱ تگ/Release** (۶ اندروید + ۵ ویندوز) بدون تغییر؛ «Latest» = `PAYAYAR build d8315e2`). شمارش‌های HEAD بدون تغییر (۴۸ فایل `.dart` در `lib/`، ۹ پوشه `features`، ۱۱ فایل تست / ۶۰ تست، ۳۳۷ کلید l10n). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ بولت‌های وضعیت مخزن (HEAD=`ae26b40`، ۳۲/۱۸ کامیت، ۹ کامیت رودمپ، ثبتِ اینکه کامیت تازه‌ای نیست)؛ بولت CI در همان بخش و بولت «نو» در بخش ۲.۱ (زمان به ۰۰:۱۳)؛ همین لاگ. جدول‌های وضعیت کلی، محصول و تست‌ها و بخش‌های ۳.۱–۳.۴ بدون تغییر ماندند چون کد از `73c94dd` به بعد عوض نشده است. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نیست ⇒ طبق روال، CI دروازهٔ کیفیت است.
- 2026-10-09 00:46 UTC — **به‌روزرسانی دوره‌ای رودمپ (باز هم بدون هیچ کامیت کد یا اجرای تازه).** خواندن واقعیت: `git log --oneline -8` + `git log -1 --format='%ci %H'` (HEAD=`f29b599` = انتشار خودکارِ نوبت پیش در ۰۰:۱۴:۴۸ UTC، مجموع ۳۳ کامیت، ۱۹ تا بعد از نوکِ `main`/`d8315e2` شامل ۱۰ کامیت رودمپ ⇒ ۹ کامیت کد/بازتولید)، `git status --short` (خالی)، `git merge-base HEAD origin/main` (= `d8315e2`) و `git ls-remote origin feat/flashcards main` (`origin/feat/flashcards`=`f29b599` ⇒ **هم‌تراز با محلی**؛ `origin/main`=`d8315e2` بدون تغییر)، `gh run list --limit 5` و `--limit 10` + `gh release list` + `git ls-remote --tags` (**هیچ اجرای تازه‌ای از ۲۱:۱۷ UTC**؛ نخستین ردیف همچنان `Codegen`/`success` روی `73c94dd` در ۲۱:۱۴:۵۲ UTC، `Android Build` زمان‌بندی‌شدهٔ `main`/`d8315e2` در ۲۰:۴۱–۲۰:۵۱ UTC، و **۱۱ تگ/Release** (۶ اندروید + ۵ ویندوز) بدون تغییر؛ «Latest» = `PAYAYAR build d8315e2`). شمارش‌های HEAD بدون تغییر (۴۸ فایل `.dart` در `lib/`، ۹ پوشه `features`، ۱۱ فایل تست / ۶۰ تست، ۳۳۷ کلید l10n). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ بولت‌های وضعیت مخزن (HEAD=`f29b599`، ۳۳/۱۹ کامیت، ۱۰ کامیت رودمپ، ثبتِ اینکه کامیت تازه‌ای نیست)؛ بولت CI در همان بخش و بولت «نو» در بخش ۲.۱ (زمان به ۰۰:۴۶)؛ همین لاگ. جدول‌های وضعیت کلی، محصول و تست‌ها و بخش‌های ۳.۱–۳.۴ بدون تغییر ماندند چون کد از `73c94dd` به بعد عوض نشده است. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نیست ⇒ طبق روال، CI دروازهٔ کیفیت است.
- 2026-10-09 01:19 UTC — **به‌روزرسانی دوره‌ای رودمپ (بدون کامیت کدِ نو، اما با نخستین workflow تازه پس از ۴ ساعت).** خواندن واقعیت: `git log --oneline -8` + `git rev-list --count` (HEAD=`8e6cc89` = انتشار خودکارِ نوبت پیش در ۰۰:۴۸:۰۹ UTC، مجموع ۳۴ کامیت، ۲۰ تا بعد از نوکِ `main`/`d8315e2` شامل ۱۱ کامیت رودمپ ⇒ ۹ کامیت کد/بازتولید)، `git status --short` (خالی)، `git merge-base HEAD origin/main` (= `d8315e2`) و `git ls-remote origin feat/flashcards main` (`origin/feat/flashcards`=`8e6cc89` ⇒ **هم‌تراز با محلی**؛ `origin/main`=`d8315e2` بدون تغییر)، `gh run list --limit 5` و `--limit 10` + `gh run view 37868655420` + `gh run view --job=113621343000` (**نو:** اجرای زمان‌بندی‌شدهٔ `Android Build` روی `main` از ۰۱:۱۲:۴۱ UTC **در جریان است** — `Set up job ✓`، `Checkout ✓`، `Java ✓`، `Flutter ✓`، `Install dependencies ✓`، `Static analysis ✓`، `Run tests ✓` و الان در `Build release APK`؛ پیش از آن هیچ workflow جدیدی از ۲۱:۱۷ UTC نبود)، `gh release list` + `git ls-remote --tags` (**۱۱ تگ/Release** بدون تغییر؛ «Latest» = `PAYAYAR build d8315e2`). شمارش‌های HEAD بدون تغییر (۴۸ فایل `.dart` در `lib/`، ۹ پوشه `features`، ۱۱ فایل تست / ۶۰ تست، ۳۳۷ کلید l10n). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ ردیف CI اندروید در جدول وضعیت کلی (اجرای در جریان + سبزِ آخرین)؛ بولت‌های وضعیت مخزن (HEAD=`8e6cc89`، ۳۴/۲۰ کامیت، ۱۱ کامیت رودمپ، ثبتِ اینکه کامیت کدِ تازه‌ای نیست)؛ بولت CI در همان بخش و بولت «نو» در بخش ۲.۱ (زمان به ۰۱:۱۹ + اجرای در جریان)؛ همین لاگ. جدول‌های محصول و تست‌ها و بخش‌های ۱.۱، ۲، ۳ و ۳.۱–۳.۴ بدون تغییر ماندند چون کد از `73c94dd` به بعد عوض نشده است. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نیست ⇒ طبق روال، CI دروازهٔ کیفیت است.
- 2026-10-09 01:54 UTC — **به‌روزرسانی دوره‌ای رودمپ (بدون کامیت کدِ نو، اما با سبزشدن اجرای اندروید).** خواندن واقعیت: `git log --oneline -8` + `git rev-list --count` (HEAD=`b6900e4` = انتشار خودکارِ نوبت پیش در ۰۱:۲۰:۴۷ UTC، مجموع ۳۵ کامیت، ۲۱ تا بعد از نوکِ `main`/`d8315e2` شامل ۱۲ کامیت رودمپ ⇒ ۹ کامیت کد/بازتولید)، `git status --short` (خالی)، `git merge-base HEAD origin/main` (= `d8315e2`) و `git ls-remote origin feat/flashcards main` (`origin/feat/flashcards`=`b6900e4` ⇒ **هم‌تراز با محلی**؛ `origin/main`=`d8315e2` بدون تغییر)، `gh run list --limit 5/8` + `gh run view 37868655420 --job=113621343000` (**نو:** `Android Build` زمان‌بندی‌شدهٔ `main`/`d8315e2` (`37868655420`) اکنون **`completed/success`** است — ۰۱:۱۲:۴۱–۰۱:۲۳:۲۲ UTC با همهٔ پله‌ها ✓ از `Static analysis` تا `Publish to Release (main only)` و artifact `PAYAYAR-apk`؛ ردیف دوم همچنان `Codegen`/`success` روی `73c94dd` در ۲۱:۱۴:۵۲ UTC)، `gh release list` + `git ls-remote --tags` (**۱۱ تگ/Release** بدون تغییر؛ «Latest» = `PAYAYAR build d8315e2` — پلهٔ انتشار تگ تازه‌ای نساخت چون `android-build-d8315e2` از قبل هست). شمارش‌های HEAD بدون تغییر (۴۸ فایل `.dart` در `lib/`، ۹ پوشه `features`، ۱۱ فایل تست / ۶۰ تست، ۳۳۷ کلید l10n). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ ردیف CI اندروید در جدول وضعیت کلی (از «در جریان» به سبزِ تمام‌شده + توضیح نساختن Release تازه)؛ بولت‌های وضعیت مخزن (HEAD=`b6900e4`، ۳۵/۲۱ کامیت، ۱۲ کامیت رودمپ، ثبتِ اینکه کامیت کدِ تازه‌ای نیست)؛ بولت CI در همان بخش و ۳ بولت در بخش ۲.۱ (زمان به ۰۱:۵۴، اجرای سبزِ `37868655420`)؛ همین لاگ. جدول‌های محصول و تست‌ها، ردیف‌های analyze/test و بخش‌های ۱.۱، ۲، ۳ و ۳.۱–۳.۴ بدون تغییر ماندند چون کد از `73c94dd` به بعد عوض نشده است. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نیست ⇒ طبق روال، CI دروازهٔ کیفیت است.
- 2026-10-09 02:32 UTC — **به‌روزرسانی دوره‌ای رودمپ، بلافاصله پس از ادغام فلش‌کارت به `main`.** خواندن واقعیت: `git log --oneline -8` + `git rev-list --count` (HEAD=`10c1373` «docs(roadmap): flashcards merged to main» در ۰۲:۱۰:۴۲ UTC — خارج از این نوبت ثبت شد؛ مجموع **۳۷ کامیت** = ۲۱ کد/بازتولید + ۱۵ رودمپ + ۱ مستندات)، `git status --short` (خالی)، `git branch -vv` + `git ls-remote` (شاخه حالا **`main`** است؛ `origin/main`=`10c1373` هم‌تراز؛ `origin/feat/flashcards`=`2a2071c` عقب‌تر؛ `git log --merges` خالی ⇒ ادغام **fast-forward** بود)، `gh run list --limit 10` + دو `gh run view` (**۲ اجرای تازه و سبز روی `main`/`2a2071c` از pushِ ۰۲:۰۹:۱۵ UTC**: `Android Build` `37873204609` تا ۰۲:۱۹:۴۴ و `Windows Build` `37873204616` تا ۰۲:۱۶:۲۳، هر دو با همهٔ پله‌ها ✓ شامل `Static analysis` و `Run tests`)، `gh release list` + `git ls-remote --tags` (**۱۳ Release** = ۷ اندروید + ۶ ویندوز؛ «Latest» = `PAYAYAR build 2a2071c` در ۰۲:۱۹:۳۹ UTC؛ هر دو تگ جدید به `10c1373` اشاره می‌کنند چون `gh release create` بدون `--target` تگ را روی نوکِ لحظه‌ای `main` می‌زند). تغییرات این نوبت: خط «آخرین به‌روزرسانی»؛ جدول وضعیت کلی (ردیف اندروید ← ۷ نسخه/۱۳ Release، ردیف ویندوز ← ۶ نسخه، ردیف فلش‌کارت ← ادغام + بیلدهای سبز، ردیف‌های `analyze`/`flutter test` ← سبز روی `main`/`2a2071c`)؛ بولت‌های وضعیت مخزن (`main`، `10c1373`، ۳۷ کامیت، fast-forward)؛ ۱ بولت «نو» در بخش ۱؛ ۳ بولت در بخش ۲.۱ (تگ‌ها، `gh run list`، نو)؛ بخش ۳.۴ (ادغام انجام شد)؛ مراحل بعدی؛ همین لاگ. شمارش‌های کد و جدول‌های محصول/تست بدون تغییر ماندند چون کد از `73c94dd`/`a64de84` به بعد عوض نشده است. اجرای محلی همچنان زیر سقف ۱ گیگابایتی cgroup ممکن نیست ⇒ طبق روال، CI دروازهٔ کیفیت است.
