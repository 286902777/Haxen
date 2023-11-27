//
//  HKPlayerLanguageCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/24.
//

import UIKit

class HKPlayerLanguageCell: UITableViewCell {

    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var nameL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.bgView.layer.cornerRadius = 10
        self.bgView.layer.masksToBounds = true
    }

    func setModel(_ model: MovieCaption) {
        self.nameL.text = model.name
        if model.isSelect {
            self.bgView.backgroundColor = UIColor.hex("#FF4131", alpha: 0.05)
            self.bgView.layer.borderColor = UIColor.white.cgColor
            self.bgView.layer.borderWidth = 1
        } else {
            self.bgView.backgroundColor = UIColor.hex("#FFFFFF", alpha: 0.05)
            self.bgView.layer.borderWidth = 0
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
