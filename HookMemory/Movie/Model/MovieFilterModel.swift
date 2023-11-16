//
//  MovieFilterModel.swift
//  HookMemory
//
//  Created by HF on 2023/11/9.
//

import Foundation
import UIKit

class MovieFilterModel: BaseModel {
    var data_type: String = ""
    var minfo: [MovieDataInfoModel] = []
    var total: Int = 0
    var gener_title: String = ""
    var filter: MovieFilterCategoryModel = MovieFilterCategoryModel()
}

class MovieFilterCategoryModel: BaseModel {
    var orderby:[MovieFilterCategoryInfoModel] = []
    var genre:[MovieFilterCategoryInfoModel] = []
    var pub:[MovieFilterCategoryInfoModel] = []
    var type:[MovieFilterCategoryInfoModel] = []
    var country:[MovieFilterCategoryInfoModel] = []
}

class MovieFilterCategoryInfoModel: BaseModel {
    var title: String = ""
    var id: String = ""
    var width: CGFloat {
        get {
            return title.getStrW(strFont: .systemFont(ofSize: 17), h: 20)
        }
    }
    var isSelect: Bool = false
}
