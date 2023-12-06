//
//  HKRemoteManager.swift
//  HookMemory
//
//  Created by HF on 2023/12/1.
//

import UIKit
import FirebaseRemoteConfig

class HKRemoteManager: NSObject {
    
    static let share = HKRemoteManager()
    
    var config = RemoteConfig.remoteConfig()
    
    var retryCount = 0
    
    let advertiseKey = "advertiseKey"
    
    func initConfig() {
        // ad setting
        var admob = ""
        if let adJson = UserDefaults.standard.value(forKey: advertiseKey) as? String, adJson.count > 0 {
            admob = UserDefaults.standard.value(forKey: advertiseKey) as! String
        } else {
#if DEBUG
            let filePath = Bundle.main.path(forResource: "hk_ad_debug", ofType: "json")!
#else
            let filePath = Bundle.main.path(forResource: "hk_ad_release", ofType: "json")!
#endif
            let fileData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
            admob = fileData.base64EncodedString()
        }
        
        config.setDefaults(["ad_json_ios": admob as NSObject])
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        config.configSettings = settings
        self.fetchConfigData()
    }
    
    func fetchConfigData() {
        config.fetch { status, error in
            guard error == nil else {
                HKLog.log("HKRemote config error: \(error?.localizedDescription ?? "No error available.")")
                if self.retryCount == 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                        self.retryCount += 1
                        self.fetchConfigData()
                    }
                }
                return
            }
            HKLog.log("HKRemote config successfully fetched")
            self.requestConfig()
        }
    }
    
    private func requestConfig() {
        config.activate { success, error in
            guard error == nil else {
                HKLog.log("HKRemote activated error: \(error?.localizedDescription ?? "No error available.")")
                return
            }
            HKLog.log("HKRemote config successfully activated!")
            DispatchQueue.main.async {
                if let jsonString = self.config["ad_json_ios"].stringValue {
                    if jsonString != UserDefaults.standard.value(forKey: self.advertiseKey) as? String {
                        UserDefaults.standard.set(jsonString, forKey: self.advertiseKey)
                        let jsonData = Data(base64Encoded: jsonString) ?? Data()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 12) {
//                            do {
//                                MTMobileAdManager.standred.adInfo = try JSONDecoder().decode(MTADTypeModel.self, from: jsonData)
//                            } catch {
//
//                            }
                        }
                    }
                }
                
            }
        }
    }

}
