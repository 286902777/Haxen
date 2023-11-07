//
//  HookNavigationBar.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit

class HookNavigationBar: UIView{
    
    @IBOutlet weak var leftL: UILabel! {
        didSet {
            leftL.font = UIFont.font(weigth: .semibold, size: 28)
        }
    }
    @IBOutlet weak var navLeft: NSLayoutConstraint!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var middleBtn: UIButton!
    
    @IBOutlet weak var rightBtn: UIButton!
    var NaviBarBlock: ((_ tag: Int)->())?
    
    class func view() -> HookNavigationBar {
        let view = Bundle.main.loadNibNamed(String(describing: HookNavigationBar.self), owner: nil)?.first as! HookNavigationBar
        view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kNavBarHeight)
        return view
    }

    
    @IBAction func BtnAction(_ sender: Any) {
        if let btn = sender as? UIButton {
            NaviBarBlock?(btn.tag)
        }
    }
    
    func setBackHidden(_ hidden: Bool = false) {
        self.backBtn.isHidden = hidden
        if hidden {
            navLeft.constant = 16
        } else {
            navLeft.constant = 6
        }
    }
}
