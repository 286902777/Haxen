//
//  HKADManager.swift
//  HookMemory
//
//  Created by HF on 2023/12/1.
//

import UIKit
import GoogleMobileAds
import AppLovinSDK
import AVKit
import HandyJSON

enum HKADIDType: String, HandyJSONEnum {
    case native = "native"
    case interstitial = "interstitial"
    case open = "open"
    case rewarded = "rewarded"
    case rewardedInterstitial = "rewardedInterstitial"
}

enum HKADLogENUM: String {
    case none, other_cool, other_download, other_search, other_show, other_playlist, other_tab, other_like, play_cool, play_play, play_pause, play_show, cool_cool, open_cool, open_show, open_hot, native_playlist, native_library, native_cool, download, search, like, tab, play, pause, open, cool, playlist, native, high
}

enum HKADType: String, HandyJSONEnum {
    case native = "native"
    case open = "open"
    case play = "play"
    case other = "landscape"
    case off = "off"
    case high = "high"
}

enum HKADSource: String, HandyJSONEnum {
    case admob = "admob"
    case max = "max"
    case tradplus = "tradplus"
}

class HKADItem: BaseModel {
    var id: String = ""
    var level: Int = 0
    var type: HKADIDType = .interstitial
    var source: HKADSource = .admob
    var open_time: Int? = 0
    
    override func mapping(mapper: HelpingMapper) {
        super.mapping(mapper: mapper)
        // 指定 type 字段用这个方法去解析
        mapper.specify(property: &type) { (rawString) -> (HKADIDType) in
            let t = HKADIDType(rawValue: rawString.lowercased())
            return t ?? .interstitial
        }
        mapper.specify(property: &source) { (rawString) -> (HKADSource) in
            let t = HKADSource(rawValue: rawString.lowercased())
            return t ?? .admob
        }
    }
}

/// 广告列表
class HKADTypeModel: BaseModel {
    var hk_native: [HKADItem] = []
    var hk_open: [HKADItem] = []
    var hk_play: [HKADItem] = []
    var hk_landscape: [HKADItem] = []
    var hk_offline: [HKADItem] = []
    var hk_highLevel: [HKADItem] = []
    var hk_sameInterval: Int = 60
    var hk_differentInterval: Int = 60
    var hk_openInterval: Int = 30
    var hk_totalShowCount: Int = 100
    var hk_play_point_time: Int = 540
}

/// 缓存广告
class HKADCache: BaseModel {
    var id: String = ""
    var level: Int = 0
    var type: HKADType = .open
    var source: HKADSource = .admob
    var id_type: HKADIDType = .open
    var time: TimeInterval = Date().timeIntervalSince1970
    var ad: NSObject?
}

class HKADManager: NSObject {
    
    static let share = HKADManager()
    
    /// 缓存定时器
    var cacheTimer: DispatchSourceTimer?
    var cacheCount = 0 {
        didSet {
            DispatchQueue.main.async {
                if self.cacheCount % 2 == 0 {
                    self.refreshAdCache()
                    HKLog.log("[AD] 检查高价层广告缓存信息")
                    guard let _ = self.getCacheWithType(type: .high) else {
                        HKLog.log("[AD] 高价层无广告,加载高价层广告")
                        self.hk_loadFullAd(type: .high, placement: .high)
                        return
                    }
                }
            }
        }
    }
    
    /// 显示和点击次数
    var adCounts: HKADCounts?
    
    var play_time: Int = 600
    
    var coolLoadSuccess = false
    var isShowCoolAd = false
    var isShowingCoolAd = false
    
    var sameInterval: Int = 60
    var differentInterval: Int = 60
    var openInterval: Int = 60
    var mixOpenWait: Int = 10
    
    var playTime: TimeInterval = 0
    var openTime: TimeInterval = 0 {
        didSet {
            HKLog.log("open_time: \(openTime)")
        }
    }
    var otherTime: TimeInterval = 0
    var offlineTime: TimeInterval = 0
    
    var dataArr: [adInfoListModel] = []
    var cacheArr: [adCacheModel] = []
    var hkAdInfo = HKADTypeModel() {
        didSet {
            self.dataArr.removeAll()
            self.setInfoData(self.hkAdInfo.hk_play, .play)
            self.setInfoData(self.hkAdInfo.hk_open, .open)
            self.setInfoData(self.hkAdInfo.hk_landscape, .other)
            self.setInfoData(self.hkAdInfo.hk_offline, .off)
            self.setInfoData(self.hkAdInfo.hk_highLevel, .high)
            self.setInfoData(self.hkAdInfo.hk_native, .native)
            self.sameInterval = self.hkAdInfo.hk_sameInterval
            self.differentInterval = self.hkAdInfo.hk_differentInterval
            self.openInterval = self.hkAdInfo.hk_openInterval
            self.play_time = self.hkAdInfo.hk_play_point_time
        }
    }
    
