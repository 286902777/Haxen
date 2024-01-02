//
//  String+Extension.swift
//  HookMemory
//
//  Created by HF on 2023/11/20.
//

import Foundation
import CryptoSwift

extension String {

    func changeTextNum() -> String {
        if self.count > 1 {
            return self
        } else {
            return "0\(self)"
        }
    }
    
    //  MARK:  AES-ECB128解密
    func AESECB_Decode() -> String? {
        //decode base64
        let key = "RuRe5m69Hn+ZFObK/Hq2SQ=="

        let data = NSData(base64Encoded: self, options: NSData.Base64DecodingOptions.init(rawValue: 0))
        
        // byte 数组
        var encrypted: [UInt8] = []
        if let count = data?.length {
            // 把data 转成byte数组
            for i in 0..<count {
                var temp: UInt8 = 0
                data?.getBytes(&temp, range: NSRange(location: i, length: 1))
                encrypted.append(temp)
            }
            
            // decode AES
            var decrypted: [UInt8] = []
            
            let keyData = Data(base64Encoded: key) ?? Data()
            
            do {
                decrypted = try AES(key: keyData.bytes, blockMode: ECB()).decrypt(encrypted)
            } catch {
                
            }
            
            // byte 转换成NSData
            let encoded = Data(decrypted)
            //解密结果从data转成string
            return String(bytes: encoded.bytes, encoding: .utf8)!
        } else {
            return nil
        }
    }
    
    func jsonToDict() -> [String : Any]? {
        if self.count > 0, let data = self.data(using: String.Encoding.utf8) {
            if let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String : Any] {
                return dict
            }
        }
        return nil
    }
    
    func jsonToArray() -> [Any]? {
        let arr = [Any]()
        if let data = self.data(using: String.Encoding.utf8) {
            do {
                //把NSData对象转换回JSON对象
                let json: Any! = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions.mutableContainers)
                
                return json as? [Any]
            } catch {
                return arr
            }
        } else {
            return arr
        }
    }
}
