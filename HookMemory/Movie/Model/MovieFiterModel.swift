//
//  MovieFiterModel.swift
//  HookMemory
//
//  Created by HF on 2023/11/9.
//

import Foundation
import UIKit

class MovieFiterModel: BaseModel {
    var width: CGFloat {
        get {
            let label = UILabel()
            label.text = name
            label.sizeToFit()
            return label.frame.width + 20
        }
    }
    var name: String = ""
}
