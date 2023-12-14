//
//  SearchView.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import UIKit

class SearchView: UIView {
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var titleL: UILabel!
    
    @IBOutlet weak var rightV: UIImageView!
    
    @IBOutlet weak var vipBtn: UIButton!
    
    var clickBlock: (() -> Void)?
    
    class func view(_ isVip: Bool = false) -> SearchView {
        let view = Bundle.main.loadNibNamed(String(describing: SearchView.self), owner: nil)?.first as! SearchView
        view.backgroundColor = .clear
        view.vipBtn.isHidden = !isVip
        view.bgView.layer.cornerRadius = 8
        view.bgView.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kNavBarHeight)
        return view
    }
    @IBAction func clickVipAction(_ sender: Any) {
        self.clickBlock?()
    }
}
