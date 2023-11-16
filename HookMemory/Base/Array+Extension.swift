//
//  Array+Extension.swift
//  HookMemory
//
//  Created by HF on 2023/11/16.
//

import Foundation

extension Array {
    func safe(_ index: Int) -> Element? {
        guard index >= 0, index < count else {
            #if DEBUG
            fatalError("数组越界啦")
            #else
            return nil
            #endif
        }
        return self[index]
    }
}