    var tempDismissComplete: (() -> Void)?
    
    var type: HKADType = .open
    
    var openLoadingSuccessComplete: (() -> Void)?
    
    var isInit = false
    
    func setInfoData(_ items: [HKADItem], _ type: HKADType) {
        let model = adInfoListModel()
        model.item = items
        model.type = type
        model.item.sort(by: {$0.level > $1.level })
        self.dataArr.append(model)
    }
    func initSet() {
        if let jsonString = UserDefaults.standard.value(forKey: HKKeys.advertiseKey) as? String {
            let jsonData = Data(base64Encoded: jsonString) ?? Data()
            if let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                if let model = HKADTypeModel.deserialize(from: json) {
                    hkAdInfo = model
                }
            }
        } else {
#if DEBUG
            let filePath = Bundle.main.path(forResource: "hk_ad_debug", ofType: "json")!
#else
            let filePath = Bundle.main.path(forResource: "hk_ad_release", ofType: "json")!
#endif
            let fileData = try! Data(contentsOf: URL(fileURLWithPath: filePath))
            if let json = try? JSONSerialization.jsonObject(with: fileData) as? [String: Any] {
                if let model = HKADTypeModel.deserialize(from: json) {
                    hkAdInfo = model
                }
            }
        }
        
        // setup counts
        setupAdmobCounts()
        
        // refresh caches
        cacheTimer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        cacheTimer?.setEventHandler(handler: { [weak self] in
            self?.cacheCount = (self?.cacheCount ?? 0) + 1
        })
        cacheTimer?.schedule(deadline: .now() + 60, repeating: 60)
        cacheTimer?.resume()
    }
    
    /// 预加载
    func startLoad() {
        DispatchQueue.main.async {
            if HKUserManager.share.isVip { return }
            self.hk_loadFullAd(type: .open, placement: .cool_cool)
            self.hk_loadFullAd(type: .play, placement: .play_cool)
        }
    }
    
    func adInit() {
        if isInit {
            return
        }
        isInit = true
        self.startLoad()
    }
}

// MARK: - fullscreen 入口
extension HKADManager {
    func hk_loadFullAd(type: HKADType, index: Int = 0, placement: HKADLogENUM) {
        if HKUserManager.share.isVip { return }
        if !HKConfig.share.isNet {
            return
        }
        // 是否可显示
        if canShowAd() == false {
            return
        }
        HKLog.log("[AD] 广告开始加载 type: \(type.rawValue)")
        // 是否在加载中 及 检查数组是否越界
//        if let m = self.dataArr.first(where: {$0.type == type}) {
//            if m.adIsLoding {
//                HKLog.log("[AD] 播放中--广告正在加载 type: \(type.rawValue)")
//                return
//            }
//        }
        
//        self.type = type
        
        if let item = self.dataArr.first(where: {$0.type == type}), let opentime = UserDefaults.standard.value(forKey: HKKeys.appOpneCount) as? Int {
            if let model = item.item.safe(index) {
                if model.open_time ?? 0 < opentime {
                    switch model.type {
                    case .interstitial:
                        self.hk_loadInterstitialAd(type: type, index: index, item: model, placement: placement)
                    case .open:
                        self.hk_loadOpenAd(type: type, index: index, item: model, placement: placement)
                    case .rewarded:
                        self.hk_loadRewardAd(type: type, index: index, item: model, placement: placement)
                    case .rewardedInterstitial:
                        self.hk_loadRewardInterstitialAd(type: type, index: index, item: model, placement: placement)
                    default:
                        break
                    }
                } else {
                    if let m = self.dataArr.first(where: {$0.type == type}) {
                        HKLog.log("[AD] opentime 不满足 type: \(type.rawValue) app_open_time: \(opentime)  open_time: \(m.item.first?.open_time)")
                        m.adIsLoding = false
                        self.hk_loadFullAd(type: m.type, index: m.index + 1, placement: m.placement)
                    }
                }
            } else {
                return
            }
        }
    }
    
