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
    
    var isVip = UserDefaults.standard.bool(forKey: User.isVip) {
        didSet {
            UserDefaults.standard.set(isVip, forKey: User.isVip)
            NotificationCenter.default.post(name: Noti_VipChange, object: nil)
        }
    }
}

class User {
    static let isVip = "isVip"
    static let expires_date_ms = "expires_date_ms"
    static let product_id = "product_id"
    static let auto_renew_status = "auto_renew_status"
}
