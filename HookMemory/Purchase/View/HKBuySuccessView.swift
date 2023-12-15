//
//  HKBuySuccessView.swift
//  HookMemory
//
//  Created by HF on 2023/12/13.
//

import UIKit

class HKBuySuccessView: UIView {

    @IBOutlet weak var bgImageV: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    class func viewWithTitle(_ text: String) -> HKBuySuccessView {
        let view = Bundle.main.loadNibNamed(String(describing: HKBuySuccessView.self), owner: nil)?.first as! HKBuySuccessView
        view.titleLabel.text = text
        view.bgImageV.image = IMG(HKConfig.share.isForUser ? "purchase_success" : "hpurchase_success")
        return view
    }
    
    @IBAction func closeAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    
}
