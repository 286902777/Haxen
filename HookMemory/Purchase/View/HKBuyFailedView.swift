//
//  HKBuyFailedView.swift
//  HookMemory
//
//  Created by HF on 2023/12/13.
//

import UIKit

class HKBuyFailedView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    class func viewWithTitle(_ text: String) -> HKBuyFailedView {
        let view = Bundle.main.loadNibNamed(String(describing: HKBuyFailedView.self), owner: nil)?.first as! HKBuyFailedView
        view.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        view.titleLabel.text = text
        view.dismissView()
        return view
    }

    func dismissView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.removeFromSuperview()
        }
    }
}
