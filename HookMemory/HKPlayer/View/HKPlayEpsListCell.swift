//
//  HKPlayEpsListCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/23.
//

import UIKit

class HKPlayEpsListCell: UITableViewCell {

    @IBOutlet weak var bView: UIView!
    @IBOutlet weak var epsL: UILabel!
    @IBOutlet weak var numL: UILabel!
    @IBOutlet weak var nameL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bView.layer.cornerRadius = 10
        self.bView.layer.masksToBounds = true
    }

    func setModel(_ model: MovieVideoInfoEpssModel) {
        let arr: [String] = model.title.components(separatedBy: ":")
        if let sub = arr.first {
            let subArr = sub.components(separatedBy: " ")
            self.epsL.text = subArr.first
            self.numL.text = subArr.last
            self.nameL.text = arr.last
        }
        if model.isSelect {
            self.bView.backgroundColor = UIColor.hex("#FF4131", alpha: 0.05)
            self.bView.layer.borderColor = UIColor.white.cgColor
            self.bView.layer.borderWidth = 1
        } else {
            self.bView.backgroundColor = UIColor.hex("#FFFFFF", alpha: 0.05)
            self.bView.layer.borderWidth = 0
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
