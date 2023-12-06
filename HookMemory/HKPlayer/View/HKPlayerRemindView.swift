//
//  HKPlayerRemindView.swift
//  HookMemory
//
//  Created by HF on 2023/11/20.
//

import UIKit

class HKPlayerRemindView: UIView {

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var remindButton: UIButton!
    
    var clickBlock: (()->())?
    class func view() -> HKPlayerRemindView {
        let view = Bundle.main.loadNibNamed(String(describing: HKPlayerRemindView.self), owner: nil)?.first as! HKPlayerRemindView
        view.frame = CGRect(x: 0, y: 0, width: 280, height: 120)
        view.remindButton.layer.cornerRadius = 12
        view.remindButton.layer.masksToBounds = true
        return view
    }
    
    @IBAction func remindAction(_ sender: UIButton) {
        self.clickBlock?()
    }
    
}
