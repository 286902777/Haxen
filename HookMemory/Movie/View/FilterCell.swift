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
        
    }

    func setModel(_ model: MovieFiterModel) {
        self.titleL.text = model.name
        self.titleL.backgroundColor = .purple
    }
}
