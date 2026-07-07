import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

/// Top-level background handler — MUST be a top-level function (not inside a class).
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📩 Background message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();

  factory PushNotificationService() => _instance;

  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // High-importance Android channel (matches AndroidManifest meta-data value)
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
    playSound: true,
  );

  // ─────────────────────────────────────────────────────────────────────────
  // PUBLIC ENTRY POINT
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    // 1. Register background handler (must happen before any other FCM call)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 2. Request permission (Android 13+ needs runtime permission)
    await _requestPermissions();

    // 3. Create Android notification channel & init flutter_local_notifications
    await _initLocalNotifications();

    // 4. Fetch the FCM token and listen for refreshes
    await _setupToken();

    // 5. Wire up message listeners
    _setupMessageHandlers();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    final NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );
    debugPrint(
        '🔔 Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _setupToken() async {
    try {
      final String? token = await _fcm.getToken();
      debugPrint('======================================');
      debugPrint('📱 FCM INITIAL TOKEN: $token');
      debugPrint('======================================');

      // Listen for automatic token refreshes
      _fcm.onTokenRefresh.listen((String newToken) {
        debugPrint('======================================');
        debugPrint('🔄 FCM TOKEN REFRESHED: $newToken');
        debugPrint('======================================');
        // TODO: send newToken to your backend server here if required
      });
    } catch (e) {
      debugPrint('❌ Failed to get FCM token: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    // v18 uses positional arguments for initialize()
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);

    await _localNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint(
            '🔔 Local notification tapped. Payload: ${response.payload}');
      },
    );

    // Register the high-importance channel on the Android device
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  void _setupMessageHandlers() {
    // ── FOREGROUND ────────────────────────────────────────────────────────────
    // FCM does not show a heads-up notification when app is in foreground,
    // so we show one manually via flutter_local_notifications.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📲 Foreground message: ${message.messageId}');
      debugPrint('   Data: ${message.data}');
      if (message.notification != null) {
        debugPrint(
            '   Notification: ${message.notification!.title} / ${message.notification!.body}');
        _showLocalNotification(message);
      }
    });

    // ── BACKGROUND → TAP ─────────────────────────────────────────────────────
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('👆 Notification tapped (background): ${message.data}');
      _handleNotificationClick(message);
    });

    // ── TERMINATED → TAP ─────────────────────────────────────────────────────
    _fcm.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('👆 Notification tapped (terminated): ${message.data}');
        _handleNotificationClick(message);
      }
    });
  }

  /// Shows a system notification while the app is in the foreground.
  void _showLocalNotification(RemoteMessage message) {
    final RemoteNotification? notification = message.notification;
    final AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      // v18 uses positional arguments for show()
      _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
          ),
        ),
      );
    }
  }

  void _handleNotificationClick(RemoteMessage message) {
    // The app opens automatically when tapped from background/terminated.
    // Add deep-link navigation here when needed, e.g.:
    // final String? route = message.data['route'];
    // if (route != null) Get.toNamed(route);
    debugPrint('🚀 Notification click handled. Data: ${message.data}');
  }
}
