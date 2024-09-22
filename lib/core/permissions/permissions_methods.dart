import 'package:permission_handler/permission_handler.dart';

class PermissionMethods
{
  askNotificationsPermissions() async
  {
    await Permission.notification.isGranted.then((value)
    {
      if(value)
        {
          Permission.notification.request();
        }
    });
  }
}
