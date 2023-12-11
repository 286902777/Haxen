//
//  MovieAlertController.swift
//  HookMemory
//
//  Created by HF on 2023/12/11.
//

import UIKit

class MovieAlertController: UIViewController {
    @IBOutlet weak var alertView: UIView!
    
    @IBOutlet weak var titleL: UILabel!
    
    @IBOutlet weak var contentL: UILabel!
    
    
    @IBAction func clickCancelAction(_ sender: Any) {
        self.dismissAnimate()
    }
    @IBAction func clickSureAction(_ sender: Any) {
        self.clickBlock?()
        self.dismissAnimate()
    }
    
    var clickBlock:(() -> Void)?
    
    private var titleStr: String?
    private var contentStr: String?
    init(_ title: String?, _ content: String?) {
        super.init(nibName: nil, bundle:nil)
        self.modalPresentationStyle = .overFullScreen
        self.titleStr = title
        self.contentStr = content
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.alertView.transform = CGAffineTransform.identity
        }
    }
    private func showAnimate() {
        view.backgroundColor = UIColor.hex("#141414",alpha: 0.5)
        alertView.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    private func dismissAnimate() {
        self.view.backgroundColor = .clear
        self.dismiss(animated: false, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        showView()
    }
    
    private func showView() {
        self.titleL.text = self.titleStr
        self.contentL.text = self.contentStr
    }
}
