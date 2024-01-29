//
//  HKPlayer.swift
//  HookMemory
//
//  Created by HF on 2023/11/17.
//

import UIKit
import MediaPlayer
import AVFoundation

enum HKPlayerPanDirection: Int {
    case horizontal = 0
    case vertical
}

protocol HKPlayerDelegate: AnyObject {
    func player(player: HKPlayer, playerStateDidChange state: HKPlayerState, errorInfo: String?)
    func player(player: HKPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval)
    func player(player: HKPlayer, playTimeDidChange currentTime : TimeInterval, totalTime: TimeInterval)
    func player(player: HKPlayer, playerIsPlaying playing: Bool)
    func player(player: HKPlayer, playerOrientChanged isFullscreen: Bool)
    func playerShowCaptionView(_ isfull: Bool)
    func playerShowEpsView()
    func playerNext()
    func playerScreenLock(_ lock: Bool)
}


class HKPlayer: UIView {
    let session = AVAudioSession.sharedInstance()

    weak var delegate: HKPlayerDelegate?
    
    var vc: UIViewController?
    
    var panGes: UIPanGestureRecognizer!
    
    var videoGravity = AVLayerVideoGravity.resizeAspect {
        didSet {
            self.playerLayer?.videoGravity = videoGravity
        }
    }
    
    var backBlock:((Bool) -> Void)?
    var exitFullScreen:((Bool) -> Void)?

    open var isPlaying: Bool {
        get {
            return playerLayer?.isPlaying ?? false
        }
    }
    
    var tempIsPlaying: Bool = false
    var isReminder: Bool = false {
        didSet {
            DispatchQueue.main.async {
                self.controlView.controlViewAnimation(isShow: !self.controlView.isShowing)
            }
            if isReminder {
                self.controlView.hideLoader()
            }
        }
    }
    
    var playTimeDidChange:((TimeInterval, TimeInterval) -> Void)?

    var playStateDidChange:((Bool) -> Void)?

//    var playOrientChanged:((Bool) -> Void)?

    var isPlayingStateChanged:((Bool) -> Void)?

    var playStateChanged:((HKPlayerState) -> Void)?
    
    var avPlayer: AVPlayer? {
        return playerLayer?.player
    }
    
    var playerLayer: HKPlayerLayerView?
    
    fileprivate var resource: HKPlayerResource!
    
    fileprivate var currentDefinition = 0
    
    fileprivate var controlView: HKPlayerControlView!
    
    fileprivate var customControlView: HKPlayerControlView?
    
    var sourceKey = ""
        
    var isFullScreen: Bool = false
    
    /// 滑动方向
    var panDirection = HKPlayerPanDirection.horizontal
    
    /// 音量
    var voSlider: UISlider!
    var voValue: Float = 0
    
    lazy var lightView: HKPlayerLightView = {
        let view = HKPlayerLightView.view()
        view.isHidden = true
        self.playerLayer?.addSubview(view)
        view.snp.makeConstraints { make in
            make.width.equalTo(204)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
        }
        return view
    }()
    
    let animationTimeInterval: Double             = 4.0
    let autoFadeOutTimeInterval: Double = 0.5
    
    /// 用来保存时间状态
    fileprivate var sumTime         : TimeInterval = 0
    var totalDuration   : TimeInterval = 0
    var currentPosition : TimeInterval = 0
    fileprivate var shouldSeekTo    : TimeInterval = 0
    
    var panPosition : TimeInterval = 0
    
    var isURLSet        = false
    var isSliderSliding = false
    var isPauseByUser   = false
    var isVolume        = false
    var isMaskShowing   = false
    var isSlowed        = false
    var isMirrored      = false
    
    var isPlayEnd  = false
    //视频画面比例
    var aspectRatio: HKPlayerAspectRatio = .normal
    
    //Cache is playing result to improve callback performance
    fileprivate var isPlayingCache: Bool? = nil
    
    var subTitleSelectId = ""
    
    // MARK: - Public functions
    
