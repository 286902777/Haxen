//
//  HKUserManager.swift
//  HookMemory
//
//  Created by HF on 2023/12/1.
//

import UIKit
import StoreKit

#if DEBUG
let vipHost = ""
#else
let vipHost = ""
#endif

struct HKUserData {
    var premiumID: HKUserID = .month
    var price = ""
    var title = ""
    var subTitle = ""
    var tag = ""
    var isLine = false
}

// 内购模型枚举
enum HKUserID: String {
    
#if DEBUG
    case week = "weekly_movie_cgfloat"
    case month = "monthly_movie_cgfloat"
    case year = "yearly_movie_cgfloat"
#else
    case week = "weezer_premium_weekly"
    case month = "weezer_premium_yearly"
    case year = "weezer_premium_permanent"
#endif
    
    static var allValueStr: Set<String>{
        return [week.rawValue, month.rawValue, year.rawValue]
    }
}

enum HKPurchaseType: Int {
    case buy = 0
    case restore
    case update
    case updatePrice
}

//内购显示价格 货币单位
var purMoneyWeek = "$1.99"
var purMoneyMonth = "$4.99"
var purMoneyYear = "$29.99"
var lifetimeMoney = "$49.99"
var purMoneyYearCut = "$120"
var purCurrencySymbol = "$"            // 货币单位

class HKUserManager: NSObject {
    
    static let share = HKUserManager()
    
    var task: URLSessionDataTask?
    
    var isVip = UserDefaults.standard.bool(forKey: HKKeys.isVip) {
        didSet {
            UserDefaults.standard.set(isVip, forKey: HKKeys.isVip)
            NotificationCenter.default.post(name: Noti_VipChange, object: nil)
        }
    }
    
    var regionCode: String = ""
    var currencyCode: String = ""
    
    var week = HKUserData(premiumID: .week, price: purMoneyWeek, title: "Weekly", subTitle: "For the per week", tag: "", isLine: false)
    var month = HKUserData(premiumID: .month, price: purMoneyMonth, title: "Monthly", subTitle: "For the per month", tag: "", isLine: false)
    var year = HKUserData(premiumID: .year, price: purMoneyYear, title: "Annually", subTitle: purMoneyYearCut, tag: "-70%", isLine: true)
    
    var premiumList: [String] = [] {
        didSet {
            var idList: [HKUserData] = []
            for item in premiumList {
                if item == month.premiumID.rawValue {
                    idList.append(month)
                }
                if item == year.premiumID.rawValue {
                    idList.append(year)
                }
                if item == week.premiumID.rawValue {
                    idList.append(week)
                }
            }
        }
    }
    
    var windowList: [String] = []
    
    var dataArr: [HKUserData] = [] {
        didSet {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Noti_VipChange, object: nil)
            }
        }
    }
    var request = SKReceiptRefreshRequest()
    var productsArray: [SKProduct] = []
    var productId: String = ""
    var from: HKPurchaseType = .update
    
#if DEBUG
    let perBundleID = "com.testbird.HookMemory"
#else
    let perBundleID = "com.haxenplatform.live"
