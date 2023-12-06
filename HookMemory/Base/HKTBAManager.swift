//
//  HKTBAManager.swift
//  HookMemory
//
//  Created by HF on 2023/12/1.
//

import UIKit
import Network
import AdSupport
import CoreTelephony


enum HKTBAType {
    case install, session, ad, event
}

class HKTBAManager: NSObject {
    
    static let share = HKTBAManager()
    
    #if DEBUG
    var host = "https://test-synergy.haxen24.com/jut/minor/juniper"
    #else
    var host = "https://synergy.haxen24.com/encroach/impact/frigga"
    #endif
    
    static let SAFEBUNDLEID = "com.haxenplatform.live"
    
    var ip: String = UserDefaults.standard.value(forKey: HKCommon.last_ip) as? String ?? "" {
        didSet {
            UserDefaults.standard.set(ip, forKey: HKCommon.last_ip)
        }
    }
    var country_code: String = Locale.current.regionCode ?? "ZZ" {
        didSet {
            if country_code != oldValue {
//                WZMediaListManager.standard.addHomeArtists()
            }
        }
    }
    var ip_country_code: String = UserDefaults.standard.value(forKey: HKCommon.last_ip_country_code) as? String ?? "" {
        didSet {
            UserDefaults.standard.set(ip_country_code, forKey: HKCommon.last_ip_country_code)
        }
    }
    var region_code: String = Locale.current.regionCode ?? "ZZ"
    var ipCount: Int = 0
    var cloakCount: Int = 0
    
    var ipComplete: ((_ isSuccess: Bool) -> Void)?
    
    var timeZone: Int = NSTimeZone.system.secondsFromGMT() / 3600
    
    var cacheTimer: DispatchSourceTimer?
    
    var adSubParam: [String: Any] = [:]
    var eventParam: [String: Any] = [:]
    
    var tbaLogs: [[String: Any]] = UserDefaults.standard.value(forKey: HKCommon.tbaLogs) == nil ? [] : UserDefaults.standard.value(forKey: HKCommon.tbaLogs) as! [[String: Any]] {
        didSet {
            UserDefaults.standard.set(tbaLogs, forKey: HKCommon.tbaLogs)
            HKLog.log("HKCommon.tbaLogs: \(tbaLogs.count) \(tbaLogs)")
        }
    }
    
    var task: URLSessionDataTask?
    
