import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/src/auth/data/models/user_model.dart';
import 'package:gs_orange/src/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:gs_orange/src/dashboard/presentation/utils/dashboard_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

import '../../../../core/permissions/permissions_methods.dart';
import '../../../../core/services/push_notifications/push_notifications_service2.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  static const routeName = '/dashboard';

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  PermissionMethods permissionMethods = PermissionMethods();

  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    dashSetup();
    notificationHandler();
  }

  void notificationHandler(){
    FirebaseMessaging.onMessage.listen((event) async {
      print(event.notification!.title);
      PushNotificationService2().showNotification(event);
    });

    // Initialize the database and reference
    FirebaseDatabase database = FirebaseDatabase.instance;
    DatabaseReference ref = database.ref("path/to/data");

    // Listen to data changes at the reference
    ref.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      print('Data from Firebase: $data');
    });

    // Enable offline persistence for Firebase Realtime Database
    database.setPersistenceEnabled(true);

    // Enable offline persistence for Firestore
    FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);

    // Listen for changes in the connection status for Realtime Database
    database.ref(".info/connected").onValue.listen((event) {
      bool connected = event.snapshot.value as bool;
      if (!connected) {
        print('Disconnected from Firebase, retrying connection...');
        // Handle reconnection logic here, e.g., show a message to the user
      }
    });

  }

  dashSetup() async {
    initializePushNotificationService()
    {
      PushNotificationService2 notificationService = PushNotificationService2();
      notificationService.generateDeviceRecognitionToken();
      notificationService.requestIOSPermissions();
      notificationService.initialize();
      //notificationService.startListeningForNewNotification(context);
    }

    await initializePushNotificationService();
    await permissionMethods.askNotificationsPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LocalUserModel>(
      stream: DashboardUtils.userDataStream,
      builder: (_, snapshot) {
        if (snapshot.hasData && snapshot.data is LocalUserModel) {
          context.read<UserProvider>().user = snapshot.data;
        }
        return Consumer<DashboardController>(
          builder: (_, controller, __) {
            return Scaffold(
              backgroundColor: Colors.white,
              body: IndexedStack(
                index: controller.currentIndex,
                children: controller.screens,
              ),
              bottomNavigationBar:
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.0), // Rounded edges
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26, // Shadow color
                        blurRadius: 10, // Shadow blur radius
                        offset: Offset(0, 4), // Shadow position
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: BottomNavigationBar(
                      currentIndex: controller.currentIndex,
                      showSelectedLabels: false,
                      backgroundColor: Colors.white,
                      elevation: 8,
                      onTap: controller.changeIndex,
                      items: [
                        BottomNavigationBarItem(
                          icon: Icon(
                            controller.currentIndex == 0
                                ? IconlyBold.home
                                : IconlyLight.home,
                            color: controller.currentIndex == 0
                                ? Colours.primaryColour
                                : Colors.grey,
                          ),
                          label: 'Home',
                          backgroundColor: Colors.white,
                        ),
                        //Eskom Feature
                        /*BottomNavigationBarItem(
                          icon: Icon(
                            controller.currentIndex == 1
                                ? IconlyBold.document
                                : IconlyLight.document,
                            color: controller.currentIndex == 1
                                ? Colours.primaryColour
                                : Colors.grey,
                          ),
                          label: 'Materials',
                          backgroundColor: Colors.white,
                        ),*/
                        BottomNavigationBarItem(
                          icon: Icon(
                            controller.currentIndex == 1
                                ? IconlyBold.time_square
                                : IconlyLight.time_square,
                            color: controller.currentIndex == 1
                                ? Colours.primaryColour
                                : Colors.grey,
                          ),
                          label: 'Timers',
                          backgroundColor: Colors.white,
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            controller.currentIndex == 2
                                ? IconlyBold.profile
                                : IconlyLight.profile,
                            color: controller.currentIndex == 2
                                ? Colours.primaryColour
                                : Colors.grey,
                          ),
                          label: 'User',
                          backgroundColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
