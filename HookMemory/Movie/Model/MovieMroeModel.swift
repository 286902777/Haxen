//
//  MovieMroeModel.swift
//  HookMemory
//
//  Created by HF on 2023/11/14.
//

import Foundation

class MovieMroeModel: BaseModel {
    var title: String = ""
    var minfo: [MovieDataInfoModel] = []
    var total: Int = 0
    var desc: String = ""
    var browser: String = ""
}

class MovieSearchModel: BaseModel {
    var movie_tv_list: [MovieDataInfoModel] = []
}
