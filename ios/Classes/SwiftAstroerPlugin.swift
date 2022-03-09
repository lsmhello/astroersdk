import Flutter
import UIKit
import UserNotifications

public class SwiftAstroerPlugin: NSObject, FlutterPlugin, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let TOKEN_KEY = "ASTROER_APNS_TOKEN"

    var flutterChannel:FlutterMethodChannel

    init(_ channel :FlutterMethodChannel ) {
        flutterChannel = channel
    }


    public static func register(with registrar: FlutterPluginRegistrar) {

        let channel = FlutterMethodChannel(name: "astroer", binaryMessenger: registrar.messenger())
        let instance = SwiftAstroerPlugin(channel)
        registrar.addApplicationDelegate(instance)

        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = instance
        }

        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "device" {
            result(device())
        } else if call.method == "registration"{
            result(registration())
        } else if call.method == "setBadge" {
            guard let args = call.arguments as? Int else {
                print("arguments error...")
                return
            }
            UIApplication.shared.applicationIconBadgeNumber = args
        }

    }

    func device() -> [String: Any]   {
        let uidevice = UIDevice.current
        let infos  = [
                        "model"         : uidevice.model,
                        "localizedModel": uidevice.localizedModel,
                        "description"   : uidevice.description,
                     ]

        let userDefaults   = UserDefaults.standard
        let token          = userDefaults.string(forKey: TOKEN_KEY)
        let credentials    = ["apns" : token == nil ? "" : token]

        var dev:[String:Any] = [:]
        dev["brand"]         = "apple"
        dev["name"]          = uidevice.name
        dev["os"]            = uidevice.systemName + " " + uidevice.systemVersion
        dev["informations"]  = infos
        dev["credentials"]   = credentials

        return dev
    }

    private func registration() -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
                (granted, _) in
                guard granted else { return }

                UNUserNotificationCenter.current().getNotificationSettings {
                    (settings) in
                    guard settings.authorizationStatus == .authorized else { return }

                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                    return
                }
            }

            return true
        } else {
            return false
        }
    }

    public func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
        } else {
            // Fallback on earlier versions
        }
        flutterChannel.invokeMethod("AppleApplicationDidBecomeActive", arguments: nil)
    }

    public func applicationDidFinishLaunching(_ application: UIApplication) {

    }

    @nonobjc
    public func application(_ application: UIApplication,
                            didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
        } else {
            // Fallback on earlier versions
        }

        let params:[String:Any] = ["factory":"apple", "params": launchOptions]
        flutterChannel.invokeMethod("OnClickedNotification", arguments: params)

        return true
    }

    public func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        let params:[String:Any] = ["factory":"apple", "params": notification.userInfo]
        flutterChannel.invokeMethod("OnRecvNotification", arguments: params)
    }

    public func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        let params:[String:Any] = ["factory":"apple", "params": userInfo]
        flutterChannel.invokeMethod("OnRecvNotification", arguments: params)
    }


    @nonobjc
    public func application(_ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void) {
        
        let params:[String:Any] = ["factory":"apple", "params": userInfo]
        flutterChannel.invokeMethod("OnRecvNotification", arguments: params)
 

    }

    @available(iOS 10.0, *)
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

        var args:[String:Any] = ["actionIdentifier": response.actionIdentifier]
        args["identifier"] = response.notification.request.identifier
        let content = response.notification.request.content
        args["params"]  =  content.userInfo
        args["factory"] = "apple"

        flutterChannel.invokeMethod("OnRecvNotification", arguments: args)
        completionHandler()
    }



    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token      = tokenParts.joined()
        print("Device Token: \(token)")


        UserDefaults.standard.set(token, forKey: TOKEN_KEY)

        let param  = ["apple": token]
        flutterChannel.invokeMethod("OnReceiveRegisterResult", arguments: param)
    }

    public func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }



}