#endif
    
    override init() {
        super.init()
        self.create()
        
        self.premiumList = [HKUserID.month.rawValue, HKUserID.year.rawValue, HKUserID.week.rawValue]
        
        //        if UserDefaults.standard.value(forKey: Remote.premiumWindow) == nil || UserDefaults.standard.value(forKey: Remote.premiumWindow) as! String == "" {
        //            self.windowList = ["US","MX","BR","CA","CH","DE","PT","GB","BE","IT","FR","ES","NL","ID","SA"]
        //        } else {
        //            let jsonString = UserDefaults.standard.value(forKey: Remote.premiumWindow) as! String
        //            let list = jsonString.components(separatedBy: ",")
        //            self.windowList = list
        //        }
        
        var idList: [HKUserData] = []
        for item in self.premiumList {
            if item == month.premiumID.rawValue {
                idList.append(month)
            }
            if item == year.premiumID.rawValue {
                idList.append(year)
            }
            if item == week.premiumID.rawValue {
                idList.append(week)
            }
        }
        self.dataArr = idList
        self.refreshReceipt(from: .update)
    }
    
    deinit {
        self.destroy()
    }
    
    func reloadLists() {
        self.week = HKUserData(premiumID: .week, price: purMoneyWeek, title: "Weekly", subTitle: "For the per week", tag: "", isLine: false)
        self.month = HKUserData(premiumID: .month, price: purMoneyMonth, title: "Monthly", subTitle: "For the per month", tag: "", isLine: false)
        self.year = HKUserData(premiumID: .year, price: purMoneyYear, title: "Annually", subTitle: purMoneyYearCut, tag: "-70%", isLine: true)
        self.dataArr = [self.month, self.year, self.week]
    }
    
    // 加入Queue
    func create() {
        SKPaymentQueue.default().add(self)
    }
    
    // 销毁
    func destroy() {
        SKPaymentQueue.default().remove(self)
    }
    
    func restore() {
        if !self.isVip {
            //            HKLog.premium_retry()
            self.from = .restore
            ProgressHUD.showLoading()
            self.refreshReceipt(from: .restore)
        } else {
            toast("You already subscribed!")
        }
    }
    
    func refreshReceipt(from: HKPurchaseType) {
        task?.cancel()
        request.cancel()
        request = SKReceiptRefreshRequest()
        request.delegate = self
        request.start()
        self.from = from
        self.getPurchaseData(from: from)
    }
    
    // 是否允许购买
    func canMakePay() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    // 完成购买流程
    func finishTransaction(transaction: SKPaymentTransaction) {
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // 获取reciptData
    func fetchReceiptData(product: Any?, from: HKPurchaseType, transaction: SKPaymentTransaction? = nil) {
        if let reciptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: reciptURL.path) {
            do {
                let reciptData = try Data(contentsOf: reciptURL, options: .alwaysMapped)
                if reciptData.count > 0 {
                    self.verifyByServer(receiptData: reciptData.base64EncodedString(options: []), from: from, transaction: transaction)
                }
            } catch {
                ProgressHUD.dismiss()
                if from == .buy || from == .restore {
                    ProgressHUD.showError("Failed to get ticket!")
                }
                self.buyError(productId: self.productId, error: "Failed to get ticket!")
            }
        } else {
            ProgressHUD.dismiss()
            if from == .buy || from == .restore {
                ProgressHUD.showError("Failed to get ticket!")
            }
            self.buyError(productId: self.productId, error: "Failed to get ticket!")
        }
    }
    
    // MARK: - apple内购价格配置
    func getPurchaseData(from: HKPurchaseType = .update) {
        self.from = from
        if canMakePay() {
            HKLog.log("[内购] 允许内购")
            let productRequest = SKProductsRequest(productIdentifiers: HKUserID.allValueStr)
            productRequest.delegate = self
            productRequest.start()
        } else {
            HKLog.log("[内购] 不允许内购")
        }
    }
    /* 准备拉起内购
     // - Parameter proId: apple内购productID
     // - Parameter from: 购买/恢复购买/验证
     // - Parameter source: 调起内购来源页面，用于日志标识
     */
    func buyProduct(_ productId: String, from: HKPurchaseType) {
        self.productId = productId
        self.from = from
        ProgressHUD.showLoading()
        if let product = self.productsArray.first(where: { $0.productIdentifier == productId }) {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            ProgressHUD.dismiss()
            ProgressHUD.showError("Failed to get product!")
            self.buyError(productId: self.productId, error: "Failed to get product!")
            let payment = SKMutablePayment()
            payment.productIdentifier = productId
            payment.quantity = 1
            SKPaymentQueue.default().add(payment)
        }
    }
    
    /// admin 内购校验
    /// - Parameter from: 购买/恢复购买/验证
    /// - Parameter source: 调起内购来源页面，用于日志标识
    func verifyByServer(receiptData: String, from: HKPurchaseType, transaction: SKPaymentTransaction?) {
        
        guard self.task == nil else {
            return
        }
        
        let bodyStr = String(format: "{\"device_id\":\"%@\",\"receipt_base64_data\":\"%@\",\"product_id\":\"%@\",\"package_name\":\"%@\"}", HKConfig.idfv, receiptData, self.productId, self.perBundleID)
        HKLog.log("[内购] bodyString: \(bodyStr)")
        let url = "https://apporder.powerfulclean.net/v1/ios/receipt-verifier"
        var request: URLRequest = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let data = bodyStr.data(using: .utf8)
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.timeoutInterval = 15
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        self.task = session.dataTask(with: request, completionHandler: { data, response, error in
            self.task = nil
            ProgressHUD.dismiss()
            if let transaction = transaction {
                self.finishTransaction(transaction: transaction)
            }
            guard error == nil else {
                switch from {
                case .buy:
                    self.showBuyFailed(.buy)
                    self.buyError(productId: self.productId, error: error?.localizedDescription)
                case .restore:
                    self.showBuyFailed(.restore)
                default:
                    break
                }
                return
            }
            if let res = response as? HTTPURLResponse {
                if res.statusCode == 200, let data = data {
                    if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let model = HKPremiuModel.deserialize(from: json) {
                            if model.entity.ok == true {
                                switch from {
                                case .buy:
                                    self.showBuySuccess(.buy)
                                case .restore:
                                    self.showBuySuccess(.restore)
                                default:
                                    break
                                }
                                UserDefaults.standard.set(model.product_id, forKey: HKKeys.product_id)
                                UserDefaults.standard.set(model.expires_date_ms, forKey: HKKeys.expires_date_ms)
                                UserDefaults.standard.set(model.auto_renew_status, forKey: HKKeys.auto_renew_status)
                                HKUserManager.share.isVip = true
                            } else {
                                HKUserManager.share.isVip = false
                                switch from {
                                case .buy:
                                    self.showBuyFailed(.buy)
                                    self.buyError(productId: self.productId, error: "severs error")
                                case .restore:
                                    self.showBuyFailed(.restore)
                                default:
                                    break
                                }
                            }
                        }
                    }
                } else {
                    switch from {
                    case .buy:
                        self.showBuyFailed(.buy)
                        self.buyError(productId: self.productId, error: "\(res.statusCode)")
                    case .restore:
                        self.showBuyFailed(.restore)
                    default:
                        break
                    }
                }
            }
        })
        self.task?.resume()
        
    }
    
    func buyError(productId: String, error: String?) {
        ProgressHUD.dismiss()
        switch from {
        case .buy, .restore:
            break
        default:
            HKLog.log("[内购] 获取票据失败: \(error ?? "unKnown")")
            break
        }
        self.getPurchaseData(from: .updatePrice)
    }
    
}