    /**
     Play
     
     - parameter resource:        media resource
     - parameter definitionIndex: starting definition index, default start with the first definition
     */
    open func setVideo(resource: HKPlayerResource, sourceKey: String, index: Int = 0) {
        isURLSet = false
        self.resource = resource
        self.sourceKey = sourceKey
        
//        MTAleartManager.shared.speedView.selectIndex = 3
        
        currentDefinition = index
        controlView.prepareUI(for: resource, selectedIndex: index)
        
        controlView.playRate = 1.0
//        MTAleartManager.shared.speedView.selectIndex = 3
        self.playerLayer?.player?.rate = 1.0
//        controlView.rateButton.setTitle("\(controlView.playRate)X", for: .normal)
//        controlView.rate1Button.setTitle("\(controlView.playRate)X", for: .normal)
        
        if HKPlayerManager.share.autoPlay {
            isURLSet = true
            let asset = resource.definitions[index]
            playerLayer?.playAsset(asset: asset.avURLAsset)
        } else {
            controlView.showCover(url: resource.cover)
            controlView.hideLoader()
        }
        
        DispatchQueue.main.async {
//            if let video = MTSourceManager.getVideoWithKey(sourceKey) {
//                MTDataManager.addVideoIntoHistory(video: video)
//                if isChangeTV {
//                    MTDataManager.changeProgressAndPlayedTime(video: video, time: 0, progress: 0)
//                } else {
//                    if video.playProgress > 0 {
//                        //                    HBToast.playerToast(String(format: HBCommons.localizedString(key: "Targeted to"), BMPlayer.secondsToFormat(video.playTime, duration: video.totalTime)))
//                        self.seek(video.playedTime)
//                    }
//                }
//            }
        }
        
    }
    
    /**
     auto start playing, call at viewWillAppear, See more at pause
     */
    open func autoPlay() {
        if !isPauseByUser && isURLSet && !isPlayEnd {
            play()
        }
    }
    
    /**
     Play
     */
    open func play() {
        guard resource != nil else { return }
        
        if !isURLSet {
            let asset = resource.definitions[currentDefinition]
            playerLayer?.playAsset(asset: asset.avURLAsset)
            controlView.hideCoverImageView()
            isURLSet = true
        }
        
        panGes.isEnabled = true
        playerLayer?.play()
        playerLayer?.player?.rate = controlView.playRate
        isPauseByUser = false
    }
    
    /**
     Pause
     
     - parameter allow: should allow to response `autoPlay` function
     */
    open func pause(allowAutoPlay allow: Bool = false) {
        playerLayer?.pause()
        isPauseByUser = !allow
    }
    
    /**
     seek
     
     - parameter to: target time
     */
    open func seek(_ to:TimeInterval, completion: (()->Void)? = nil) {
        playerLayer?.seek(to: to, completion: completion)
    }
    
    /**
     update UI to fullScreen
     */
    func setUpdateUI(_ isFullScreen: Bool) {
        controlView.setUpdateUI(isFullScreen)
    }
    
    func addVolume(step: Float = 0.1) {
        self.voSlider.value += step
        self.voValue += step
    }
    
    /**
     decreace volume with step, default step 0.1
     
     - parameter step: step
     */
    func reduceVolume(step: Float = 0.1) {
        self.voSlider.value -= step
        self.voValue -= step
    }
    
    /**
     prepare to dealloc player, call at View or Controllers deinit funciton.
     */
    func prepareToDealloc() {
        playerLayer?.prepareToDeinit()
        controlView.prepareToDealloc()
    }
    
    /**
     If you want to create BMPlayer with custom control in storyboard.
     create a subclass and override this method.
     
     - return: costom control which you want to use
     */
    func storyBoardCustomControl() -> HKPlayerControlView? {
        return nil
    }
    
    // MARK: - Action Response
    
