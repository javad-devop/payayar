// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Payayaar';

  @override
  String get brandLatin => 'PAYAYAR';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_planning => 'Planning';

  @override
  String get nav_study => 'Study';

  @override
  String get nav_exams => 'Exams';

  @override
  String get nav_reports => 'Reports';

  @override
  String get nav_lifestyle => 'Lifestyle';

  @override
  String get nav_aiAdvisor => 'AI Advisor';

  @override
  String get nav_settings => 'Settings';

  @override
  String get nav_more => 'More';

  @override
  String get home_greeting => 'Hi';

  @override
  String get home_greetingSubtitle => 'What progress are you making today?';

  @override
  String get home_metric_plannedToday => 'Planned today';

  @override
  String get home_metric_completed => 'Completed';

  @override
  String get home_metric_remaining => 'Remaining';

  @override
  String get home_metric_nextExam => 'Next exam';

  @override
  String get home_metric_todayStudy => 'Studied today';

  @override
  String get home_metric_streak => 'Day streak';

  @override
  String get home_todayPlan_title => 'Today\'s plan';

  @override
  String get home_todayPlan_emptyTitle => 'No plan recorded yet';

  @override
  String get home_todayPlan_emptyDesc =>
      'Build today\'s plan from the Planning section.';

  @override
  String get home_calendar_title => 'Calendar';

  @override
  String get home_progress_title => 'Today\'s progress';

  @override
  String get home_ai_title => 'AI Advisor';

  @override
  String get home_ai_unconfigured => 'No API key configured.';

  @override
  String get home_ai_cta => 'Go to settings';

  @override
  String get home_recentActivities_title => 'Recent activity';

  @override
  String get home_lifestyle_title => 'Lifestyle summary';

  @override
  String get home_lifestyle_none => 'Nothing logged today';

  @override
  String get home_recentExams_title => 'Recent exams';

  @override
  String get home_quickActions_title => 'Quick actions';

  @override
  String get action_logStudy => 'Log study';

  @override
  String get action_logTest => 'Log test';

  @override
  String get action_logSleep => 'Log sleep';

  @override
  String get action_logExercise => 'Log exercise';

  @override
  String get action_addTask => 'Add task';

  @override
  String get empty_study_title => 'No study recorded yet';

  @override
  String get empty_study_desc =>
      'After your first session, test or review, it shows up here.';

  @override
  String get empty_planning_title => 'No plan created yet';

  @override
  String get empty_planning_desc => 'Add your first task to get started.';

  @override
  String get empty_exams_title => 'No exams recorded';

  @override
  String get empty_exams_desc => 'Record your exams to see results and trends.';

  @override
  String get empty_reports_title => 'No data for reports yet';

  @override
  String get empty_reports_desc =>
      'Reports appear here as you log study and tests.';

  @override
  String get empty_lifestyle_title => 'Lifestyle not logged';

  @override
  String get empty_lifestyle_desc =>
      'Log sleep, exercise and daily notes to see trends.';

  @override
  String get empty_ai_title => 'AI Advisor is ready';

  @override
  String get empty_ai_desc =>
      'Enter your own Gemini API key in Settings to start chatting.';

  @override
  String get empty_topics_title => 'No topics yet';

  @override
  String get empty_topics_desc => 'Add your topics for this subject.';

  @override
  String get settings_title => 'Settings';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_language_fa => 'فارسی';

  @override
  String get settings_language_en => 'English';

  @override
  String get settings_theme => 'Theme';

  @override
  String get settings_theme_dark => 'Dark';

  @override
  String get settings_theme_light => 'Light';

  @override
  String get settings_userName => 'Name';

  @override
  String get settings_userName_hint => 'Shown in the app greeting';

  @override
  String get settings_ai => 'AI Advisor';

  @override
  String get settings_ai_comingSoon =>
      'Configuration lives further down this page.';

  @override
  String get settings_ai_provider => 'Provider';

  @override
  String get settings_ai_model => 'Model';

  @override
  String get settings_ai_key => 'API key';

  @override
  String get settings_ai_key_hint => 'Stored only on this device';

  @override
  String get settings_ai_test => 'Test connection';

  @override
  String get settings_ai_testOk => 'Connection successful';

  @override
  String settings_ai_testFail(String error) {
    return 'Connection failed: $error';
  }

  @override
  String get settings_ai_keyMissing => 'Enter your API key';

  @override
  String get settings_data => 'Data management';

  @override
  String get settings_data_export => 'Export backup (JSON)';

  @override
  String get settings_data_import => 'Restore from backup';

  @override
  String get settings_data_importConfirm =>
      'Backup data will be merged into your current data. Continue?';

  @override
  String settings_data_importDone(int count) {
    return '$count records imported';
  }

  @override
  String get settings_data_importInvalid => 'Invalid backup file';

  @override
  String get settings_data_wipe => 'Erase all data';

  @override
  String get settings_data_wipeConfirm =>
      'All plans, subjects, exams and reports will be permanently deleted. This cannot be undone!';

  @override
  String get settings_data_wipeType => 'Type DELETE to confirm';

  @override
  String get settings_about => 'About';

  @override
  String get settings_about_version => 'Version';

  @override
  String get settings_ai_localNote =>
      'All data is stored locally on this device only.';

  @override
  String get planning_title => 'Planning';

  @override
  String get planning_tab_week => 'Weekly';

  @override
  String get planning_tab_day => 'Daily';

  @override
  String get planning_tab_dashboard => 'Dashboard';

  @override
  String get planning_tab_mock => 'Mock exams';

  @override
  String get planning_week_prev => 'Previous week';

  @override
  String get planning_week_next => 'Next week';

  @override
  String get planning_week_today => 'Today';

  @override
  String get planning_task_add => 'New task';

  @override
  String get planning_task_edit => 'Edit task';

  @override
  String get planning_task_title => 'Title';

  @override
  String get planning_task_titleHint => 'e.g. Review algebra';

  @override
  String get planning_task_subject => 'Subject';

  @override
  String get planning_task_subjectNone => 'No subject';

  @override
  String get planning_task_topic => 'Topic';

  @override
  String get planning_task_topicNone => 'No topic';

  @override
  String get planning_task_date => 'Date';

  @override
  String get planning_task_start => 'Start time';

  @override
  String get planning_task_duration => 'Duration (minutes)';

  @override
  String get planning_task_priority => 'Priority';

  @override
  String get planning_task_notes => 'Notes';

  @override
  String get planning_task_delete => 'Delete task';

  @override
  String get planning_task_deleteConfirm =>
      'This task will be permanently deleted.';

  @override
  String get planning_task_moveTo => 'Move to another day';

  @override
  String get planning_task_complete => 'Complete';

  @override
  String get planning_task_reopen => 'Reopen';

  @override
  String get planning_task_cancel => 'Cancel';

  @override
  String get planning_task_skip => 'Skip';

  @override
  String get planning_priority_low => 'Low';

  @override
  String get planning_priority_medium => 'Medium';

  @override
  String get planning_priority_high => 'High';

  @override
  String get planning_status_notStarted => 'Not started';

  @override
  String get planning_status_inProgress => 'In progress';

  @override
  String get planning_status_completed => 'Completed';

  @override
  String get planning_status_cancelled => 'Cancelled';

  @override
  String get planning_status_moved => 'Moved';

  @override
  String get planning_status_skipped => 'Skipped';

  @override
  String get planning_dashboard_planned => 'Planned hours';

  @override
  String get planning_dashboard_actual => 'Completed hours';

  @override
  String get planning_dashboard_completion => 'Completion';

  @override
  String get planning_dashboard_overdue => 'Overdue';

  @override
  String get planning_dashboard_today => 'Today\'s tasks';

  @override
  String get planning_dashboard_upcoming => 'Upcoming days';

  @override
  String get planning_day_empty => 'No tasks recorded for this day';

  @override
  String get planning_mock_title => 'Mock exams';

  @override
  String get planning_mock_add => 'Add mock exam';

  @override
  String get planning_mock_desc => 'You decide when your next exam happens.';

  @override
  String get planning_mock_subjects => 'Subjects and topics (optional)';

  @override
  String get planning_noSubjectsYet => 'You haven\'t created any subjects yet';

  @override
  String get planning_minutes => 'min';

  @override
  String get planning_hoursUnit => 'h';

  @override
  String get study_title => 'Study';

  @override
  String get study_addSubject => 'New subject';

  @override
  String get study_subjectName => 'Subject name';

  @override
  String get study_subjectNameHint => 'e.g. Mathematics';

  @override
  String get study_subjectCategory => 'Category (optional)';

  @override
  String get study_addTopic => 'New topic';

  @override
  String get study_topicName => 'Topic name';

  @override
  String get study_addSubtopic => 'New subtopic';

  @override
  String get study_deleteSubject => 'Delete subject';

  @override
  String get study_deleteSubjectConfirm =>
      'All of its topics and study sessions will be deleted too.';

  @override
  String get study_deleteTopic => 'Delete topic';

  @override
  String get study_deleteTopicConfirm =>
      'This topic will be permanently deleted.';

  @override
  String get study_topicStatus => 'Status';

  @override
  String get study_status_notStarted => 'Not started';

  @override
  String get study_status_learning => 'Learning';

  @override
  String get study_status_reviewing => 'Reviewing';

  @override
  String get study_status_mastered => 'Mastered';

  @override
  String get study_difficulty => 'Difficulty';

  @override
  String get study_mastery => 'Mastery';

  @override
  String get study_session_add => 'Log study session';

  @override
  String get study_session_type => 'Type';

  @override
  String get study_session_type_learning => 'Learning';

  @override
  String get study_session_type_review => 'Review';

  @override
  String get study_session_type_test => 'Test';

  @override
  String get study_session_type_problemSolving => 'Problem solving';

  @override
  String get study_session_start => 'Start';

  @override
  String get study_session_end => 'End';

  @override
  String get study_session_history => 'Study history';

  @override
  String get study_topicNotes => 'Topic notes';

  @override
  String get study_sessionsTotal => 'Total study';

  @override
  String get exams_title => 'Exams';

  @override
  String get ai_weeklySummary => 'AI weekly summary';

  @override
  String ai_weeklySummaryPrompt(Object range) {
    return 'Summarize my $range: what went well, where I fell behind, and what you suggest for next week. Keep it short.';
  }

  @override
  String get calc_title => 'Grade calculator';

  @override
  String get calc_score => 'Score';

  @override
  String get calc_weight => 'Weight';

  @override
  String get calc_add => 'Add row';

  @override
  String get calc_average => 'Weighted average';

  @override
  String remind_examToday(Object title) {
    return '$title: exam today';
  }

  @override
  String remind_examTomorrow(Object title) {
    return '$title: exam tomorrow';
  }

  @override
  String remind_examInDays(Object n, Object title) {
    return '$title: exam in $n days';
  }

  @override
  String remind_taskToday(Object title) {
    return 'Task «$title» is due today';
  }

  @override
  String remind_taskTomorrow(Object title) {
    return 'Task «$title» is due tomorrow';
  }

  @override
  String get exams_add => 'New exam';

  @override
  String get exams_edit => 'Edit exam';

  @override
  String get exams_examTitle => 'Exam title';

  @override
  String get exams_type => 'Type';

  @override
  String get exams_type_mock => 'Mock exam';

  @override
  String get exams_type_school => 'School exam';

  @override
  String get exams_type_personal => 'Personal test';

  @override
  String get exams_type_other => 'Other';

  @override
  String get exams_date => 'Date';

  @override
  String get exams_duration => 'Duration (minutes)';

  @override
  String get exams_description => 'Description';

  @override
  String get exams_deleteConfirm =>
      'This exam and all of its results will be deleted.';

  @override
  String get exams_results => 'Results';

  @override
  String get exams_result_add => 'Add result';

  @override
  String get exams_result_subject => 'Subject';

  @override
  String get exams_result_overall => 'Overall result';

  @override
  String get exams_result_correct => 'Correct';

  @override
  String get exams_result_wrong => 'Wrong';

  @override
  String get exams_result_unanswered => 'Unanswered';

  @override
  String get exams_result_score => 'Score';

  @override
  String get exams_result_timeSpent => 'Time spent (minutes)';

  @override
  String get exams_result_percent => 'Percent';

  @override
  String get exams_analysis => 'Analysis';

  @override
  String get exams_analysis_strong => 'Strong subjects';

  @override
  String get exams_analysis_weak => 'Weak subjects';

  @override
  String get exams_analysis_trend => 'Score trend';

  @override
  String get exams_analysis_noResults => 'No results recorded yet';

  @override
  String get exams_upcoming => 'Upcoming exams';

  @override
  String get exams_past => 'Past exams';

  @override
  String get reports_title => 'Reports';

  @override
  String get reports_range_week => 'This week';

  @override
  String get reports_range_month => 'This month';

  @override
  String get reports_study_daily => 'Daily study hours';

  @override
  String get reports_study_total => 'Total study';

  @override
  String get reports_study_subjectDistribution => 'Subject distribution';

  @override
  String get reports_planning_completion => 'Plan completion';

  @override
  String get reports_planning_plannedVsDone => 'Planned vs completed';

  @override
  String get reports_subjects_mastery => 'Topic mastery';

  @override
  String get reports_subjects_weak => 'Weak topics (below 50%)';

  @override
  String get reports_exams_scores => 'Exam score trend';

  @override
  String get reports_notEnoughData => 'Not enough data for this report yet.';

  @override
  String get lifestyle_title => 'Lifestyle';

  @override
  String get lifestyle_today => 'Today\'s log';

  @override
  String get lifestyle_sleep => 'Sleep';

  @override
  String get lifestyle_bedTime => 'Bed time';

  @override
  String get lifestyle_wakeTime => 'Wake time';

  @override
  String get lifestyle_exercise => 'Exercise (minutes)';

  @override
  String get lifestyle_mood => 'Mood';

  @override
  String get lifestyle_energy => 'Energy';

  @override
  String get lifestyle_screenTime => 'Screen time (minutes)';

  @override
  String get lifestyle_notes => 'Daily note';

  @override
  String get lifestyle_save => 'Save today';

  @override
  String get lifestyle_saved => 'Saved';

  @override
  String get lifestyle_history => 'History';

  @override
  String get lifestyle_observation_title => 'Simple observation';

  @override
  String lifestyle_observation_energy(int diff) {
    return 'Days you slept more, your energy was $diff points higher.';
  }

  @override
  String get lifestyle_observation_needMore =>
      'Log 7 days to see simple observations here.';

  @override
  String get lifestyle_level_1 => 'Very low';

  @override
  String get lifestyle_level_2 => 'Low';

  @override
  String get lifestyle_level_3 => 'Medium';

  @override
  String get lifestyle_level_4 => 'Good';

  @override
  String get lifestyle_level_5 => 'Great';

  @override
  String get ai_title => 'AI Advisor';

  @override
  String get ai_notConfigured =>
      'Enter your own API key in Settings to start chatting.';

  @override
  String get ai_configure => 'Configure AI';

  @override
  String get ai_inputHint => 'Type your question…';

  @override
  String get ai_send => 'Send';

  @override
  String get ai_thinking => 'Thinking…';

  @override
  String get ai_error => 'AI request failed';

  @override
  String get ai_errorNetwork =>
      'Could not connect. Check your internet or API key.';

  @override
  String get ai_errorNoKey => 'No API key configured.';

  @override
  String get ai_newChat => 'New chat';

  @override
  String get ai_suggestionApply => 'Apply';

  @override
  String get ai_suggestionEdit => 'Edit';

  @override
  String get ai_suggestionDismiss => 'Dismiss';

  @override
  String get ai_suggestionTask => 'Task suggestion';

  @override
  String get ai_welcome =>
      'Hi! I\'m your AI advisor. We can talk about your study plan or I can give suggestions — but nothing changes without your approval.';

  @override
  String get ai_contextConsent => 'Send a summary of my plan to AI';

  @override
  String get ai_provider_gemini => 'Google Gemini';

  @override
  String get ai_provider_none => 'Not selected';

  @override
  String get ai_assist => 'AI help';

  @override
  String get ai_promptPlanning =>
      'Look at my weekly plan and upcoming exams and give three practical suggestions to improve it. Only suggest — change nothing.';

  @override
  String get ai_promptExams =>
      'Analyze my exam results and history and tell me which subjects I should focus on most. Only suggest.';

  @override
  String get ai_promptReports =>
      'Review these reports and give me the most important points and my next step in a few sentences.';

  @override
  String get ai_promptStudy =>
      'Look at my study status (subjects, today\'s sessions, flashcards) and give one concrete suggestion for today.';

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_add => 'Add';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_loading => 'Loading…';

  @override
  String get common_errorTitle => 'Something went wrong';

  @override
  String get common_errorDesc => 'Please try again.';

  @override
  String get common_valuePending => 'Coming soon';

  @override
  String get common_ok => 'OK';

  @override
  String get common_close => 'Close';

  @override
  String get common_untitled => 'Untitled';

  @override
  String get common_none => 'None';

  @override
  String get ai_suggestion => 'AI suggestion';

  @override
  String get reports_sleep_daily => 'Daily sleep trend';

  @override
  String get reports_sleep_avg => 'Average sleep';

  @override
  String get reports_exercise_daily => 'Daily exercise';

  @override
  String get reports_exercise_total => 'Total exercise';

  @override
  String get reports_tests_daily => 'Daily test count';

  @override
  String get reports_tests_total => 'Total tests';

  @override
  String get focus_title => 'Focus session';

  @override
  String get focus_desc =>
      'Start a focus session; you record the time yourself.';

  @override
  String get focus_setup_title => 'Start focus session';

  @override
  String get focus_start => 'Start focus';

  @override
  String get focus_subject => 'Subject';

  @override
  String get focus_topic => 'Topic (optional)';

  @override
  String get focus_selectSubject => 'Pick a subject';

  @override
  String get focus_duration => 'Session length';

  @override
  String get focus_minutes => 'min';

  @override
  String get focus_running => 'Studying';

  @override
  String get focus_paused => 'Paused';

  @override
  String get focus_remaining => 'Remaining';

  @override
  String get focus_pause => 'Pause';

  @override
  String get focus_resume => 'Resume';

  @override
  String get focus_end => 'End session';

  @override
  String get focus_completed => 'Session completed and saved automatically';

  @override
  String get focus_endTitle => 'End session?';

  @override
  String get focus_endDesc =>
      'You have not reached the planned time. You can save the elapsed time or leave without saving.';

  @override
  String get focus_endRecord => 'Save elapsed time';

  @override
  String get focus_endDiscard => 'Leave without saving';

  @override
  String get focus_discarded => 'Session discarded without saving';

  @override
  String get focus_partialSaved => 'Partial session saved';

  @override
  String get focus_needSubject =>
      'Create a subject before starting a focus session.';

  @override
  String get focus_newSession => 'New session';

  @override
  String get home_quickNote_title => 'Quick note';

  @override
  String get home_quickNote_hint => 'Anything you need to remember…';

  @override
  String get home_quickNote_save => 'Save';

  @override
  String get home_quickNote_saved => 'Note saved';

  @override
  String get home_quickNote_clear => 'Clear';

  @override
  String get home_quickNote_clearTitle => 'Clear the note?';

  @override
  String get home_quickNote_clearDesc =>
      'This note\'s text will be removed permanently.';

  @override
  String get home_quickNote_cleared => 'Note cleared';

  @override
  String get home_quickNote_emptyTitle => 'No note yet';

  @override
  String get home_quickNote_emptyDesc =>
      'The fastest way to capture a thought or tomorrow\'s task.';

  @override
  String get notif_title => 'Notifications';

  @override
  String get notif_emptyTitle => 'No notifications yet';

  @override
  String get notif_emptyDesc => 'Plan reminders will appear here.';

  @override
  String get notif_doTask => 'Do task';

  @override
  String get notif_dismiss => 'Dismiss';

  @override
  String get notif_status_read => 'Read';

  @override
  String get notif_status_actioned => 'Done';

  @override
  String get notif_status_dismissed => 'Dismissed';

  @override
  String notif_taskReminder(String title) {
    return 'Reminder: $title';
  }

  @override
  String notif_focusDone(int minutes) {
    return 'Focus of $minutes min logged';
  }

  @override
  String notif_sessionLogged(int minutes) {
    return 'Study session of $minutes min logged';
  }

  @override
  String get flashcard_title => 'Flashcards';

  @override
  String get flashcard_add => 'Add card';

  @override
  String get flashcard_front => 'Front';

  @override
  String get flashcard_back => 'Back';

  @override
  String flashcard_due(int count) {
    return '$count cards due today';
  }

  @override
  String get flashcard_dueNone => 'All caught up ✨';

  @override
  String get flashcard_review => 'Start review';

  @override
  String get flashcard_reveal => 'Show answer';

  @override
  String get flashcard_knew => 'I knew it';

  @override
  String get flashcard_forgot => 'Need to repeat';

  @override
  String flashcard_remaining(int count) {
    return 'Remaining: $count';
  }

  @override
  String get flashcard_done => 'Today\'s review is complete!';

  @override
  String get flashcard_empty_title => 'No cards yet';

  @override
  String get flashcard_empty_desc => 'Make a card from anything you study';

  @override
  String get flashcard_manage => 'My cards';

  @override
  String get flashcard_delete => 'Delete card';

  @override
  String flashcard_box(int box) {
    return 'Box $box';
  }

  @override
  String get settings_theme_color => 'Theme color';

  @override
  String get settings_theme_color_blue => 'Blue';

  @override
  String get settings_theme_color_green => 'Green';

  @override
  String get settings_theme_color_purple => 'Purple';

  @override
  String get settings_theme_color_amber => 'Amber';

  @override
  String get settings_theme_color_pink => 'Pink';

  @override
  String get settings_theme_color_teal => 'Teal';

  @override
  String get ai_provider_openai => 'OpenAI-compatible';

  @override
  String get settings_ai_baseUrl => 'Base URL';

  @override
  String get settings_ai_baseUrl_hint => 'https://api.openai.com/v1';

  @override
  String get settings_ai_model_hint =>
      'gpt-4o-mini / gemini-2.0-flash / llama-3.3-70b';

  @override
  String get ai_errorBadUrl => 'The service URL or model is not correct';

  @override
  String get ai_contextHint =>
      'Turn on “Share plan summary” in Settings so the advisor can answer questions about your data.';

  @override
  String get ai_chipAnalyze => 'Week analysis';

  @override
  String get ai_chipPlan => 'Next-week plan';

  @override
  String get ai_chipReport => 'Weekly report';

  @override
  String get ai_chipExams => 'Exams';

  @override
  String get ai_chipAnalyzeQ =>
      'Analyze my week and tell me my strengths and weaknesses.';

  @override
  String get ai_chipPlanQ => 'Suggest a realistic study plan for next week.';

  @override
  String get ai_chipReportQ => 'Write a short report about my week.';

  @override
  String get ai_chipExamsQ =>
      'Which exams are coming up and how much time do I have for each?';

  @override
  String get ai_promptLifestyle =>
      'Analyze my recent sleep, exercise and energy, and give one practical suggestion. Only suggest — change nothing.';

  @override
  String get ai_promptHome =>
      'Given my plan and today\'s status, tell me the single most important thing to do now and suggest one concrete step for today.';

  @override
  String get lifestyle_exerciseType => 'Exercise type';

  @override
  String get lifestyle_nutrition => 'Nutrition';

  @override
  String get lifestyle_rest => 'Rest (min)';

  @override
  String get lifestyle_sleepQuality => 'Sleep quality';

  @override
  String get lifestyle_none => 'None';

  @override
  String get lifestyle_exWalking => 'Walking';

  @override
  String get lifestyle_exRunning => 'Running';

  @override
  String get lifestyle_exWeights => 'Weights';

  @override
  String get lifestyle_exSwimming => 'Swimming';

  @override
  String get lifestyle_exGroup => 'Team sport';

  @override
  String get lifestyle_food_good => 'Good';

  @override
  String get lifestyle_food_fair => 'Fair';

  @override
  String get lifestyle_food_poor => 'Poor';

  @override
  String get exams_today => 'Today';

  @override
  String get exams_tomorrow => 'Tomorrow';

  @override
  String exams_daysLeft(int n) {
    return '$n days left';
  }
}
