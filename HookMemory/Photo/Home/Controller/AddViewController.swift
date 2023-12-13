//
//  AddViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/3.
//

import UIKit
import Photos
import IQKeyboardManagerSwift

class AddViewController: BaseViewController {
    let contentH = 132
    var margin: CGFloat = 0
    var duration: TimeInterval = 0
    var doneBlock: ((_ model: photoVideoModel)->())?
    var model: photoVideoModel = photoVideoModel()
    lazy var imageV: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 48
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let contentV: UIView = UIView()
    
    private lazy var doneBtn:UIButton = {
        let btn = UIButton()
        btn.setTitle("Done", for: .normal)
        btn.titleLabel?.font = UIFont.font(size: 14)
        btn.setTitleColor(UIColor.hex("#141414"), for: .normal)
        btn.addGradientLayer(colorO: UIColor.hex("#ECFFDE"), colorT: UIColor.hex("#4FDACF"), frame: CGRect.init(x: 0, y: 0, width: 64, height: 32))
        btn.layer.cornerRadius = 16
        btn.layer.masksToBounds = true
        btn.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        return btn
    }()
    let textView: IQTextView = IQTextView()
    let numL: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavbar()
        setepUI()
        setContentView()
        setImageData()
    }
    func setNavbar() {
        cusBar.backBtn.setImage(UIImage(named: "close"), for: .normal)
        cusBar.rightBtn.isHidden = true
        cusBar.addSubview(doneBtn)
        
        doneBtn.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalTo(cusBar.backBtn)
            make.size.equalTo(CGSize(width: 64, height: 32))
        }
        
        cusBar.NaviBarBlock = { [weak self] index in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setepUI() {
        let H = Int(kScreenHeight - kNavBarHeight - kBottomSafeAreaHeight) - 112 - contentH
        view.addSubview(imageV)
        imageV.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(48)
            make.right.equalToSuperview().offset(-48)
            make.top.equalTo(cusBar.snp.bottom).offset(32)
            make.height.equalTo(H)
        }
    }
    
    func setContentView() {
        view.addSubview(contentV)
        contentV.addGradientLayer(colorO: UIColor.hex("#B3FFED"), colorT: UIColor.hex("#FFFFFF"), frame: CGRect(x: 0, y: 0, width: kScreenWidth - 96, height: 132), top: true)
        contentV.layer.cornerRadius = 14
        contentV.layer.masksToBounds = true
        
        contentV.addSubview(textView)
        contentV.addSubview(numL)
        
        textView.textColor = UIColor.hex("#141414")
        textView.font = UIFont.font(size: 14)
        textView.backgroundColor = .clear
        textView.delegate = self
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        textView.placeholder = "Add Journal"
        textView.placeholderTextColor = UIColor.hex("#141414", alpha: 0.7)
        
        numL.textColor = UIColor.hex("#141414", alpha: 0.7)
        numL.font = UIFont.font(size: 10)
        contentV.snp.makeConstraints { make in
            make.top.equalTo(self.imageV.snp.bottom).offset(32)
            make.left.equalTo(48)
            make.right.equalTo(-48)
            make.height.equalTo(132)
        }
        
        numL.snp.makeConstraints { make in
            make.height.equalTo(14)
            make.right.bottom.equalToSuperview().offset(-8)
        }
        
        textView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(numL.snp.top)
        }

        self.textView.text = ""
        self.numL.text = "\(self.textView.text.count)/1000"
    }
    
    func setImageData() {
        self.model.image.getPhotoImage(complete: { [weak self] image in
            guard let self = self else { return }
             self.imageV.image = image
        })
    }
    @objc func doneAction() {
        HKConfig.showInterAD(type: .play, placement: .play) { [weak self] _ in
            guard let self = self else { return }
            self.model.content = self.textView.text
            self.doneBlock?(self.model)
            self.navigationController?.popViewController(animated: true)

        }
    }
}

extension AddViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.markedTextRange == nil {
            if textView.text.count >= 1000 {
                self.textView.text = textView.text.substring(to: 1000)
            }
        }
        self.numL.text = "\(textView.text.count)/1000"
    }
}
