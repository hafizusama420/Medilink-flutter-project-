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
    print('🔔 ========== NOTIFICATION SERVICE INIT START ==========');
    
    // ========== STEP 1: Request Notification Permissions ==========
    if (GetPlatform.isAndroid) {
      print('📱 STEP 1: Requesting Android notification permission...');
      
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
          print('✅ Notification permission granted');
        } else {
          print('⚠️ Notification permission denied or not available');
        }
      } catch (e) {
        print('❌ Error requesting Android permission: $e');
      }
    }

    // ========== STEP 2: Request FCM Permissions ==========
    print('📱 STEP 2: Requesting FCM permissions...');
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      print('✅ FCM permission status: ${settings.authorizationStatus}');
    } catch (e) {
      print('❌ FCM permission error: $e');
    }

    // ========== STEP 3: Initialize Local Notifications with Callbacks ==========
    print('🔔 STEP 3: Initializing local notifications with tap handler...');
    
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
    print('✅ Notification tap handler configured');

    // ========== STEP 4: Create Android Notification Channels ==========
    print('🔔 STEP 4: Creating notification channels...');
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

      print('✅ Notification channels created');
    } catch (e) {
      print('❌ Error creating channels: $e');
    }

    // ========== STEP 5: Setup Foreground Message Handler ==========
    print('🔔 STEP 5: Setting up foreground message handler...');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received: ${message.notification?.title}');
      _showFCMNotification(message);
    });

    // ========== STEP 6: Get FCM Token ==========
    print('🔔 STEP 6: Getting FCM token...');
    try {
      String? token = await _fcm.getToken();
      print("🔑 FCM Token: $token");
    } catch (e) {
      print('❌ FCM token error: $e');
    }

    // ========== STEP 7: Send Test Notification ==========
    print('🔔 STEP 7: Sending startup test notification...');
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
      print('✅ Test notification sent');
    } catch (e) {
      print('❌ Test notification error: $e');
    }

    print('🎉 ========== NOTIFICATION SERVICE INIT COMPLETE ==========');
  }

  /// Get current FCM token for saving with appointments
  Future<String?> getFCMToken() async {
    try {
      final token = await _fcm.getToken();
      print('🔑 Retrieved FCM token: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }

  void _handleNotificationTap(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
    
    try {
      if (response.payload != null && response.payload!.isNotEmpty) {
        Get.toNamed('/appointments', arguments: {
          'appointmentId': response.payload
        });
      } else {
        Get.toNamed('/appointments');
      }
    } catch (e) {
      print('❌ Error handling notification tap: $e');
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
      
      print('✅ Foreground notification displayed');
    } catch (e) {
      print('❌ Error showing foreground notification: $e');
    }
  }

  Future<void> sendTestNotification() async {
    try {
      print('🧪 Sending test notification...');
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
      print('✅ Test notification sent successfully');
    } catch (e, stack) {
      print('❌ Test notification error: $e');
      print(stack);
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
      print('📅 Showing immediate appointment notification');
      
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
      
      print('✅ Appointment notification shown - ID: $id');
      return true;
      
    } catch (e, stack) {
      print('❌ Error showing appointment notification: $e');
      print(stack);
      return false;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Cancel notification (no-op for immediate notifications)
  Future<void> cancelNotification(int id) async {
    print('ℹ️ Notification cancellation not needed for immediate notifications');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      print('✅ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }
}
