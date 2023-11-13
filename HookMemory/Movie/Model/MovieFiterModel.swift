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
            return name.getStrW(strFont: .systemFont(ofSize: 17), h: 20) + 20
        }
    }
    var isSelect: Bool = false
    var name: String = ""
}
