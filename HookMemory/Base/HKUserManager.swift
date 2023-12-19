//
//  HKUserManager.swift
//  HookMemory
//
//  Created by HF on 2023/12/1.
//

import UIKit
import StoreKit

#if DEBUG
let vipHost = "https://apporder.powerfulclean.net"
#else
let vipHost = "https://prod.haxeorder.com"
#endif

struct HKUserData {
    var premiumID: HKUserID = .month
    var price = ""
    var oldPrice = ""
    var title = ""
    var subTitle = ""
    var tag = ""
    var isLine = false
}

// 内购模型枚举
enum HKUserID: String {
    
#if DEBUG
    case week = "haxen_123_week"
    case month = "haxen_123_month"
    case year = "haxen_123_year"
#else
    case week = "haxen_premium_week"
    case month = "haxen_premium_month"
    case year = "haxen_premium_year"
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
var purMoneyYearCut = "$120"
//var purCurrencySymbol = "$"            // 货币单位

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
    
    var week = HKUserData(premiumID: .week, price: purMoneyWeek, oldPrice: "", title: "Weekly", subTitle: "For the per week", tag: "", isLine: false)
    var month = HKUserData(premiumID: .month, price: purMoneyMonth, oldPrice: "",  title: "Monthly", subTitle: "For the per month", tag: "", isLine: false)
    var year = HKUserData(premiumID: .year, price: purMoneyYear, oldPrice: "",  title: "Annually", subTitle: purMoneyYearCut, tag: "-70%", isLine: true)
    
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
    
