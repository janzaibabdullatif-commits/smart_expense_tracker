import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );
    tz.initializeTimeZones();
  }

  Future<void> showNotification(int id, String title, String body) async {
    final prefs = await SharedPreferences.getInstance();
    bool notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (!notificationsEnabled) return;

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_alerts',
          'General Alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> showBudgetAlert(String category, double percentage) async {
    final prefs = await SharedPreferences.getInstance();
    bool budgetAlertsEnabled = prefs.getBool('budget_alerts_enabled') ?? true;
    if (!budgetAlertsEnabled) return;

    String title = percentage >= 1.0 ? "🚨 Budget Exceeded" : "⚠️ Budget Warning";
    String body = percentage >= 1.0
        ? "You have exceeded your budget for $category!"
        : "You have used ${(percentage * 100).toStringAsFixed(0)}% of your $category budget.";

    // Use category name hash to have unique but consistent notification IDs per category
    int notificationId = category.hashCode + (percentage >= 1.0 ? 100 : 80);

    await flutterLocalNotificationsPlugin.show(
      notificationId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }

  Future<void> scheduleDailyReminder(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    bool dailyRemindersEnabled = prefs.getBool('daily_reminders_enabled') ?? true;

    // Cancel existing first to avoid duplicates
    await flutterLocalNotificationsPlugin.cancel(0);

    if (!dailyRemindersEnabled) return;

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Daily Reminder',
      'Don\'t forget to record your expenses today! 💸',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminders',
          'Daily Reminders',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> showMonthlySummary(double expenses, double budget) async {
    final prefs = await SharedPreferences.getInstance();
    bool notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    if (!notificationsEnabled) return;

    double savings = budget - expenses;
    String title = "📊 Monthly Financial Summary";
    String body = "Expenses: Rs ${expenses.toStringAsFixed(0)}\n"
                 "Budget: Rs ${budget.toStringAsFixed(0)}\n"
                 "Savings: Rs ${savings.toStringAsFixed(0)}";

    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'monthly_summary',
          'Monthly Summary',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(''),
        ),
      ),
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}