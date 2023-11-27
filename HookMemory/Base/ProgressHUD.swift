//
//  ProgressHud.swift
//  HookMemory
//
//  Created by HF on 2023/11/15.
//

import Foundation
import SVProgressHUD

class ProgressHUD {
    static func showLoading() {
        SVProgressHUD.show(withStatus: "loading")
    }
    
    static func showSuccess(_ text: String) {
        SVProgressHUD.showSuccess(withStatus: text)
    }
    
    static func showError(_ text: String) {
        SVProgressHUD.showError(withStatus: text)
    }
    
    static func dismiss() {
        SVProgressHUD.dismiss()
    }
}
