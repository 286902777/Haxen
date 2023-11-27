//
//  HKPlayerCaptionFullSetView.swift
//  HookMemory
//
//  Created by HF on 2023/11/25.
//

import UIKit

class HKPlayerCaptionFullSetView: UIView {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var switchBtn: UIButton!
    
    @IBOutlet weak var languageBtn: UIButton!
    
    @IBAction func clickAction(_ sender: Any) {
        if let btn = sender as? UIButton, btn.tag == 0 {
            btn.isSelected = !btn.isSelected
            HKPlayerManager.share.subtitleOn = btn.isSelected
        } else {
            let langView = HKPlayerLanguageFullView.view()
            self.superV?.addSubview(langView)
            langView.snp.makeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.right.equalTo(-48)
            }
            langView.setModel(self.dataArr)
            langView.clickBlock = { [weak self] id in
                self?.clickBlock?(id)
            }
        }
    }
    var clickBlock: ((_ id: String)->())?
    private var superV: UIView?
    private var dataArr: [MovieCaption] = []
    class func view() -> HKPlayerCaptionFullSetView {
        let view = Bundle.main.loadNibNamed(String(describing: HKPlayerCaptionFullSetView.self), owner: nil)?.first as! HKPlayerCaptionFullSetView
        view.switchBtn.isSelected = HKPlayerManager.share.subtitleOn
        view.bgView.backgroundColor = UIColor.hex("#FFFFFF", alpha: 0.05)
        view.bgView.effectView(CGSize(width: 308, height: kScreenWidth))
        return view
    }
    
    func setModel(_ list: [MovieCaption], view: UIView) {
        self.dataArr = list
        self.superV = view
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        self.addGestureRecognizer(tap)
    }
    
    @objc func dismissView() {
        self.removeFromSuperview()
    }
}
