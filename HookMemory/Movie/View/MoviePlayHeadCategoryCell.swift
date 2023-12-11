//
//  MoviePlayHeadCategoryCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/22.
//

import UIKit

class MoviePlayHeadCategoryCell: UICollectionViewCell {

    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
    }
    
    func setHistoryModel(_ model: MovieHistoryModel) {
        self.layer.cornerRadius = 8
        self.nameL.font = .font(size: 14)
        nameL.text = model.text
    }
}
