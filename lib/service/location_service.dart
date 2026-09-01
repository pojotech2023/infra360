import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raptor_pro/base_url.dart';
import 'package:raptor_pro/service/shared_preference_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Search "[LocationService]" in console to filter all location tracking logs
// ─────────────────────────────────────────────────────────────────────────────
const _tag = '[LocationService]';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<void> initializeService() async {
    debugPrint('$_tag initializeService() called');
    final service = FlutterBackgroundService();

    // ── 1. Check GPS enabled ────────────────────────────────────────────────
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('$_tag ERROR: Device GPS is turned OFF');
      return Future.error('Location services are disabled.');
    }
    debugPrint('$_tag GPS is enabled on device');

    // ── 2. Check / request permission ──────────────────────────────────────
    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('$_tag Current permission status: $permission');

    if (permission == LocationPermission.denied) {
      // Show prominent disclosure required by Google Play Policies
      bool? agreed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text("Location Permission Required"),
          content: const Text(
              "Pojo Infra360 collects location data to enable tracking your location for supervisor duty, even when the app is closed or not in use. This ensures accurate monitoring of field activities and site management.\n\nPlease tap 'Agree' to proceed and grant location access."),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text("Deny", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text("Agree"),
            ),
          ],
        ),
        barrierDismissible: false,
      );

      if (agreed != true) {
        debugPrint('$_tag User denied location disclosure');
        return Future.error('Location disclosure was not accepted.');
      }

      permission = await Geolocator.requestPermission();
      debugPrint('$_tag Permission after request: $permission');

      if (permission == LocationPermission.denied) {
        debugPrint('$_tag ERROR: Permission still denied after request');
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('$_tag ERROR: Permission permanently denied');
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    debugPrint('$_tag Location permission granted: $permission');

    // ── 3. Create notification channel ─────────────────────────────────────
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'location_tracking',
      'Location Tracking',
      description: 'Used for supervisor background location tracking.',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('$_tag Notification channel created');

    // ── 4. Configure background service ────────────────────────────────────
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'location_tracking',
        initialNotificationTitle: 'Location Tracking Active',
        initialNotificationContent: 'Pojo Infra360 is tracking your location',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    debugPrint('$_tag Background service configured successfully');
  }

  static Future<void> startService() async {
    debugPrint('$_tag startService() called');
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    debugPrint('$_tag Service already running? $isRunning');
    if (!isRunning) {
      service.startService();
      debugPrint('$_tag Service START command sent');
    } else {
      debugPrint('$_tag Service was already running — skipping start');
    }
  }

  static void stopService() {
    debugPrint('$_tag stopService() called');
    FlutterBackgroundService().invoke("stopService");
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// iOS background handler (iOS does not support persistent background services)
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  debugPrint('$_tag [iOS] onIosBackground called');
  return true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Main background service entry point — runs in a SEPARATE Dart isolate
// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  debugPrint('$_tag ✅ onStart() EXECUTED — background isolate is alive at ${DateTime.now()}');

  // ── CRITICAL: Init SharedPreferences in this isolate independently ────────
  // Background isolate has NO shared memory with the Flutter UI isolate.
  debugPrint('$_tag Initializing SharedPreferences in background isolate...');
  await PreferenceUtils().init();

  final String token = PreferenceUtils().getSessionToken();
  debugPrint('$_tag Auth token present: ${token.isNotEmpty}');
  if (token.isNotEmpty) {
    debugPrint('$_tag Auth token (first 10 chars): ${token.substring(0, token.length > 10 ? 10 : token.length)}...');
  }

  if (token.isEmpty) {
    debugPrint('$_tag 🚫 No auth token — user not logged in. Stopping service.');
    service.stopSelf();
    return;
  }

  // ── Service event listeners ───────────────────────────────────────────────
  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      debugPrint('$_tag Event: setAsForeground received');
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      debugPrint('$_tag Event: setAsBackground received');
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    debugPrint('$_tag Event: stopService received — stopping');
    service.stopSelf();
  });

  // ── Send location immediately on start ───────────────────────────────────
  debugPrint('$_tag Sending location immediately on service start...');
  await _sendLocation(token);

  // ── Schedule every 2 minutes ─────────────────────────────────────────────
  debugPrint('$_tag ⏱️ Scheduling location updates every 2 minutes');
  Timer.periodic(const Duration(minutes: 2), (timer) async {
    debugPrint('$_tag ⏰ 2-minute timer fired at ${DateTime.now()} (tick #${timer.tick})');
    // Re-read token each tick in case user logged out
    await PreferenceUtils().init();
    final String currentToken = PreferenceUtils().getSessionToken();
    if (currentToken.isEmpty) {
      debugPrint('$_tag 🚫 Token gone — user logged out. Stopping service.');
      timer.cancel();
      service.stopSelf();
      return;
    }
    await _sendLocation(currentToken);
    debugPrint('$_tag Next location update in 2 minutes');
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Fetch GPS + POST to backend
// Uses direct http.post (NOT ApiData/ApiService) to avoid singletons that
// are NOT initialized in the background isolate.
// Uses last-known-position fallback when fresh GPS times out.
// ─────────────────────────────────────────────────────────────────────────────
Future<void> _sendLocation(String token) async {
  debugPrint('$_tag ──────────────────────────────────────────');
  debugPrint('$_tag _sendLocation() called at ${DateTime.now()}');

  Position? position;

  // ── Step 1a: Last known position (instant — no GPS warm-up wait) ──────────
  try {
    debugPrint('$_tag [Step 1a] Fetching last known position...');
    position = await Geolocator.getLastKnownPosition();
    if (position != null) {
      debugPrint('$_tag [Step 1a] ✅ Last known position found:');
      debugPrint('$_tag   Latitude : ${position.latitude}');
      debugPrint('$_tag   Longitude: ${position.longitude}');
      debugPrint('$_tag   Accuracy : ${position.accuracy}m');
    } else {
      debugPrint('$_tag [Step 1a] No last known position available');
    }
  } catch (e) {
    debugPrint('$_tag [Step 1a] Error: $e');
  }

  // ── Step 1b: Fresh GPS with built-in 25s timeout via AndroidSettings ──────
  try {
    debugPrint('$_tag [Step 1b] Fetching fresh GPS (medium accuracy, 25s timeout)...');
    final freshPosition = await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 25),
        forceLocationManager: false,
      ),
    );
    position = freshPosition;
    debugPrint('$_tag [Step 2] ✅ Fresh GPS SUCCESS:');
    debugPrint('$_tag   Latitude : ${position.latitude}');
    debugPrint('$_tag   Longitude: ${position.longitude}');
    debugPrint('$_tag   Accuracy : ${position.accuracy}m');
  } on TimeoutException {
    debugPrint('$_tag [Step 1b] ⚠️ GPS timed out after 25s — will use last known position if available');
  } catch (e) {
    debugPrint('$_tag [Step 1b] ⚠️ GPS error: $e');
  }

  // ── If absolutely no position available, skip the API call ────────────────
  if (position == null) {
    debugPrint('$_tag ❌ No position available (no GPS fix, no cached) — skipping API call');
    debugPrint('$_tag ──────────────────────────────────────────');
    return;
  }

  // ── Step 3: POST lat/lng to backend ──────────────────────────────────────
  try {
    debugPrint('$_tag [Step 3] Sending location to backend...');
    debugPrint('$_tag   URL: ${baseUrl}save-location');
    debugPrint('$_tag   Latitude : ${position.latitude}');
    debugPrint('$_tag   Longitude: ${position.longitude}');

    final uri = Uri.parse('${baseUrl}save-location');
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'latitude': position.latitude,
        'longitude': position.longitude,
      }),
    ).timeout(
      const Duration(seconds: 20),
      onTimeout: () => throw TimeoutException('API POST timed out after 20s'),
    );

    debugPrint('$_tag [Step 4] API Response:');
    debugPrint('$_tag   Status code  : ${response.statusCode}');
    debugPrint('$_tag   Response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('$_tag ✅ Location saved successfully on backend');
    } else if (response.statusCode == 401) {
      debugPrint('$_tag ⛔ 401 Unauthorized — token expired or invalid');
    } else {
      debugPrint('$_tag ⚠️ Unexpected status ${response.statusCode}: ${response.body}');
    }
  } on TimeoutException catch (e) {
    debugPrint('$_tag ❌ API TIMEOUT: $e');
  } on SocketException catch (e) {
    debugPrint('$_tag ❌ NETWORK ERROR (no internet?): $e');
  } catch (e, stack) {
    debugPrint('$_tag ❌ ERROR posting to backend: $e');
    debugPrint('$_tag   Stack: $stack');
  }

  debugPrint('$_tag ──────────────────────────────────────────');
}
