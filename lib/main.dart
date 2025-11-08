import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/res/fonts.dart';
import 'package:gs_orange/core/services/dependency_injection.dart';
import 'package:gs_orange/core/services/injection_container_exports.dart';
import 'package:gs_orange/core/services/router_exports.dart';
import 'package:gs_orange/firebase_options.dart';
import 'package:gs_orange/src/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:gs_orange/src/home/presentation/providers/geyser_provider.dart';
import 'package:gs_orange/src/profile/presentation/refactors/presentation/connection_link_update.dart';
import 'package:gs_orange/src/timers/presentation/refactors/custom_timer_provider/custom_timer_provider.dart';
import 'package:gs_orange/src/timers/presentation/refactors/timers_providers/timer_provider.dart';
import 'package:provider/provider.dart';
import 'package:gs_orange/bootstrap/app_bootstrap.dart';
import 'package:gs_orange/src/ble/presentation/providers/mode_provider.dart';

@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message)async{
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: "GeyserSwitch-Orange",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  await AppBootstrap.preRun();
  await init();
  runApp(const MyApp());
  DependencyInjection.init();
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DashboardController()),
        ChangeNotifierProvider(create: (_) => GeyserProvider()),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
        ChangeNotifierProvider(create: (_) => CustomTimerProvider()),
        ChangeNotifierProvider(create: (_) => ConnectionLinkProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ModeProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GeyserSwitch Orange',
        theme: ThemeData(
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          fontFamily: Fonts.poppins,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            color: Colors.transparent,
          ),
          colorScheme: ColorScheme.fromSwatch(
            accentColor: Colours.primaryColour,
          ),
        ),
        builder: (context, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            AppBootstrap.postRun(context);
            // Bind mode switching (Local vs Remote) to GeyserProvider
            context.read<GeyserProvider>().bindMode(context);
          });
          // Add the MediaQuery to disable text scaling
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          );
        },
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
