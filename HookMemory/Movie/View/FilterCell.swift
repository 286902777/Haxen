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
        self.titleL.layer.borderColor = UIColor.green.cgColor
    }

    func setModel(_ model: MovieFiterModel) {
        self.titleL.text = model.name
        if model.isSelect {
            self.titleL.layer.cornerRadius = 4
            self.titleL.layer.borderWidth = 1
            self.titleL.backgroundColor = .purple
        } else {
            self.titleL.layer.cornerRadius = 0
            self.titleL.layer.borderWidth = 0
            self.titleL.backgroundColor = .yellow
        }
    }
}
