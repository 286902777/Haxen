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
    /// tvSeason
    case movieTvSeasonApi = "api/video_season/"
    /// tvssn
    case movieTvSSNApi = "api/video_ssn/"
    /// movie,tvInfo
    case movieInfoApi = "api/video_detail/"
    /// redmin
    case movieRedminApi = "need_created_media/upsert"
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
                if responseModel.status == .success {
                    HKLog.hk_home_sh(loadsuccess: "1", errorinfo: "")
                } else {
                    HKLog.hk_home_sh(loadsuccess: "4", errorinfo: responseModel.errorMessage)
                }
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
    
    func movieSearch(keyword: String, from: MovieSearchViewController.searchFrom, page: Int = 1, _ completion: @escaping (_ success: Bool, _ model: MovieSearchModel) -> ()) {
        para["keyword"] = keyword
        para["v_type"] = "\(0)"
        para["page"] = "\(page)"
        para["page_size"] = "\(self.pageSize)"

        NetManager.request(url: MovieNetAPI.movieSearchApi.rawValue, method: .post, parameters: para, modelType: MovieSearchModel.self) { responseModel in
            if let mod = responseModel.model {
                if responseModel.status == .success {
                    HKLog.hk_search_result_sh(keyword: keyword, errorinf: "", source: "\(from.rawValue)")
                } else {
                    HKLog.hk_search_result_sh(keyword: keyword, errorinf: responseModel.errorMessage, source: "\(from.rawValue)")
                }
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
        ProgressHUD.showLoading()
        NetManager.request(url: MovieNetAPI.movieFilterApi.rawValue, method: .post, parameters: para, modelType: MovieFilterModel.self) { responseModel in
            if let mod = responseModel.model {
                if responseModel.status == .success {
                    HKLog.hk_explore_sh(loadsuccess: "1", errorinfo: "")
                } else {
                    HKLog.hk_explore_sh(loadsuccess: "4", errorinfo: responseModel.errorMessage)
                }
                completion(responseModel.status == .success, mod)
            }
        }
    }
    //MARK: - Movie,TV data Info
    func movieInfo(ssn_id: String = "", eps_id: String = "", id: String, _ completion: @escaping (_ success: Bool, _ model: MovieVideoInfoModel?) -> ()) {
        para["ssn_id"] = ssn_id
        para["eps_id"] = eps_id
        para["id"] = id
        var url = String(format: "app_id=100&device_os=android&lang=en&device=android&app_ver=1.0.0&os_ver=11.1.1&resolution=800*600&deviceNo=D5C27BB2-3272-4CA9-869F-771A5DA1DABB&page=1&page_size=20&token=1&id=%@", id)
        if ssn_id.count > 0, eps_id.count > 0 {
            url = String(format: "app_id=100&device_os=android&lang=en&device=android&app_ver=1.0.0&os_ver=11.1.1&resolution=800*600&deviceNo=D5C27BB2-3272-4CA9-869F-771A5DA1DABB&page=1&page_size=20&type=2&token=1&id=%@&ssn_id=%@&eps_id=%@", id, ssn_id, eps_id)
        }
        let host = NetManager.defualt.RequestUrlHost + MovieNetAPI.movieInfoApi.rawValue
        var request: URLRequest = URLRequest(url: URL(string: host)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        request.httpMethod = "POST"
        let data = url.data(using: .ascii, allowLossyConversion: true)
        request.httpBody = data
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                completion(false, nil)
                return
            }
            if let res = response as? HTTPURLResponse, res.statusCode == 200, let data = data {
                let dataString = String(data: data, encoding: .utf8)
                if let model = MovieVideoInfoModel.deserialize(from: dataString) {
                    completion(true, model)
                }
            } else {
                completion(false, nil)
            }
        })
        task.resume()
    }
    
    //MARK: - TV
    func movieTVSeason(id: String, _ completion: @escaping (_ success: Bool, _ list: [MovieVideoInfoSsnlistModel?]) -> ()) {
        para["id"] = id
        ProgressHUD.showLoading()
        NetManager.request(url: MovieNetAPI.movieTvSeasonApi.rawValue, method: .post, parameters: para, modelType: MovieVideoInfoSsnlistModel.self) { responseModel in
            ProgressHUD.dismiss()
            if let list = responseModel.models {
                completion(responseModel.status == .success, list)
            }
        }
    }
    func movieTVSSN(ssn_id: String, id: String, _ completion: @escaping (_ success: Bool, _ model: MovieTVEpsListModel) -> ()) {
        para["ssn_id"] = ssn_id
        para["id"] = id
        ProgressHUD.showLoading()
        NetManager.request(url: MovieNetAPI.movieTvSSNApi.rawValue, method: .post, parameters: para, modelType: MovieTVEpsListModel.self) { responseModel in
            ProgressHUD.dismiss()
            if let mod = responseModel.model {
                completion(responseModel.status == .success, mod)
            }
        }
    }
    
    func getCaptions(id: String, type: Int, _ completion: @escaping (_ success: Bool, _ list: [MovieCaptionModel?]?) -> ()) {
        let url = String(format:"%@get_captions?source_sequence=%@&source_type_ordinal=%d&source_key=%@", NetManager.defualt.RequestVideoHost, id, type, "68D23E4E2A7013E21D82C5A24D8E051A")
        var request: URLRequest = URLRequest(url: URL(string: url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                completion(false, nil)
                return
            }
            if let res = response as? HTTPURLResponse, res.statusCode == 200, let data = data {
                let dataString = String(data: data, encoding: .utf8)
                if let list = [MovieCaptionModel].deserialize(from: dataString) {
                    completion(true, list)
                }
            } else {
                completion(false, nil)
            }
        })
        task.resume()
    }
    
    func getVideoLink(id: String, type: Int, _ completion: @escaping (_ success: Bool, _ model: MoviePlayLinkModel?) -> Void) {
        let url = String(format:"%@get/play_address?source_sequence=%@&source_type_ordinal=%d&source_key=%@", NetManager.defualt.RequestVideoHost, id, type, "68D23E4E2A7013E21D82C5A24D8E051A")
        var request: URLRequest = URLRequest(url: URL(string: url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                completion(false, nil)
                return
            }
            if let res = response as? HTTPURLResponse, res.statusCode == 200, let data = data {
                let dataString = String(data: data, encoding: .utf8)
                if let model = MoviePlayLinkModel.deserialize(from: dataString) {
                    completion(true, model)
                }
            } else {
                completion(false, nil)
            }
        })
        task.resume()
    }
    
    func uploadRedmin(id: String, ssn_id: String = "", eps_id: String = "", isMoive: Bool = true, _ completion: @escaping (_ success: Bool) -> ()) {
        para["video_id"] = id
        para["tv_season_id"] = ssn_id
        para["tv_id"] = eps_id
        para["source_type_ordinal"] = isMoive ? "1" : "0"
        let host = NetManager.defualt.RequestVideoHost + MovieNetAPI.movieRedminApi.rawValue
        var request: URLRequest = URLRequest(url: URL(string: host)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        request.httpMethod = "POST"
        if let data = try? JSONSerialization.data(withJSONObject: para) {
            request.httpBody = data
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        let task: URLSessionDataTask = session.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                completion(false)
                return
            }
            if let res = response as? HTTPURLResponse, res.statusCode == 200, let data = data {
                let dataString = String(data: data, encoding: .utf8)
                completion(true)
            } else {
                completion(false)
            }
        })
        task.resume()
    }
}
