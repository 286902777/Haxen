//
//  HKCommon.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import Foundation
import UIKit

let kScreenBounds = UIScreen.main.bounds

//屏幕大小
let kScreenSize                           = kScreenBounds.size
//屏幕宽度
let kScreenWidth:CGFloat                  = kScreenSize.width
//屏幕高度
let kScreenHeight:CGFloat                 = kScreenSize.height
//状态栏默认高度
var kStatusBarHeight:CGFloat {
    get {
        let scene = UIApplication.shared.connectedScenes.first
        guard let windowScene = scene as? UIWindowScene else { return 0 }
        guard let statusBarManager = windowScene.statusBarManager else { return 0 }
        return statusBarManager.statusBarFrame.height
    }
}
//导航栏默认高度
var kNavBarHeight:CGFloat {
    get {
        return (kStatusBarHeight + 44)
    }
}

/// 底部安全区高度
var kBottomSafeAreaHeight:CGFloat {
    get {
        let scene = UIApplication.shared.connectedScenes.first
        if let windowScene = scene as? UIWindowScene, let keyWindow = windowScene.windows.first  {
            return keyWindow.safeAreaInsets.bottom
        } else {
            return 0
        }
    }
}

//Tabbar默认高度
var kTabBarHeight: CGFloat {
    get {
        return kBottomSafeAreaHeight + 49
    }
}

extension UIFont {
    static func font(weigth: UIFont.Weight = .regular ,size: CGFloat) -> UIFont {
        return UIFont.systemFont(ofSize: size, weight: weigth)
    }
}

extension UIColor {
    /// 16进制字符串转颜色
    /// - Parameters:
    ///   - hexString: 16进制色值字符串, "FFFFFF"
    ///   - alpha: 透明度
    /// - Returns: 颜色
    static func hex(_ hexString: String, alpha: CGFloat = 1.0) -> UIColor {
        // 存储转换后的数值
        var red: UInt64 = 0, green: UInt64 = 0, blue: UInt64 = 0
        var hex = hexString
        // 如果传入的十六进制颜色有前缀，去掉前缀
        if hex.hasPrefix("0x") || hex.hasPrefix("0X") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 2)...])
        } else if hex.hasPrefix("#") {
            hex = String(hex[hex.index(hex.startIndex, offsetBy: 1)...])
        }
        // 如果传入的字符数量不足6位按照后边都为0处理，当然你也可以进行其它操作
        if hex.count < 6 {
            for _ in 0..<6-hex.count {
                hex += "0"
            }
        }
        
        // 分别进行转换
        // 红
        Scanner(string: String(hex[..<hex.index(hex.startIndex, offsetBy: 2)])).scanHexInt64(&red)
        // 绿
        Scanner(string: String(hex[hex.index(hex.startIndex, offsetBy: 2)..<hex.index(hex.startIndex, offsetBy: 4)])).scanHexInt64(&green)
        // 蓝
        Scanner(string: String(hex[hex.index(hex.startIndex, offsetBy: 4)...])).scanHexInt64(&blue)
        
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: alpha)
    }
}
extension UIView {
    func addCorner(conrners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: conrners, cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
    
    func addGradientLayer(colorO: UIColor, colorT: UIColor, frame: CGRect, top: Bool = false) {
        let gradient = CAGradientLayer()
        gradient.colors = [colorO.cgColor, colorT.cgColor]
        gradient.locations = [0, 1]
        gradient.frame = frame
        if top {
            gradient.startPoint = CGPoint(x: 0.50, y: 0.01)
            gradient.endPoint = CGPoint(x: 0.50, y: 1.0)
        } else {
            gradient.startPoint = CGPoint(x: 0.01, y: 0.50)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.50)
        }
        self.layer.insertSublayer(gradient, at: 0)
    }
}

extension String {
    
    /// 正则替换所有字符
    ///
    /// - Parameters:
    ///   - pattern: 正则表达式
    ///   - template: 替换字符
    /// - Returns: 替换后的字符串
    func replacingCharacters(pattern: String, template: String) -> String {
        do {
            let regularExpression: NSRegularExpression = try  NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            
            return regularExpression.stringByReplacingMatches(in: self, options: .reportProgress, range: NSMakeRange(0, self.count), withTemplate: template)
        } catch  {
            return self
        }
    }
    
