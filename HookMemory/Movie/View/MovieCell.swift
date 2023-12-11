//
//  MovieCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/9.
//

import UIKit

class MovieCell: UICollectionViewCell {

    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var contentL: UILabel!
    
    @IBOutlet weak var progressV: UIProgressView!
    @IBOutlet weak var scoreL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        imageV.layer.cornerRadius = 8
        imageV.layer.masksToBounds = true
        scoreL.font = UIFont(name: "Fjalla One Regular", size: 20)
    }

    func setModel(model: MovieDataInfoModel, _ isHistory: Bool = false) {
        self.progressV.isHidden = !isHistory
        self.progressV.progress = Float(model.playProgress)
        self.scoreL.text = model.rate
        self.contentL.text = model.title
        self.imageV.setImage(with: model.cover)
    }
    /*
    private func setupScore(_ text: String) {

        let arr: Array = text.components(separatedBy: ".")
        
        var integer = ""
        var point = ""
        if arr.count == 1 {
            integer = arr.first ?? ""
        } else if arr.count > 0 {
            integer = arr.first ?? ""
            point = "." + (arr.last ?? "")
        } else {
            return
        }

        let integerAttr = NSMutableAttributedString(string: integer)
        integerAttr.addAttributes([.font: UIFont.systemFont(ofSize: 20)], range: NSRange(location: 0, length: integer.count))
        
        let pointAttr = NSMutableAttributedString(string: point)
        pointAttr.addAttributes([.font: UIFont.systemFont(ofSize: 12)], range: NSRange(location: 0, length: point.count))
        integerAttr.append(pointAttr)
        
        scoreL.attributedText = integerAttr
    }*/
}
