//
//  AboutUsViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit

class AboutUsViewController: BaseViewController {

    @IBOutlet weak var top: NSLayoutConstraint!
    
    @IBOutlet weak var nameL: UILabel!
    
    @IBOutlet weak var versionL: UILabel!
    
    var titleName: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.top.constant = kNavBarHeight + 88
        self.cusBar.titleL.text = titleName
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            nameL.text = appName
        }
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionL.text = "v\(version)"
        }
    }
}
