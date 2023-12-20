//
//  AppDelegate.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit
import CoreData
import IQKeyboardManagerSwift
import AppTrackingTransparency
import Alamofire
import SVProgressHUD
import FirebaseCore
import FirebaseMessaging
import GoogleMobileAds
import AppLovinSDK
import StoreKit
#if DEBUG

#else
import FBSDKCoreKit
#endif
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var allowRotate: Bool = false
    var screenLock: Bool = false
    override init() {
        super.init()
        CaptionTransformer.register()    // 注册CaptionTransformer
    }
    private lazy var reachabilityManager: NetworkReachabilityManager? = {
        let reachbility = NetworkReachabilityManager.default
        return reachbility
    }()
    var netStatus: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown {
        didSet {
            if netStatus != oldValue {
                NotificationCenter.default.post(name: NSNotification.Name("netStatus"), object: nil)
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initIQKeyBoard()
        initSVProgressHUD()
        setTrackingAuth()
        self.reachabilityManager?.startListening(onQueue: DispatchQueue.main, onUpdatePerforming: { [weak self] (status) in
            self?.netStatus = status
        })
        FirebaseApp.configure()
        initGADMobileAds()
        
        HKUserManager.share.getPurchaseData(from: .app)
#if DEBUG
//        HKUserManager.share.isVip = false
#else
        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
        Settings.shared.isAdvertiserTrackingEnabled = true
        Settings.shared.isAdvertiserIDCollectionEnabled = true
        Settings.shared.isAutoLogAppEventsEnabled = true
        Settings.shared.isCodelessDebugLogEnabled = false
#endif
        Messaging.messaging().delegate = self
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error)")
          } else if let token = token {
            print("FCM registration token: \(token)")
          }
        }
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        return true
    }
    
    /// TrackingAuth
    func setTrackingAuth() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
#if DEBUG
#else
                    Settings.shared.isAdvertiserTrackingEnabled = true
#endif
                }
            }
        }
    }
    /// 配置IQKeyboardManager
    func initIQKeyBoard() {
        // 配置键盘
        IQKeyboardManager.shared.enable = true
        // 点击背景收起键盘
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func initSVProgressHUD() {
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setMinimumSize(CGSizeMake(100, 100))
    }
    
    func initGADMobileAds() {
        if let count = UserDefaults.standard.value(forKey: HKKeys.appOpneCount) as? Int {
            UserDefaults.standard.set(count + 1, forKey: HKKeys.appOpneCount)
        } else {
            UserDefaults.standard.set(1, forKey: HKKeys.appOpneCount)
        }
        HKRemoteManager.share.initConfig()
        HKADManager.share.initSet()
        HKTBAManager.share.initSet()

        GADMobileAds.sharedInstance().start { status in
            // Optional: Log each adapter's initialization latency.
            let adapterStatuses = status.adapterStatusesByClassName
            for adapter in adapterStatuses {
                let adapterStatus = adapter.value
                NSLog("Ad Name: %@, Description: %@, Latency: %f", adapter.key,
                      adapterStatus.description, adapterStatus.latency)
            }
            
            if !HKADManager.share.isInit {
                HKADManager.share.adInit()
            }
        }
        GADMobileAds.sharedInstance().applicationMuted = true
    }
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "HookMemory")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if screenLock {
            return .landscape
        } else {
            return allowRotate ? .all : .portrait
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  willPresent notification: UNNotification) async
        -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo

        print(userInfo)

        return [[.alert, .sound]]
      }

      func userNotificationCenter(_ center: UNUserNotificationCenter,
                                  didReceive response: UNNotificationResponse) async {
        let userInfo = response.notification.request.content.userInfo

        print(userInfo)
      }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
      print("Firebase registration token: \(String(describing: fcmToken))")

      let dataDict: [String: String] = ["token": fcmToken ?? ""]
      NotificationCenter.default.post(
        name: Notification.Name("FCMToken"),
        object: nil,
        userInfo: dataDict
      )
    }
}

@available(iOS, introduced: 15.7, obsoleted: 16.0)
@objc extension SKStoreProductViewController {
    func sceneDisconnected(_ arg: AnyObject) {}
    func appWillTerminate() {}
}
