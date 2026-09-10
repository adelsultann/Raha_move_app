import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "raha/reminders/system", binaryMessenger: controller.binaryMessenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "permissionStatus":
        UNUserNotificationCenter.current().getNotificationSettings { settings in
          switch settings.authorizationStatus {
          case .authorized, .provisional, .ephemeral: result("granted")
          case .denied: result("denied")
          case .notDetermined: result("notDetermined")
          @unknown default: result("denied")
          }
        }
      case "openNotificationSettings":
        DispatchQueue.main.async {
          UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
          result(nil)
        }
      default: result(FlutterMethodNotImplemented)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
