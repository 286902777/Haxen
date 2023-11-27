//
//  MoviePlayHeadCategoryCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/22.
//

import UIKit

class MoviePlayHeadCategoryCell: UICollectionViewCell {

    @IBOutlet weak var nameL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
    }
}