    func reloadLists(arr: [SKProduct]) {
        self.dataArr.removeAll()
        let form = NumberFormatter.init()
        form.numberStyle = .currencyAccounting
        form.usesGroupingSeparator = true
        for (_, model) in arr.enumerated() {
            var price: String = ""
            var oldPrice: String = ""
            if let p = model.introductoryPrice?.price, let op = form.string(from: p) {
                price = op
                if let op = form.string(from: model.price) {
                    oldPrice = op
                }
            } else {
                if let p = form.string(from: model.price) {
                    price = p
                }
            }
            
            switch HKUserID(rawValue: model.productIdentifier) {
            case .week:
                purMoneyWeek = price
//                purCurrencySymbol = form.currencySymbol
                self.week = HKUserData(premiumID: .week, price: purMoneyWeek, oldPrice: oldPrice, title: "Weekly", subTitle: "For the per week", tag: "", isLine: false)
            case .month:
                purMoneyMonth = price
                self.month = HKUserData(premiumID: .month, price: purMoneyMonth, oldPrice: oldPrice, title: "Monthly", subTitle: "For the per month", tag: "", isLine: false)
            case .year:
                purMoneyYear = price
                purMoneyYearCut = form.string(from: (model.price.doubleValue / 0.3) as NSNumber) ?? "$120"
                self.year = HKUserData(premiumID: .year, price: purMoneyYear, oldPrice: oldPrice, title: "Annually", subTitle: purMoneyYearCut, tag: "-70%", isLine: true)
            case .none:
                break
            }
            self.dataArr = [self.month, self.year, self.week]
        }
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
    func getReceiptData(product: Any?, from: HKPurchaseType, transaction: SKPaymentTransaction? = nil) {
        if let reciptURL = Bundle.main.appStoreReceiptURL, FileManager.default.fileExists(atPath: reciptURL.path) {
            do {
                let reciptData = try Data(contentsOf: reciptURL, options: .alwaysMapped)
                if reciptData.count > 0 {
                    self.checkByServer(receiptData: reciptData.base64EncodedString(options: []), from: from, transaction: transaction)
                }
            } catch {
                ProgressHUD.dismiss()
                if from == .buy || from == .restore {
                    ProgressHUD.showError("Failed to get ticket!")
                }
                self.showError(productId: self.productId, error: "Failed to get ticket!")
            }
        } else {
            ProgressHUD.dismiss()
            if from == .buy || from == .restore {
                ProgressHUD.showError("Failed to get ticket!")
            }
            self.showError(productId: self.productId, error: "Failed to get ticket!")
        }
    }
    
    // MARK: - apple内购价格配置
    func getPurchaseData(from: HKPurchaseType = .update) {
        self.from = from
        if canMakePay() {
            HKLog.log("app [内购] 允许内购")
            let productRequest = SKProductsRequest(productIdentifiers: HKUserID.allValueStr)
            productRequest.delegate = self
            productRequest.start()
        } else {
            HKLog.log("app [内购] 不允许内购")
        }
    }
    /* 准备拉起内购
     // - Parameter proId: apple内购productID
     // - Parameter from: 购买/恢复购买/验证
     // - Parameter source: 调起内购来源页面，用于日志标识
     */
    func goBuyProduct(_ productId: String, from: HKPurchaseType) {
        ProgressHUD.showLoading()
        self.productId = productId
        self.from = from
        if let product = self.productsArray.first(where: { $0.productIdentifier == productId }) {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        } else {
            ProgressHUD.showError("Failed to get product!")
            self.showError(productId: self.productId, error: "Failed to get product!")
            let payment = SKMutablePayment()
            payment.productIdentifier = productId
            payment.quantity = 1
            SKPaymentQueue.default().add(payment)
        }
    }
    
    /// admin 内购校验
    /// - Parameter from: 购买/恢复购买/验证
    /// - Parameter source: 调起内购来源页面，用于日志标识
    func checkByServer(receiptData: String, from: HKPurchaseType, transaction: SKPaymentTransaction?) {
        guard self.task == nil else {
            return
        }
        let bodyStr = String(format: "{\"device_id\":\"%@\",\"receipt_base64_data\":\"%@\",\"product_id\":\"%@\",\"package_name\":\"%@\"}", HKConfig.idfv, receiptData, self.productId, self.perBundleID)
        HKLog.log("[内购] bodyString: \(bodyStr)")
        let url = "\(vipHost)/v1/ios/receipt-verifier"
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
                    self.showError(productId: self.productId, error: error?.localizedDescription)
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
                                    self.showError(productId: self.productId, error: "severs error")
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
                        self.showError(productId: self.productId, error: "\(res.statusCode)")
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
    
    func showError(productId: String, error: String?) {
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
        ProgressHUD.dismiss()
        DispatchQueue.main.async {
            self.reloadLists(arr: self.productsArray)
        }
        
    }
    
    // 请求产品信息失败
    func request(_ request: SKRequest, didFailWithError error: Error) {
        if self.from == .restore {
            HKLog.log("[内购] 恢复购买失败: \(error.localizedDescription)")
            ProgressHUD.dismiss()
            ProgressHUD.showError("Restore purchase failed!")
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
            case .purchased:
                HKLog.log("[内购] 交易完成")
                self.getReceiptData(product: self.productId, from: self.from, transaction: transaction)
                self.getPurchaseData(from: .updatePrice)
            case .failed:
                HKLog.log("[内购] 交易失败")
                self.finishTransaction(transaction: transaction)
                self.showError(productId: self.productId, error: transaction.error?.localizedDescription)
            case .restored:
                HKLog.log("[内购] 已经购买过")
                self.getReceiptData(product: self.productId, from: self.from, transaction: transaction)
                self.getPurchaseData(from: .updatePrice)
            default:
                HKLog.log("[内购] 未知错误")
                self.finishTransaction(transaction: transaction)
                self.showError(productId: self.productId, error: transaction.error?.localizedDescription)
            }
        }
    }
    
    func requestDidFinish(_ request: SKRequest) {
        if self.from == .restore || self.from == .update {
            self.getReceiptData(product: nil, from: from)
        }
    }
    
}
extension HKUserManager {
    func showBuySuccess(_ type: HKPurchaseType) {
        let text: String = type == .buy ? "Subscription Success!" : "Restore Success!"
        DispatchQueue.main.async {
            let view = HKBuySuccessView.viewWithTitle(text)
            HKConfig.currentVC()?.view.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    func showBuyFailed(_ type: HKPurchaseType) {
        let text: String = type == .buy ? "Subscription Failed Please Retry!" : "Restore Failed Please Retry!"
        DispatchQueue.main.async {
            let view = HKBuyFailedView.viewWithTitle(text)
            HKConfig.currentVC()?.view.addSubview(view)
            view.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
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
