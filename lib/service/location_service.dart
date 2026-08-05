import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:raptor_pro/service/shared_preference_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:raptor_pro/api/api_data.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    
    // Request permissions first
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'location_tracking', 
      'Location Tracking', 
      description: 'Used for supervisor background location tracking.', 
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    if (Platform.isIOS || Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
          iOS: DarwinInitializationSettings(),
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
    }

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
        notificationChannelId: 'location_tracking',
        initialNotificationTitle: 'Location Tracking Active',
        initialNotificationContent: 'Tracking your location for supervisor duty',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }

  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    var isRunning = await service.isRunning();
    if (!isRunning) {
      service.startService();
    }
  }

  static void stopService() {
    FlutterBackgroundService().invoke("stopService");
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  
  // Verify user is logged in before continuing
  await PreferenceUtils().init();
  if (PreferenceUtils().getSessionToken().isEmpty) {
    print('🚫 [BACKGROUND] User is not logged in. Stopping tracking service.');
    service.stopSelf();
    return;
  }

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // Call immediately on start
  print('⏳ [BACKGROUND] Immediate location tracking triggered on service start at ${DateTime.now()}');
  await _sendLocation();

  // Then every 5 minutes
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    print('⏰ [BACKGROUND] 5-minute timer triggered at ${DateTime.now()}');
    await _sendLocation();
  });
}

Future<void> _sendLocation() async {
  try {
    print('📍 [BACKGROUND] Fetching high-accuracy GPS coordinates...');
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print('📍 [BACKGROUND] Coordinates fetched: Lat: ${position.latitude}, Lng: ${position.longitude}');
    
    print('📍 [BACKGROUND] Sending location to API...');
    final bool success = await ApiData().saveLocation(position.latitude, position.longitude);
    
    if (success) {
      print('✅ [BACKGROUND] Successfully saved location in the backend.');
    } else {
      print('⚠️ [BACKGROUND] API call completed but returned unsuccessful status or null.');
    }
  } catch (e) {
    print('❌ [BACKGROUND] Error fetching or sending location: $e');
  }
}
