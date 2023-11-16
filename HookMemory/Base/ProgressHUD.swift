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
    
    static func dismiss() {
        SVProgressHUD.dismiss()
    }
}
