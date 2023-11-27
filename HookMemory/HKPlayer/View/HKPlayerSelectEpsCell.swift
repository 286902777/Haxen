//
//  HKPlayerSelectEpsCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/22.
//

import UIKit

class HKPlayerSelectEpsCell: UICollectionViewCell {
    @IBOutlet weak var titleL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleL.layer.cornerRadius = 10
        self.titleL.layer.masksToBounds = true
    }

    func setModel(_ model: MovieVideoInfoEpssModel) {
        self.titleL.text = "\(model.eps_num)"
        if model.isSelect {
            self.titleL.backgroundColor = UIColor.hex("#FF4131", alpha: 0.05)
            self.titleL.layer.borderColor = UIColor.white.cgColor
            self.titleL.layer.borderWidth = 1
        } else {
            self.titleL.backgroundColor = UIColor.hex("#FFFFFF", alpha: 0.05)
            self.titleL.layer.borderWidth = 0
        }
    }
}
