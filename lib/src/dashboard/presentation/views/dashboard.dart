import 'package:gs_orange/core/common/app/providers/user_provider.dart';
import 'package:gs_orange/core/res/colours.dart';
import 'package:gs_orange/core/services/push_notifications/get_service_key.dart';
import 'package:gs_orange/core/services/push_notifications/notification_service.dart';
import 'package:gs_orange/src/auth/data/models/user_model.dart';
import 'package:gs_orange/src/dashboard/presentation/providers/dashboard_controller.dart';
import 'package:gs_orange/src/dashboard/presentation/utils/dashboard_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  static const routeName = '/dashboard';

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  NotificationService notificationService = NotificationService();
  GetServerKey getServerKey = GetServerKey();

  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    initialSetup();
  }

  void initialSetup()async{
    NotificationService.requestNotificationPermissions(context);
    notificationService.firebaseInit(context);
    notificationService.setupInteractMessage(context);
    await notificationService.getDeviceToken();
    getServerKey.getServerKeyToken();
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
                padding: const EdgeInsets.all(9),
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
                      selectedItemColor: Colors.black,
                      currentIndex: controller.currentIndex,
                      showSelectedLabels: true,
                      backgroundColor: Colors.white,
                      elevation: 0,
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
