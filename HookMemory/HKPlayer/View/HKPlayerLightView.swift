//
//  HKPlayerLightView.swift
//  HookMemory
//
//  Created by HF on 2023/11/25.
//

import UIKit

class HKPlayerLightView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var topViewWidth: NSLayoutConstraint!
    
    class func view() -> HKPlayerLightView {
        let view = Bundle.main.loadNibNamed(String(describing: HKPlayerLightView.self), owner: nil)?.first as! HKPlayerLightView
        view.frame = CGRect(x: 0, y: 0, width: 204, height: 40)
        return view
    }
    
}
