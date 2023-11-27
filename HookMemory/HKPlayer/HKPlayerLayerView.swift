//
//  HKPlayerLayerView.swift
//  HookMemory
//
//  Created by HF on 2023/11/17.
//

import UIKit
import AVFoundation

enum HKPlayerState: Int {
    case noURL = 0
    case ready
    case waiting
    case finished
    case end
    case error
}

enum HKPlayerAspectRatio : Int {
    case normal    = 0
    case sixteen // 16: 9
    case four    // 4 : 3
}

protocol HKPlayerLayerViewDelegate : AnyObject {
    func player(player: HKPlayerLayerView, playerStateDidChange state: HKPlayerState)
    func player(player: HKPlayerLayerView, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval)
    func player(player: HKPlayerLayerView, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval)
    func player(player: HKPlayerLayerView, playerIsPlaying playing: Bool)
}

class HKPlayerLayerView: UIView {
   
    weak var delegate: HKPlayerLayerViewDelegate?
   
   /// 视频跳转秒数置0
    var seekTime = 0
   
   /// 播放属性
    var playerItem: AVPlayerItem? {
       didSet {
           playerItemChange()
       }
   }
   
   /// 播放属性
    lazy var player: AVPlayer? = {
       if let item = self.playerItem {
           let player = AVPlayer(playerItem: item)
           return player
       }
       return nil
   }()
   
   
    var videoGravity = AVLayerVideoGravity.resizeAspect {
       didSet {
           self.playerLayer?.videoGravity = videoGravity
       }
   }
   
    var isPlaying: Bool = false {
       didSet {
           if oldValue != isPlaying {
               delegate?.player(player: self, playerIsPlaying: isPlaying)
           }
       }
   }
   
   var aspectRatio: HKPlayerAspectRatio = .normal {
       didSet {
           self.setNeedsLayout()
       }
   }
   
   /// 计时器
   var timer: Timer?
   
   fileprivate var urlAsset: AVURLAsset?
   
   fileprivate var lastPlayerItem: AVPlayerItem?
   /// playerLayer
   var playerLayer: AVPlayerLayer?

   /// 播放器的几种状态
   fileprivate var state = HKPlayerState.noURL {
       didSet {
           if state != oldValue {
             delegate?.player(player: self, playerStateDidChange: state)
           }
       }
   }

   /// 是否点了重播
   fileprivate var repeatToPlay  = false
   /// 播放完了
   fileprivate var playEnd    = false

   fileprivate var isBuffering     = false
   fileprivate var hasReadyToPlay  = false
   fileprivate var seekTo: TimeInterval = 0
   
   var currentTime: Float64 = 0
   
   // MARK: - Actions
    func playURL(url: URL) {
       let asset = AVURLAsset(url: url)
       playAsset(asset: asset)
   }
   
    func playAsset(asset: AVURLAsset) {
       urlAsset = asset
       setVideoAsset()
       play()
   }
   
   
    func play() {
       if let player = player {
           player.play()
           setupTimer()
           isPlaying = true
       }
   }
   
    func pause() {
       player?.pause()
       isPlaying = false
       timer?.fireDate = Date.distantFuture
   }
   
