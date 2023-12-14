//
//  WebViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/13.
//

import UIKit
import WebKit

class WebViewController: MovieBaseViewController {

    var titleName: String = ""
    var url: String = ""
    private lazy var webView: WKWebView = {
        let view = WKWebView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    func setUI() {
        self.cusBar.titleL.text = titleName
        view.addSubview(webView)
        webView.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(cusBar.snp.bottom)
        }
        if let u = URL(string: self.url) {
            webView.load(URLRequest(url: u))
        }
    }
}
