import UIKit
import Flutter
import Firebase // Import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate { // Inherits from FlutterAppDelegate

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Firebase
    FirebaseApp.configure() // This initializes Firebase services

    // Set the UNUserNotificationCenter delegate for handling notifications
    UNUserNotificationCenter.current().delegate = self

    // Register the app to receive remote notifications (APNs)
    application.registerForRemoteNotifications()

    // Call the Flutter generated plugin registrant to register plugins
    GeneratedPluginRegistrant.register(with: self)

    // Continue the normal app initialization process
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // APNs has assigned the device a unique token, register it with Firebase
  override func application(_ application: UIApplication,
                            didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    // Set the APNs token in Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
  }

  // Handle notifications when the app is in the foreground
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    // Show the notification even when the app is in the foreground
    completionHandler([.alert, .badge, .sound])
  }

  // Handle the response to a notification when the user interacts with it
  override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void) {
    // Handle the notification response and trigger any necessary actions
    completionHandler()
  }
}