    func hk_showFullAd(type: HKADType, placement: HKADLogENUM, complete: @escaping(Bool, GADFullScreenPresentingAd?) -> Void) {
        if HKUserManager.share.isVip {
            complete(false, nil)
            return
        }
        if !HKConfig.share.isNet {
            complete(false, nil)
            return
        }
        // 是否可显示
        if canShowAd() == false {
            complete(false, nil)
            return
        }
        let time = Date().timeIntervalSince1970
        if let _ = self.dataArr.first(where: {$0.type == type}) {
            switch type {
            case .open:
                if Int(ceil(time - self.openTime)) < self.sameInterval || Int(ceil(time - self.otherTime)) < self.differentInterval || Int(ceil(time - self.playTime)) < self.differentInterval || Int(ceil(time - self.offlineTime)) < self.differentInterval {
                    HKLog.log("[AD] 同场景间隔时间小于\(self.sameInterval) 或者 不同场景间隔时间小于\(self.differentInterval) 或者 开屏与插屏间隔时间小于\(self.openInterval)")
                    complete(false, nil)
                    return
                }
            case .play:
                if Int(ceil(time - self.openTime)) < self.openInterval || Int(ceil(time - self.otherTime)) < self.differentInterval || Int(ceil(time - self.playTime)) < self.sameInterval || Int(ceil(time - self.offlineTime)) < self.differentInterval {
                    HKLog.log("[AD] 同场景间隔时间小于\(self.sameInterval) 或者 不同场景间隔时间小于\(self.differentInterval) 或者 开屏与插屏间隔时间小于\(self.openInterval)")
                    complete(false, nil)
                    return
                }
            case .other:
                if Int(ceil(time - self.openTime)) < self.openInterval || Int(ceil(time - self.playTime)) < self.differentInterval || Int(ceil(time - self.otherTime)) < self.sameInterval || Int(ceil(time - self.offlineTime)) < self.differentInterval {
                    HKLog.log("[AD] 同场景间隔时间小于\(self.sameInterval) 或者 不同场景间隔时间小于\(self.differentInterval) 或者 开屏与插屏间隔时间小于\(self.openInterval)")
                    complete(false, nil)
                    return
                }
            case .off:
                if Int(ceil(time - self.openTime)) < self.openInterval || Int(ceil(time - self.playTime)) < self.differentInterval || Int(ceil(time - self.otherTime)) < self.differentInterval || Int(ceil(time - self.offlineTime)) < self.sameInterval {
                    HKLog.log("[AD] 同场景间隔时间小于\(self.sameInterval) 或者 不同场景间隔时间小于\(self.differentInterval) 或者 开屏与插屏间隔时间小于\(self.openInterval)")
                    complete(false, nil)
                    return
                }
            default:
                break
            }
        }
        // 是否有缓存
        HKLog.log("[AD] 无高价层广告, 按原有加载逻辑进行")
        if let arr = self.getCacheWithType(type: type), arr.count > 0 {
            self.type = type
            if let c = arr.first {
                if c.source == .admob {
                    if let ad = c.ad as? GADInterstitialAd {
                        ad.fullScreenContentDelegate = self
                        complete(true, ad)
                    } else if let ad = c.ad as? GADAppOpenAd {
                        ad.fullScreenContentDelegate = self
                        complete(true, ad)
                    } else if let ad = c.ad as? GADRewardedAd {
                        ad.fullScreenContentDelegate = self
                        complete(true, ad)
                    } else if let ad = c.ad as? GADRewardedInterstitialAd {
                        ad.fullScreenContentDelegate = self
                        complete(true, ad)
                    } else {
                        self.removeFirstCache(type: type)
                        self.hk_loadFullAd(type: type, placement: placement)
                        self.type = .open
                        complete(false, nil)
                    }
                } else if c.source == .max {
                    if (c.ad as? MAInterstitialAd)?.isReady == true {
                        (c.ad as? MAInterstitialAd)?.show()
                        complete(true, nil)
                    } else if (c.ad as? MAAppOpenAd)?.isReady == true {
                        (c.ad as? MAAppOpenAd)?.show()
                        complete(true, nil)
                    } else if (c.ad as? MARewardedAd)?.isReady == true {
                        (c.ad as? MARewardedAd)?.show()
                        complete(true, nil)
                    } else if (c.ad as? MARewardedInterstitialAd)?.isReady == true {
                        (c.ad as? MARewardedInterstitialAd)?.show()
                        complete(true, nil)
                    } else {
                        self.removeFirstCache(type: type)
                        self.hk_loadFullAd(type: type, placement: placement)
                        self.type = .open
                        complete(false, nil)
                    }
                }
            }
        } else {
            self.removeFirstCache(type: type)
            self.hk_loadFullAd(type: type, placement: placement)
            self.type = .open
            complete(false, nil)
        }
    }
}

