//
//  HKSheetCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/3.
//

import UIKit

class HKSheetCell: UITableViewCell {

    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var titleL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setData(data: [String: String]) {
        imageV.image = UIImage(named: data["image"] ?? "")
        titleL.text = data["name"]
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
