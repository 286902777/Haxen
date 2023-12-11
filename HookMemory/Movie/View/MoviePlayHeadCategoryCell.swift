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
        if model.type == .text {
            nameL.text = model.text
            nameL.isHidden = false
            imgV.isHidden = true
        } else {
            imgV.isHidden = false
            nameL.isHidden = true
            imgV.image = IMG(model.type == .show ? "play_more_down" : "play_more_right")
        }
    }
}
