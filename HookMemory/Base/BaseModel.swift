//
//  BaseModel.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import HandyJSON

protocol BaseModelProtocol: HandyJSON {

}

class BaseModel: HandyJSON {
    required init() {}
    
    func mapping(mapper: HelpingMapper) {   //自定义解析规则，日期数字颜色，如果要指定解析格式，子类实现重写此方法即可
    
    }
}
