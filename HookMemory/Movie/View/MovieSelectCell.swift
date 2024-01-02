//
//  MovieSelectCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/9.
//

import UIKit

class MovieSelectCell: UICollectionViewCell {
    @IBOutlet weak var epsL: UILabel!
    
    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var contentL: UILabel!
    
    @IBOutlet weak var progressV: UIProgressView!
    @IBOutlet weak var scoreL: UILabel!

    @IBOutlet weak var selectBtn: UIButton!
    typealias clickBlock = () -> Void
    var clickHandle : clickBlock?
    typealias clickSelectBlock = () -> Void
    var clickSelectHandle : clickSelectBlock?

    override func awakeFromNib() {
        super.awakeFromNib()
        imageV.layer.borderColor = UIColor.white.cgColor
        imageV.layer.cornerRadius = 8
        imageV.layer.masksToBounds = true
        selectBtn.addCorner(conrners: [.topLeft, .bottomRight], radius: 8)
        scoreL.font = UIFont(name: "Fjalla One Regular", size: 20)
    }

    func setModel(isSelect: Bool, model: MovieDataInfoModel, _ clickBlock: clickBlock?, _ clickSelectBlock: clickSelectBlock?) {
        self.epsL.isHidden = model.isMovie
        self.epsL.text = model.ssn_eps
        self.selectBtn.isHidden = !isSelect
        self.clickHandle = clickBlock
        self.clickSelectHandle = clickSelectBlock
        self.progressV.progress = Float(model.playProgress)
        self.scoreL.text = String(format: "%.1f", Float(model.rate) ?? 0)
        self.contentL.text = model.title
        self.selectBtn.isSelected = model.isSelect
        self.imageV.setImage(with: model.cover)
        self.imageV.layer.borderWidth = model.isSelect ? 2 : 0
    }
    
    @IBAction func clickAction(_ sender: Any) {
        self.clickHandle?()
    }
    
    @IBAction func clickSelectAction(_ sender: Any) {
        self.selectBtn.isSelected = !self.selectBtn.isSelected
        self.imageV.layer.borderWidth = self.selectBtn.isSelected ? 2 : 0
        self.clickSelectHandle?()
    }
    
}
