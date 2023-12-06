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
//import FBSDKCoreKit

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
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    
                }
            }
        }
        self.reachabilityManager?.startListening(onQueue: DispatchQueue.main, onUpdatePerforming: { [weak self] (status) in
            self?.netStatus = status
        })
        FirebaseApp.configure()
//        ApplicationDelegate.shared.application(application,didFinishLaunchingWithOptions: launchOptions)
//        Settings.shared.isAdvertiserTrackingEnabled = true
//        Settings.shared.isAdvertiserIDCollectionEnabled = true
//        Settings.shared.isAutoLogAppEventsEnabled = true
//        Settings.shared.isCodelessDebugLogEnabled = false
        return true
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
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
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

