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
    
    var isChoose = false {
        didSet {
            if isChoose {
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
    
}
