//
//  VideoViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/3.
//

import UIKit
import AVKit

class VideoViewController: BaseViewController {

    var urlString: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        let player = AVPlayer(url: NSURL(string: urlString)! as URL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.player?.play()
        //添加view播放的模式
        let rect = CGRect(x: 0, y: kNavBarHeight, width: kScreenWidth, height: kScreenHeight - kNavBarHeight)
        playerViewController.view.frame = rect
        self.addChild(playerViewController)
        self.view.addSubview(playerViewController.view)
    }
}
