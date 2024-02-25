import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
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
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "GeyserSwitch Orange",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
  await init();
  //PushNotifications.init();
  //Listen to Background Notifications
  // FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);
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
        //BlocProvider(create: (_) => sl<LoadSheddingBloc>()),
      ],
      child: GetMaterialApp(
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
        onGenerateRoute: generateRoute,
      ),
    );
  }
}
