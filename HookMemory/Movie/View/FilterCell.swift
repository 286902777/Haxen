//
//  FilterCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/9.
//

import UIKit

class FilterCell: UICollectionViewCell {

    @IBOutlet weak var titleL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.titleL.layer.masksToBounds = true
        self.titleL.layer.borderColor = UIColor.white.cgColor
    }

    func setModel(_ model: MovieFilterCategoryInfoModel) {
        self.titleL.text = model.title
        if model.isSelect {
            self.titleL.layer.cornerRadius = 10
            self.titleL.layer.borderWidth = 1
            self.titleL.backgroundColor = UIColor.hex("#FF4131", alpha: 0.05)
        } else {
            self.titleL.layer.cornerRadius = 0
            self.titleL.layer.borderWidth = 0
            self.titleL.backgroundColor = .clear
        }
    }
}
