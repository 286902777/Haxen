//
//  HKRefresh.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import Foundation
import Alamofire
import HandyJSON

enum ResponseError: Int {
    case    unkown      =    0
    case    success     =   200
    case    failure     =   500
    case    expaired    =   401
    case    beOffLine   =   402
}

protocol RequestBaseParam :Encodable{
    var page        :   Int { get }
    var limit       :   Int {get}
}

protocol ResponseBaseParam: BaseModel{
    
    var total       :   Int?{ get }
    var per_page    :   Int?{ get }
    var curent_page :   Int{ get set }
    var last_page   :   Int?{ get }
}

struct RequestHeaders: HandyJSON{
    var timestamp       :   String?
    var token           :   String?
    var sign            :   String?
}

struct ResponseDefault: HandyJSON {}

struct ResponseData: HandyJSON{
    var code    :   Int?
    var msg     :   String?
    var data    :   Any?
}

struct ResponseModel<T:HandyJSON>{
    var errorCode       :   ResponseError = .unkown
    var errorMessage    :   String = "未知错误"
    var model           :   T?
    var models          :   [T?]?
    var resultData      :   Any?
}

class NetManager {
    static let defualt: NetManager = NetManager()

    /// 请求头
    var HKHeaders: HTTPHeaders{
        get{
            var headers = RequestHeaders()
            headers.sign = ""
            headers.token = ""
            headers.timestamp = ""
            guard let jsonHeader = headers.toJSON() ,let jsonHeader = jsonHeader as? [String:String] else {
                return []
            }
            return HTTPHeaders.init(jsonHeader)
        }
    }
    
    /// 接口地址
    let RequestUrlHost : String = ""
    
    /// 参数编码方式
    let HKParameterEncoder : ParameterEncoder = URLEncodedFormParameterEncoder.default
}

extension NetManager{
    
    fileprivate class func InitDataRequest<Parameters: Encodable>(url:String,
                                                                  method:HTTPMethod = .post,
                                                                  parameters:Parameters? = nil
    ) -> DataRequest{
        AF.sessionConfiguration.timeoutIntervalForRequest = 10
        let headers : HTTPHeaders = NetManager.defualt.HKHeaders
        let encoder : ParameterEncoder = NetManager.defualt.HKParameterEncoder
        let requestUrl = url.jointHost()
        
        let request : DataRequest = AF.request(requestUrl, method: method, parameters: parameters, encoder: encoder, headers: headers, interceptor: nil, requestModifier: nil)
        return request
    }
}

typealias ResponseBlock<T:HandyJSON> = (_ responseModel:ResponseModel<T>) -> ()

extension NetManager{
    ///可无参数，无模型数据返回
    class func request(url:String,
                       method:HTTPMethod = .post,
                       parametersDic:[String:String]? = [:],
                       resultBlock:ResponseBlock<ResponseDefault>?){
        self.request(url: url, method: method, parametersDic: parametersDic, modelType: ResponseDefault.self, resultBlock: resultBlock)
    }
    /// 可无参数
    class func request<T:HandyJSON>(url:String,
                                    method:HTTPMethod = .post,
                                    parametersDic:[String:String]? = [:],
                                    modelType:T.Type,
                                    resultBlock:ResponseBlock<T>?){
        self.request(url: url, method: method, parameters: parametersDic, modelType: modelType, resultBlock: resultBlock)
    }
    /// 无模型数据返回
    class func request<Parameters: Encodable>(url:String,
                                              method:HTTPMethod = .post,
                                              parameters:Parameters,
                                              resultBlock:ResponseBlock<ResponseDefault>?){
        self.request(url: url, method: method, parameters: parameters, modelType: ResponseDefault.self, resultBlock: resultBlock)
    }
    
    /// 数据模型返回
    class func request<T:HandyJSON,Parameters: Encodable>(url:String,
                                                          method:HTTPMethod = .post,
                                                          parameters:Parameters,
                                                          modelType:T.Type,
                                                          resultBlock:ResponseBlock<T>?)
    {
        NetManager.InitDataRequest(url: url, method: method, parameters: parameters)
            .responseString { string in
                
                if let error = string.error{
                    print(error.errorDescription as Any)
                    return
                }
                self.response(modelType, string.value,resultBlock)
            }
    }
    
    class func requestXML(url: String, method:HTTPMethod = .post,
                          parameters: [String:String]? = [:], resultBlock: @escaping (String) ->()) {
        NetManager.InitDataRequest(url: url, method: .get ,parameters: parameters)
            .responseString { string in
                if let error = string.error{
                    print(error.errorDescription as Any)
                    return
                }
                resultBlock(string.value ?? "")
            }
    }
    

    fileprivate class func response<T:HandyJSON>
    (
        _ modelType:T.Type,
        _ responseData:String?,
        _ resultBlock:ResponseBlock<T>?
    ){
        guard let resultBlock = resultBlock else {
            return
        }
        guard modelType != ResponseDefault.self else {
            return
        }
        var responseModel = ResponseModel<T>()
        let baseModel = ResponseData.deserialize(from: responseData)
        
        guard let baseModel = baseModel else {
            return resultBlock(responseModel)
        }
        responseModel.errorCode = ResponseError(rawValue: baseModel.code ?? 0) ?? .unkown
        if let _ = baseModel.msg{
            responseModel.errorMessage = baseModel.msg!
        }
        responseModel.resultData = baseModel.data
        
        // 当被转模型数据不存在,停止转模型.
        guard let data = baseModel.data else {
            return resultBlock(responseModel)
        }
        if let dataArray = data as? [Any]{          // 解析数组
            responseModel.models = [T].deserialize(from: dataArray)
            return resultBlock(responseModel)
        }
        else if let data = data as? [String : Any]{     //解析字典
            
            responseModel.model = T.deserialize(from: data)
            return resultBlock(responseModel)
        }
        else{   //原样返回Data数据
            return resultBlock(responseModel)
        }
    }
}

extension String{
    fileprivate func jointHost() -> String{
        let host = NetManager.defualt.RequestUrlHost
        guard !self.isEmpty else {
            return host
        }
        guard !self.contains("http") else {
            return self
        }
        return host + self
    }
}