extension HKUserManager: SKProductsRequestDelegate, SKPaymentTransactionObserver, SKRequestDelegate {
    // 请求产品信息成功
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let productsArray = response.products
        self.productsArray = productsArray
        HKLog.log("[内购] 无效的产品ID: \(response.invalidProductIdentifiers)")
        
        if productsArray.count <= 0 {
            HKLog.log("[内购] 没有有效地产品")
            return
        }
        
        let form = NumberFormatter.init()
        form.numberStyle = .currencyAccounting
        form.usesGroupingSeparator = true
        self.regionCode = form.locale.regionCode ?? ""
        self.currencyCode = form.currencyCode
        
        for product in self.productsArray {
            HKLog.log("[内购] 产品价格: \(product.productIdentifier) \(product.price)")
            form.locale = product.priceLocale
            switch product.productIdentifier {
            case HKUserID.week.rawValue:
                purMoneyWeek = form.string(from: product.price) ?? "$1.99"
                purCurrencySymbol = form.currencySymbol
            case HKUserID.month.rawValue:
                purMoneyMonth = form.string(from: product.price) ?? "$4.99"
            case HKUserID.year.rawValue:
                purMoneyYear = form.string(from: product.price) ?? "$29.99"
                purMoneyYearCut = form.string(from: (product.price.doubleValue / 0.3) as NSNumber) ?? "$120"
            default:
                break
            }
        }
        DispatchQueue.main.async {
            self.reloadLists()
        }
        
    }
    
    // 请求产品信息失败
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if self.from == .restore {
            HKLog.log("[内购] 恢复购买失败: \(error.localizedDescription)")
            
            //            ProgressHUD.dismiss()
            //            toast(MTCommonManager.localizedString(key: "Restore purchase failed!"))
            toast("Restore purchase failed!")
        } else {
            HKLog.log("[内购] 产品请求失败: \(error.localizedDescription)")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                HKLog.log("[内购] 商品添加进列表")
            case .deferred:
                HKLog.log("[内购] 交易延期")
                ProgressHUD.dismiss()
            case .purchased:
                HKLog.log("[内购] 交易完成")
                self.fetchReceiptData(product: self.productId, from: self.from, transaction: transaction)
                self.getPurchaseData(from: .updatePrice)
            case .failed:
                HKLog.log("[内购] 交易失败")
                self.finishTransaction(transaction: transaction)
                self.buyError(productId: self.productId, error: transaction.error?.localizedDescription)
            case .restored:
                HKLog.log("[内购] 已经购买过")
                self.fetchReceiptData(product: self.productId, from: self.from, transaction: transaction)
                self.getPurchaseData(from: .updatePrice)
            @unknown default:
                HKLog.log("[内购] 未知错误")
                self.finishTransaction(transaction: transaction)
                self.buyError(productId: self.productId, error: transaction.error?.localizedDescription)
            }
            
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        if self.from == .restore || self.from == .update {
            self.fetchReceiptData(product: nil, from: from)
        }
    }
    
}
extension HKUserManager {
    func showBuySuccess(_ type: HKPurchaseType) {
        let text: String = type == .buy ? "Subscription Success!" : "Restore Success!"
        DispatchQueue.main.async {
            HKConfig.currentVC()?.view.addSubview(HKBuySuccessView.viewWithTitle(text))
        }
    }
    
