//
//  HKUserManager.swift
//  HookMemory
//
//  Created by HF on 2023/12/1.
//

import Foundation

class HKUserManager: NSObject {
    
    static let share = HKUserManager()
    
    var task: URLSessionDataTask?
    
    var isVip = UserDefaults.standard.bool(forKey: HKKeys.isVip) {
        didSet {
            UserDefaults.standard.set(isVip, forKey: HKKeys.isVip)
            NotificationCenter.default.post(name: Noti_VipChange, object: nil)
        }
    }
}
