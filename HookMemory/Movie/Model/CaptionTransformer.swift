//
//  CaptionTransformer.swift
//  HookMemory
//
//  Created by HF on 2023/11/22.
//

import Foundation

class CaptionTransformer: NSSecureUnarchiveFromDataTransformer {
   
   // 定义静态属性name，方便使用
   static let name = NSValueTransformerName(rawValue: String(describing: CaptionTransformer.self))
   
   // 重写allowedTopLevelClasses，确保UIColor在允许的类列表中
   override static var allowedTopLevelClasses: [AnyClass] {
       return [NSArray.self, MovieCaption.self] // NSArray.self 也要加上，不然不能在数组中使用！
   }
   
   // 定义Transformer转换器注册方法
   public static func register() {
       let transformer = CaptionTransformer()
       ValueTransformer.setValueTransformer(transformer, forName: name)
   }
}
