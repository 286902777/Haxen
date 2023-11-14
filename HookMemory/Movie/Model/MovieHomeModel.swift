//
//  MovieHomeModel.swift
//  HookMemory
//
//  Created by HF on 2023/11/13.
//

import Foundation

class MovieHomeModel: BaseModel {
    var name: String = ""
    var data: [MovieHomeDataModel] = []
    var order: Int = 0
    var display_type: Int = 0
    var secname: String = ""
    var data_type: Int = 0
    var video_flag: Int = 0
}

class MovieHomeDataModel: BaseModel {
    var id: String = ""
    var name: String = ""
    var cover: String = ""
    var cover2: String = ""
    var cover3: String = ""
    var desc: String = ""
    var tag: String = ""
    var type: String = ""
    var comment: String = ""
    var fav: String = ""
    var share: String = ""
    var status: String = ""
    var creator_id: String = ""
    var create_time: String = ""
    var recognition: String = ""
    var browser: String = ""
    var dislikes: String = ""
    var country: String = ""
    var lang: String = ""
    var region: String = ""
    var total: Int = 0
    var m20: [MovieDataInfoModel] = []
}

class MovieDataInfoModel: BaseModel {
    var id: String = ""
    var rate: String = ""
    var title: String = ""
    var tags: String = ""
    var board: String = ""
    var board_id_1: String = ""
    var board_id_2: String = ""
    var cover: String = ""
    var m_type: String = ""
    var m_type_2: String = ""
    var quality: String = ""
    var order: String = ""
    var stars: String = ""
    var views: String = ""
    var pub_date: String = ""
    var gif: String = ""
    var description: String = ""
    var c_cnts: String = ""
    var medit: Int = 0
    var data_type: String = ""
    var eps_cnts: String = ""
    var ssn_id: String = ""
    var eps_list: [String] = []
    var country: String = ""
    var ss_eps: String = ""
    var new_flag: String = ""
    var nw_flag: String = ""
    var best: String = ""
    var sub: String = ""
    var dub: String = ""
    var ep: String = ""
    var age: String = ""
    var video_flag: String = ""
}

