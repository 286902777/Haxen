//
//  BaseViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit
import SnapKit
import AppTrackingTransparency

class BaseViewController: UIViewController {

    lazy var cusBar: HookNavigationBar = {
        let view = HookNavigationBar.view()
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hex("#141414")
        addBackImage()
        addNavBar()
        hidesBottomBarWhenPushed = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appTrackingAuth()
    }
    func addBackImage() {
        let imageV = UIImageView()
        view.addSubview(imageV)
        imageV.image = UIImage.init(named: "backgroudImage")
        imageV.contentMode = .scaleToFill
        imageV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func addNavBar() {
        self.navigationController?.navigationBar.isHidden = true
        view.addSubview(self.cusBar)
        cusBar.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(kNavBarHeight)
        }
        cusBar.NaviBarBlock = { [weak self] tag in
            print(tag)
            guard let self = self else { return }
            switch tag {
            case 0:
                self.backAction()
            case 1:
                self.rightAction()
            default:
                self.middleAction()
            }
        }
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func rightAction() {
        
    }
    
    func middleAction() {
        
    }
    func appTrackingAuth() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                
            }
        }
    }
}

