//
//  HKPlayerLoadingView.swift
//  HookMemory
//
//  Created by HF on 2023/11/28.
//

import UIKit
import Lottie

class HKPlayerLoadingView: UIView {
    
    @IBOutlet weak var lottieView: UIView!
    var animationV: LottieAnimationView?
    
    class func view() -> HKPlayerLoadingView {
        let view = Bundle.main.loadNibNamed(String(describing: HKPlayerLoadingView.self), owner: nil)?.first as! HKPlayerLoadingView
//        view.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        view.addAnimotion()
        return view
    }
    
    func addAnimotion() {
        animationV = LottieAnimationView(name: "playLoading")
        animationV?.isHidden = true
        lottieView.addSubview(animationV!)
        animationV?.snp.makeConstraints({make in
            make.edges.equalToSuperview()
        })
    }
    
    /// 选中lottie动画
    func showAnimation(progress: CGFloat = 0) {
        animationV?.isHidden = false
        animationV?.currentProgress = progress
        animationV?.isHidden = false
        animationV?.play(fromProgress: progress, toProgress: 1 - progress, loopMode: .loop, completion: {(state) in
        })
    }
    
    /// 结束lottie动画
    func dismissAnimation() {
        animationV?.currentProgress = 0
        animationV?.stop()
        animationV?.isHidden = true
    }
}
