import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:raptor_pro/service/shared_preference_service.dart';
import 'package:raptor_pro/utils/styles.dart';
import 'package:raptor_pro/view/dashboard/dashboard_controller.dart';
import 'package:raptor_pro/view/dashboard/dashboard_screen.dart';
import 'package:raptor_pro/view/login/login_screen.dart';
import 'package:raptor_pro/view/material_category/bricks_details_controller.dart';
import 'package:raptor_pro/view/material_category/new_bricks/new_request_controller.dart';
import 'package:raptor_pro/view/properties_list/properties_list_screen.dart';
import 'package:raptor_pro/view/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:raptor_pro/service/push_notification_service.dart';
import 'package:raptor_pro/service/location_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  await PreferenceUtils().init(); // initialize before app starts
  
  // Initialize Push Notifications
  await PushNotificationService().initialize();
  
  runApp(const MyApp());
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Msm Infratech',
      theme: AppTheme.appTheme,
      navigatorKey: navigatorKey,
      initialRoute: "/",
      builder: (context, child) {
        return SafeArea(
          top: false,
          left: false,
          right: false,
          bottom: true,
          child: child ?? const SizedBox(),
        );
      },
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/properties', page: () => PropertiesListScreen()),
      ],
    );
  }
}

