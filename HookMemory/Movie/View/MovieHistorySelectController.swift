//
//  MovieHistorySelectController.swift
//  HookMemory
//
//  Created by HF on 2023/12/11.
//

import UIKit

class MovieHistorySelectController: UIViewController {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var infoV: UIView!
    
    @IBOutlet weak var deleteV: UIView!
    @IBAction func clickCloseAction(_ sender: Any) {
        self.dismissAnimate()
    }
    
    var clickBlock:((_ index: Int) -> Void)?
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
    
    private func dismissAnimate() {
        self.view.backgroundColor = .clear
        self.dismiss(animated: false, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.bgView.frame = CGRectMake(0, kScreenHeight - 200 - kBottomSafeAreaHeight, kScreenWidth, 200 + kBottomSafeAreaHeight)
        self.view.setNeedsLayout()
        let infoTap = UITapGestureRecognizer(target: self, action: #selector(clickInfoAction))
        self.infoV.addGestureRecognizer(infoTap)
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(clickDeleteAction))
        self.deleteV.addGestureRecognizer(deleteTap)
        bgView.backgroundColor = UIColor.hex("#FFFFFF", alpha: 0.15)
        bgView.effectView(CGSize(width: kScreenWidth, height: 200 + kBottomSafeAreaHeight))
        bgView.addCorner(conrners: [.topLeft, .topRight], radius: 24)
        bgView.layer.masksToBounds = true
        showAnimate()
    }
    
    @objc func clickInfoAction() {
        self.clickBlock?(0)
        self.dismissAnimate()
    }
    
    @objc func clickDeleteAction() {
        self.clickBlock?(1)
        self.dismissAnimate()
    }
    
}
