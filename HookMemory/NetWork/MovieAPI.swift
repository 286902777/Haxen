//
//  MovieAPI.swift
//  HookMemory
//
//  Created by HF on 2023/11/13.
//

import Foundation
enum MovieNetAPI: String {
    /// 首页
    case movieHomeApi = "api/home/"
    /// 更多
    case movieMoreListApi = "api/mlist_detail/"
    /// 搜索
    case movieSearchApi = "api/search_video/"
    /// filter
    case movieFilterApi = "api/video/"
}

class MovieAPI {
    static let share = MovieAPI()
    let pageSize: Int = 30

    var para: [String: String] = ["app_id": "1",
                                "lang": "en",
                                "device": "android",
                                "os_ver": "11.1.1",
                                "app_ver": "1.0.0",
                                "resolution": "200*150",
                                "deviceNo": "D5C27BB2-3272-4CA9-869F-771A5DA1DABB",
                                "token": "1"]

    func movieHomeList(_ completion: @escaping (_ success: Bool, _ list: [MovieHomeModel?]?) -> ()) {
        NetManager.request(url: MovieNetAPI.movieHomeApi.rawValue, method: .post, parameters: para, modelType: MovieHomeModel.self) { responseModel in
            if let list = responseModel.models as [MovieHomeModel?]? {
                completion(responseModel.status == .success, list)
            }
        }
    }
    
    func movieMoreList(id: String, page: Int = 1, _ completion: @escaping (_ success: Bool, _ model: MovieMroeModel) -> ()) {
        para["id"] = id
        para["page"] = "\(page)"
        para["page_size"] = "\(self.pageSize)"

        NetManager.request(url: MovieNetAPI.movieMoreListApi.rawValue, method: .post, parameters: para, modelType: MovieMroeModel.self) { responseModel in
            if let mod = responseModel.model {
                completion(responseModel.status == .success, mod)
            }
        }
    }
    
    func movieSearch(keyword: String, page: Int = 1, _ completion: @escaping (_ success: Bool, _ model: MovieSearchModel) -> ()) {
        para["keyword"] = keyword
        para["v_type"] = "\(0)"
        para["page"] = "\(page)"
        para["page_size"] = "\(self.pageSize)"

        NetManager.request(url: MovieNetAPI.movieSearchApi.rawValue, method: .post, parameters: para, modelType: MovieSearchModel.self) { responseModel in
            if let mod = responseModel.model {
                completion(responseModel.status == .success, mod)
            }
        }
    }
    
    func movieFilterInfo(cntyno: String = "100", genre: String = "100", orderby: String = "1", pubdate: String = "100", type: String = "1", page: Int = 1, _ completion: @escaping (_ success: Bool, _ model: MovieFilterModel) -> ()) {
        para["cntyno"] = cntyno
        para["genre"] = genre
        para["orderby"] = orderby
        para["pubdate"] = pubdate
        para["type"] = type
        para["page"] = "\(page)"
        para["page_size"] = "\(self.pageSize)"
        NetManager.request(url: MovieNetAPI.movieFilterApi.rawValue, method: .post, parameters: para, modelType: MovieFilterModel.self) { responseModel in
            if let mod = responseModel.model {
                completion(responseModel.status == .success, mod)
            }
        }
    }
}
//&page=%d&page_size=%d&v_type=0&keyword=%@
