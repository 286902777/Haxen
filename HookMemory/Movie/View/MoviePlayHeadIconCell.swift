//
//  MoviePlayHeadIconCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/22.
//

import UIKit

class MoviePlayHeadIconCell: UICollectionViewCell {

    @IBOutlet weak var iconView: UIImageView!
    
    @IBOutlet weak var nameL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.iconView.layer.cornerRadius = 28
        self.iconView.layer.masksToBounds = true
    }

    func setModel(_ model: MovieVideoInfoDataModel.MovieCastsModel) {
        self.iconView.setImage(with: model.cover)
        self.nameL.text = model.title
    }
}
