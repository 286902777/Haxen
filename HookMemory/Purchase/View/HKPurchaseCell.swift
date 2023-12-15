//
//  HKPurchaseCell.swift
//  HookMemory
//
//  Created by HF on 2023/12/13.
//

import UIKit

class HKPurchaseCell: UITableViewCell {

    @IBOutlet weak var backView: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var tipLabel: UILabel! {
        didSet {
            tipLabel.addCorner(conrners: [.topLeft, .topRight, .bottomLeft], radius: 4)
        }
    }
    
    var isSelelct = false {
        didSet {
            if isSelelct {
                backView.layer.borderWidth = 2
                if HKConfig.share.isForUser {
                    backView.layer.borderColor = UIColor.hex("#FF4131").cgColor
                    backView.backgroundColor = UIColor.hex("#FF4131", alpha: 0.1)
                    tipLabel.backgroundColor = UIColor.hex("#FF4131")
                } else {
                    backView.layer.borderColor = UIColor.hex("#4AD8D1").cgColor
                    tipLabel.backgroundColor = UIColor.hex("#4AD8D1")
                }
            } else {
                backView.layer.borderWidth = 2
                backView.layer.borderColor = UIColor.hex("#FFFFFF", alpha: 0.2).cgColor
                backView.backgroundColor = UIColor.hex("#393939", alpha: 0.75)
                tipLabel.backgroundColor = UIColor.hex("#747474")
            }
        }
    }
    
    func setModel(_ model: HKUserData) {
        self.titleLabel.text = model.title
        self.costLabel.text = model.price
        self.tipLabel.isHidden = model.tag.count == 0
        self.tipLabel.text = model.tag
        if model.isLine {
            let worldAttrStr: NSMutableAttributedString = NSMutableAttributedString(string: model.subTitle)
            worldAttrStr.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: model.subTitle.count))
            self.infoLabel.attributedText = worldAttrStr
        } else {
            self.infoLabel.text = model.subTitle
        }
    }
}
