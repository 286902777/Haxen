//
//  LoadingViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/15.
//

import UIKit

class LoadingViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        HKConfig.share.appRequest()
        NotificationCenter.default.addObserver(self, selector: #selector(netWorkChange), name: Notification.Name("netStatus"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func netWorkChange() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            switch appDelegate.netStatus {
            case .reachable(_):
                HKConfig.share.appRequest()
            default:
                break
            }
        }
    }
}
