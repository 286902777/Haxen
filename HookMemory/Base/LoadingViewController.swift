//
//  LoadingViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/15.
//

import UIKit

class LoadingViewController: UIViewController {
    @IBOutlet weak var progressView: UIProgressView!
    
    var timer: DispatchSourceTimer?

    var isRequest: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        timer?.setEventHandler(handler: { [weak self] in
            self?.setProgress()
        })
        timer?.schedule(deadline: .now(), repeating: 1)
        timer?.resume()
        
        HKADManager.share.openLoadingSuccessComplete = { [weak self] in
            HKADManager.share.openLoadingSuccessComplete = nil
            self?.endLoading(gotoHome: false)
            HKADManager.share.openLoadingSuccessComplete = nil
        }
        HKADManager.share.tempDismissComplete = {
            HKConfig.share.appRequest()
            HKADManager.share.tempDismissComplete = nil
        }
        NotificationCenter.default.addObserver(self, selector: #selector(netWorkChange), name: Notification.Name("netStatus"), object: nil)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.cancel()
    }
    
    deinit {
        self.timer?.cancel()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func netWorkChange() {
        if isRequest == false {
            return
        }
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            switch appDelegate.netStatus {
            case .reachable(_):
                HKConfig.share.appRequest()
            default:
                break
            }
        }
    }
    func setProgress() {
        let v: Float = 0.1
        self.progressView.progress += v
        if self.progressView.progress == 1 {
            self.endLoading()
            self.isRequest = true
        }
    }
    
    func endLoading(gotoHome: Bool = true) {
        DispatchQueue.main.async {
            self.timer?.cancel()
            UIView.animate(withDuration: 0.25) {
                self.progressView.progress = 1
            } completion: { _ in
                if gotoHome {
                    HKConfig.share.appRequest()
                } else {
                    self.showAdmob()
                }
            }
        }
    }
    func showAdmob() {
        HKConfig.showInterAD(type: .open, placement: .open) { success in
            if success == false {
                HKConfig.share.appRequest()
            }
        }
        
    }
}
