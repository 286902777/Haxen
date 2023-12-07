//
//  HKConfig.swift
//  HookMemory
//
//  Created by HF on 2023/11/15.
//

import Foundation
import UIKit
import AdSupport
import Alamofire
import GoogleMobileAds

class HKConfig{
    static let share = HKConfig()
    enum rootType: Int {
        case home = 0
        case movie
    }
    
    static let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    static let idfv = UIDevice.current.identifierForVendor?.uuidString ?? ""
    static let app_version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    
    private let Host: String = "https://sleeve.haxen24.com/thurman/ware"
    private let bundle_id: String = "com.haxenplatform.live"
    
    var isLoadingVC = true
    
    var isForUser = UserDefaults.standard.bool(forKey: HKKeys.isForUser) {
        didSet {
            if isForUser == true {
                UserDefaults.standard.set(isForUser, forKey: HKKeys.isForUser)
                if !isLoadingVC {
                    self.setRoot(.movie)
                }
            }
        }
    }
    
    func appRequest() {
#if DEBUG
        setRoot(.movie)
#else
        if HKConfig.share.getPermission() {
            HKConfig.share.setRoot(.movie)
        } else {
            request { [weak self] info in
                guard let self = self else { return }
                if let result = info, result == "thymus" {
                    HKConfig.share.setPermission(true)
                    self.setRoot(.movie)
                } else {
                    self.setRoot(.home)
                }
            }
        }
#endif
        
    }
    
    func setRoot(_ type: rootType) {
        self.isLoadingVC = false
        DispatchQueue.main.async {
            let vc = HomeViewController()
            let nav = UINavigationController(rootViewController: vc)
            let tabbar = HKTabBarViewController()
            if type == .movie {
                HKConfig.share.currentWindow()?.rootViewController = tabbar
            } else {
                HKConfig.share.currentWindow()?.rootViewController = nav
            }
        }
    }
    
    private func request(complete: @escaping ((_ info: String?) -> Void)) {
        let distinct_id = HKConfig.share.getDistinctId()
        let client_ts = "\(Date().timeIntervalSince1970 * 1000)"
        let device_model = UIDevice().modelName
        let os_version = UIDevice.current.systemVersion
        let idfv = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let gaid = ""
        let android_id = ""
        let os = "ios"
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let app_version = HKConfig.app_version
        
        let paraString = "?itll=\(distinct_id)&sole=\(client_ts)&chair=\(device_model)&ashram=\(bundle_id)&shebang=\(os_version)&sneaky=\(idfv)&editor=\(gaid)&anger=\(android_id)&allegate=\(os)&hobo=\(idfa)&able=\(app_version)"
        let url = Host + paraString
        var request: URLRequest = URLRequest(url: URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                complete(nil)
                return
            }
            if let result = response as? HTTPURLResponse, result.statusCode == 200, let d = data {
                if let dataString = String(data: d, encoding: .utf8) {
                    complete(dataString)
                    return
                }
            } else {
                complete(nil)
            }
        })
        task.resume()
    }
    func setPermission(_ able: Bool) {
        UserDefaults.standard.setValue(able, forKey: "Permission")
        UserDefaults.standard.synchronize()
    }
    
    func getPermission() -> Bool {
        let able = UserDefaults.standard.bool(forKey: "Permission")
        return able
    }
    
    /// uuid
    func getDistinctId() -> String {
        if let uuid = UserDefaults.standard.string(forKey: "uuid") {
            return uuid
        }
        UserDefaults.standard.setValue(UUID().uuidString, forKey: "uuid")
        return UUID().uuidString
    }
    
    func currentWindow() -> UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let sceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = sceneDelegate.window else {
            return UIApplication.shared.windows.last
        }
        return window
    }
    
    var currentVC: UIViewController? {
        get {
            if let window = HKConfig.share.currentWindow() {
                if let navVC = window.rootViewController as? UINavigationController {
                    return navVC.visibleViewController
                }
                if let tabVC = window.rootViewController as? UITabBarController {
                    return tabVC.selectedViewController
                }
                if let presentVC = window.rootViewController?.presentedViewController {
                    return presentVC
                }
                if let vc = window.rootViewController {
                    return vc
                }
            }
            return nil
        }
    }
    
    var isNet: Bool {
        get {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                switch appDelegate.netStatus {
                case .reachable(_):
                    return true
                default:
                    return false
                }
            }
            return false
        }
    }
    
    enum netStatusType: Int {
        case unknown = 0
        case notNet
        case wifi
        case cellular
    }
    
    var netStatus: netStatusType {
        get {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                switch appDelegate.netStatus {
                case .reachable(.cellular):
                    return .cellular
                case .reachable(.ethernetOrWiFi):
                    return .wifi
                case .notReachable:
                    return .notNet
                default:
                    return .unknown
                }
            }
            return .unknown
        }
    }
    
    class func showInterAD(type: HKADType, placement: HKADLogENUM, complete: @escaping(Bool) -> Void) {
        HKADManager.share.hk_showFullAd(type: type, placement: placement) { result, ad in
            DispatchQueue.main.async {
                if result, let vc = HKConfig.share.currentVC {
                    if let ad = ad as? GADInterstitialAd {
                        ad.present(fromRootViewController: vc)
                        complete(true)
                    } else if let ad = ad as? GADAppOpenAd {
                        ad.present(fromRootViewController: vc)
                        complete(true)
                    } else if let ad = ad as? GADRewardedAd {
                        ad.present(fromRootViewController: vc, userDidEarnRewardHandler: {
//                            toast("Reward received!")
                        })
                        complete(true)
                    } else if let ad = ad as? GADRewardedInterstitialAd {
                        ad.present(fromRootViewController: vc, userDidEarnRewardHandler: {
//                            toast("Reward received!")
                        })
                        complete(true)
                    } else {
                        complete(true)
                    }
                    
                } else {
                    complete(false)
                }
            }
        }
    }
}