    /// 截取字符串
    ///
    /// - Parameter range: 截取范围
    func substring(withRange range: NSRange) -> String {
        
        return NSString(string: self).substring(with: range)
    }
    
    /// String使用下标截取字符串
    /// string[index] 例如："abcdefg"[3] // c
    subscript (i:Int)->String{
        let startIndex = self.index(self.startIndex, offsetBy: i)
        let endIndex = self.index(startIndex, offsetBy: 1)
        return String(self[startIndex..<endIndex])
    }
    
    /// String使用下标截取字符串
    /// string[index..<index] 例如："abcdefg"[3..<4] // d
    subscript (r: Range<Int>) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
            let endIndex = self.index(self.startIndex, offsetBy: r.upperBound)
            return String(self[startIndex..<endIndex])
        }
    }
    
    /// String使用下标截取字符串
    /// string[index,length] 例如："abcdefg"[3,2] // de
    subscript (index:Int , length:Int) -> String {
        get {
            let startIndex = self.index(self.startIndex, offsetBy: index)
            let endIndex = self.index(startIndex, offsetBy: length)
            return String(self[startIndex..<endIndex])
        }
    }
    
    // 截取 从头到i位置
    func substring(to:Int) -> String{
        return self[0..<to]
    }
    
    // 截取 从i到尾部
    func substring(from:Int) -> String{
        return self[from..<self.count]
    }
    
    /// String 转换 int
    func intValue() -> Int {
        
        return NSString(string: self).integerValue
    }
    // 截取 从头到i位置，添加后缀字符
    func substringAndSuffix(to:Int , suffix : String = "...") -> String{
        if self.count > to {
            return self[0..<to] + suffix
        }
        return self
    }
    
    /// 获取字符串Size
    ///
    /// - Parameters:
    ///   - str: 待计算的字符串
    ///   - attriStr: 待计算的Attribute字符串
    ///   - font: 字体大小
    ///   - w: 宽度
    ///   - h: 高度
    /// - Returns: Size
    static func getStrSize(str: String? = nil, attriStr: NSMutableAttributedString? = nil, font: CGFloat, w: CGFloat, h: CGFloat) -> CGSize {
        if str != nil {
            let strSize = (str! as NSString).boundingRect(with: CGSize(width: w, height: h), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font)], context: nil).size
            return strSize
        }
        
        if attriStr != nil {
            let strSize = attriStr!.boundingRect(with: CGSize(width: w, height: h), options: .usesLineFragmentOrigin, context: nil).size
            return strSize
        }
        
        return CGSize.zero
    }
    
    /// 获取普通字符串高度
    static func getStrH(str: String, strFont: CGFloat, w: CGFloat) -> CGFloat {
        return getStrSize(str: str, font: strFont, w: w, h: CGFloat.greatestFiniteMagnitude).height
    }

    /// 获取普通字符串宽度
    static func getStrW(str: String, strFont: CGFloat, h: CGFloat) -> CGFloat {
        return getStrSize(str: str, font: strFont, w: CGFloat.greatestFiniteMagnitude, h: h).width
    }

    func getStrSize(font: UIFont, w: CGFloat, h: CGFloat) -> CGSize {
        let strSize = self.boundingRect(with: CGSize(width: w, height: h), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
        
        return strSize
    }
    
    func getStrH(strFont: UIFont, w: CGFloat) -> CGFloat {
        getStrSize(font: strFont, w: w, h: CGFloat.greatestFiniteMagnitude).height
    }
    
    func getStrW(strFont: UIFont, h: CGFloat) -> CGFloat {
        return getStrSize(font: strFont, w: CGFloat.greatestFiniteMagnitude, h: h).width
    }
    
    /// 获取Attribute字符串高度
    static func getAttributedStrH(attriStr: NSMutableAttributedString, strFont: CGFloat, w: CGFloat) -> CGFloat {
        return getStrSize(attriStr: attriStr, font: strFont, w: w, h: CGFloat.greatestFiniteMagnitude).height
    }

    /// 获取Attribute字符串宽度
    static func getAttributedStrW(attriStr: NSMutableAttributedString, strFont: CGFloat, h: CGFloat) -> CGFloat {
        return getStrSize(attriStr: attriStr, font: strFont, w: CGFloat.greatestFiniteMagnitude, h: h).width
    }

    /// 删除字符串前后空格
    func trim() -> String {
        
        return self.trimmingCharacters(in: .whitespaces)
    }
    
    /// 删除字符串所有空格
    func trimAll() -> String {
        
        return self.replacingOccurrences(of: " ", with: "")
    }
    
    /// 验证是否是手机号码
    func isPhoneNum() -> Bool {
        
        let pattern = "^1+[23456789]+\\d{9}"
        
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        
        return pred.evaluate(with:self)
    }
    
    /// 验证6-20位密码
    func checkPassword() -> Bool {
        let pattern = "^(?![0-9]+$)(?![a-zA-Z]+$)[a-zA-Z0-9]{6,20}"
        
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        
        return pred.evaluate(with:self)
    }
    
    /// 验证只能是数字字母汉字，无其他特殊字符
    func isNoOtherSuperStr() -> Bool {
        let pattern = "^[\\u4E00-\\u9FA5A-Za-z0-9]+$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        
        return pred.evaluate(with:self)
    }
    
    /// 计算时间戳与当前的时间差
    ///
    /// - Returns: 10分钟之内的，都显示为：刚刚
    /// 10-60分钟之间的，显示为：xx分钟前
    /// 1-24小时之间的，显示为：xx小时前
    /// 超出24小时的，显示为：mm-dd hh:mm
    func compareTime() -> String {
        
        let timeSp = TimeInterval(self)
        
        guard timeSp != nil else {
            
            return ""
        }
        
        let compareDate = Date.init(timeIntervalSince1970: timeSp!)
        
        var compareTime = compareDate.timeIntervalSinceNow
        
        compareTime = -compareTime
        
        // 获取分钟数
        var tmp = Int(compareTime / 60)
        
        var result = "刚刚"
        
        if tmp < 10 {
            // 10分钟以内，显示刚刚
            result = "刚刚"
        } else if tmp < 60 {
            // 10-60分钟之间，显示xx分钟前
            result = "\(tmp)分钟前"
        } else if Int(tmp/60) < 24 {
            // 1-24小时之间，显示xx小时前
            tmp = Int(tmp/60)
            
            result = "\(tmp)小时前"
        } else {
            // 超出24小时的，显示为：mm-dd hh:mm
            
            result = compareDate.formatString("MM-dd hh:mm")
        }
        
        return result
    }
    
    /// 时间戳转日期格式 “yyyy-MM-dd hh:mm:ss”
    func timeStampToDateString(format: String? = nil) -> String {
        
        let timeSp = TimeInterval(self)
        
        guard timeSp != nil else {
            
            return ""
        }
        
        let date = Date.init(timeIntervalSince1970: timeSp!)
        
        if format != nil {
            
            return date.formatString(format!)
        }
        
        return date.formatString("yyyy-MM-dd hh:mm:ss")
    }
    
    /// 去除空格
    func thinStr() -> String {
        
        return self.replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "\n", with: "")
                .replacingOccurrences(of: "\r", with: "")
    }
    
    func phoneStr() -> String {
        
        let str = self.thinStr()
        
        guard str.count >= 11 else {
            
            return self
        }
        
        let first = str.substring(withRange: NSMakeRange(0, 3))
        let second = str.substring(withRange: NSMakeRange(3, 4))
        let third = str.substring(withRange: NSMakeRange(7, 4))
        
        return first + " " + second + " " + third
    }
    
    func studentIDStr() -> String {
        
        let str = self.thinStr()
        
        guard str.count >= 12 else {
            
            return self
        }
        
        let first = str.substring(withRange: NSMakeRange(0, 4))
        let second = str.substring(withRange: NSMakeRange(4, 4))
        let third = str.substring(withRange: NSMakeRange(8, 4))
        
        return first + " " + second + " " + third
    }
}

extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
}
