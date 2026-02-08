import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'dart:async';


/// NotificationService - Simplified reliable notification system
/// Uses immediate notifications for appointments (shown when created)
/// FCM notifications work perfectly for push messages
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  /// Initialize notification service
  Future<void> init() async {

    
    // ========== STEP 1: Request Notification Permissions ==========
    if (GetPlatform.isAndroid) {

      
      try {
        const AndroidInitializationSettings androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const InitializationSettings initSettings =
            InitializationSettings(android: androidSettings);
        
        await _localNotifications.initialize(initSettings);
        
        final bool? granted = await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
        
        if (granted == true) {

        } else {

        }
      } catch (e) {

      }
    }

    // ========== STEP 2: Request FCM Permissions ==========

    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

    } catch (e) {

    }

    // ========== STEP 3: Initialize Local Notifications with Callbacks ==========

    
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      macOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );


    // ========== STEP 4: Create Android Notification Channels ==========

    try {
      const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
        'medilink_channel',
        'MediLink Notifications',
        description: 'General notifications for MediLink app',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel appointmentChannel = AndroidNotificationChannel(
        'appointment_reminders',
        'Appointment Reminders',
        description: 'Reminders for upcoming appointments',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(generalChannel);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(appointmentChannel);


    } catch (e) {

    }

    // ========== STEP 5: Setup Foreground Message Handler ==========

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      _showFCMNotification(message);
    });

    // ========== STEP 6: Get FCM Token ==========

    try {
      String? token = await _fcm.getToken();

    } catch (e) {

    }

    // ========== STEP 7: Send Test Notification ==========

    try {
      await _localNotifications.show(
        99999,
        '✅ MediLink Notifications Active',
        'Notifications are configured and ready!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medilink_channel',
            'MediLink Notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_notification',
          ),
        ),
      );

    } catch (e) {

    }


  }

  /// Get current FCM token for saving with appointments
  Future<String?> getFCMToken() async {
    try {
      final token = await _fcm.getToken();

      return token;
    } catch (e) {

      return null;
    }
  }

  void _handleNotificationTap(NotificationResponse response) {

    
    try {
      if (response.payload != null && response.payload!.isNotEmpty) {
        Get.toNamed('/appointments', arguments: {
          'appointmentId': response.payload
        });
      } else {
        Get.toNamed('/appointments');
      }
    } catch (e) {

    }
  }

  Future<void> _showFCMNotification(RemoteMessage message) async {
    try {
      final String title = message.notification?.title ?? 
                          message.data['title'] ?? 
                          'MediLink';
      final String body = message.notification?.body ?? 
                         message.data['body'] ?? 
                         'New notification';
      final String? payload = message.data['appointmentId']?.toString();

      await _localNotifications.show(
        message.hashCode,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medilink_channel',
            'MediLink Notifications',
            importance: Importance.high,
            priority: Priority.high,
            icon: 'ic_notification',
          ),
        ),
        payload: payload,
      );
      

    } catch (e) {

    }
  }

  Future<void> sendTestNotification() async {
    try {

      await _localNotifications.show(
        99998,
        '🧪 Test Notification',
        'If you see this, notifications are working perfectly!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medilink_channel',
            'MediLink Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'ic_notification',
          ),
        ),
      );

    } catch (e, stack) {

      rethrow;
    }
  }

  /// Show immediate appointment notification
  /// This is more reliable than scheduled notifications on Realme devices
  Future<bool> scheduleAppointmentReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? appointmentId,
  }) async {
    try {

      
      // Show notification immediately when appointment is created
      await _localNotifications.show(
        id,
        '✅ Appointment Confirmed',
        '$title\nScheduled for: ${_formatDateTime(scheduledDate)}',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_reminders',
            'Appointment Reminders',
            channelDescription: 'Appointment confirmations',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: 'ic_notification',
          ),
        ),
        payload: appointmentId,
      );
      

      return true;
      
    } catch (e, stack) {

      return false;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Cancel notification (no-op for immediate notifications)
  Future<void> cancelNotification(int id) async {

  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();

    } catch (e) {

    }
  }
}
