//
//  HKPlayerSelectSsnCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/22.
//

import UIKit

class HKPlayerSelectSsnCell: UICollectionViewCell {

    @IBOutlet weak var selectView: UIView!
    @IBOutlet weak var nameL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setModel(_ model: MovieVideoInfoSsnlistModel) {
        self.selectView.isHidden = !model.isSelect
        self.nameL.text = model.title
        if model.isSelect {
            self.nameL.font = .font(weigth: .medium, size: 18)
            self.nameL.textColor = .white
        } else {
            self.nameL.font = .font(size: 14)
            self.nameL.textColor = UIColor.hex("#FFFFFF", alpha: 0.5)
        }
    }
}