    @objc fileprivate func panDirection(_ pan: UIPanGestureRecognizer) {
        // 根据在view上Pan的位置，确定是调音量还是亮度
        let locationPoint = pan.location(in: self)
        
        // 我们要响应水平移动和垂直移动
        // 根据上次和本次移动的位置，算出一个速率的point
        let velocityPoint = pan.velocity(in: self)
        
        // 判断是垂直移动还是水平移动
        switch pan.state {
        case UIGestureRecognizer.State.began:
            // 使用绝对值来判断移动的方向
            let x = abs(velocityPoint.x)
            let y = abs(velocityPoint.y)
            
            if x > y {
                if HKPlayerManager.share.enablePlaytimeGestures {
                    self.panDirection = HKPlayerPanDirection.horizontal
                    if let player = playerLayer?.player {
                        let time = player.currentTime()
                        self.sumTime = TimeInterval(time.value) / TimeInterval(time.timescale)
                        self.panPosition = TimeInterval(time.value) / TimeInterval(time.timescale)
                    }
                    self.tempIsPlaying = self.isPlaying
                    self.pause()
                }
            } else {
                self.panDirection = HKPlayerPanDirection.vertical
                if locationPoint.x > self.bounds.size.width / 2 {
                    self.isVolume = true
                } else {
                    self.isVolume = false
                    self.playerLayer?.bringSubviewToFront(self.lightView)
                    self.lightView.isHidden = false
                    self.lightView.imageView.isHighlighted = true
                }
            }
            
        case UIGestureRecognizer.State.changed:
            switch self.panDirection {
            case HKPlayerPanDirection.horizontal:
                self.horizontalMoved(velocityPoint.x)
            case HKPlayerPanDirection.vertical:
                self.verticalMoved(velocityPoint.y)
            }
            
        case UIGestureRecognizer.State.ended:
            switch (self.panDirection) {
            case HKPlayerPanDirection.horizontal:
                controlView.hideSeekToView()
                isSliderSliding = false
                if isPlayEnd {
                    isPlayEnd = false
                    seek(self.sumTime, completion: {[weak self] in
                        self?.play()
                    })
                } else {
                    seek(self.sumTime, completion: {[weak self] in
                        if self?.tempIsPlaying == true {
                            self?.play()
                        } else {
                            self?.autoPlay()
                        }
                    })
                }
                // sumTime会越加越多
                self.panPosition = 0.0
                self.sumTime = 0.0
            case HKPlayerPanDirection.vertical:
                self.isVolume = false
                self.lightView.isHidden = true
            }
        default:
            break
        }
    }
    
    fileprivate func verticalMoved(_ value: CGFloat) {
        if HKPlayerManager.share.enableVolumeGestures && self.isVolume {
            self.voSlider.value -= Float(value / 10000)
            self.voValue -= Float(value / 10000)
        } else if HKPlayerManager.share.enableBrightnessGestures && !self.isVolume {
            UIScreen.main.brightness -= value / 5000
            self.lightView.isHidden = false
            let width = CGFloat(UIScreen.main.brightness) * 140
            self.lightView.topViewWidth.constant = width
            self.lightView.layoutIfNeeded()
        }
    }
    
    fileprivate func horizontalMoved(_ value: CGFloat) {
        guard HKPlayerManager.share.enablePlaytimeGestures else { return }
        
        isSliderSliding = true
        if let playerItem = playerLayer?.playerItem {
            // 每次滑动需要叠加时间，通过一定的比例，使滑动一直处于统一水平
            self.sumTime = self.sumTime + TimeInterval(value) / 100.0 * (TimeInterval(self.totalDuration)/400)
            
            let totalTime = playerItem.duration
            
            // 防止出现NAN
            if totalTime.timescale == 0 { return }
            
            let totalDuration = TimeInterval(totalTime.value) / TimeInterval(totalTime.timescale)
            if (self.sumTime >= totalDuration) { self.sumTime = totalDuration }
            if (self.sumTime <= 0) { self.sumTime = 0 }
            
            controlView.showSeekToView(to: sumTime, total: totalDuration, isAdd: value > 0)
            if isPlayEnd {
                isPlayEnd = false
            }
        }
    }
    
//    @objc open func onOrientationChanged() {
//        self.setUpdateUI(isFullScreen)
//        delegate?.player(player: self, playerOrientChanged: isFullScreen)
//        playOrientChanged?(isFullScreen)
//    }
    
