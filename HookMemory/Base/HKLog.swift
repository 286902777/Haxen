//
//  HKLog.swift
//  HookMemory
//
//  Created by HF on 2023/12/1.
//

import Foundation
import FirebaseAnalytics

class HKLog: NSObject {
    /// debug 打印
    class func log(_ items: String) {
        #if DEBUG
            print(items)
        #endif
    }
}

extension HKLog {
    class func logEvent(_ name: String, parameters: [String: Any]?) {
        #if DEBUG

        #else
        Analytics.logEvent(name, parameters: parameters)
        #endif
        
        var eventParam: [String: Any] = ["healthy": name]
        if let parameters = parameters {
            for item in parameters.keys {
                eventParam[item] = parameters[item]
            }
        }
        HKTBAManager.share.eventParam = eventParam
        HKTBAManager.share.setHktbaParams(type: .event)
    }
 
    class func hk_home_sh(loadsuccess: String, errorinfo: String, show: String = "0") {
        HKLog.log("[LOG]: 电影首页展示 拉取内容时上报一次即可，不用每次展示都上报 home_sh loadsuccess: \(loadsuccess), errorinfo: \(errorinfo)")
        HKLog.logEvent("home_sh", parameters: ["loadsuccess": loadsuccess, "errorinfo": errorinfo, "show": show])
    }
    
    class func hk_home_cl(kid: String, c_id: String, c_name: String, ctype: String, secname: String, secid: String) {
        HKLog.log("[LOG]: 电影首页点击 home_cl kid: \(kid), c_id: \(c_id), c_name: \(c_name), ctype: \(ctype), secname: \(secname), secid: \(secid)")
        HKLog.logEvent("home_cl", parameters: ["kid": kid, "c_id": c_id, "c_name": c_name, "ctype": ctype, "secname": secname, "secid": secid])
    }
    
    class func hk_explore_sh(loadsuccess: String, errorinfo: String, show: String = "0") {
        HKLog.log("[LOG]: tab_电影展示 tab_movie_sh loadsuccess: \(loadsuccess), errorinfo: \(errorinfo), show: \(show)")
        HKLog.logEvent("explore_sh", parameters: ["loadsuccess": loadsuccess, "errorinfo": errorinfo, "show": show])
    }
    
    class func hk_explore_cl(kid: String) {
        HKLog.log("[LOG]: tab_电影点击 tab_movie_cl kid: \(kid)")
        HKLog.logEvent("explore_cl", parameters: ["kid": kid])
    }
    
    class func tab_tv_sh(loadsuccess: String, errorinfo: String) {
        HKLog.log("[LOG]: tab_电视剧展示 tab_tv_sh loadsuccess: \(loadsuccess), errorinfo: \(errorinfo)")
        HKLog.logEvent("tab_tv_sh", parameters: ["loadsuccess": loadsuccess, "errorinfo": errorinfo])
    }
    
    class func tab_tv_cl(kid: String) {
        HKLog.log("[LOG]: tab_电视剧点击 tab_tv_cl kid: \(kid)")
        HKLog.logEvent("tab_tv_cl", parameters: ["kid": kid])
    }
    
    class func hk_search_result_sh(keyword: String, errorinf: String, source: String) {
        HKLog.log("[LOG]: 搜索结果页展示 search_result_sh keyword: \(keyword), errorinf: \(errorinf), source: \(source)")
        HKLog.logEvent("search_result_sh", parameters: ["keyword": keyword, "errorinf": errorinf, "source": source])
    }
    
    class func hk_movie_play_sh(movie_id: String, movie_name: String, eps_id: String, eps_name: String, source: String, movie_type: String) {
        HKLog.log("[LOG]: 播放页展示 movie_play_sh movie_id: \(movie_id), movie_name: \(movie_name), eps_id: \(eps_id), eps_name: \(eps_name), source: \(source), movie_type: \(movie_type)")
        HKLog.logEvent("movie_play_sh", parameters: ["movie_id": movie_id, "movie_name": movie_name, "eps_id": eps_id, "eps_name": eps_name, "source": source, "movie_type": movie_type])
    }
    
