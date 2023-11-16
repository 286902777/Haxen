//
//  memoryModel.swift
//  HookMemory
//
//  Created by HF on 2023/11/6.
//

import Foundation

class memoryModel {
    var isMonth: Bool = false
    var month: String = ""
    var week: String = ""
    var day: String = ""
    var date: String = ""
    var dModel: dayModel = dayModel()
    var isData: Bool {
        get {
            if dModel.array.count == 0 {
                return false
            } else {
                return true
            }
        }
    }
}