    func showBuyFailed(_ type: HKPurchaseType) {
        let text: String = type == .buy ? "Subscription Failed Please Retry!" : "Restore Failed Please Retry!"
        DispatchQueue.main.async {
            HKConfig.currentVC()?.view.addSubview(HKBuyFailedView.viewWithTitle(text))
        }
    }
}
extension HKUserManager {
    //    func math(numberStr: String, day: Double) -> String {
    //        var pointNumber = 0
    //        let price = Double(numberStr) ?? 0.0
    //
    //        if numberStr.contains(".") {
    //            let follow = numberStr.components(separatedBy: ".").last
    //            pointNumber = follow?.count ?? 0
    //            if follow == "0" {
    //                pointNumber = 0
    //            }
    //        }
    //
    //        let dayPrice = self.interceptionDecimal(pointNumber, number: price / day)
    //
    //        return self.newStrBy(pointNumber: pointNumber, dayPrice: dayPrice)
    //    }
    
    //    func newStrBy(pointNumber: Int, dayPrice: Double) -> String {
    //        var newStr = String(format: "%.\(pointNumber)f", dayPrice)
    //
    ////        var minusStr = "9"
    ////        if pointNumber > 0 {
    ////            var magicStr = ""
    ////            for _ in 0..<pointNumber - 1 {
    ////                magicStr += "0"
    ////            }
    ////
    ////            minusStr = magicStr == "" ? "0.9" : "0." + magicStr + "9"
    ////        }
    ////
    ////        if let minus = Double(minusStr), dayPrice > minus {
    ////            newStr = String(format: "%.\(pointNumber)f", dayPrice - minus)
    ////            let range = newStr.index(newStr.endIndex, offsetBy: -1) ..< newStr.endIndex
    ////            newStr.replaceSubrange(range, with: "9")
    ////        }
    //
    //        return newStr
    //    }
    //
    //    func interceptionDecimal(_ base: Int, number: Double) -> Double {
    //        let format = NumberFormatter()
    //        format.numberStyle = .decimal
    //        format.minimumFractionDigits = base
    //        format.maximumFractionDigits = base
    //        format.formatterBehavior = .default
    //        format.roundingMode = .down
    //        let string = format.string(from: NSNumber(value: number)) ?? ""
    //        let string2 = string.replacingOccurrences(of: ",", with: "")
    //        return Double(string2) ?? 0.0
    //    }
}

class HKPremiuModel: BaseModel {
    var entity = MTPremiuEntityModel()
    var checks = [String]()
    
    var auto_renew_status: String {
        return entity.pending_renewal_info.first?.auto_renew_status ?? "0"
    }
    
    var product_id: String {
        return entity.latest_receipt_info.first?.product_id ?? ""
    }
    
    var expires_date_ms: TimeInterval {
        return entity.latest_receipt_info.first?.expires_date_ms ?? 0
    }
    
}

class HKPremiuEntityModel: BaseModel {
    var environment = ""
    var status = 0
    var receipt = ""
    var latest_receipt_info = [HKReceiptInfo]()
    var pending_renewal_info = [HKPendingRenewalInfo]()
    var device_id = ""
    var ok: Bool = false
}

class HKReceiptInfo: BaseModel {
    var quantity = ""
    var product_id = ""
    var transaction_id = ""
    var original_transaction_id = ""
    var web_order_line_item_id = ""
    var subscription_group_identifier = ""
    var is_trial_period = ""
    var is_in_intro_offer_period = ""
    var in_app_ownership_type = ""
    var purchase_date_ms: TimeInterval = 0
    var purchase_date = ""
    var purchase_date_pst = ""
    var original_purchase_date_ms: TimeInterval = 0
    var original_purchase_date = ""
    var original_purchase_date_pst = ""
    var expires_date_ms: TimeInterval = 0
    var expires_date = ""
    var expires_date_pst = ""
}

class HKPendingRenewalInfo: BaseModel {
    var auto_renew_status = ""
    var original_transaction_id = ""
}