// MARK: - 插屏
extension HKADManager {
    func hk_loadInterstitialAd(type: HKADType, index: Int, item: HKADItem, placement: HKADLogENUM) {
        let id = item.id
        if item.source == .admob {
            let request = GADRequest()
            GADInterstitialAd.load(withAdUnitID: id, request: request) { [weak self] ad, error in
                guard let self = self else { return }
                if let m = self.dataArr.first(where:{$0.type == type}) {
                    m.adIsLoding = false
                }
                guard error == nil else {
                    HKLog.log("[AD] 广告加载失败 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    self.hk_adFail(placement: placement, code: error.debugDescription)
                    self.hk_loadFullAd(type: type, index: index + 1, placement: placement)
                    return
                }
                
                if let ad = ad {
                    let cache = HKADCache()
                    cache.id = item.id
                    cache.level = item.level
                    cache.type = type
                    cache.source = item.source
                    cache.ad = ad
                    cache.id_type = item.type
                    
                    /// 加入缓存
                    self.addCacheWithType(type: type, model: cache)
                    HKLog.log("[AD] 广告加载成功 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    
                    if type == .open {
                        self.coolLoadSuccess = true
                        if self.openLoadingSuccessComplete != nil {
                            self.openLoadingSuccessComplete!()
                        }
                    }
                    
                    ad.paidEventHandler = { value in
                        let nvalue = value.value
                        let currencyCode = value.currencyCode
                        HKLog.hk_ad_impression_revenue(value: nvalue.doubleValue, currency: currencyCode, adFormat: "INTERSTITIAL", adSource: ad.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "", adPlatform: "admob", adUnitName: item.id , precision: "\(value.precision.rawValue)", placement: type.rawValue)
                    }
                } else {
                    HKLog.log("[AD] 广告加载失败 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    self.hk_adFail(placement: placement, code: error.debugDescription)
                    
                    self.hk_loadFullAd(type: type, index: index + 1, placement: placement)
                }
            }
        } else if item.source == .max {
            if let m = self.dataArr.first(where: {$0.type == type}) {
                let cache = HKADCache()
                cache.id = item.id
                cache.level = item.level
                cache.type = type
                cache.source = item.source
                cache.ad = m.ad
                cache.id_type = item.type
                cache.ad = MAInterstitialAd(adUnitIdentifier: item.id)
                (cache.ad as? MAInterstitialAd)?.delegate = self
                (cache.ad as? MAInterstitialAd)?.revenueDelegate = self
                (cache.ad as? MAInterstitialAd)?.load()
                /// 加入缓存
                self.addCacheWithType(type: type, model: cache)
            }
        }
    }
}

// MARK: - 激励
extension HKADManager {
    func hk_loadRewardAd(type: HKADType, index: Int, item: HKADItem, placement: HKADLogENUM) {
        let id = item.id
        if item.source == .admob {
            let request = GADRequest()
            GADRewardedAd.load(withAdUnitID: id, request: request) { [weak self] ad, error in
                guard let self = self else { return }
                if let m = self.dataArr.first(where:{$0.type == type}) {
                    m.adIsLoding = false
                }
                
                guard error == nil else {
                    HKLog.log("[AD] 广告加载失败 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    self.hk_adFail(placement: placement, code: error.debugDescription)
                    
                    self.hk_loadFullAd(type: type, index: index + 1, placement: placement)
                    
                    return
                }
                
                if let ad = ad {
                    let cache = HKADCache()
                    cache.id = item.id
                    cache.level = item.level
                    cache.type = type
                    cache.source = item.source
                    cache.ad = ad
                    cache.id_type = item.type
                    /// 加入缓存
                    self.addCacheWithType(type: type, model: cache)
                    HKLog.log("[AD] 广告加载成功 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    
                    if type == .open {
                        self.coolLoadSuccess = true
                        if self.openLoadingSuccessComplete != nil {
                            self.openLoadingSuccessComplete!()
                        }
                    }
                    
                    ad.paidEventHandler = { value in
                        let nvalue = value.value
                        let currencyCode = value.currencyCode
                        
                        HKLog.hk_ad_impression_revenue(value: nvalue.doubleValue, currency: currencyCode, adFormat: "INTERSTITIAL", adSource: ad.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "", adPlatform: "admob", adUnitName: item.id , precision: "\(value.precision.rawValue)", placement: type.rawValue)
                    }
                    
                } else {
                    HKLog.log("[AD] 广告加载失败 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    self.hk_adFail(placement: placement, code: error.debugDescription)
                    
                    self.hk_loadFullAd(type: type, index: index + 1, placement: placement)
                }
            }
        } else if item.source == .max {
            if let m = self.dataArr.first(where: {$0.type == type}) {
                m.ad = MARewardedAd.shared(withAdUnitIdentifier: item.id)
                (m.ad as? MARewardedAd)?.delegate = self
                (m.ad as? MARewardedAd)?.revenueDelegate = self
                (m.ad as? MARewardedAd)?.load()
            }
        }
    }
}

// MARK: - 激励插屏
extension HKADManager {
    func hk_loadRewardInterstitialAd(type: HKADType, index: Int, item: HKADItem, placement: HKADLogENUM) {
        let id = item.id
        if item.source == .admob {
            
            let request = GADRequest()
            GADRewardedInterstitialAd.load(withAdUnitID: id, request: request) {[weak self] ad, error in
                guard let self = self else { return }
                if let m = self.dataArr.first(where: {$0.type == type}) {
                    m.adIsLoding = false
                }
                guard error == nil else {
                    HKLog.log("[AD] 广告加载失败 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    self.hk_adFail(placement: placement, code: error.debugDescription)
                    
                    self.hk_loadFullAd(type: type, index: index + 1, placement: placement)
                    
                    return
                }
                
                if let ad = ad {
                    let cache = HKADCache()
                    cache.id = item.id
                    cache.level = item.level
                    cache.type = type
                    cache.source = item.source
                    cache.ad = ad
                    cache.id_type = item.type
                    
                    /// 加入缓存
                    self.addCacheWithType(type: type, model: cache)
                    HKLog.log("[AD] 广告加载成功 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    
                    if type == .open {
                        self.coolLoadSuccess = true
                        if self.openLoadingSuccessComplete != nil {
                            self.openLoadingSuccessComplete!()
                        }
                    }
                    
                    ad.paidEventHandler = { value in
                        let nvalue = value.value
                        let currencyCode = value.currencyCode
                        HKLog.hk_ad_impression_revenue(value: nvalue.doubleValue, currency: currencyCode, adFormat: "INTERSTITIAL", adSource: ad.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "", adPlatform: "admob", adUnitName: item.id , precision: "\(value.precision.rawValue)", placement: type.rawValue)
                    }
                    
                } else {
                    HKLog.log("[AD] 广告加载失败 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    self.hk_adFail(placement: placement, code: error.debugDescription)
                    
                    self.hk_loadFullAd(type: type, index: index + 1, placement: placement)
                }
            }
        } else {
            if let m = self.dataArr.first(where: {$0.type == type}) {
                m.ad = MARewardedInterstitialAd(adUnitIdentifier: item.id)
                (m.ad as? MARewardedInterstitialAd)?.delegate = self
                (m.ad as? MARewardedInterstitialAd)?.revenueDelegate = self
                (m.ad as? MARewardedInterstitialAd)?.load()
            }
            self.hk_loadFullAd(type: type, index: index + 1, placement: placement)
        }
        
    }
}

// MARK: - 开屏
extension HKADManager {
    /// 开屏广告加载
    func hk_loadOpenAd(type: HKADType, index: Int, item: HKADItem, placement: HKADLogENUM) {
        
        let id = item.id
        if item.source == .admob {
            let request = GADRequest()
            GADAppOpenAd.load(withAdUnitID: id, request: request, orientation: .portrait) { [weak self] ad, error in
                guard let self = self else { return }
                switch type {
                case .open:
                    if let m = self.dataArr.first(where: {$0.type == .open}) {
                        m.adIsLoding = false
                    }
                default:
                    return
                }
                guard error == nil else {
                    HKLog.log("[AD] 广告加载失败 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    self.hk_adFail(placement: placement, code: error.debugDescription)
                    
                    self.hk_loadFullAd(type: type, index: index + 1, placement: placement)
                    return
                }
                
                if let ad = ad {
                    let cache = HKADCache()
                    cache.id = item.id
                    cache.level = item.level
                    cache.source = item.source
                    cache.type = type
                    cache.ad = ad
                    cache.id_type = item.type
                    
                    ad.paidEventHandler = { value in
                        let nvalue = value.value
                        let currencyCode = value.currencyCode
                        
                        HKLog.hk_ad_impression_revenue(value: nvalue.doubleValue, currency: currencyCode, adFormat: "OPEN", adSource: ad.responseInfo.loadedAdNetworkResponseInfo?.adNetworkClassName ?? "", adPlatform: "admob", adUnitName: item.id , precision: "\(value.precision.rawValue)", placement: type.rawValue)
                    }
                    
                    /// 加入缓存
                    self.addCacheWithType(type: type, model: cache)
                    HKLog.log("[AD] 广告加载成功 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    switch type {
                    case .open:
                        self.coolLoadSuccess = true
                        if self.openLoadingSuccessComplete != nil {
                            self.openLoadingSuccessComplete!()
                        }
                    default:
                        return
                    }
                    
                } else {
                    HKLog.log("[AD] 广告加载失败 type: \(type.rawValue) 优先级: \(index + 1), id: \(id)")
                    self.hk_adFail(placement: placement, code: error.debugDescription)
                    
                    self.hk_loadFullAd(type: type, index: index + 1, placement: placement)
                    
                    return
                }
            }
        } else {
            self.hk_loadFullAd(type: type, index: index + 1, placement: placement)
        }
    }
    
}

extension HKADManager {
    func hk_adFail(placement: HKADLogENUM, code: String) {
        
    }
}

// MARK: - 全屏广告代理
extension HKADManager: GADFullScreenContentDelegate {
    
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        HKLog.log("[AD] Ad did fail to present full screen content.")
        
        if ad is GADAppOpenAd {
            if self.type == .open {
                if let m = self.dataArr.first(where: {$0.type == .open}) {
                    m.adIsLoding = false
                    self.removeFirstCache(type: m.type)
                    self.hk_loadFullAd(type: m.type, placement: m.placement)
                    if self.tempDismissComplete != nil {
                        self.tempDismissComplete!()
                    }
                }
            }
        } else {
            let interstitialAd = ad as? GADInterstitialAd
            let rewardAd = ad as? GADRewardedAd
            let rewardInterstitialAd = ad as? GADRewardedInterstitialAd
            if let m = self.dataArr.first(where: {$0.type == type}) {
                if let _ = m.item.first(where: {$0.id == interstitialAd?.adUnitID || $0.id == rewardAd?.adUnitID || $0.id == rewardInterstitialAd?.adUnitID}) {
                    m.adIsLoding = false
                    self.removeFirstCache(type: m.type)
                    self.hk_loadFullAd(type: m.type, placement: m.placement)
                    if self.tempDismissComplete != nil {
                        self.tempDismissComplete!()
                    }
                }
            }
        }
    }
    
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        UIApplication.shared.isStatusBarHidden = true
        if ad is GADAppOpenAd {
            if self.type == .open {
                self.addShowCount(type: .open)
            }
        } else {
            let interstitialAd = ad as? GADInterstitialAd
            let rewardAd = ad as? GADRewardedAd
            let rewardInterstitialAd = ad as? GADRewardedInterstitialAd
            if let m = self.dataArr.first(where: {$0.type == type}) {
                if let _ = m.item.first(where: {$0.id == interstitialAd?.adUnitID || $0.id == rewardAd?.adUnitID || $0.id == rewardInterstitialAd?.adUnitID}) {
                    self.addShowCount(type: m.type)
                    m.adShowing = true
                }
            }
        }
        self.isShowingCoolAd = true
    }
    
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        UIApplication.shared.isStatusBarHidden = false
        if ad is GADAppOpenAd {
            self.openTime = Date().timeIntervalSince1970
            if self.type == .open {
                self.removeFirstCache(type: .open)
                self.hk_loadFullAd(type: .open, placement: .open_show)
            }
        } else {
            let interstitialAd = ad as? GADInterstitialAd
            let rewardAd = ad as? GADRewardedAd
            let rewardInterstitialAd = ad as? GADRewardedInterstitialAd
            if let m = self.dataArr.first(where: {$0.type == type}) {
                if let _ = m.item.first(where: {$0.id == interstitialAd?.adUnitID || $0.id == rewardAd?.adUnitID || $0.id == rewardInterstitialAd?.adUnitID}) {
                    self.removeFirstCache(type: m.type)
                    m.adIsLoding = false
                    m.adShowing = false
                    self.setTime(m.type)
                    self.hk_loadFullAd(type: m.type, placement: m.placement)
                }
            }
        }
        if self.tempDismissComplete != nil {
            self.tempDismissComplete!()
        }
    }
    
    func adDidRecordClick(_ ad: GADFullScreenPresentingAd) {
        
        if ad is GADAppOpenAd {
            if self.type == .open {
                self.addClickCount(type: .open)
            }
        } else {
            let interstitialAd = ad as? GADInterstitialAd
            let rewardAd = ad as? GADRewardedAd
            let rewardInterstitialAd = ad as? GADRewardedInterstitialAd
            for (_, mod) in self.dataArr.enumerated() {
                if let _ = mod.item.first(where: {$0.id == interstitialAd?.adUnitID || $0.id == rewardAd?.adUnitID || $0.id == rewardInterstitialAd?.adUnitID}) {
                    self.addClickCount(type: self.type)
                }
            }
        }
    }
}

extension HKADManager: MAAdViewAdDelegate {
    func didExpand(_ ad: MAAd) {
        HKLog.log("[Ad] didExpand")
    }
    
    func didCollapse(_ ad: MAAd) {
        HKLog.log("[Ad] didCollapse")
    }
    
    func didLoad(_ ad: MAAd) {
        HKLog.log("[Ad] didLoad")
        for mod in self.dataArr {
            if let _ = mod.item.first(where: {$0.id == ad.adUnitIdentifier}) {
                HKLog.log("[Ad] 广告加载成功 type: \(mod.type.rawValue) 优先级: \(mod.index + 1), placementid: \(ad.adUnitIdentifier)")
                mod.adIsLoding = false
                if mod.index >= mod.item.count {
                    return
                }
                if let model = mod.item.safe(mod.index) {
                    let cache = HKADCache()
                    cache.id = model.id
                    cache.level = model.level
                    cache.source = model.source
                    cache.type = type
                    cache.ad = mod.ad
                    cache.id_type = model.type
                    self.addCacheWithType(type: type, model: cache)
                }
            }
        }
        self.coolLoadSuccess = true
        if self.openLoadingSuccessComplete != nil {
            self.openLoadingSuccessComplete!()
        }
    }
    
    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        HKLog.log("[Ad] didFailToLoadAd: adUnitIdentifier: \(adUnitIdentifier), error: \(error.mediatedNetworkErrorCode) \(error.message)")
        for mod in self.dataArr {
            if let _ = mod.item.first(where: {$0.id == adUnitIdentifier}) {
                HKLog.log("[Ad] 广告加载失败 type: \(HKADType.play.rawValue) 优先级: \(mod.index + 1), placementid: \(adUnitIdentifier)")
                self.hk_adFail(placement: mod.placement, code: "\(error.code.rawValue)")
                mod.adIsLoding = false
                self.hk_loadFullAd(type: mod.type, index: mod.index + 1, placement: mod.placement)
            }
        }
    }
    
    func didDisplay(_ ad: MAAd) {
        HKLog.log("[Ad] didDisplay")
        for mod in self.dataArr {
            if let _ = mod.item.first(where: {$0.id == ad.adUnitIdentifier}), mod.type == self.type {
                self.addShowCount(type: mod.type)
                mod.adShowing = true
                break
            }
        }
        self.isShowingCoolAd = true
    }
    
    func didHide(_ ad: MAAd) {
        HKLog.log("[Ad] didHide")
        UIApplication.shared.isStatusBarHidden = false
        for (_, mod) in self.dataArr.enumerated() {
            if let _ = mod.item.first(where: {$0.id == ad.adUnitIdentifier}), mod.type == self.type {
                self.removeFirstCache(type: mod.type)
                mod.adIsLoding = false
                mod.adShowing = false
                self.setTime(mod.type)
                self.hk_loadFullAd(type: mod.type, placement: mod.placement)
                break
            }
        }
        if self.tempDismissComplete != nil {
            self.tempDismissComplete!()
        }
    }
    
    func didClick(_ ad: MAAd) {
        HKLog.log("[Ad] didClick")
        for (_, mod) in self.dataArr.enumerated() {
            if let _ = mod.item.first(where: {$0.id == ad.adUnitIdentifier}), mod.type == self.type {
                self.addClickCount(type: self.type)
                break
            }
        }
    }
    
    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        HKLog.log("[Ad] didFailtoDisplay, error: \(error)")
        if error.code.rawValue != -23 {
            for (_, mod) in self.dataArr.enumerated() {
                if let _ = mod.item.first(where: {$0.id == ad.adUnitIdentifier}), mod.type == self.type {
                    mod.adIsLoding = false
                    self.removeFirstCache(type: mod.type)
                    self.hk_loadFullAd(type: mod.type, placement: mod.placement)
                    if self.tempDismissComplete != nil {
                        self.tempDismissComplete!()
                    }
                    break
                }
            }
        }
    }
}

extension HKADManager: MARewardedAdDelegate {
    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        //        HKMethods.rewardGeted()
    }
}

extension HKADManager: MAAdRevenueDelegate {
    func didPayRevenue(for ad: MAAd) {
        HKLog.log("[Ad] didPayRevenue")
        
        let revenue = ad.revenue // In USD
        // Miscellaneous data
        let countryCode = ALSdk.shared()!.configuration.countryCode // "US" for the United States, etc - Note: Do not confuse this with currency code which is "USD" in most cases!
        let networkName = ad.networkName // Display name of the network that showed the ad (e.g. "AdColony")
        let adUnitId = ad.adUnitIdentifier // The MAX Ad Unit ID
        let adFormat = ad.format // The ad format of the ad (e.g. BANNER, MREC, INTERSTITIAL, REWARDED)
        let placement = ad.placement // The placement this ad's postbacks are tied to
        let networkPlacement = ad.networkPlacement // The placement ID from the network that showed the ad
        
        var format = ""
        var placem = ""
        for (_, mod) in self.dataArr.enumerated() {
            if let _ = mod.item.first(where: {$0.id == adUnitId}) {
                format = "INTERSTITIAL"
                if mod.type == .other || mod.type == .play {
                    format = "INTERSTITIAL"
                } else if mod.type == .native {
                    format = "NATIVE"
                }
                placem = mod.type.rawValue
            }
        }
        HKLog.hk_ad_impression_revenue(value: revenue, currency: "USD", adFormat: format, adSource: networkName, adPlatform: "MAX", adUnitName: adUnitId , precision: "", placement: placem)
    }
}

// MARK: - 缓存相关
extension HKADManager {
    /// 更新缓存 缓存时长3000s
    func refreshAdCache() {
        let now = Date().timeIntervalSince1970
        self.cacheArr.forEach { m in
            m.cache = m.cache.filter({
                if $0.id_type == .open {
                    now - $0.time < 14000
                } else {
                    now - $0.time < 3000
                }
            })
        }
    }
    /// 获取缓存数组
    func getCacheWithType(type: HKADType) -> [HKADCache]? {
        if let m = self.cacheArr.first(where: {$0.type == type}) {
            return m.cache
        }
        return nil
    }
    /// 加入缓存
    func addCacheWithType(type: HKADType, model: HKADCache) {
        if let m = self.cacheArr.first(where: {$0.type == type}) {
            m.cache.append(model)
            m.cache = m.cache.sorted(by: {$0.level > $1.level})
        } else {
            let m = adCacheModel()
            m.cache.append(model)
            m.type = type
            self.cacheArr.append(m)
        }
    }
    /// 清除单个缓存
    func removeFirstCache(type: HKADType) {
        if let m = self.cacheArr.first(where: {$0.type == type}) {
            m.cache.removeAll()
            if let mod = self.dataArr.first(where: {$0.type == type}) {
                mod.index = 0
            }
        }
    }
    /// 清除全部缓存
    func removeAllCache() {
        self.cacheArr.removeAll()
    }
}
// MARK: - 展示及点击次数相关
extension HKADManager {
    /// 是否可显示广告
    func canShowAd() -> Bool {
        self.setupAdmobCounts()
        if adCounts!.totalShowCount >= hkAdInfo.hk_totalShowCount {
            HKLog.log("[AD] total 展示次数上限")
        }
        
        return adCounts!.totalShowCount < hkAdInfo.hk_totalShowCount
    }
    /// 显示次数增加
    func addShowCount(type: HKADType) {
        setupAdmobCounts()
        guard var counts = adCounts else { return }
        counts.totalShowCount += 1
        adCounts = counts
        do {
            let data = try JSONEncoder().encode(counts)
            UserDefaults.standard.setValue(data, forKey: String(describing: HKADCounts.self))
            HKLog.log("[AD] 广告展示 \(counts.totalShowCount) 次")
        } catch let e {
            HKLog.log("[AD] 广告统计失败 \(e.localizedDescription)")
        }
    }
    /// 点击次数增加
    func addClickCount(type: HKADType?) {
        setupAdmobCounts()
        guard var counts = adCounts else { return }
        counts.totalClickCount += 1
        adCounts = counts
        do {
            let data = try JSONEncoder().encode(counts)
            UserDefaults.standard.setValue(data, forKey: String(describing: HKADCounts.self))
            HKLog.log("[AD] 广告点击 \(counts.totalClickCount) 次")
        } catch let e {
            HKLog.log("[AD] 广告统计失败 \(e.localizedDescription)")
        }
    }
    /// 次数更新
    func setupAdmobCounts() {
        if adCounts != nil {
            if Date().timeIntervalSince1970 - adCounts!.time > 24 * 60 * 60 {
                UserDefaults.standard.removeObject(forKey: String(describing: HKADCounts.self))
                adCounts = nil
                setupAdmobCounts()
            }
            return
        }
        if let countData = UserDefaults.standard.value(forKey: String(describing: HKADCounts.self)) as? Data,
           let counts = try? JSONDecoder().decode(HKADCounts.self, from: countData) {
            if Date().timeIntervalSince1970 - counts.time > 24 * 60 * 60 {
                UserDefaults.standard.removeObject(forKey: String(describing: HKADCounts.self))
                setupAdmobCounts()
                return
            }
            adCounts = counts
        } else {
            let adCount = HKADCounts()
            do {
                let data = try JSONEncoder().encode(adCount)
                UserDefaults.standard.setValue(data, forKey: String(describing: HKADCounts.self))
                adCounts = adCount
            } catch let e {
                HKLog.log("[AD] 加载广告统计失败 \(e.localizedDescription)")
            }
        }
    }
    
    fileprivate func setTime(_ type: HKADType) {
        switch type {
        case .open:
            self.openTime = Date().timeIntervalSince1970
        case .other:
            self.otherTime = Date().timeIntervalSince1970
        case .play:
            self.playTime = Date().timeIntervalSince1970
        case .off:
            self.offlineTime = Date().timeIntervalSince1970
        case .high:
            self.playTime = Date().timeIntervalSince1970
            self.otherTime = Date().timeIntervalSince1970
        case .native:
            break
        }
    }
}

struct HKADCounts: Codable {
    var time = Date().timeIntervalSince1970
    var totalShowCount: Int = 0
    var totalClickCount: Int = 0
}

class adItemModel: BaseModel {
    var item: HKADItem = HKADItem()
}

class adCacheModel: BaseModel {
    var cache: [HKADCache] = []
    var type: HKADType = .native
}

class adInfoListModel: BaseModel {
    var item: [HKADItem] = []
    var type: HKADType = .native
    var adIsLoding = false
    var index = 0
    var ad: NSObject?
    var adShowing = false
    var placement: HKADLogENUM = .none
    var tradAd: NSObject?
    var loader: MANativeAdLoader?
    var canShow = true
    var maxAd: MAAd?
    var adView: MANativeAdView!
}
