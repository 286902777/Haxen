//
//  HKPlayerManager.swift
//  HookMemory
//
//  Created by HF on 2023/11/17.
//

import UIKit


enum HKPlayerTopBarCase: Int {
    case always         = 0 /// 始终显示
    case horizantal     = 1 /// 只在横屏界面显示
    case none           = 2 /// 不显示
}

enum HKPlayerFrom: Int {
    case net = 0
    case search
    case player 
}

class HKPlayerManager {
    static let share = HKPlayerManager()
        
    var language: String = ""
    /// tint color
    var tintColor = UIColor.white
    
    var isLock: Bool = false
    /// auto play
    var autoPlay = true
    
    var topBarInCase = HKPlayerTopBarCase.always
    
    var animateDelayInterval = TimeInterval(3)
    
    var subtitleOn = true
    /// should show log
    var allowLog  = false
    
    /// use gestures to set brightness, volume and play position
    var enableBrightnessGestures = true
    var enableVolumeGestures = true
    var enablePlaytimeGestures = true
    var enableChooseDefinition = false
    var enablePlayControlGestures = true
    
    func getLanguage() -> String {
        if self.language.isEmpty {
            if let lang = NSLocale.preferredLanguages.first?.components(separatedBy: "-").first {
                return lang
            } else {
                return "en"
            }
        } else {
            return self.language
        }
    }
    func gotoPlayer(controller: UIViewController, id: String, from: HKPlayerFrom) {
        if HKConfig.share.isNet == false {
            ProgressHUD.showError("No network!")
            return
        }
        if let model = DBManager.share.selectVideoData(id: id) {
            if model.isMovie {
                let vc = MoviePlayViewController(model: model, from: from)
                vc.hidesBottomBarWhenPushed = true
                controller.navigationController?.pushViewController(vc, animated: true)
            } else {
                if model.ssn_id.count == 0, model.eps_id.count == 0 {
                    MovieAPI.share.movieTVSeason(id: model.id) { success, list in
                        if success, let m = list.last, let mod = m {
                            MovieAPI.share.movieTVSSN(ssn_id: mod.id, id: model.id) { success, ssnMod in
                                if let ssnM = ssnMod.eps_list.first {
                                    DispatchQueue.main.async {
                                        let videoModel = MovieVideoModel()
                                        videoModel.id = model.id
                                        videoModel.title = model.title
                                        videoModel.coverImageUrl = model.coverImageUrl
                                        videoModel.rate = model.rate
                                        videoModel.ssn_eps = model.ssn_eps
                                        videoModel.country = model.country
                                        videoModel.ssn_id = mod.id
                                        videoModel.ssn_name = mod.title
                                        videoModel.eps_id = ssnM.id
                                        videoModel.eps_num = ssnM.eps_num
                                        videoModel.eps_name = ssnM.title
                                        videoModel.isMovie = false
                                        let vc = MoviePlayViewController(model: videoModel, from: from)
                                        DBManager.share.updateVideoData(videoModel)
                                        vc.hidesBottomBarWhenPushed = true
                                        controller.navigationController?.pushViewController(vc, animated: true)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    let vc = MoviePlayViewController(model: model, from: from)
                    vc.hidesBottomBarWhenPushed = true
                    controller.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }    
}
