import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In fa, this message translates to:
  /// **'پایا‌یار'**
  String get appTitle;

  /// No description provided for @brandLatin.
  ///
  /// In fa, this message translates to:
  /// **'PAYAYAR'**
  String get brandLatin;

  /// No description provided for @nav_home.
  ///
  /// In fa, this message translates to:
  /// **'خانه'**
  String get nav_home;

  /// No description provided for @nav_planning.
  ///
  /// In fa, this message translates to:
  /// **'برنامه‌ریزی'**
  String get nav_planning;

  /// No description provided for @nav_study.
  ///
  /// In fa, this message translates to:
  /// **'مطالعه'**
  String get nav_study;

  /// No description provided for @nav_exams.
  ///
  /// In fa, this message translates to:
  /// **'آزمون‌ها'**
  String get nav_exams;

  /// No description provided for @nav_reports.
  ///
  /// In fa, this message translates to:
  /// **'گزارش‌ها'**
  String get nav_reports;

  /// No description provided for @nav_lifestyle.
  ///
  /// In fa, this message translates to:
  /// **'سبک زندگی'**
  String get nav_lifestyle;

  /// No description provided for @nav_aiAdvisor.
  ///
  /// In fa, this message translates to:
  /// **'مشاور AI'**
  String get nav_aiAdvisor;

  /// No description provided for @nav_settings.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get nav_settings;

  /// No description provided for @nav_more.
  ///
  /// In fa, this message translates to:
  /// **'بیشتر'**
  String get nav_more;

  /// No description provided for @home_greeting.
  ///
  /// In fa, this message translates to:
  /// **'سلام'**
  String get home_greeting;

  /// No description provided for @home_greetingSubtitle.
  ///
  /// In fa, this message translates to:
  /// **'امروز چه پیشرفتی در پیش داری؟'**
  String get home_greetingSubtitle;

  /// No description provided for @home_metric_plannedToday.
  ///
  /// In fa, this message translates to:
  /// **'برنامهٔ امروز'**
  String get home_metric_plannedToday;

  /// No description provided for @home_metric_completed.
  ///
  /// In fa, this message translates to:
  /// **'انجام‌شده'**
  String get home_metric_completed;

  /// No description provided for @home_metric_remaining.
  ///
  /// In fa, this message translates to:
  /// **'باقی‌مانده'**
  String get home_metric_remaining;

  /// No description provided for @home_metric_nextExam.
  ///
  /// In fa, this message translates to:
  /// **'آزمون بعدی'**
  String get home_metric_nextExam;

  /// No description provided for @home_metric_todayStudy.
  ///
  /// In fa, this message translates to:
  /// **'مطالعهٔ امروز'**
  String get home_metric_todayStudy;

  /// No description provided for @home_metric_streak.
  ///
  /// In fa, this message translates to:
  /// **'روزهای پیوسته'**
  String get home_metric_streak;

  /// No description provided for @home_todayPlan_title.
  ///
  /// In fa, this message translates to:
  /// **'برنامهٔ امروز'**
  String get home_todayPlan_title;

  /// No description provided for @home_todayPlan_emptyTitle.
  ///
  /// In fa, this message translates to:
  /// **'هنوز برنامه‌ای ثبت نشده'**
  String get home_todayPlan_emptyTitle;

  /// No description provided for @home_todayPlan_emptyDesc.
  ///
  /// In fa, this message translates to:
  /// **'از بخش برنامه‌ریزی، برنامهٔ امروزت را بساز.'**
  String get home_todayPlan_emptyDesc;

  /// No description provided for @home_calendar_title.
  ///
  /// In fa, this message translates to:
  /// **'تقویم'**
  String get home_calendar_title;

  /// No description provided for @home_progress_title.
  ///
  /// In fa, this message translates to:
  /// **'پیشرفت امروز'**
  String get home_progress_title;

  /// No description provided for @home_ai_title.
  ///
  /// In fa, this message translates to:
  /// **'مشاور AI'**
  String get home_ai_title;

  /// No description provided for @home_ai_unconfigured.
  ///
  /// In fa, this message translates to:
  /// **'کلید API تنظیم نشده است.'**
  String get home_ai_unconfigured;

  /// No description provided for @home_ai_cta.
  ///
  /// In fa, this message translates to:
  /// **'رفتن به تنظیمات'**
  String get home_ai_cta;

  /// No description provided for @home_recentActivities_title.
  ///
  /// In fa, this message translates to:
  /// **'فعالیت‌های اخیر'**
  String get home_recentActivities_title;

  /// No description provided for @home_lifestyle_title.
  ///
  /// In fa, this message translates to:
  /// **'خلاصهٔ سبک زندگی'**
  String get home_lifestyle_title;

  /// No description provided for @home_lifestyle_none.
  ///
  /// In fa, this message translates to:
  /// **'ثبت امروز انجام نشده'**
  String get home_lifestyle_none;

  /// No description provided for @home_recentExams_title.
  ///
  /// In fa, this message translates to:
  /// **'آزمون‌های اخیر'**
  String get home_recentExams_title;

  /// No description provided for @home_quickActions_title.
  ///
  /// In fa, this message translates to:
  /// **'دسترسی سریع'**
  String get home_quickActions_title;

  /// No description provided for @action_logStudy.
  ///
  /// In fa, this message translates to:
  /// **'ثبت مطالعه'**
  String get action_logStudy;

  /// No description provided for @action_logTest.
  ///
  /// In fa, this message translates to:
  /// **'ثبت تست'**
  String get action_logTest;

  /// No description provided for @action_logSleep.
  ///
  /// In fa, this message translates to:
  /// **'ثبت خواب'**
  String get action_logSleep;

  /// No description provided for @action_logExercise.
  ///
  /// In fa, this message translates to:
  /// **'ثبت ورزش'**
  String get action_logExercise;

  /// No description provided for @action_addTask.
  ///
  /// In fa, this message translates to:
  /// **'افزودن تسک'**
  String get action_addTask;

  /// No description provided for @empty_study_title.
  ///
  /// In fa, this message translates to:
  /// **'هنوز مطالعه‌ای ثبت نشده'**
  String get empty_study_title;

  /// No description provided for @empty_study_desc.
  ///
  /// In fa, this message translates to:
  /// **'بعد از ثبت اولین جلسهٔ مطالعه، تست یا مرور، اینجا می‌بینیش.'**
  String get empty_study_desc;

  /// No description provided for @empty_planning_title.
  ///
  /// In fa, this message translates to:
  /// **'هنوز برنامه‌ای ساخته نشده'**
  String get empty_planning_title;

  /// No description provided for @empty_planning_desc.
  ///
  /// In fa, this message translates to:
  /// **'اولین تسک برنامه‌ات را اضافه کن.'**
  String get empty_planning_desc;

  /// No description provided for @empty_exams_title.
  ///
  /// In fa, this message translates to:
  /// **'آزمونی ثبت نشده'**
  String get empty_exams_title;

  /// No description provided for @empty_exams_desc.
  ///
  /// In fa, this message translates to:
  /// **'آزمون‌هایت را ثبت کن تا نتایج و روندت را ببینی.'**
  String get empty_exams_desc;

  /// No description provided for @empty_reports_title.
  ///
  /// In fa, this message translates to:
  /// **'هنوز داده‌ای برای گزارش نیست'**
  String get empty_reports_title;

  /// No description provided for @empty_reports_desc.
  ///
  /// In fa, this message translates to:
  /// **'با ثبت مطالعه و تست، گزارش‌هایت اینجا ساخته می‌شود.'**
  String get empty_reports_desc;

  /// No description provided for @empty_lifestyle_title.
  ///
  /// In fa, this message translates to:
  /// **'سبک زندگی‌ات ثبت نشده'**
  String get empty_lifestyle_title;

  /// No description provided for @empty_lifestyle_desc.
  ///
  /// In fa, this message translates to:
  /// **'خواب، ورزش و گزارش روزانت را ثبت کن تا روندت را ببینی.'**
  String get empty_lifestyle_desc;

  /// No description provided for @empty_ai_title.
  ///
  /// In fa, this message translates to:
  /// **'مشاور AI آماده است'**
  String get empty_ai_title;

  /// No description provided for @empty_ai_desc.
  ///
  /// In fa, this message translates to:
  /// **'کلید Gemini خودت را در تنظیمات وارد کن تا گفتگو را شروع کنی.'**
  String get empty_ai_desc;

  /// No description provided for @empty_topics_title.
  ///
  /// In fa, this message translates to:
  /// **'مبحثی اضافه نشده'**
  String get empty_topics_title;

  /// No description provided for @empty_topics_desc.
  ///
  /// In fa, this message translates to:
  /// **'برای این درس، مبحث‌هایت را اضافه کن.'**
  String get empty_topics_desc;

  /// No description provided for @settings_title.
  ///
  /// In fa, this message translates to:
  /// **'تنظیمات'**
  String get settings_title;

  /// No description provided for @settings_language.
  ///
  /// In fa, this message translates to:
  /// **'زبان'**
  String get settings_language;

  /// No description provided for @settings_language_fa.
  ///
  /// In fa, this message translates to:
  /// **'فارسی'**
  String get settings_language_fa;

  /// No description provided for @settings_language_en.
  ///
  /// In fa, this message translates to:
  /// **'English'**
  String get settings_language_en;

  /// No description provided for @settings_theme.
  ///
  /// In fa, this message translates to:
  /// **'پوسته'**
  String get settings_theme;

  /// No description provided for @settings_theme_dark.
  ///
  /// In fa, this message translates to:
  /// **'تیره'**
  String get settings_theme_dark;

  /// No description provided for @settings_theme_light.
  ///
  /// In fa, this message translates to:
  /// **'روشن'**
  String get settings_theme_light;

  /// No description provided for @settings_userName.
  ///
  /// In fa, this message translates to:
  /// **'نام'**
  String get settings_userName;

  /// No description provided for @settings_userName_hint.
  ///
  /// In fa, this message translates to:
  /// **'نام تو در سلام برنامه نمایش داده می‌شود'**
  String get settings_userName_hint;

  /// No description provided for @settings_ai.
  ///
  /// In fa, this message translates to:
  /// **'مشاور AI'**
  String get settings_ai;

  /// No description provided for @settings_ai_comingSoon.
  ///
  /// In fa, this message translates to:
  /// **'پیکربندی در ادامه همین صفحه انجام می‌شود.'**
  String get settings_ai_comingSoon;

  /// No description provided for @settings_ai_provider.
  ///
  /// In fa, this message translates to:
  /// **'سرویس‌دهنده'**
  String get settings_ai_provider;

  /// No description provided for @settings_ai_model.
  ///
  /// In fa, this message translates to:
  /// **'مدل'**
  String get settings_ai_model;

  /// No description provided for @settings_ai_key.
  ///
  /// In fa, this message translates to:
  /// **'کلید API'**
  String get settings_ai_key;

  /// No description provided for @settings_ai_key_hint.
  ///
  /// In fa, this message translates to:
  /// **'کلید فقط روی همین دستگاه ذخیره می‌شود'**
  String get settings_ai_key_hint;

  /// No description provided for @settings_ai_test.
  ///
  /// In fa, this message translates to:
  /// **'تست اتصال'**
  String get settings_ai_test;

  /// No description provided for @settings_ai_testOk.
  ///
  /// In fa, this message translates to:
  /// **'اتصال موفق بود'**
  String get settings_ai_testOk;

  /// No description provided for @settings_ai_testFail.
  ///
  /// In fa, this message translates to:
  /// **'اتصال ناموفق: {error}'**
  String settings_ai_testFail(String error);

  /// No description provided for @settings_ai_keyMissing.
  ///
  /// In fa, this message translates to:
  /// **'کلید API را وارد کن'**
  String get settings_ai_keyMissing;

  /// No description provided for @settings_data.
  ///
  /// In fa, this message translates to:
  /// **'مدیریت داده'**
  String get settings_data;

  /// No description provided for @settings_data_export.
  ///
  /// In fa, this message translates to:
  /// **'خروجی گرفتن (بکاپ JSON)'**
  String get settings_data_export;

  /// No description provided for @settings_data_import.
  ///
  /// In fa, this message translates to:
  /// **'بازیابی از بکاپ'**
  String get settings_data_import;

  /// No description provided for @settings_data_importConfirm.
  ///
  /// In fa, this message translates to:
  /// **'داده‌های فعلی با بکاپ ترکیب می‌شوند. ادامه می‌دهی؟'**
  String get settings_data_importConfirm;

  /// No description provided for @settings_data_importDone.
  ///
  /// In fa, this message translates to:
  /// **'{count} رکورد بازیابی شد'**
  String settings_data_importDone(int count);

  /// No description provided for @settings_data_importInvalid.
  ///
  /// In fa, this message translates to:
  /// **'فایل بکاپ معتبر نیست'**
  String get settings_data_importInvalid;

  /// No description provided for @settings_data_wipe.
  ///
  /// In fa, this message translates to:
  /// **'پاک‌کردن همهٔ داده‌ها'**
  String get settings_data_wipe;

  /// No description provided for @settings_data_wipeConfirm.
  ///
  /// In fa, this message translates to:
  /// **'همهٔ برنامه‌ها، دروس، آزمون‌ها و گزارش‌ها برای همیشه حذف می‌شوند. این کار برگشت‌پذیر نیست!'**
  String get settings_data_wipeConfirm;

  /// No description provided for @settings_data_wipeType.
  ///
  /// In fa, this message translates to:
  /// **'برای تأیید، کلمهٔ DELETE را بنویس'**
  String get settings_data_wipeType;

  /// No description provided for @settings_about.
  ///
  /// In fa, this message translates to:
  /// **'درباره'**
  String get settings_about;

  /// No description provided for @settings_about_version.
  ///
  /// In fa, this message translates to:
  /// **'نسخه'**
  String get settings_about_version;

  /// No description provided for @settings_ai_localNote.
  ///
  /// In fa, this message translates to:
  /// **'همهٔ داده‌ها فقط روی همین دستگاه ذخیره می‌شوند.'**
  String get settings_ai_localNote;

  /// No description provided for @planning_title.
  ///
  /// In fa, this message translates to:
  /// **'برنامه‌ریزی'**
  String get planning_title;

  /// No description provided for @planning_tab_week.
  ///
  /// In fa, this message translates to:
  /// **'هفتگی'**
  String get planning_tab_week;

  /// No description provided for @planning_tab_day.
  ///
  /// In fa, this message translates to:
  /// **'روزانه'**
  String get planning_tab_day;

  /// No description provided for @planning_tab_dashboard.
  ///
  /// In fa, this message translates to:
  /// **'داشبورد'**
  String get planning_tab_dashboard;

  /// No description provided for @planning_tab_mock.
  ///
  /// In fa, this message translates to:
  /// **'آزمون آزمایشی'**
  String get planning_tab_mock;

  /// No description provided for @planning_week_prev.
  ///
  /// In fa, this message translates to:
  /// **'هفتهٔ قبل'**
  String get planning_week_prev;

  /// No description provided for @planning_week_next.
  ///
  /// In fa, this message translates to:
  /// **'هفتهٔ بعد'**
  String get planning_week_next;

  /// No description provided for @planning_week_today.
  ///
  /// In fa, this message translates to:
  /// **'امروز'**
  String get planning_week_today;

  /// No description provided for @planning_task_add.
  ///
  /// In fa, this message translates to:
  /// **'تسک جدید'**
  String get planning_task_add;

  /// No description provided for @planning_task_edit.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش تسک'**
  String get planning_task_edit;

  /// No description provided for @planning_task_title.
  ///
  /// In fa, this message translates to:
  /// **'عنوان'**
  String get planning_task_title;

  /// No description provided for @planning_task_titleHint.
  ///
  /// In fa, this message translates to:
  /// **'مثلاً: مرور جبر'**
  String get planning_task_titleHint;

  /// No description provided for @planning_task_subject.
  ///
  /// In fa, this message translates to:
  /// **'درس'**
  String get planning_task_subject;

  /// No description provided for @planning_task_subjectNone.
  ///
  /// In fa, this message translates to:
  /// **'بدون درس'**
  String get planning_task_subjectNone;

  /// No description provided for @planning_task_topic.
  ///
  /// In fa, this message translates to:
  /// **'مبحث'**
  String get planning_task_topic;

  /// No description provided for @planning_task_topicNone.
  ///
  /// In fa, this message translates to:
  /// **'بدون مبحث'**
  String get planning_task_topicNone;

  /// No description provided for @planning_task_date.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ'**
  String get planning_task_date;

  /// No description provided for @planning_task_start.
  ///
  /// In fa, this message translates to:
  /// **'ساعت شروع'**
  String get planning_task_start;

  /// No description provided for @planning_task_duration.
  ///
  /// In fa, this message translates to:
  /// **'مدت (دقیقه)'**
  String get planning_task_duration;

  /// No description provided for @planning_task_priority.
  ///
  /// In fa, this message translates to:
  /// **'اولویت'**
  String get planning_task_priority;

  /// No description provided for @planning_task_notes.
  ///
  /// In fa, this message translates to:
  /// **'یادداشت'**
  String get planning_task_notes;

  /// No description provided for @planning_task_delete.
  ///
  /// In fa, this message translates to:
  /// **'حذف تسک'**
  String get planning_task_delete;

  /// No description provided for @planning_task_deleteConfirm.
  ///
  /// In fa, this message translates to:
  /// **'این تسک برای همیشه حذف می‌شود.'**
  String get planning_task_deleteConfirm;

  /// No description provided for @planning_task_moveTo.
  ///
  /// In fa, this message translates to:
  /// **'جابجایی به روز دیگر'**
  String get planning_task_moveTo;

  /// No description provided for @planning_task_complete.
  ///
  /// In fa, this message translates to:
  /// **'تکمیل'**
  String get planning_task_complete;

  /// No description provided for @planning_task_reopen.
  ///
  /// In fa, this message translates to:
  /// **'بازکردن مجدد'**
  String get planning_task_reopen;

  /// No description provided for @planning_task_cancel.
  ///
  /// In fa, this message translates to:
  /// **'لغو'**
  String get planning_task_cancel;

  /// No description provided for @planning_task_skip.
  ///
  /// In fa, this message translates to:
  /// **'رد کردن'**
  String get planning_task_skip;

  /// No description provided for @planning_priority_low.
  ///
  /// In fa, this message translates to:
  /// **'کم'**
  String get planning_priority_low;

  /// No description provided for @planning_priority_medium.
  ///
  /// In fa, this message translates to:
  /// **'متوسط'**
  String get planning_priority_medium;

  /// No description provided for @planning_priority_high.
  ///
  /// In fa, this message translates to:
  /// **'زیاد'**
  String get planning_priority_high;

  /// No description provided for @planning_status_notStarted.
  ///
  /// In fa, this message translates to:
  /// **'شروع نشده'**
  String get planning_status_notStarted;

  /// No description provided for @planning_status_inProgress.
  ///
  /// In fa, this message translates to:
  /// **'در حال انجام'**
  String get planning_status_inProgress;

  /// No description provided for @planning_status_completed.
  ///
  /// In fa, this message translates to:
  /// **'تکمیل‌شده'**
  String get planning_status_completed;

  /// No description provided for @planning_status_cancelled.
  ///
  /// In fa, this message translates to:
  /// **'لغو‌شده'**
  String get planning_status_cancelled;

  /// No description provided for @planning_status_moved.
  ///
  /// In fa, this message translates to:
  /// **'جابجا‌شده'**
  String get planning_status_moved;

  /// No description provided for @planning_status_skipped.
  ///
  /// In fa, this message translates to:
  /// **'رد‌شده'**
  String get planning_status_skipped;

  /// No description provided for @planning_dashboard_planned.
  ///
  /// In fa, this message translates to:
  /// **'ساعت برنامه‌ریزی‌شده'**
  String get planning_dashboard_planned;

  /// No description provided for @planning_dashboard_actual.
  ///
  /// In fa, this message translates to:
  /// **'ساعت انجام‌شده'**
  String get planning_dashboard_actual;

  /// No description provided for @planning_dashboard_completion.
  ///
  /// In fa, this message translates to:
  /// **'درصد تکمیل'**
  String get planning_dashboard_completion;

  /// No description provided for @planning_dashboard_overdue.
  ///
  /// In fa, this message translates to:
  /// **'عقب‌افتاده'**
  String get planning_dashboard_overdue;

  /// No description provided for @planning_dashboard_today.
  ///
  /// In fa, this message translates to:
  /// **'تسک‌های امروز'**
  String get planning_dashboard_today;

  /// No description provided for @planning_dashboard_upcoming.
  ///
  /// In fa, this message translates to:
  /// **'روزهای آینده'**
  String get planning_dashboard_upcoming;

  /// No description provided for @planning_day_empty.
  ///
  /// In fa, this message translates to:
  /// **'برای این روز تسکی ثبت نشده'**
  String get planning_day_empty;

  /// No description provided for @planning_mock_title.
  ///
  /// In fa, this message translates to:
  /// **'آزمون‌های آزمایشی'**
  String get planning_mock_title;

  /// No description provided for @planning_mock_add.
  ///
  /// In fa, this message translates to:
  /// **'ثبت آزمون آزمایشی'**
  String get planning_mock_add;

  /// No description provided for @planning_mock_desc.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ آزمون بعدی را خودت تعیین می‌کنی.'**
  String get planning_mock_desc;

  /// No description provided for @planning_mock_subjects.
  ///
  /// In fa, this message translates to:
  /// **'دروس و مباحث (اختیاری)'**
  String get planning_mock_subjects;

  /// No description provided for @planning_noSubjectsYet.
  ///
  /// In fa, this message translates to:
  /// **'هنوز درسی نساخته‌ای'**
  String get planning_noSubjectsYet;

  /// No description provided for @planning_minutes.
  ///
  /// In fa, this message translates to:
  /// **'دقیقه'**
  String get planning_minutes;

  /// No description provided for @planning_hoursUnit.
  ///
  /// In fa, this message translates to:
  /// **'ساعت'**
  String get planning_hoursUnit;

  /// No description provided for @study_title.
  ///
  /// In fa, this message translates to:
  /// **'مطالعه'**
  String get study_title;

  /// No description provided for @study_addSubject.
  ///
  /// In fa, this message translates to:
  /// **'درس جدید'**
  String get study_addSubject;

  /// No description provided for @study_subjectName.
  ///
  /// In fa, this message translates to:
  /// **'نام درس'**
  String get study_subjectName;

  /// No description provided for @study_subjectNameHint.
  ///
  /// In fa, this message translates to:
  /// **'مثلاً: ریاضی'**
  String get study_subjectNameHint;

  /// No description provided for @study_subjectCategory.
  ///
  /// In fa, this message translates to:
  /// **'دسته (اختیاری)'**
  String get study_subjectCategory;

  /// No description provided for @study_addTopic.
  ///
  /// In fa, this message translates to:
  /// **'مبحث جدید'**
  String get study_addTopic;

  /// No description provided for @study_topicName.
  ///
  /// In fa, this message translates to:
  /// **'نام مبحث'**
  String get study_topicName;

  /// No description provided for @study_addSubtopic.
  ///
  /// In fa, this message translates to:
  /// **'زیرمبحث جدید'**
  String get study_addSubtopic;

  /// No description provided for @study_deleteSubject.
  ///
  /// In fa, this message translates to:
  /// **'حذف درس'**
  String get study_deleteSubject;

  /// No description provided for @study_deleteSubjectConfirm.
  ///
  /// In fa, this message translates to:
  /// **'همهٔ مبحث‌ها و جلسات مطالعهٔ این درس هم حذف می‌شوند.'**
  String get study_deleteSubjectConfirm;

  /// No description provided for @study_deleteTopic.
  ///
  /// In fa, this message translates to:
  /// **'حذف مبحث'**
  String get study_deleteTopic;

  /// No description provided for @study_deleteTopicConfirm.
  ///
  /// In fa, this message translates to:
  /// **'این مبحث برای همیشه حذف می‌شود.'**
  String get study_deleteTopicConfirm;

  /// No description provided for @study_topicStatus.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت'**
  String get study_topicStatus;

  /// No description provided for @study_status_notStarted.
  ///
  /// In fa, this message translates to:
  /// **'شروع نشده'**
  String get study_status_notStarted;

  /// No description provided for @study_status_learning.
  ///
  /// In fa, this message translates to:
  /// **'در حال یادگیری'**
  String get study_status_learning;

  /// No description provided for @study_status_reviewing.
  ///
  /// In fa, this message translates to:
  /// **'در حال مرور'**
  String get study_status_reviewing;

  /// No description provided for @study_status_mastered.
  ///
  /// In fa, this message translates to:
  /// **'تسلط کامل'**
  String get study_status_mastered;

  /// No description provided for @study_difficulty.
  ///
  /// In fa, this message translates to:
  /// **'سختی'**
  String get study_difficulty;

  /// No description provided for @study_mastery.
  ///
  /// In fa, this message translates to:
  /// **'تسلط'**
  String get study_mastery;

  /// No description provided for @study_session_add.
  ///
  /// In fa, this message translates to:
  /// **'ثبت جلسهٔ مطالعه'**
  String get study_session_add;

  /// No description provided for @study_session_type.
  ///
  /// In fa, this message translates to:
  /// **'نوع'**
  String get study_session_type;

  /// No description provided for @study_session_type_learning.
  ///
  /// In fa, this message translates to:
  /// **'یادگیری'**
  String get study_session_type_learning;

  /// No description provided for @study_session_type_review.
  ///
  /// In fa, this message translates to:
  /// **'مرور'**
  String get study_session_type_review;

  /// No description provided for @study_session_type_test.
  ///
  /// In fa, this message translates to:
  /// **'تست'**
  String get study_session_type_test;

  /// No description provided for @study_session_type_problemSolving.
  ///
  /// In fa, this message translates to:
  /// **'حل تمرین'**
  String get study_session_type_problemSolving;

  /// No description provided for @study_session_start.
  ///
  /// In fa, this message translates to:
  /// **'شروع'**
  String get study_session_start;

  /// No description provided for @study_session_end.
  ///
  /// In fa, this message translates to:
  /// **'پایان'**
  String get study_session_end;

  /// No description provided for @study_session_history.
  ///
  /// In fa, this message translates to:
  /// **'تاریخچهٔ مطالعه'**
  String get study_session_history;

  /// No description provided for @study_topicNotes.
  ///
  /// In fa, this message translates to:
  /// **'یادداشت مبحث'**
  String get study_topicNotes;

  /// No description provided for @study_sessionsTotal.
  ///
  /// In fa, this message translates to:
  /// **'مجموع مطالعه'**
  String get study_sessionsTotal;

  /// No description provided for @exams_title.
  ///
  /// In fa, this message translates to:
  /// **'آزمون‌ها'**
  String get exams_title;

  /// No description provided for @exams_add.
  ///
  /// In fa, this message translates to:
  /// **'آزمون جدید'**
  String get exams_add;

  /// No description provided for @exams_edit.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش آزمون'**
  String get exams_edit;

  /// No description provided for @exams_examTitle.
  ///
  /// In fa, this message translates to:
  /// **'عنوان آزمون'**
  String get exams_examTitle;

  /// No description provided for @exams_type.
  ///
  /// In fa, this message translates to:
  /// **'نوع'**
  String get exams_type;

  /// No description provided for @exams_type_mock.
  ///
  /// In fa, this message translates to:
  /// **'آزمون آزمایشی'**
  String get exams_type_mock;

  /// No description provided for @exams_type_school.
  ///
  /// In fa, this message translates to:
  /// **'آزمون مدرسه'**
  String get exams_type_school;

  /// No description provided for @exams_type_personal.
  ///
  /// In fa, this message translates to:
  /// **'آزمون شخصی'**
  String get exams_type_personal;

  /// No description provided for @exams_type_other.
  ///
  /// In fa, this message translates to:
  /// **'سایر'**
  String get exams_type_other;

  /// No description provided for @exams_date.
  ///
  /// In fa, this message translates to:
  /// **'تاریخ'**
  String get exams_date;

  /// No description provided for @exams_duration.
  ///
  /// In fa, this message translates to:
  /// **'مدت (دقیقه)'**
  String get exams_duration;

  /// No description provided for @exams_description.
  ///
  /// In fa, this message translates to:
  /// **'توضیحات'**
  String get exams_description;

  /// No description provided for @exams_deleteConfirm.
  ///
  /// In fa, this message translates to:
  /// **'این آزمون و همهٔ نتایجش حذف می‌شوند.'**
  String get exams_deleteConfirm;

  /// No description provided for @exams_results.
  ///
  /// In fa, this message translates to:
  /// **'نتایج'**
  String get exams_results;

  /// No description provided for @exams_result_add.
  ///
  /// In fa, this message translates to:
  /// **'ثبت نتیجه'**
  String get exams_result_add;

  /// No description provided for @exams_result_subject.
  ///
  /// In fa, this message translates to:
  /// **'درس'**
  String get exams_result_subject;

  /// No description provided for @exams_result_overall.
  ///
  /// In fa, this message translates to:
  /// **'نتیجهٔ کل'**
  String get exams_result_overall;

  /// No description provided for @exams_result_correct.
  ///
  /// In fa, this message translates to:
  /// **'صحیح'**
  String get exams_result_correct;

  /// No description provided for @exams_result_wrong.
  ///
  /// In fa, this message translates to:
  /// **'غلط'**
  String get exams_result_wrong;

  /// No description provided for @exams_result_unanswered.
  ///
  /// In fa, this message translates to:
  /// **'بی‌جواب'**
  String get exams_result_unanswered;

  /// No description provided for @exams_result_score.
  ///
  /// In fa, this message translates to:
  /// **'نمره'**
  String get exams_result_score;

  /// No description provided for @exams_result_timeSpent.
  ///
  /// In fa, this message translates to:
  /// **'زمان مصرف‌شده (دقیقه)'**
  String get exams_result_timeSpent;

  /// No description provided for @exams_result_percent.
  ///
  /// In fa, this message translates to:
  /// **'درصد'**
  String get exams_result_percent;

  /// No description provided for @exams_analysis.
  ///
  /// In fa, this message translates to:
  /// **'تحلیل'**
  String get exams_analysis;

  /// No description provided for @exams_analysis_strong.
  ///
  /// In fa, this message translates to:
  /// **'درس‌های قوی'**
  String get exams_analysis_strong;

  /// No description provided for @exams_analysis_weak.
  ///
  /// In fa, this message translates to:
  /// **'درس‌های ضعیف'**
  String get exams_analysis_weak;

  /// No description provided for @exams_analysis_trend.
  ///
  /// In fa, this message translates to:
  /// **'روند نتایج'**
  String get exams_analysis_trend;

  /// No description provided for @exams_analysis_noResults.
  ///
  /// In fa, this message translates to:
  /// **'هنوز نتیجه‌ای ثبت نشده'**
  String get exams_analysis_noResults;

  /// No description provided for @exams_upcoming.
  ///
  /// In fa, this message translates to:
  /// **'آزمون‌های پیشِ‌رو'**
  String get exams_upcoming;

  /// No description provided for @exams_past.
  ///
  /// In fa, this message translates to:
  /// **'آزمون‌های گذشته'**
  String get exams_past;

  /// No description provided for @reports_title.
  ///
  /// In fa, this message translates to:
  /// **'گزارش‌ها'**
  String get reports_title;

  /// No description provided for @reports_range_week.
  ///
  /// In fa, this message translates to:
  /// **'این هفته'**
  String get reports_range_week;

  /// No description provided for @reports_range_month.
  ///
  /// In fa, this message translates to:
  /// **'این ماه'**
  String get reports_range_month;

  /// No description provided for @reports_study_daily.
  ///
  /// In fa, this message translates to:
  /// **'ساعت مطالعهٔ روزانه'**
  String get reports_study_daily;

  /// No description provided for @reports_study_total.
  ///
  /// In fa, this message translates to:
  /// **'مجموع مطالعه'**
  String get reports_study_total;

  /// No description provided for @reports_study_subjectDistribution.
  ///
  /// In fa, this message translates to:
  /// **'توزیع درسی'**
  String get reports_study_subjectDistribution;

  /// No description provided for @reports_planning_completion.
  ///
  /// In fa, this message translates to:
  /// **'تکمیل برنامه'**
  String get reports_planning_completion;

  /// No description provided for @reports_planning_plannedVsDone.
  ///
  /// In fa, this message translates to:
  /// **'برنامه‌ریزی‌شده در برابر انجام‌شده'**
  String get reports_planning_plannedVsDone;

  /// No description provided for @reports_subjects_mastery.
  ///
  /// In fa, this message translates to:
  /// **'تسلط مباحث'**
  String get reports_subjects_mastery;

  /// No description provided for @reports_subjects_weak.
  ///
  /// In fa, this message translates to:
  /// **'مباحث ضعیف (تسلط زیر ۵۰٪)'**
  String get reports_subjects_weak;

  /// No description provided for @reports_exams_scores.
  ///
  /// In fa, this message translates to:
  /// **'روند نمرات آزمون'**
  String get reports_exams_scores;

  /// No description provided for @reports_notEnoughData.
  ///
  /// In fa, this message translates to:
  /// **'برای این گزارش هنوز دادهٔ کافی نیست.'**
  String get reports_notEnoughData;

  /// No description provided for @lifestyle_title.
  ///
  /// In fa, this message translates to:
  /// **'سبک زندگی'**
  String get lifestyle_title;

  /// No description provided for @lifestyle_today.
  ///
  /// In fa, this message translates to:
  /// **'ثبت امروز'**
  String get lifestyle_today;

  /// No description provided for @lifestyle_sleep.
  ///
  /// In fa, this message translates to:
  /// **'خواب'**
  String get lifestyle_sleep;

  /// No description provided for @lifestyle_bedTime.
  ///
  /// In fa, this message translates to:
  /// **'ساعت خواب'**
  String get lifestyle_bedTime;

  /// No description provided for @lifestyle_wakeTime.
  ///
  /// In fa, this message translates to:
  /// **'ساعت بیداری'**
  String get lifestyle_wakeTime;

  /// No description provided for @lifestyle_exercise.
  ///
  /// In fa, this message translates to:
  /// **'ورزش (دقیقه)'**
  String get lifestyle_exercise;

  /// No description provided for @lifestyle_mood.
  ///
  /// In fa, this message translates to:
  /// **'حال و هوا'**
  String get lifestyle_mood;

  /// No description provided for @lifestyle_energy.
  ///
  /// In fa, this message translates to:
  /// **'انرژی'**
  String get lifestyle_energy;

  /// No description provided for @lifestyle_screenTime.
  ///
  /// In fa, this message translates to:
  /// **'اسکرین‌تایم (دقیقه)'**
  String get lifestyle_screenTime;

  /// No description provided for @lifestyle_notes.
  ///
  /// In fa, this message translates to:
  /// **'یادداشت روز'**
  String get lifestyle_notes;

  /// No description provided for @lifestyle_save.
  ///
  /// In fa, this message translates to:
  /// **'ذخیرهٔ امروز'**
  String get lifestyle_save;

  /// No description provided for @lifestyle_saved.
  ///
  /// In fa, this message translates to:
  /// **'ثبت شد'**
  String get lifestyle_saved;

  /// No description provided for @lifestyle_history.
  ///
  /// In fa, this message translates to:
  /// **'تاریخچه'**
  String get lifestyle_history;

  /// No description provided for @lifestyle_observation_title.
  ///
  /// In fa, this message translates to:
  /// **'مشاهدهٔ ساده'**
  String get lifestyle_observation_title;

  /// No description provided for @lifestyle_observation_energy.
  ///
  /// In fa, this message translates to:
  /// **'روزهایی که بیشتر خوابیدی، انرژی‌ات {diff} واحد بالاتر بود.'**
  String lifestyle_observation_energy(int diff);

  /// No description provided for @lifestyle_observation_needMore.
  ///
  /// In fa, this message translates to:
  /// **'با ثبت ۷ روز، مشاهده‌های ساده اینجا نمایش داده می‌شود.'**
  String get lifestyle_observation_needMore;

  /// No description provided for @lifestyle_level_1.
  ///
  /// In fa, this message translates to:
  /// **'خیلی کم'**
  String get lifestyle_level_1;

  /// No description provided for @lifestyle_level_2.
  ///
  /// In fa, this message translates to:
  /// **'کم'**
  String get lifestyle_level_2;

  /// No description provided for @lifestyle_level_3.
  ///
  /// In fa, this message translates to:
  /// **'متوسط'**
  String get lifestyle_level_3;

  /// No description provided for @lifestyle_level_4.
  ///
  /// In fa, this message translates to:
  /// **'خوب'**
  String get lifestyle_level_4;

  /// No description provided for @lifestyle_level_5.
  ///
  /// In fa, this message translates to:
  /// **'عالی'**
  String get lifestyle_level_5;

  /// No description provided for @ai_title.
  ///
  /// In fa, this message translates to:
  /// **'مشاور AI'**
  String get ai_title;

  /// No description provided for @ai_notConfigured.
  ///
  /// In fa, this message translates to:
  /// **'برای شروع گفتگو، کلید API خودت را در تنظیمات وارد کن.'**
  String get ai_notConfigured;

  /// No description provided for @ai_configure.
  ///
  /// In fa, this message translates to:
  /// **'پیکربندی AI'**
  String get ai_configure;

  /// No description provided for @ai_inputHint.
  ///
  /// In fa, this message translates to:
  /// **'سؤالت را بنویس…'**
  String get ai_inputHint;

  /// No description provided for @ai_send.
  ///
  /// In fa, this message translates to:
  /// **'ارسال'**
  String get ai_send;

  /// No description provided for @ai_thinking.
  ///
  /// In fa, this message translates to:
  /// **'در حال فکر کردن…'**
  String get ai_thinking;

  /// No description provided for @ai_error.
  ///
  /// In fa, this message translates to:
  /// **'خطا در ارتباط با AI'**
  String get ai_error;

  /// No description provided for @ai_errorNetwork.
  ///
  /// In fa, this message translates to:
  /// **'اتصال برقرار نشد. اینترنت یا کلید API را چک کن.'**
  String get ai_errorNetwork;

  /// No description provided for @ai_errorNoKey.
  ///
  /// In fa, this message translates to:
  /// **'کلید API تنظیم نشده است.'**
  String get ai_errorNoKey;

  /// No description provided for @ai_newChat.
  ///
  /// In fa, this message translates to:
  /// **'گفتگوی جدید'**
  String get ai_newChat;

  /// No description provided for @ai_suggestionApply.
  ///
  /// In fa, this message translates to:
  /// **'اعمال'**
  String get ai_suggestionApply;

  /// No description provided for @ai_suggestionEdit.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش'**
  String get ai_suggestionEdit;

  /// No description provided for @ai_suggestionDismiss.
  ///
  /// In fa, this message translates to:
  /// **'رد'**
  String get ai_suggestionDismiss;

  /// No description provided for @ai_suggestionTask.
  ///
  /// In fa, this message translates to:
  /// **'پیشنهاد تسک'**
  String get ai_suggestionTask;

  /// No description provided for @ai_welcome.
  ///
  /// In fa, this message translates to:
  /// **'سلام! من مشاور AI تو هستم. می‌توانم دربارهٔ برنامهٔ مطالعه‌ات با تو حرف بزنم یا نکته‌ای بدهم — ولی هیچ تغییری بدون اجازهٔ تو اعمال نمی‌شود.'**
  String get ai_welcome;

  /// No description provided for @ai_contextConsent.
  ///
  /// In fa, this message translates to:
  /// **'ارسال خلاصهٔ برنامهٔ من به AI'**
  String get ai_contextConsent;

  /// No description provided for @ai_provider_gemini.
  ///
  /// In fa, this message translates to:
  /// **'Google Gemini'**
  String get ai_provider_gemini;

  /// No description provided for @ai_provider_none.
  ///
  /// In fa, this message translates to:
  /// **'انتخاب نشده'**
  String get ai_provider_none;

  /// No description provided for @ai_assist.
  ///
  /// In fa, this message translates to:
  /// **'کمک AI'**
  String get ai_assist;

  /// No description provided for @ai_promptPlanning.
  ///
  /// In fa, this message translates to:
  /// **'برنامهٔ هفتگی و وضعیت آزمون‌هایم را ببین و سه پیشنهاد عملی برای بهتر کردن برنامه بده. فقط پیشنهاد بده و هیچ داده‌ای را تغییر نده.'**
  String get ai_promptPlanning;

  /// No description provided for @ai_promptExams.
  ///
  /// In fa, this message translates to:
  /// **'نتایج و تاریخچهٔ آزمون‌هایم را تحلیل کن و بگو روی چه درس‌هایی باید بیشتر تمرکز کنم. فقط پیشنهاد بده.'**
  String get ai_promptExams;

  /// No description provided for @ai_promptReports.
  ///
  /// In fa, this message translates to:
  /// **'این گزارش‌ها را مرور کن و مهم‌ترین نکات و قدم بعدی‌ام را در چند جمله بگو.'**
  String get ai_promptReports;

  /// No description provided for @ai_promptStudy.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت مطالعه‌ام (درس‌ها، جلسات امروز و فلش‌کارت‌ها) را ببین و یک پیشنهاد مشخص برای امروز بده.'**
  String get ai_promptStudy;

  /// No description provided for @common_save.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In fa, this message translates to:
  /// **'انصراف'**
  String get common_cancel;

  /// No description provided for @common_add.
  ///
  /// In fa, this message translates to:
  /// **'افزودن'**
  String get common_add;

  /// No description provided for @common_delete.
  ///
  /// In fa, this message translates to:
  /// **'حذف'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In fa, this message translates to:
  /// **'ویرایش'**
  String get common_edit;

  /// No description provided for @common_retry.
  ///
  /// In fa, this message translates to:
  /// **'تلاش دوباره'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In fa, this message translates to:
  /// **'در حال بارگذاری…'**
  String get common_loading;

  /// No description provided for @common_errorTitle.
  ///
  /// In fa, this message translates to:
  /// **'خطایی پیش آمد'**
  String get common_errorTitle;

  /// No description provided for @common_errorDesc.
  ///
  /// In fa, this message translates to:
  /// **'لطفاً دوباره تلاش کن.'**
  String get common_errorDesc;

  /// No description provided for @common_valuePending.
  ///
  /// In fa, this message translates to:
  /// **'به‌زودی'**
  String get common_valuePending;

  /// No description provided for @common_ok.
  ///
  /// In fa, this message translates to:
  /// **'باشه'**
  String get common_ok;

  /// No description provided for @common_close.
  ///
  /// In fa, this message translates to:
  /// **'بستن'**
  String get common_close;

  /// No description provided for @common_untitled.
  ///
  /// In fa, this message translates to:
  /// **'بدون عنوان'**
  String get common_untitled;

  /// No description provided for @common_none.
  ///
  /// In fa, this message translates to:
  /// **'هیچ‌کدام'**
  String get common_none;

  /// No description provided for @ai_suggestion.
  ///
  /// In fa, this message translates to:
  /// **'پیشنهاد AI'**
  String get ai_suggestion;

  /// No description provided for @reports_sleep_daily.
  ///
  /// In fa, this message translates to:
  /// **'روند خواب روزانه'**
  String get reports_sleep_daily;

  /// No description provided for @reports_sleep_avg.
  ///
  /// In fa, this message translates to:
  /// **'میانگین خواب'**
  String get reports_sleep_avg;

  /// No description provided for @reports_exercise_daily.
  ///
  /// In fa, this message translates to:
  /// **'ورزش روزانه'**
  String get reports_exercise_daily;

  /// No description provided for @reports_exercise_total.
  ///
  /// In fa, this message translates to:
  /// **'مجموع ورزش'**
  String get reports_exercise_total;

  /// No description provided for @reports_tests_daily.
  ///
  /// In fa, this message translates to:
  /// **'تعداد تست روزانه'**
  String get reports_tests_daily;

  /// No description provided for @reports_tests_total.
  ///
  /// In fa, this message translates to:
  /// **'مجموع تست‌ها'**
  String get reports_tests_total;

  /// No description provided for @focus_title.
  ///
  /// In fa, this message translates to:
  /// **'تمرکز مطالعه'**
  String get focus_title;

  /// No description provided for @focus_desc.
  ///
  /// In fa, this message translates to:
  /// **'یک جلسهٔ تمرکز شروع کن؛ زمانش را خودت ثبت می‌کنی.'**
  String get focus_desc;

  /// No description provided for @focus_setup_title.
  ///
  /// In fa, this message translates to:
  /// **'شروع جلسهٔ تمرکز'**
  String get focus_setup_title;

  /// No description provided for @focus_start.
  ///
  /// In fa, this message translates to:
  /// **'شروع تمرکز'**
  String get focus_start;

  /// No description provided for @focus_subject.
  ///
  /// In fa, this message translates to:
  /// **'درس'**
  String get focus_subject;

  /// No description provided for @focus_topic.
  ///
  /// In fa, this message translates to:
  /// **'مبحث (اختیاری)'**
  String get focus_topic;

  /// No description provided for @focus_selectSubject.
  ///
  /// In fa, this message translates to:
  /// **'درس را انتخاب کن'**
  String get focus_selectSubject;

  /// No description provided for @focus_duration.
  ///
  /// In fa, this message translates to:
  /// **'مدت جلسه'**
  String get focus_duration;

  /// No description provided for @focus_minutes.
  ///
  /// In fa, this message translates to:
  /// **'دقیقه'**
  String get focus_minutes;

  /// No description provided for @focus_running.
  ///
  /// In fa, this message translates to:
  /// **'در حال مطالعه'**
  String get focus_running;

  /// No description provided for @focus_paused.
  ///
  /// In fa, this message translates to:
  /// **'متوقف'**
  String get focus_paused;

  /// No description provided for @focus_remaining.
  ///
  /// In fa, this message translates to:
  /// **'باقی‌مانده'**
  String get focus_remaining;

  /// No description provided for @focus_pause.
  ///
  /// In fa, this message translates to:
  /// **'توقف'**
  String get focus_pause;

  /// No description provided for @focus_resume.
  ///
  /// In fa, this message translates to:
  /// **'ادامه'**
  String get focus_resume;

  /// No description provided for @focus_end.
  ///
  /// In fa, this message translates to:
  /// **'پایان جلسه'**
  String get focus_end;

  /// No description provided for @focus_completed.
  ///
  /// In fa, this message translates to:
  /// **'جلسه کامل شد و خودکار ثبت گردید'**
  String get focus_completed;

  /// No description provided for @focus_endTitle.
  ///
  /// In fa, this message translates to:
  /// **'پایان جلسه؟'**
  String get focus_endTitle;

  /// No description provided for @focus_endDesc.
  ///
  /// In fa, this message translates to:
  /// **'هنوز به زمان تعیین‌شده نرسیده‌ای. می‌توانی زمان سپری‌شده را ثبت کنی یا بدون ثبت خارج شوی.'**
  String get focus_endDesc;

  /// No description provided for @focus_endRecord.
  ///
  /// In fa, this message translates to:
  /// **'ثبت زمان سپری‌شده'**
  String get focus_endRecord;

  /// No description provided for @focus_endDiscard.
  ///
  /// In fa, this message translates to:
  /// **'بدون ثبت خارج شو'**
  String get focus_endDiscard;

  /// No description provided for @focus_discarded.
  ///
  /// In fa, this message translates to:
  /// **'جلسه بدون ثبت کنار گذاشته شد'**
  String get focus_discarded;

  /// No description provided for @focus_partialSaved.
  ///
  /// In fa, this message translates to:
  /// **'جلسهٔ ناقص ذخیره شد'**
  String get focus_partialSaved;

  /// No description provided for @focus_needSubject.
  ///
  /// In fa, this message translates to:
  /// **'برای شروع تمرکز ابتدا یک درس بساز.'**
  String get focus_needSubject;

  /// No description provided for @focus_newSession.
  ///
  /// In fa, this message translates to:
  /// **'جلسهٔ جدید'**
  String get focus_newSession;

  /// No description provided for @home_quickNote_title.
  ///
  /// In fa, this message translates to:
  /// **'یادداشت سریع'**
  String get home_quickNote_title;

  /// No description provided for @home_quickNote_hint.
  ///
  /// In fa, this message translates to:
  /// **'هر چیزی که باید یادت بماند…'**
  String get home_quickNote_hint;

  /// No description provided for @home_quickNote_save.
  ///
  /// In fa, this message translates to:
  /// **'ذخیره'**
  String get home_quickNote_save;

  /// No description provided for @home_quickNote_saved.
  ///
  /// In fa, this message translates to:
  /// **'یادداشت ذخیره شد'**
  String get home_quickNote_saved;

  /// No description provided for @home_quickNote_clear.
  ///
  /// In fa, this message translates to:
  /// **'پاک کردن'**
  String get home_quickNote_clear;

  /// No description provided for @home_quickNote_clearTitle.
  ///
  /// In fa, this message translates to:
  /// **'پاک کردن یادداشت؟'**
  String get home_quickNote_clearTitle;

  /// No description provided for @home_quickNote_clearDesc.
  ///
  /// In fa, this message translates to:
  /// **'متن این یادداشت برای همیشه حذف می‌شود.'**
  String get home_quickNote_clearDesc;

  /// No description provided for @home_quickNote_cleared.
  ///
  /// In fa, this message translates to:
  /// **'یادداشت پاک شد'**
  String get home_quickNote_cleared;

  /// No description provided for @home_quickNote_emptyTitle.
  ///
  /// In fa, this message translates to:
  /// **'یادداشتی نداری'**
  String get home_quickNote_emptyTitle;

  /// No description provided for @home_quickNote_emptyDesc.
  ///
  /// In fa, this message translates to:
  /// **'سریع‌ترین راه برای ثبت یک فکر یا کار فردا.'**
  String get home_quickNote_emptyDesc;

  /// No description provided for @notif_title.
  ///
  /// In fa, this message translates to:
  /// **'اعلان‌ها'**
  String get notif_title;

  /// No description provided for @notif_emptyTitle.
  ///
  /// In fa, this message translates to:
  /// **'اعلانی نداری'**
  String get notif_emptyTitle;

  /// No description provided for @notif_emptyDesc.
  ///
  /// In fa, this message translates to:
  /// **'یادآورهای برنامه اینجا نمایش داده می‌شوند.'**
  String get notif_emptyDesc;

  /// No description provided for @notif_doTask.
  ///
  /// In fa, this message translates to:
  /// **'انجام وظیفه'**
  String get notif_doTask;

  /// No description provided for @notif_dismiss.
  ///
  /// In fa, this message translates to:
  /// **'بی‌توجه'**
  String get notif_dismiss;

  /// No description provided for @notif_status_read.
  ///
  /// In fa, this message translates to:
  /// **'خوانده شد'**
  String get notif_status_read;

  /// No description provided for @notif_status_actioned.
  ///
  /// In fa, this message translates to:
  /// **'انجام شد'**
  String get notif_status_actioned;

  /// No description provided for @notif_status_dismissed.
  ///
  /// In fa, this message translates to:
  /// **'نادیده گرفته شد'**
  String get notif_status_dismissed;

  /// Reminder created when a task is scheduled for today
  ///
  /// In fa, this message translates to:
  /// **'یادآوری: {title}'**
  String notif_taskReminder(String title);

  /// Focus timer finished
  ///
  /// In fa, this message translates to:
  /// **'تمرکز {minutes} دقیقه ثبت شد'**
  String notif_focusDone(int minutes);

  /// Manual study session logged
  ///
  /// In fa, this message translates to:
  /// **'مطالعه {minutes} دقیقه ثبت شد'**
  String notif_sessionLogged(int minutes);

  /// No description provided for @flashcard_title.
  ///
  /// In fa, this message translates to:
  /// **'فلش‌کارت‌ها'**
  String get flashcard_title;

  /// No description provided for @flashcard_add.
  ///
  /// In fa, this message translates to:
  /// **'افزودن کارت'**
  String get flashcard_add;

  /// No description provided for @flashcard_front.
  ///
  /// In fa, this message translates to:
  /// **'روی کارت'**
  String get flashcard_front;

  /// No description provided for @flashcard_back.
  ///
  /// In fa, this message translates to:
  /// **'پشت کارت'**
  String get flashcard_back;

  /// Number of flashcards due today
  ///
  /// In fa, this message translates to:
  /// **'{count} کارت برای امروز'**
  String flashcard_due(int count);

  /// No description provided for @flashcard_dueNone.
  ///
  /// In fa, this message translates to:
  /// **'همه‌چیز مرور شد ✨'**
  String get flashcard_dueNone;

  /// No description provided for @flashcard_review.
  ///
  /// In fa, this message translates to:
  /// **'شروع مرور'**
  String get flashcard_review;

  /// No description provided for @flashcard_reveal.
  ///
  /// In fa, this message translates to:
  /// **'نمایش پاسخ'**
  String get flashcard_reveal;

  /// No description provided for @flashcard_knew.
  ///
  /// In fa, this message translates to:
  /// **'بلد بودم'**
  String get flashcard_knew;

  /// No description provided for @flashcard_forgot.
  ///
  /// In fa, this message translates to:
  /// **'نیاز به مرور'**
  String get flashcard_forgot;

  /// Cards left in the review session
  ///
  /// In fa, this message translates to:
  /// **'باقی‌مانده: {count}'**
  String flashcard_remaining(int count);

  /// No description provided for @flashcard_done.
  ///
  /// In fa, this message translates to:
  /// **'مرور امروز تمام شد!'**
  String get flashcard_done;

  /// No description provided for @flashcard_empty_title.
  ///
  /// In fa, this message translates to:
  /// **'هنوز کارتی نداری'**
  String get flashcard_empty_title;

  /// No description provided for @flashcard_empty_desc.
  ///
  /// In fa, this message translates to:
  /// **'از هر مفهومی که می‌خوانی یک کارت بساز'**
  String get flashcard_empty_desc;

  /// No description provided for @flashcard_manage.
  ///
  /// In fa, this message translates to:
  /// **'کارت‌های من'**
  String get flashcard_manage;

  /// No description provided for @flashcard_delete.
  ///
  /// In fa, this message translates to:
  /// **'حذف کارت'**
  String get flashcard_delete;

  /// Spaced-repetition box number 1..5
  ///
  /// In fa, this message translates to:
  /// **'جعبه {box}'**
  String flashcard_box(int box);

  /// No description provided for @settings_theme_color.
  ///
  /// In fa, this message translates to:
  /// **'رنگ ظاهر'**
  String get settings_theme_color;

  /// No description provided for @settings_theme_color_blue.
  ///
  /// In fa, this message translates to:
  /// **'آبی'**
  String get settings_theme_color_blue;

  /// No description provided for @settings_theme_color_green.
  ///
  /// In fa, this message translates to:
  /// **'سبز'**
  String get settings_theme_color_green;

  /// No description provided for @settings_theme_color_purple.
  ///
  /// In fa, this message translates to:
  /// **'بنفش'**
  String get settings_theme_color_purple;

  /// No description provided for @settings_theme_color_amber.
  ///
  /// In fa, this message translates to:
  /// **'کهربایی'**
  String get settings_theme_color_amber;

  /// No description provided for @settings_theme_color_pink.
  ///
  /// In fa, this message translates to:
  /// **'صورتی'**
  String get settings_theme_color_pink;

  /// No description provided for @settings_theme_color_teal.
  ///
  /// In fa, this message translates to:
  /// **'فیروزه‌ای'**
  String get settings_theme_color_teal;

  /// No description provided for @ai_provider_openai.
  ///
  /// In fa, this message translates to:
  /// **'سازگار با OpenAI'**
  String get ai_provider_openai;

  /// No description provided for @settings_ai_baseUrl.
  ///
  /// In fa, this message translates to:
  /// **'آدرس پایه (Base URL)'**
  String get settings_ai_baseUrl;

  /// No description provided for @settings_ai_baseUrl_hint.
  ///
  /// In fa, this message translates to:
  /// **'https://api.openai.com/v1'**
  String get settings_ai_baseUrl_hint;

  /// No description provided for @settings_ai_model_hint.
  ///
  /// In fa, this message translates to:
  /// **'gpt-4o-mini / gemini-2.0-flash / llama-3.3-70b'**
  String get settings_ai_model_hint;

  /// No description provided for @ai_errorBadUrl.
  ///
  /// In fa, this message translates to:
  /// **'آدرس سرویس‌دهنده یا مدل درست نیست'**
  String get ai_errorBadUrl;

  /// No description provided for @ai_contextHint.
  ///
  /// In fa, this message translates to:
  /// **'برای پاسخ دربارهٔ داده‌های خودت، «اشتراک خلاصهٔ برنامه» را در تنظیمات روشن کن.'**
  String get ai_contextHint;

  /// No description provided for @ai_chipAnalyze.
  ///
  /// In fa, this message translates to:
  /// **'تحلیل هفته'**
  String get ai_chipAnalyze;

  /// No description provided for @ai_chipPlan.
  ///
  /// In fa, this message translates to:
  /// **'برنامهٔ هفتهٔ آینده'**
  String get ai_chipPlan;

  /// No description provided for @ai_chipReport.
  ///
  /// In fa, this message translates to:
  /// **'گزارش هفتگی'**
  String get ai_chipReport;

  /// No description provided for @ai_chipExams.
  ///
  /// In fa, this message translates to:
  /// **'امتحانات'**
  String get ai_chipExams;

  /// No description provided for @ai_chipAnalyzeQ.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت این هفتهٔ مرا تحلیل کن و نقاط قوت و ضعفم را بگو.'**
  String get ai_chipAnalyzeQ;

  /// No description provided for @ai_chipPlanQ.
  ///
  /// In fa, this message translates to:
  /// **'برای هفتهٔ آینده‌ام یک برنامهٔ مطالعهٔ واقع‌بینانه پیشنهاد بده.'**
  String get ai_chipPlanQ;

  /// No description provided for @ai_chipReportQ.
  ///
  /// In fa, this message translates to:
  /// **'از هفتهٔ من یک گزارش کوتاه بنویس.'**
  String get ai_chipReportQ;

  /// No description provided for @ai_chipExamsQ.
  ///
  /// In fa, this message translates to:
  /// **'نزدیک‌ترین امتحاناتم کدام‌اند و برای هرکدام چقدر وقت دارم؟'**
  String get ai_chipExamsQ;

  /// No description provided for @ai_promptLifestyle.
  ///
  /// In fa, this message translates to:
  /// **'وضعیت خواب، ورزش و انرژی این روزهای مرا تحلیل کن و یک پیشنهاد عملی برای بهتر شدن بده. فقط پیشنهاد بده و چیزی را تغییر نده.'**
  String get ai_promptLifestyle;

  /// No description provided for @ai_promptHome.
  ///
  /// In fa, this message translates to:
  /// **'با توجه به برنامه و وضعیت امروزم بگو الان اولویت‌ترین کارم چیست و یک قدم مشخص برای امروز پیشنهاد بده.'**
  String get ai_promptHome;

  /// No description provided for @lifestyle_exerciseType.
  ///
  /// In fa, this message translates to:
  /// **'نوع ورزش'**
  String get lifestyle_exerciseType;

  /// No description provided for @lifestyle_nutrition.
  ///
  /// In fa, this message translates to:
  /// **'تغذیه'**
  String get lifestyle_nutrition;

  /// No description provided for @lifestyle_rest.
  ///
  /// In fa, this message translates to:
  /// **'استراحت (دقیقه)'**
  String get lifestyle_rest;

  /// No description provided for @lifestyle_sleepQuality.
  ///
  /// In fa, this message translates to:
  /// **'کیفیت خواب'**
  String get lifestyle_sleepQuality;

  /// No description provided for @lifestyle_none.
  ///
  /// In fa, this message translates to:
  /// **'بدون انتخاب'**
  String get lifestyle_none;

  /// No description provided for @lifestyle_exWalking.
  ///
  /// In fa, this message translates to:
  /// **'پیاده‌روی'**
  String get lifestyle_exWalking;

  /// No description provided for @lifestyle_exRunning.
  ///
  /// In fa, this message translates to:
  /// **'دویدن'**
  String get lifestyle_exRunning;

  /// No description provided for @lifestyle_exWeights.
  ///
  /// In fa, this message translates to:
  /// **'وزنه'**
  String get lifestyle_exWeights;

  /// No description provided for @lifestyle_exSwimming.
  ///
  /// In fa, this message translates to:
  /// **'شنا'**
  String get lifestyle_exSwimming;

  /// No description provided for @lifestyle_exGroup.
  ///
  /// In fa, this message translates to:
  /// **'ورزش گروهی'**
  String get lifestyle_exGroup;

  /// No description provided for @lifestyle_food_good.
  ///
  /// In fa, this message translates to:
  /// **'خوب'**
  String get lifestyle_food_good;

  /// No description provided for @lifestyle_food_fair.
  ///
  /// In fa, this message translates to:
  /// **'متوسط'**
  String get lifestyle_food_fair;

  /// No description provided for @lifestyle_food_poor.
  ///
  /// In fa, this message translates to:
  /// **'ضعیف'**
  String get lifestyle_food_poor;

  /// No description provided for @exams_today.
  ///
  /// In fa, this message translates to:
  /// **'امروز'**
  String get exams_today;

  /// No description provided for @exams_tomorrow.
  ///
  /// In fa, this message translates to:
  /// **'فردا'**
  String get exams_tomorrow;

  /// No description provided for @exams_daysLeft.
  ///
  /// In fa, this message translates to:
  /// **'{n} روز مانده'**
  String exams_daysLeft(int n);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
