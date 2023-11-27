//
//  UIView+Extension.swift
//  HookMemory
//
//  Created by HF on 2023/11/24.
//

import UIKit

extension UIView {
    func effectView(_ size: CGSize) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame.size = size
        blurView.layer.masksToBounds = true
        self.addSubview(blurView)
        self.sendSubviewToBack(blurView)
    }
}