    func preSet() {
        cacheTimer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        cacheTimer?.setEventHandler(handler: { [weak self] in
            self?.tbaNeedRequest()
        })
        cacheTimer?.schedule(deadline: .now() + 10, repeating: 10)
        cacheTimer?.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if !UserDefaults.standard.bool(forKey: HKCommon.tbaInstall) {
                self.setHktbaParams(type: .install)
                UserDefaults.standard.set(true, forKey: HKCommon.tbaInstall)
            }
        }
        
    }
    
    func tbaNeedRequest() {
        if self.tbaLogs.count > 0 {
            self.tbaRequest()
        }
    }
    
    func tbaRequest() {
        
        if self.task != nil {
            return
        }
        
        let tempTbaLogs = self.tbaLogs
        let urlString = "\(self.host)?bayonet=\(HKConfig.share.netStatus)&fin=\(UIDevice.current.systemVersion)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! // bundle_id  idfa  brand
        
        var request: URLRequest = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(HKConfig.idfv, forHTTPHeaderField: "sneaky") // idfv
        request.setValue(String(Int(Date().timeIntervalSince1970 * 1000)), forHTTPHeaderField: "virus") // client_ts
        request.setValue("", forHTTPHeaderField: "louvre") // channel
        
        if let data = try? JSONSerialization.data(withJSONObject: tempTbaLogs, options: []) {
            request.httpBody = data
        }
        
        request.timeoutInterval = 10
        let configuration: URLSessionConfiguration = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: configuration)
        self.task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            guard error == nil else {
                HKLog.log("TBA error: \(error?.localizedDescription ?? "")")
                self.task = nil
                return
            }
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                HKLog.log("TBA data: \(dataString)")
            }
            if let res = response as? HTTPURLResponse, res.statusCode == 200 {
                HKLog.log("TBA success!")

                for item in tempTbaLogs {
                    if let index = self.tbaLogs.firstIndex(where: { ($0["kinetic"] as? String) == (item["kinetic"] as? String) }) {
                        self.tbaLogs.remove(at: index)
                    }
                }
            } else {
                HKLog.log("TBA fail!")
            }
            self.task = nil
            
        })
        self.task?.resume()
    }
    
    func getTabParameters(type: HKTBAType) -> [String: Any] {
        var paras: [String: Any] = [
            "able": HKConfig.app_version, // 应用的版本
            "sole": Int(Date().timeIntervalSince1970 * 1000), // 日志发生的客户端时间，毫秒数
            "figure": "\(Locale.current.languageCode ?? "zh")_\(Locale.current.regionCode ?? "CN")", // String locale = Locale.getDefault(); 拼接为：zh_CN的形式，下杠
            "shebang": UIDevice.current.systemVersion, // 操作系统版本号
//            "bayonet": MTNetworkManager.standerd.currentTypeString, // 网络类型：wifi，3g等，非必须，和产品确认是否需要分析网络类型相关的信息，此参数可能需要系统权限
            "kosher": Locale.current.regionCode ?? "ZZ", // 操作系统中的国家简写，例如 CN，US等
            "agave": "Apple", // 收集厂商，hauwei、opple
            "ashram": HKTBAManager.SAFEBUNDLEID, // 当前的包名称，a.b.c
            "editor": "", // 没有开启google广告服务的设备获取不到，但是必须要尝试获取，用于归因，原值，google广告id
            "itll": HKConfig.share.getDistinctId(), // 用户排重字段，统计涉及到的排重用户数就是依据该字段，对接时需要和产品确认
            "sneaky": HKConfig.idfv, // ios的idfv原值
            "hobo": HKConfig.idfa, // idfa 原值（iOS）
            "remorse": self.ip, // 客户端IP地址，获取的结果需要判断是否为合法的ip地址！！
            "mongolia": "Apple", // 品牌
//            "isis": "\(kScreenWidth)*\(kScreenHeight)", // 屏幕分辨率：宽*高， 例如：380*640
            "chair": UIDevice.current.modelName, // 手机型号
            "pershing": UUID().uuidString, // 日志唯一id，用于排重日志
            "lace": self.getCarrierName(), // 网络供应商名称
//            "uniplex": UUID().uuidString, // 随机生成的uuid
            "sen": self.timeZone, // 客户端时区
            "allegate": "lopez" // 操作系统；映射关系：{“cabinet”: “android”, “lopez”: “ios”, “frontier”: “web”}
        ]
        switch type {
        case .install:
            let subparas: [String: Any] = [
                "nuptial": "build/\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? "1")", // 系统构建版本，Build.ID， 以 build/ 开头
                "exclude": "segment", // 用户是否启用了限制跟踪，0：没有限制，1：限制了；映射关系：{“segment”: 0, “hang”: 1}
                "megaword": "", // referrer_url
                "charm": "",
                "non": "", // webview中的user_agent, 注意为webview的，android中的useragent有;wv关键字
                "arise": 0,
                "english": 0,
                "ember": 0,
                "helmsmen": 0,
                "sprung": 0,
                "clayton": 0,
                "skiff": false
            ]
            paras["encomia"] = subparas
        case .session:
            paras["healthy"] = "prentice"
        case .ad:
            paras["dual"] = self.adSubParam
        case .event:
            if let borne = self.eventParam["healthy"] as? String {
                paras["healthy"] = borne
                var eventMap: [String: Any] = [:]
                for item in self.eventParam.keys.filter({ $0 != "healthy" }) {
                    eventMap[item] = self.eventParam[item]
                }
                paras[borne] = eventMap
            }
        }
        HKLog.log("[REQUEST] paras: \(paras)")
        return paras
    }
    
    func setAdSubParas(capstan: Int64, anew: String, bright: String, avocate: String, smear: String, thruway: String, amnesia: String = "", penitent: String = "", drowsy: String, trefoil: String = "0") {
        self.adSubParam = [
            "impeller": capstan, // 预估收益, admob取出来的值可以直接使用（x/10^6）=> 美元， Max的值为美元, 需要 * 10^6在上报
            "boon": anew, // 预估收益的货币单位
            "stampede": bright, // 广告网络，广告真实的填充平台，例如admob的bidding，填充了Facebook的广告，此值为Facebook
            "theseus": avocate, // 广告SDK，admob，max等
            "decca": smear, // 广告位id，例如：ca-app-pub-7068043263440714/75724612
            "host": thruway, // 广告位逻辑编号，例如：page1_bottom, connect_finished
            "loch": amnesia, // 真实广告网络返回的广告id，海外获取不到，不传递该字段
            "gruff": penitent, // 广告场景，置空
            "homonym": drowsy, // 广告类型，插屏，原生，banner，激励视频等
            "salem": trefoil, // google ltvpingback的预估收益类型
            "grill": self.ip, // 广告加载时候的ip地址
            "helmsman": self.ip // 广告显示时候的ip地址
        ]
    }
    
    func setHktbaParams(type: HKTBAType) {
        var tbas = self.tbaLogs
        tbas.append(self.getTabParameters(type: type))
        self.tbaLogs = tbas
        self.tbaRequest()
    }

    func getCarrierName() -> String {
        var name = ""
        let info = CTTelephonyNetworkInfo()
        if let carrierArr = info.serviceSubscriberCellularProviders {
            let values = carrierArr.values
            if let firstName = values.first {
                name = firstName.carrierName ?? ""
            }
        }
        
        return name
    }
    
    func getIp() {
        if let url = "https://api.myip.com/".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
//            WZToast.alert(title: "ip请求开始", text: "时间: \(Date())")
            let startDate = Date().timeIntervalSince1970
            let request: URLRequest = URLRequest(url: URL(string: url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
            let configuration: URLSessionConfiguration = URLSessionConfiguration.default
            let session: URLSession = URLSession(configuration: configuration)

            let task = session.dataTask(with: request) { data, response, error in

                guard error == nil else {
                    self.getIp2()
                    return
                }

                if let res = response as? HTTPURLResponse, res.statusCode == 200, let data = data {
                    if let dataString = String(data: data, encoding: .utf8), dataString.count > 0 {
                        if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            if let ip = dict["ip"] as? String {
                                self.ip = ip
                            }
                            if let country_code = dict["cc"] as? String {
                                self.country_code = country_code
                                self.ip_country_code = country_code
                            }
                            HKLog.log("[REQUEST] ip: \(self.ip)")
//                            WZToast.alert(title: "ip请求结束", text: "时间: \(Date())")
//                            HKLog.get_ip("\(ceil(Date().timeIntervalSince1970) - startDate)")
                            if self.ipComplete != nil {
                                self.ipComplete!(true)
                            }
//                            NotificationCenter.default.post(name: .TBA.ipget, object: nil)
                        } else {
                            self.getIp2()
                        }
                    } else {
                        self.getIp2()
                    }
                } else {
                    self.getIp2()
                }
            }
            task.resume()

        }

    }

    func getIp2() {
        if let url = "https://ip.seeip.org/geoip/".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            let startDate = Date().timeIntervalSince1970
            let request: URLRequest = URLRequest(url: URL(string: url)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
            let configuration: URLSessionConfiguration = URLSessionConfiguration.default
            let session: URLSession = URLSession(configuration: configuration)

            let task = session.dataTask(with: request) { data, response, error in

                guard error == nil else {
                    self.ipFail(count: self.ipCount)
                    return
                }

                if let res = response as? HTTPURLResponse, res.statusCode == 200, let data = data {
                    if let dataString = String(data: data, encoding: .utf8), dataString.count > 0 {
                        if let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            if let ip = dict["ip"] as? String {
                                self.ip = ip
                            }
                            if let country_code = dict["country_code"] as? String {
                                self.country_code = country_code
                                self.ip_country_code = country_code
                            }
                            HKLog.log("[REQUEST] ip: \(self.ip)")
                            if self.ipComplete != nil {
                                self.ipComplete!(true)
                            }
                        } else {
                            self.ipFail(count: self.ipCount)
                        }
                    } else {
                        self.ipFail(count: self.ipCount)
                    }
                } else {
                    self.ipFail(count: self.ipCount)
                }
            }
            task.resume()
        }

    }

    func ipFail(count: Int) {
        HKLog.log("[REQUEST] ipFail")
        if count == 0 {
            self.ipCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.getIp()
            }
        } else {
            if self.ipComplete != nil {
                self.ipComplete!(false)
            }
        }
    }
}


