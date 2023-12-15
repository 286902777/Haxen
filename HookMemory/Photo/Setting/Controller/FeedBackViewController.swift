//
//  FeedBackViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit
import IQKeyboardManagerSwift

class FeedBackViewController: MovieBaseViewController {
    var titleName: String = ""
    var isMovie: Bool = false
    private var corner: CGFloat {
        get {
            return isMovie ? 16 : 22
        }
    }
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var feedBackL: UILabel!
    @IBOutlet weak var contentV: IQTextView!
    @IBOutlet weak var emailV: IQTextView!
    private lazy var doneBtn:UIButton = {
        let btn = UIButton()
        btn.setTitle("Done", for: .normal)
        btn.titleLabel?.font = UIFont.font(size: 14)
        if isMovie {
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.backgroundColor = UIColor.hex("#FF4131")
            btn.layer.cornerRadius = 8
        } else {
            btn.setTitleColor(UIColor.hex("#141414"), for: .normal)
            btn.addGradientLayer(colorO: UIColor.hex("#ECFFDE"), colorT: UIColor.hex("#4FDACF"), frame: CGRect.init(x: 0, y: 0, width: 64, height: 32))
            btn.layer.cornerRadius = 16
        }
        
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        return btn
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cusBar.rightBtn.isHidden = true
        self.cusBar.titleL.text = titleName
        
        self.cusBar.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(cusBar.backBtn)
            make.size.equalTo(CGSize(width: 64, height: 32))
        }
        top.constant = kNavBarHeight + 20
        contentV.layer.cornerRadius = corner
        contentV.layer.masksToBounds = true
        contentV.textContainerInset = UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16)
        emailV.layer.cornerRadius = corner
        emailV.layer.masksToBounds = true
        emailV.textContainerInset = UIEdgeInsets.init(top: 16, left: 16, bottom: 16, right: 16)
        contentV.placeholder = "Please input"
        emailV.placeholder = "Please input"
        if self.isMovie {
            contentV.backgroundColor = UIColor.hex("#FFFFFF", alpha: 0.15)
            contentV.textColor = UIColor.white
            contentV.placeholderTextColor = UIColor.hex("#FFFFFF", alpha: 0.75)
            emailV.backgroundColor = UIColor.hex("#FFFFFF", alpha: 0.15)
            emailV.textColor = UIColor.white
            emailV.placeholderTextColor = UIColor.hex("#FFFFFF", alpha: 0.75)
        } else {
            contentV.textColor = UIColor.hex("#141414")
            contentV.placeholderTextColor = UIColor.hex("#141414", alpha: 0.75)
            emailV.textColor = UIColor.hex("#141414")
            emailV.placeholderTextColor = UIColor.hex("#141414", alpha: 0.75)
            contentV.addGradientLayer(colorO: UIColor.hex("#D8FFF6"), colorT: UIColor.hex("#FFFFFF"), frame: CGRect(x: 0, y: 0, width: kScreenWidth - 32, height: 100), top: true)
            emailV.addGradientLayer(colorO: UIColor.hex("#D8FFF6"), colorT: UIColor.hex("#FFFFFF"), frame: CGRect(x: 0, y: 0, width: kScreenWidth - 32, height: 100), top: true)
        }
    }

    @objc func doneAction() {
        if contentV.text.count > 0, emailV.text.count > 0 {
            toast("Feedback successful")
            self.navigationController?.popViewController(animated: true)
        } else {
            toast("Please enter your feedback or email")
        }
    }
}