   deinit {
     NotificationCenter.default.removeObserver(self)
   }
   
   
   // MARK: - layoutSubviews
   override func layoutSubviews() {
       super.layoutSubviews()
       switch self.aspectRatio {
       case .normal:
           self.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspect
           self.playerLayer?.frame  = self.bounds
           break
       case .sixteen:
           self.playerLayer?.videoGravity = AVLayerVideoGravity.resize
           self.playerLayer?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.width/(16/9))
           break
       case .four:
           self.playerLayer?.videoGravity = AVLayerVideoGravity.resize
           let width = self.bounds.height * 4 / 3
           self.playerLayer?.frame = CGRect(x: (self.bounds.width - width )/2, y: 0, width: width, height: self.bounds.height)
           break
       }
   }
   
    func resetPlayer() {
       // 初始化状态变量
   
     self.playEnd = false
     self.playerItem = nil
     self.lastPlayerItem = nil
     self.seekTime   = 0
     
     self.timer?.invalidate()
     
     self.pause()
     // 移除原来的layer
     self.playerLayer?.removeFromSuperlayer()
     // 替换PlayerItem为nil
     self.player?.replaceCurrentItem(with: nil)
     player?.removeObserver(self, forKeyPath: "rate")
     
     // 把player置为nil
     self.player = nil
   }
   
    func prepareToDeinit() {
       self.resetPlayer()
   }
   
    func setTimeSliderBegan() {
       if self.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
           self.timer?.fireDate = Date.distantFuture
       }
   }
   
    func seek(to secounds: TimeInterval, completion:(()->Void)?) {
       if secounds.isNaN {
           return
       }
       if self.player?.currentItem?.status == AVPlayerItem.Status.readyToPlay {
           let draggedTime = CMTime(value: Int64(secounds), timescale: 1)
           self.player!.seek(to: draggedTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { (finished) in
               completion?()
           })
       } else {
           self.seekTo = secounds
       }
       setupTimer()
   }
   
   
   // MARK: - 设置视频URL
   fileprivate func setVideoAsset() {
       repeatToPlay = false
       playEnd   = false
       configPlayer()
   }
   
   fileprivate func playerItemChange() {
       if lastPlayerItem == playerItem {
           return
       }
       
       if let item = lastPlayerItem {
           NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item)
           // 添加打断播放通知
           NotificationCenter.default.addObserver(self, selector: #selector(interruptionComing(notification:)), name: AVAudioSession.interruptionNotification, object: nil)
           // 添加插拔耳机通知
           NotificationCenter.default.addObserver(self, selector: #selector(routeChanged(notification:)), name: AVAudioSession.routeChangeNotification, object: nil)
           item.removeObserver(self, forKeyPath: "status")
           item.removeObserver(self, forKeyPath: "loadedTimeRanges")
           item.removeObserver(self, forKeyPath: "playbackBufferEmpty")
           item.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
       }
       
       lastPlayerItem = playerItem
       
       if let item = playerItem {
           NotificationCenter.default.addObserver(self, selector: #selector(movieplayEnd),
                                                  name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                  object: playerItem)
           
           item.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
           item.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
           // 缓冲区空了，需要等待数据
           item.addObserver(self, forKeyPath: "playbackBufferEmpty", options: NSKeyValueObservingOptions.new, context: nil)
           // 缓冲区有足够数据可以播放了
           item.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: nil)
       }
   }
   
   fileprivate func configPlayer(){
       player?.removeObserver(self, forKeyPath: "rate")
       playerItem = AVPlayerItem(asset: urlAsset!)
       player     = AVPlayer(playerItem: playerItem!)
       player!.addObserver(self, forKeyPath: "rate", options: NSKeyValueObservingOptions.new, context: nil)
       self.connectPlayerLayer()
       setNeedsLayout()
       layoutIfNeeded()
       
       NotificationCenter.default.addObserver(self, selector: #selector(self.connectPlayerLayer), name: UIApplication.willEnterForegroundNotification, object: nil)
       NotificationCenter.default.addObserver(self, selector: #selector(self.disconnectPlayerLayer), name: UIApplication.didEnterBackgroundNotification, object: nil)
   }
   
   func setupTimer() {
       timer?.invalidate()
       timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(playerTimerAction), userInfo: nil, repeats: true)
       timer?.fireDate = Date()
   }
 
   // MARK: - 计时器事件
   @objc fileprivate func playerTimerAction() {
       guard let playerItem = playerItem else { return }
       
       if playerItem.duration.timescale != 0, self.state != .waiting {
           if abs(CMTimeGetSeconds(self.player!.currentTime()) - self.currentTime) > 0.5 {
               self.currentTime = CMTimeGetSeconds(self.player!.currentTime())
               let totalTime   = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)
               delegate?.player(player: self, playTimeDidChange: self.currentTime, totalTime: totalTime)
           }
       }
       updateStatus(includeLoading: true)
   }
   
   fileprivate func updateStatus(includeLoading: Bool = false) {
       if let player = player {
           if let playerItem = playerItem, includeLoading {
               if playerItem.isPlaybackLikelyToKeepUp || playerItem.isPlaybackBufferFull {
                   self.state = .finished
//                if playerItem.isPlaybackBufferFull {
//                        self.state = .bufferFinished
               } else if playerItem.status == .failed {
                   self.state = .error
               } else {
                   self.state = .waiting
               }
           }
           if player.rate == 0.0 {
               if player.error != nil {
                   self.state = .error
                   return
               }
               if let currentItem = player.currentItem {
                   if player.currentTime() >= currentItem.duration {
                       movieplayEnd()
                       return
                   }
                   if currentItem.isPlaybackLikelyToKeepUp || currentItem.isPlaybackBufferFull {
                       
                   }
               }
           }
       }
   }
   
   // MARK: - Notification Event
   @objc fileprivate func movieplayEnd() {
       if state != .end {
           if let playerItem = playerItem {
               delegate?.player(player: self,
                                  playTimeDidChange: CMTimeGetSeconds(playerItem.duration),
                                  totalTime: CMTimeGetSeconds(playerItem.duration))
           }
           
           self.state = .end
           self.isPlaying = false
           self.playEnd = true
           self.timer?.invalidate()
       }
   }
   
   /// 插拔耳机
   @objc func routeChanged(notification: Notification) {
       let dic = notification.userInfo
       if let changeReasonInt = dic?[AVAudioSessionRouteChangeReasonKey] {
           let changeReason = AVAudioSession.RouteChangeReason(rawValue: changeReasonInt as! UInt)
           // 旧输出不可用
           if changeReason == AVAudioSession.RouteChangeReason.oldDeviceUnavailable {
               let routeDescription = dic?[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
               let portDescription = routeDescription?.outputs.first
               let newPortDescription = routeDescription?.outputs.first
               // 原设备为耳机则暂停
               if portDescription?.portType == .headphones || portDescription?.portType == .bluetoothHFP  || portDescription?.portType == .bluetoothA2DP {
                   self.pause()
                   if newPortDescription?.portType == .builtInSpeaker {
                       do {
                           // 扬声器
                           try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                       } catch {}
                   }
               }
           }
       }
       
   }
   
   /// 来电/闹钟打断
   @objc func interruptionComing(notification: Notification) {
       let dic = notification.userInfo
       if let typeInt = dic?[AVAudioSessionInterruptionTypeKey] {
           let type = AVAudioSession.InterruptionType(rawValue: typeInt as! UInt)
           if type == .began {
               self.pause()
           } else if type == .ended {
//                self.play()
           }
       }
   }
   
   // MARK: - KVO
   override  func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
       if let item = object as? AVPlayerItem, let keyPath = keyPath {
           if item == self.playerItem {
               switch keyPath {
               case "status":
                   if item.status == .failed || player?.status == AVPlayer.Status.failed {
                       self.state = .error
                   } else if player?.status == AVPlayer.Status.readyToPlay {
                       self.state = .waiting
                       if seekTo != 0 {
                           seek(to: seekTo, completion: { [weak self] in
                               self?.seekTo = 0
                               self?.hasReadyToPlay = true
                               self?.state = .ready
                           })
                       } else {
                           self.hasReadyToPlay = true
                           self.state = .ready
                       }
                   }
                   
               case "loadedTimeRanges":
                   // 计算缓冲进度
                   if let timeInterVarl    = self.availableDuration() {
                       let duration        = item.duration
                       let totalDuration   = CMTimeGetSeconds(duration)
                       delegate?.player(player: self, loadedTimeDidChange: timeInterVarl, totalDuration: totalDuration)
                   }
                   
               case "playbackBufferEmpty":
                   // 当缓冲是空的时候
                   if self.playerItem!.isPlaybackBufferEmpty {
                       self.state = .waiting
                       self.bufferingSomeSecond()
                   }
               case "playbackLikelyToKeepUp":
                   if item.isPlaybackBufferEmpty {
                       if state != .finished && hasReadyToPlay {
                           self.state = .finished
                           self.playEnd = true
                       }
                   }
               default:
                   break
               }
           }
       }
       
       if keyPath == "rate" {
           updateStatus()
       }
   }
   
   /**
    缓冲进度
    
    - returns: 缓冲进度
    */
   fileprivate func availableDuration() -> TimeInterval? {
       if let loadedTimeRanges = player?.currentItem?.loadedTimeRanges,
           let first = loadedTimeRanges.first {
           
           let timeRange = first.timeRangeValue
           let startSeconds = CMTimeGetSeconds(timeRange.start)
           let durationSecound = CMTimeGetSeconds(timeRange.duration)
           let result = startSeconds + durationSecound
           return result
       }
       return nil
   }
   
   /**
    缓冲比较差的时候
    */
   fileprivate func bufferingSomeSecond() {
       self.state = .waiting
       // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
       
       if isBuffering {
           return
       }
       isBuffering = true
       // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
       player?.pause()
       let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * 1.0 )) / Double(NSEC_PER_SEC)
       
       DispatchQueue.main.asyncAfter(deadline: popTime) {[weak self] in
           guard let `self` = self else { return }
           // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
           self.isBuffering = false
           if let item = self.playerItem {
               if !item.isPlaybackLikelyToKeepUp {
                   self.bufferingSomeSecond()
               } else {
                   // 如果此时用户已经暂停了，则不再需要开启播放了
                   self.state = .finished
               }
           }
       }
   }
   
   @objc fileprivate func connectPlayerLayer() {
       playerLayer?.removeFromSuperlayer()
       playerLayer = AVPlayerLayer(player: player)
       playerLayer!.videoGravity = videoGravity
       
       layer.addSublayer(playerLayer!)
   }
   
   @objc fileprivate func disconnectPlayerLayer() {
       playerLayer?.removeFromSuperlayer()
       playerLayer = nil
   }
}
