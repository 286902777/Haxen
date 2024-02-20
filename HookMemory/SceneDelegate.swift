//
//  SceneDelegate.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var first = true

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScenc = (scene as? UIWindowScene) else { return }
        let vc = LoadingViewController()
        self.window = UIWindow.init(windowScene: windowScenc)
        self.window?.rootViewController = vc
        self.window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        HKTBAManager.share.setHktbaParams(type: .session)
        if !first {
            HKUserManager.share.refreshReceipt(from: .update)
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                if HKConfig.currentVC()?.isKind(of: MovieBaseViewController.self) == true {
                    HKADManager.share.hk_loadFullAd(type: .open, placement: .open)
                    HKConfig.showInterAD(type: .open, placement: .open) { _ in
                        
                    }
                }
            }
        } else {
            first = false
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        HKUserManager.share.request.cancel()
        HKUserManager.share.task?.cancel()
        HKUserManager.share.task = nil
    }
    
//    func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection) {
//        var userInfo: [AnyHashable : Any] = [:]
//        if previousInterfaceOrientation.isLandscape {
//            userInfo["isLandscape"] = 0
//        } else {
//            userInfo["isLandscape"] = 1
//        }
//        print("++++++++")
//        NotificationCenter.default.post(name: Noti_WindowInterface, object: nil, userInfo: userInfo)
//    }
}

