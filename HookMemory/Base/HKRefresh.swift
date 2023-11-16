//
//  HKRefresh.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import Foundation
import MJRefresh
import Lottie

class RefreshGifHeader: MJRefreshGifHeader{
    override func prepare() {
        super.prepare()
        self.gifView?.isHidden = true
        let animation = LottieAnimationView(name: "loading")
        let view = UIView(frame: CGRect(x: (kScreenWidth - 60) * 0.5, y: 10, width: 60, height: 60))
        animation.frame = view.bounds
        animation.loopMode = .loop
        animation.play()
        view.addSubview(animation)
        self.addSubview(view)
        self.mj_h = 80
        self.stateLabel?.isHidden = true
        self.lastUpdatedTimeLabel?.isHidden = true
    }
}

class RefreshFilterGifHeader: MJRefreshGifHeader{
    override func prepare() {
        super.prepare()
        self.gifView?.isHidden = true
        let animation = LottieAnimationView(name: "loading")
        let view = UIView(frame: CGRect(x: (kScreenWidth - 60) * 0.5, y: -202, width: 60, height: 60))
        animation.frame = view.bounds
        animation.loopMode = .loop
        animation.play()
        view.addSubview(animation)
        self.addSubview(view)
        self.mj_h = 80
        self.stateLabel?.isHidden = true
        self.lastUpdatedTimeLabel?.isHidden = true
    }
}

class RefreshAutoNormalFooter: MJRefreshAutoStateFooter {

    override func prepare() {
        super.prepare()
        self.mj_h = 65
        self.stateLabel?.font = UIFont.systemFont(ofSize: 12)
        self.stateLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.setTitle("", for: .idle)
        self.setTitle("", for: .refreshing)
        self.setTitle("No more content", for: .noMoreData)
    }

}

class RefreshNormalHeader: MJRefreshNormalHeader {
    override func prepare() {
        super.prepare()
        self.mj_h = 50
        self.stateLabel?.font = UIFont.systemFont(ofSize: 12)
        self.stateLabel?.textColor = #colorLiteral(red: 0.6784313725, green: 0.6941176471, blue: 0.7254901961, alpha: 1)
        self.lastUpdatedTimeLabel?.isHidden = true
        self.setTitle("下拉即可刷新", for: .idle)
        self.setTitle("松开立即刷新", for: .pulling)
        self.setTitle("数据加载中", for: .refreshing)
    }
}