    class func hk_movie_play_cl(kid: String, movie_id: String, movie_name: String, eps_id: String, eps_name: String) {
        HKLog.log("[LOG]: 播放页点击 movie_play_cl kid: \(kid), movie_id: \(movie_id), movie_name: \(movie_name), eps_id: \(eps_id), eps_name: \(eps_name)")
        HKLog.logEvent("movie_play_cl", parameters: ["kid": kid, "movie_id": movie_id, "movie_name": movie_name, "eps_id": eps_id, "eps_name": eps_name])
    }
    
    class func hk_movie_play_len(movie_id: String, movie_name: String, eps_id: String, eps_name: String, movie_type: String, watch_len: String, source: String, if_success: String) {
        HKLog.log("[LOG]: 播放页停留时长 movie_play_len movie_id: \(movie_id), movie_name: \(movie_name), eps_id: \(eps_id), eps_name: \(eps_name), movie_type: \(movie_type), watch_len: \(watch_len), source: \(source), if_success: \(if_success)")
        HKLog.logEvent("movie_play_len", parameters: ["movie_id": movie_id, "movie_name": movie_name, "eps_id": eps_id, "eps_name": eps_name, "movie_type": movie_type, "watch_len": watch_len, "source": source, "if_success": if_success])
    }
    
    class func hk_playback_status(movie_id: String, movie_name: String, eps_id: String, eps_name: String, movie_type: String, cache_len: String, source: String, if_success: String, errorinfo: String) {
        HKLog.log("[LOG]: 播放状态 playback_status movie_id: \(movie_id), movie_name: \(movie_name), eps_id: \(eps_id), eps_name: \(eps_name), movie_type: \(movie_type), watch_len: \(cache_len), source: \(source), if_success: \(if_success), errorinfo: \(errorinfo)")
        HKLog.logEvent("playback_status", parameters: ["movie_id": movie_id, "movie_name": movie_name, "eps_id": eps_id, "eps_name": eps_name, "movie_type": movie_type, "cache_len": cache_len, "source": source, "if_success": if_success, "errorinfo": errorinfo])
    }
    
    class func hk_vip_sh(source: String) {
        HKLog.log("[LOG]: 订阅页展示 vip_sh source: \(source)")
        HKLog.logEvent("vip_sh", parameters: ["source": source])
    }
    
    class func hk_vip_cl(kid: String, type: String, source: String) {
        HKLog.log("[LOG]: 订阅页点击 vip_cl kid: \(kid), hk_type: \(type), source: \(source)")
        HKLog.logEvent("vip_cl", parameters: ["kid": kid, "hk_type": type, "source": source])
    }
    
    class func hk_subscribe_status(status: String, source: String, pay_time: String) {
        HKLog.log("[LOG]: 订阅状态 subscribe_status status: \(status), source: \(source), pay_time: \(pay_time)")
        HKLog.logEvent("subscribe_status", parameters: ["status": status, "source": source, "pay_time": pay_time])
    }
    
}

extension HKLog {
    class func hk_ad_impression_revenue(value: Double, currency: String, adFormat: String, adSource: String, adPlatform: String, adUnitName: String, precision: String, placement: String) {
        
        HKLog.log("[LOG]: revenue value: \(value), currency: \(currency), adFormat: \(adFormat), adSource: \(adSource), adPlatform: \(adPlatform), adUnitName: \(adUnitName), precision: \(precision), placement: \(placement)")
        
        HKTBAManager.share.setAdSubParas(capstan: Int64(value * 1000000), anew: currency, bright: adSource, avocate: adPlatform, smear: adUnitName, thruway: placement, drowsy: adFormat, trefoil: precision)
        HKTBAManager.share.setHktbaParams(type: .ad)

        /// 上报firebase
        HKLog.logEvent(
                        "Ad_impression_revenue",
                        parameters: [
                          AnalyticsParameterAdPlatform: adPlatform,
                          AnalyticsParameterAdSource: adSource,
                          AnalyticsParameterAdFormat: adFormat,
                          AnalyticsParameterAdUnitName: adUnitName,
                          AnalyticsParameterCurrency: currency,
                          AnalyticsParameterValue: value
                        ])
    }
}
