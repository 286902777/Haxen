//
//  HKPlayerCaptionSetView.swift
//  HookMemory
//
//  Created by HF on 2023/11/24.
//

import UIKit

class HKPlayerCaptionSetView: UIViewController {
    private var dataArr: [MovieCaption] = []
    var clickBlock: ((_ id: String)->())?

    @IBOutlet weak var btn: UIButton!
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var subtitleView: UIView!
    
    @IBOutlet weak var languageView: UIView!
    
    /// 初始化方法
    /// - Parameters:

    init(list:[MovieCaption], isCancel: Bool = false) {
        super.init(nibName: nil, bundle:nil)
        self.dataArr = list
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBAction func clickAction(_ sender: Any) {
        self.btn.isSelected = !self.btn.isSelected
        HKPlayerManager.share.subtitleOn = self.btn.isSelected
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.bgView.transform = CGAffineTransform.identity
        }
    }
    private func showAnimate() {
        view.backgroundColor = UIColor.hex("#141414",alpha: 0.5)
        bgView.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    @objc func dismissAnimate() {
        self.view.backgroundColor = .clear
        self.dismiss(animated: false, completion: nil)
    }
    private func commentInit() {
        bgView.backgroundColor = UIColor.hex("#FFFFFF", alpha: 0.05)
        bgView.effectView(CGSize(width: kScreenWidth, height: 254))
        bgView.addCorner(conrners: [.topLeft, .topRight], radius: 24)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissAnimate))
        view.addGestureRecognizer(tap)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        commentInit()
        self.btn.isSelected = HKPlayerManager.share.subtitleOn
    }
    
    @IBAction func clickBtnAction(_ sender: Any) {
        let vc = HKPlayerLanguageView()
        vc.dataArr = self.dataArr
        vc.clickBlock = { [weak self] id in
            self?.clickBlock?(id)
        }
        vc.backBlock = { [weak self] in
            self?.dismissAnimate()
        }
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: false)
    }
}

