import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/permissions/permissions_methods.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/res/fonts.dart';
import 'package:gs_orange/core/services/dependency_injection.dart';
import 'package:gs_orange/core/services/injection_container.dart';
import 'package:gs_orange/core/services/router.dart';
import 'package:gs_orange/firebase_options.dart';
import 'package:gs_orange/src/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/refactors/home_providers/home_button_provider.dart';
import 'package:gs_orange/src/timers/presentation/refactors/custom_timer_provider/custom_timer_provider.dart';
import 'package:gs_orange/src/timers/presentation/refactors/timers_providers/timer_provider.dart';
import 'package:provider/provider.dart';

import 'core/services/push_notifications/push_notifications_service2.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "GeyserSwitch-Orange",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  await init();

  PermissionMethods permissionMethods = PermissionMethods();
  await permissionMethods.askNotificationsPermissions();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  //PushNotifications.init();
  //Listen to Background Notifications
  // FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
  runApp(const MyApp());
  DependencyInjection.init();
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Ensure Firebase is initialized before handling background messages
  await Firebase.initializeApp();
  PushNotificationService2().showNotification(message);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => HomeButtonProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => CustomTimerProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GeyserSwitch Orange',
        theme: ThemeData(
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: Fonts.poppins,
          appBarTheme: const AppBarTheme(
            color: Colors.transparent,
          ),
          colorScheme: ColorScheme.fromSwatch(
            accentColor: Colours.primaryColour,
          ),
        ),
        builder: (context, child) {
          // Add the MediaQuery to disable text scaling
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: child!,
          );
        },
        onGenerateRoute: generateRoute,
      ),
    );
  }
}