    @objc func fullScreenButtonPressed() {
        self.isFullScreen = !self.isFullScreen
        delegate?.player(player: self, playerOrientChanged: isFullScreen)
        controlView.setUpdateUI(self.isFullScreen)
        self.exitFullScreen?(self.isFullScreen)
        self.controlView.controlViewAnimation(isShow: self.isFullScreen)
        if #available(iOS 16.0, *) {
            vc?.setNeedsUpdateOfSupportedInterfaceOrientations()
            let scene = UIApplication.shared.connectedScenes.first
            guard let windowScene = scene as? UIWindowScene else { return }
            let orientation: UIInterfaceOrientationMask = isFullScreen ?  UIInterfaceOrientationMask.landscapeRight : UIInterfaceOrientationMask.portrait
            let geometryPreferencesIOS = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientation)
            windowScene.requestGeometryUpdate(geometryPreferencesIOS) { error in
                print("geometryPreferencesIOS error: \(error)")
            }
        } else {
            if isFullScreen {
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
    }
    
    @objc fileprivate func airplayButtonPressed() {
        
    }
    
    // MARK: - 生命周期
    deinit {
        playerLayer?.pause()
        playerLayer?.prepareToDeinit()
        NotificationCenter.default.removeObserver(self, name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        if let customControlView = storyBoardCustomControl() {
            self.customControlView = customControlView
        }
        initUI()
        configureVolume()
        preparePlayer()
    }
    
//    public convenience init(customControllView: HKPlayerControlView?) {
//        self.init(customControlView: customControllView)
//    }
    
    public init(customControlView: HKPlayerControlView?) {
        super.init(frame:CGRect.zero)
        self.customControlView = customControlView
        initUI()
        configureVolume()
        preparePlayer()
    }
    
    public convenience init() {
        self.init(customControlView: nil)
    }
    
    // MARK: - 初始化
    fileprivate func initUI() {
        self.backgroundColor = UIColor.black
        
        if let customView = customControlView {
            controlView = customView
        } else {
            controlView = HKPlayerControlView()
        }
        
        addSubview(controlView)
        controlView.setUpdateUI(isFullScreen)
        controlView.delegate = self
        controlView.player   = self
        controlView.snp.makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        panGes = UIPanGestureRecognizer(target: self, action: #selector(self.panDirection(_:)))
        panGes.delegate = self
        self.addGestureRecognizer(panGes)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(self.onOrientationChanged), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    fileprivate func configureVolume() {
        let voView = MPVolumeView(frame: CGRect(x: -100, y: -100, width: 40, height: 40))
        vc?.view.addSubview(voView)
        voView.showsVolumeSlider = true
        for view in voView.subviews {
            if let slider = view as? UISlider {
                self.voSlider = slider
            }
        }
    }
    
    fileprivate func preparePlayer() {
        
        do {
            try session.setCategory(AVAudioSession.Category.playback, options: [.defaultToSpeaker, .allowBluetoothA2DP])
            try session.setActive(true)
        } catch {
            print("error: session \(error.localizedDescription)")
        }
        
        playerLayer = HKPlayerLayerView()
        playerLayer!.videoGravity = videoGravity
        insertSubview(playerLayer!, at: 0)
        playerLayer!.snp.makeConstraints { make in
          make.edges.equalTo(self)
        }
        playerLayer!.delegate = self
        controlView.showLoader()
        self.layoutIfNeeded()
    }
    
    func playNext() {
//        if let list = MTSourceManager.getOrderPlaylist() {
//            if let index = list.videos.firstIndex(where: { $0.sourceKey == MTCommonManager.shared.sourceKey }), index < list.videos.count - 1 {
//                self.playNew(sourceKey: list.videos[index + 1].sourceKey)
//            }
//        }
    }
    
    func playNew(sourceKey: String) {
//        if let video = MTSourceManager.getVideoWithKey(sourceKey) {
//            let url = video.isImport ? MTCommonManager.pathForSourceKey(video.sourceKey) : URL(string: video.url)!
//            let asset = BMPlayerResource(name: video.title,
//                                         definitions: [BMPlayerResourceDefinition(url: url!, definition: "480p")],
//                                         cover: nil,
//                                         subtitles: nil)
//            MTCommonManager.shared.sourceKey = video.sourceKey
//            self.setVideo(resource: asset)
//        }
    }
    
    func showPlayingAd(placement: HKADLogENUM) {
        HKConfig.showInterAD(type: self.isFullScreen ? .other : .play, placement: placement) { [weak self] result in
            DispatchQueue.main.async {
                if result {
                    self?.tempIsPlaying = self?.isPlaying ?? false
                    self?.pause()
                }
            }
        }
        HKADManager.share.tempDismissComplete = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if self?.tempIsPlaying == true {
                    self?.play()
                }
            }
            HKADManager.share.tempDismissComplete = nil
        }
    }
}

extension HKPlayer: HKPlayerLayerViewDelegate {
    func player(player: HKPlayerLayerView, playerIsPlaying playing: Bool) {
        controlView.playStateDidChange(isPlaying: playing)
        delegate?.player(player: self, playerIsPlaying: playing)
        playStateDidChange?(player.isPlaying)
        isPlayingStateChanged?(player.isPlaying)
    }
    
    func player(player: HKPlayerLayerView, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        controlView.loadedTimeDidChange(loadedDuration: loadedDuration, totalDuration: totalDuration)
        delegate?.player(player: self, loadedTimeDidChange: loadedDuration, totalDuration: totalDuration)
        controlView.totalDuration = totalDuration
        self.totalDuration = totalDuration
        DispatchQueue.main.async {
//            if totalDuration > 0, let video = MTSourceManager.getVideoWithKey(self.sourceKey), video.totalTime == 0 {
//                MTDataManager.changeTotalTime(video: video, time: totalDuration)
//            }
        }
    }
    
    func player(player: HKPlayerLayerView, playerStateDidChange state: HKPlayerState) {
        controlView.playerStateDidChange(state: state)
        var info: String?
        switch state {
        case .ready:
            if !isPauseByUser {
                play()
            }
            if shouldSeekTo != 0 {
                seek(shouldSeekTo, completion: {[weak self] in
                  guard let `self` = self else { return }
                  if !self.isPauseByUser {
                      self.play()
                  } else {
                      self.pause()
                  }
                })
                shouldSeekTo = 0
            }
            
        case .finished:
            autoPlay()
            
        case .end:
            break
//            if let list = MTSourceManager.getOrderPlaylist() {
//                if let index = list.videos.firstIndex(where: { $0.sourceKey == MTCommonManager.shared.sourceKey }), index < list.videos.count - 1 {
//                    self.playNext()
//                } else {
//                    isPlayEnd = true
//                }
//            }
            
        case .error:
            info = String(describing: player.player?.error)
            print("playerError: \(player.player?.error)")
            break
        default:
            break
        }
        panGes.isEnabled = state != .end
        delegate?.player(player: self, playerStateDidChange: state, errorInfo: info)
        playStateChanged?(state)
    }
    
    func player(player: HKPlayerLayerView, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
//        MTLog.log("playTimeDidChange - \(currentTime) - \(totalTime)")
        delegate?.player(player: self, playTimeDidChange: currentTime, totalTime: totalTime)
        self.currentPosition = currentTime
        totalDuration = totalTime
        if isSliderSliding {
            return
        }
        controlView.playTimeDidChange(currentTime: currentTime, totalTime: totalTime)
        controlView.totalDuration = totalDuration
        playTimeDidChange?(currentTime, totalTime)
        
        if self.isPlaying, !self.isSliderSliding, Int(currentTime) % HKADManager.share.play_time == 0, Int(currentTime) / HKADManager.share.play_time != 0 {
            self.showPlayingAd(placement: .play)
        }
    }
}

extension HKPlayer: HKPlayerControlViewDelegate {
    func controlView(controlView: HKPlayerControlView,
                          didChooseDefinition index: Int) {
        shouldSeekTo = currentPosition
        playerLayer?.resetPlayer()
        currentDefinition = index
        playerLayer?.playAsset(asset: resource.definitions[index].avURLAsset)
    }
    
    func controlView(controlView: HKPlayerControlView,
                          didPressButton button: UIButton) {
        if let action = HKButtonType(rawValue: button.tag) {
            switch action {
            case .back:
                backBlock?(isFullScreen)
//                if isFullScreen {
//                    fullScreenButtonPressed()
//                } else {
//                    playerLayer?.prepareToDeinit()
//                }
            case .play:
                if button.isSelected {
                    pause()
                } else {
                    if isPlayEnd {
                        seek(0, completion: {[weak self] in
                          self?.play()
                        })
                        controlView.hidePlayToTheEndView()
                        isPlayEnd = false
                    }
                    play()
                }
            case .replay:
                isPlayEnd = false
                seek(0)
                play()
                
            case .fullscreen:
                fullScreenButtonPressed()
                
            case.airplay:
                airplayButtonPressed()
                
            case .rate:
//                MTAleartManager.shared.showSpeedView(view: self.vc?.view)
                controlView.controlViewAnimation(isShow: false)
                
            case .backword:
                controlView.backword()
                self.showSeekViewWithTime(false)
            case .forword:
                controlView.forword()
                self.showSeekViewWithTime(true)
            case .list:
                break                
            case .cc:
                self.controlView.controlViewAnimation(isShow: false)
                self.delegate?.playerShowCaptionView(isFullScreen)
            case .eps:
                self.delegate?.playerShowEpsView()
            case .next:
                self.delegate?.playerNext()
            case .lock:
                self.delegate?.playerScreenLock(controlView.lockBtn.isSelected)
            default:
                print("[Error] unhandled Action")
            }
        }
    }
    
    func showSeekViewWithTime(_ forword: Bool = false) {
        if let playerItem = playerLayer?.playerItem, let player = playerLayer?.player{
            let time = player.currentTime()
            var sumTime: TimeInterval = TimeInterval(time.value) / TimeInterval(time.timescale)
            let totalTime = playerItem.duration
            
            // 防止出现NAN
            if totalTime.timescale == 0 { return }
            
            let totalDuration = TimeInterval(totalTime.value) / TimeInterval(totalTime.timescale)
            if (sumTime >= totalDuration) { sumTime = totalDuration }
            if (sumTime <= 0) { sumTime = 0 }
            controlView.forOrBackSeekToView(forword, to: sumTime, total: totalDuration, isAdd: forword)
        }
    }
    
    func controlView(controlView: HKPlayerControlView,
                          slider: UISlider,
                          onSliderEvent event: UIControl.Event) {
        switch event {
        case .touchDown:
            playerLayer?.setTimeSliderBegan()
            isSliderSliding = true
        case .touchUpInside :
            isSliderSliding = false
            let target = self.totalDuration * Double(slider.value)
//            controlView.showSeekToView(to: sumTime, total: totalDuration, isAdd: sumTime > 0)
            if isPlayEnd {
                isPlayEnd = false
                seek(target, completion: {[weak self] in
                  self?.play()
                })
                controlView.hidePlayToTheEndView()
            } else {
                seek(target, completion: {[weak self] in
                    if self?.tempIsPlaying == true {
                        self?.play()
                    } else {
                        self?.autoPlay()
                    }
                })
            }
        default:
            break
        }
    }
    
    func controlView(controlView: HKPlayerControlView, didChangeVideoAspectRatio: HKPlayerAspectRatio) {
        self.playerLayer?.aspectRatio = self.aspectRatio
    }
    
    func controlView(controlView: HKPlayerControlView, didChangeVideoPlaybackRate rate: Float) {
        if self.isPlaying {
            self.playerLayer?.player?.rate = rate
        } else {
            self.controlView.playRate = rate
        }
    }
}

extension HKPlayer {
    static func secondsToFormat(_ seconds: TimeInterval, duration: TimeInterval) -> String {
        if seconds.isNaN {
            return "00:00"
        }
        if duration >= 3600 {
            let sec = Int(seconds.truncatingRemainder(dividingBy: 3600).truncatingRemainder(dividingBy: 60))
            let hour = Int(seconds / 3600)
            let min = Int(seconds.truncatingRemainder(dividingBy: 3600) / 60)
            return String(format: "%02d:%02d:%02d", hour, abs(min), abs(sec))
        } else {
            let sec = Int(seconds.truncatingRemainder(dividingBy: 60))
            let min = Int(seconds / 60)
            return String(format: "%02d:%02d", abs(min), abs(sec))
        }
    }
}

extension HKPlayer: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if HKPlayerManager.share.isLock {
            return false
        }
        return true
    }
}
