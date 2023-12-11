//
//  MovieHistoryBottomView.swift
//  HookMemory
//
//  Created by HF on 2023/12/11.
//

import UIKit

class MovieHistoryBottomView: UIView {
    
    @IBOutlet weak var selectBtn: UIButton!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    var clickBlock:((_ index: Int) -> Void)?
    var clickSelectBlock:((_ select: Bool) -> Void)?

    class func view() -> MovieHistoryBottomView {
        let view = Bundle.main.loadNibNamed(String(describing: MovieHistoryBottomView.self), owner: nil)?.first as! MovieHistoryBottomView
        view.cancelBtn.layer.cornerRadius = 10
        view.cancelBtn.layer.borderWidth = 2
        view.cancelBtn.layer.borderColor = UIColor.white.cgColor
        view.cancelBtn.layer.masksToBounds = true
        view.deleteBtn.layer.cornerRadius = 10
        view.deleteBtn.layer.masksToBounds = true
        view.backgroundColor = UIColor.hex("#141414", alpha: 0.1)
        return view
    }
    
    override func layoutSubviews() {
        self.effectView(CGSize(width: kScreenWidth, height: 98 + kBottomSafeAreaHeight))
    }
    
    @IBAction func clickAction(_ sender: Any) {
        if let btn = sender as? UIButton {
            if btn.tag == 0 {
                self.selectBtn.isSelected = !self.selectBtn.isSelected
                self.clickSelectBlock?(self.selectBtn.isSelected)
            } else {
                self.clickBlock?(btn.tag)
            }
        }
    }
    
    func show() {
        self.selectBtn.isSelected = false
        
    }
}
