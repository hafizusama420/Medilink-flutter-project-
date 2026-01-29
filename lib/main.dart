import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app/core/theme/app_theme.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'firebase_options.dart';
import 'app/data/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'app/data/services/call_service.dart';


/// Global navigator key for ZegoCloud to navigate to call screens
final navigatorKey = GlobalKey<NavigatorState>();

/// CRITICAL: Background message handler MUST be top-level function
/// This is called when app is in background or killed state
/// @pragma ensures this function is not tree-shaken during compilation
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase ONLY if not already initialized
  // This prevents [core/duplicate-app] error
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  
  print("📨 Background message received: ${message.messageId}");
  
  // CRITICAL: Ignore ZegoCloud signaling messages!
  // These are handled natively by the ZegoUIKitPrebuiltCallInvitationService plugin.
  // Showing a local notification here will interfere with Zego's full-screen calling UI.
  final data = message.data;
  if (data.containsKey('call_id') || 
      data.containsKey('zegocloud') || 
      (data['body'] != null && data['body'].toString().contains('zegocloud'))) {
    print("🚀 [FCM] Ignoring ZegoCloud signaling message - letting Zego handle it.");
    return;
  }
  
  print("   Title: ${message.notification?.title ?? message.data['title']}");
  print("   Body: ${message.notification?.body ?? message.data['body']}");
  
  // CRITICAL: Must show local notification in background handler
  // FCM only delivers the message; we must display it ourselves
  try {
    final FlutterLocalNotificationsPlugin localNotifications = 
        FlutterLocalNotificationsPlugin();
    
    // Initialize with minimal settings (no callbacks needed in background)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    
    await localNotifications.initialize(initSettings);
    
    // CRITICAL: Create notification channel BEFORE showing notification
    // The channel might not exist if app was killed and this is first run
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medilink_channel',
      'MediLink Notifications',
      description: 'General notifications for MediLink app',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    
    await localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    // Extract title and body from notification OR data payload
    final String title = message.notification?.title ?? 
                        message.data['title'] ?? 
                        'MediLink';
    final String body = message.notification?.body ?? 
                       message.data['body'] ?? 
                       'New notification';
    final String? payload = message.data['appointmentId']?.toString();
    
    // Show the notification with proper Android settings
    await localNotifications.show(
      message.hashCode, // Unique ID based on message
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medilink_channel',
          'MediLink Notifications',
          channelDescription: 'General notifications for MediLink app',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_notification', // Must use drawable resource, not mipmap
        ),
      ),
      payload: payload,
    );
    
    print("✅ Background notification displayed successfully");
  } catch (e, stack) {
    print("❌ Error showing background notification: $e");
    print(stack);
  }
}

void main() async {
  try {
    // Ensure Flutter bindings are initialized before any async operations
    WidgetsFlutterBinding.ensureInitialized();
    
    // Tiny delay to ensure bits are settled before plugin access
    // This helps avoid PlatformException(channel-error) on some devices
    await Future.delayed(const Duration(milliseconds: 100));

    // Initialize local storage with error handling
    try {
      await GetStorage.init();
      print('✅ GetStorage initialized');
    } catch (e) {
      print('❌ GetStorage error: $e');
    }

    // ========== STEP 1: Initialize Firebase ==========
    print('🚀 Initializing Firebase...');
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized');
    } catch (e) {
      print('⚠️ Firebase error: $e');
    }
    
    // ========== STEP 2: Initialize Timezone ==========
    print('🌍 Initializing timezone...');
    try {
      tz.initializeTimeZones();
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print('✅ Timezone set to: $timeZoneName');
    } catch (e) {
      print('⚠️ Timezone error, using UTC: $e');
      try {
        tz.initializeTimeZones();
        tz.setLocalLocation(tz.UTC);
      } catch (_) {}
    }
  } catch (e) {
    print('❌ Fatal initialization error: $e');
    // Continue anyway to allow app to start
  }
  
  // ========== STEP 3: Register Background Handler ==========
  try {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('✅ Background handler registered');
  } catch (e) {
    print('⚠️ Background handler error: $e');
  }
  
  // ========== STEP 4: Initialize Notification Service ==========
  print('🔔 Initializing Notification Service...');
  try {
    await NotificationService().init().timeout(
      const Duration(seconds: 15),
      onTimeout: () => print('⚠️ NotificationService timeout'),
    );
    print('✅ Notification Service initialized');
  } catch (e) {
    print('❌ NotificationService error: $e');
  }
  
  // ========== STEP 5: Set NavigatorKey for ZegoCloud ==========
  print('🔵 Setting ZegoCloud NavigatorKey...');
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);
  print('✅ ZegoCloud NavigatorKey configured');

  // ========== STEP 6: Initialize ZegoCloud for Auto-logged-in Users ==========
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userName = user.displayName ?? '';
      if (userName.isEmpty && user.email != null) {
        userName = user.email!.split('@')[0];
      }
      if (userName.isEmpty) {
        userName = 'User_${user.uid.substring(0, 8)}';
      }
      
      print('🔵 [main] Auto-login detected, initializing ZegoCloud...');
      // Start initialization immediately but don't block app launch
      CallService().onUserLogin(user.uid, userName).then((_) {
        print('✅ [main] ZegoCloud initialization completed');
      }).catchError((e) {
        print('❌ [main] ZegoCloud initialization error: $e');
      });
    }
  } catch (e) {
    print('⚠️ ZegoCloud auto-init error: $e');
  }

  // Run the app
  runApp(const MediLinkApp());
}

class MediLinkApp extends StatelessWidget {
  const MediLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediLink App',
      theme: AppTheme.lightTheme,
      navigatorKey: navigatorKey, // Register navigator key with GetX
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
    );
  }
}
