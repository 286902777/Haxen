//
//  HKPlayerControlView.swift
//  HookMemory
//
//  Created by HF on 2023/11/17.
//

import UIKit

enum HKButtonType: Int {
    case play       = 101
    case pause
    case back
    case fullscreen
    case replay
    case forword
    case airplay
    case rate
    case list
    case backword
    case lock
    case cc
    case next
    case eps
}

protocol HKPlayerControlViewDelegate: AnyObject {
    /**
     call when control view choose a definition
     
     - parameter controlView: control view
     - parameter index:       index of definition
     */
    func controlView(controlView: HKPlayerControlView, didChooseDefinition index: Int)
    
    /**
     call when control view pressed an button
     
     - parameter controlView: control view
     - parameter button:      button type
     */
    func controlView(controlView: HKPlayerControlView, didPressButton button: UIButton)
    
    /**
     call when slider action trigged
     
     - parameter controlView: control view
     - parameter slider:      progress slider
     - parameter event:       action
     */
    func controlView(controlView: HKPlayerControlView, slider: UISlider, onSliderEvent event: UIControl.Event)
    
    /**
     call when needs to change playback rate
     
     - parameter controlView: control view
     - parameter rate:        playback rate
     */
    func controlView(controlView: HKPlayerControlView, didChangeVideoPlaybackRate rate: Float)
}

class HKPlayerControlView: UIView {
    weak var delegate: HKPlayerControlViewDelegate?
    weak var player: HKPlayer?
    
    // MARK: Variables
    var resource: HKPlayerResource?
    
    var selectedIndex = 0
    var isFullscreen = false {
        didSet {
            if isFullscreen, isMovie == false {
                self.epsButton.isHidden = false
                self.nextBtn.isHidden = false
            } else {
                self.epsButton.isHidden = true
                self.nextBtn.isHidden = true
            }
        }
    }
    var isShowing = true
    var isMovie = false
    var playRate: Float = 1.0
    var isReadyToPlayed = false
    
    var totalDuration: TimeInterval = 0
    var delayItem: DispatchWorkItem?
    
    var playerState: HKPlayerState = .noURL
    
    let leading: CGFloat = 16
    let marge: CGFloat = 8
    
    fileprivate var isSelectDefinition = false
    
    // MARK: UI Components
    /// main views which contains the topView and bottom  view
    var mainView   = UIView()
    var topView    = UIView()
    var bottomView = UIView()
    var centerView = UIView()
    var leftView   = UIView()
    var rightView = UIView()
    
    /// Image view to show video cover
    var ImageView = UIImageView()
    
    /// top views
    var topWrapperView = UIView()
    var backBtn = UIButton(type : .custom)
    //    var rate1Button = UIButton(type : .custom)
    var ccButton = UIButton(type : .custom)
    var epsButton = UIButton(type : .custom)
    var titleLabel = UILabel()
    var chooseDefinitionView = UIView()
    
    /// bottom view
    var bottomWrapperView = UIView()
    var currentTimeL = UILabel()
    //    var centerTimeLabel = UILabel()
    var totalTimeLabel   = UILabel()
    
    /// Progress slider
    var timeSlider = HKTimeSlider()
    
    /// load progress view
    var progressView = UIProgressView()
    
    /* play button
     playButton.isSelected = player.isPlaying
     */
    var playButton = UIButton(type: .custom)
    //    var forwordBtn = UIButton(type: .custom)
    //    var backwordBtn = UIButton(type: .custom)
    
    
    var centerWrapperView = UIView()
    var play1Btn = UIButton(type: .custom)
    var forword1Button = UIButton(type: .custom)
    var backword1Button = UIButton(type: .custom)
    
    var lockBtn = UIButton(type: .custom)
    /* fullScreen button
     fullScreenButton.isSelected = player.isFullscreen
     */
    var nextBtn = UIButton(type: .custom)
    var fullscreenButton = UIButton(type: .custom)
    //    var rateButton = UIButton(type: .custom)
    
    var subtitleL    = UILabel()
    var subtitleBackView = UIView()
    var subtileAttribute: [NSAttributedString.Key : Any]?
    
    /// Activty Indector for loading
    //      var loadingIndicator  = NVActivityIndicatorView(frame:  CGRect(x: 0, y: 0, width: 30, height: 30))
    //      var loadingIndicator  = MTPageLoadingView.initWithXib()
    
    //    lazy var loadingIndicator: MTPageLoadingView = {
    //        let view = MTPageLoadingView.initWithXib()
    //        return view
    //    }()
    
    var seekToView       = UIView()
    var seekToEffView    = UIView()
    var seekToViewImage  = UIImageView()
    var seekToLabel      = UILabel()
    var offsetToLabel    = UILabel()
    
    //    var replayBtn     = UIButton(type: .custom)
    
    /// Gesture used to show / hide control view
    var tapGesture: UITapGestureRecognizer!
    var doubleGesture: UITapGestureRecognizer!
    var leftGesture: UITapGestureRecognizer!
    var rightGesture: UITapGestureRecognizer!
    
    // MARK: - handle player state change
    /**
     call on when play time changed, update duration here
     
     - parameter currentTime: current play time
     - parameter totalTime:   total duration
     */
    func playTimeDidChange(currentTime: TimeInterval, totalTime: TimeInterval) {
        currentTimeL.text = HKPlayer.formatSecondsToString(currentTime, duration: totalTime)
        totalTimeLabel.text   = HKPlayer.formatSecondsToString(totalTime, duration: totalTime)
        timeSlider.value      = Float(currentTime) / Float(totalTime)
        showSubtile(from: resource?.subtitle, at: currentTime)
    }
    
    
    /**
     change subtitle resource
     
     - Parameter subtitles: new subtitle object
     */
    func update(subtitles: HKSubtitles?) {
        resource?.subtitle = subtitles
        self.ccButton.isEnabled = subtitles != nil
    }
    
    /**
     call on load duration changed, update load progressView here
     
     - parameter loadedDuration: loaded duration
     - parameter totalDuration:  total duration
     */
    func loadedTimeDidChange(loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        progressView.setProgress(Float(loadedDuration)/Float(totalDuration), animated: true)
    }
    
    func playerStateDidChange(state: HKPlayerState) {
        switch state {
        case .ready:
            hideLoader()
            self.isReadyToPlayed = true
            
        case .waiting:
            showLoader()
            
        case .finished:
            if self.isReadyToPlayed {
                hideLoader()
            }
            
        case .end:
            playButton.isSelected = false
            play1Btn.isSelected = false
            lockBtn.isSelected = false
            controlViewAnimation(isShow: true)
        default:
            break
        }
        playerState = state
    }
    
    /**
     Call when User use the slide to seek function
     
     - parameter toSecound:     target time
     - parameter totalDuration: total duration of the video
     - parameter isAdd:         isAdd
     */
    func showSeekToView(to toSecound: TimeInterval, total totalDuration:TimeInterval, isAdd: Bool) {
        seekToView.isHidden = false
        //        seekToLabel.text    = BMPlayer.formatSecondsToString(toSecound, duration: totalDuration)
        seekToLabel.text = HKPlayer.formatSecondsToString(self.player?.panPosition ?? 0, duration: totalDuration)
        
        if let currentPosition = self.player?.currentPosition {
            //            let offset = toSecound - currentPosition
            let offset = toSecound - (self.player?.panPosition ?? 0)
            offsetToLabel.text  = "\(offset > 0 ? "+ " : "- ")\(HKPlayer.formatSecondsToString(offset, duration: totalDuration))"
        }
        
        //        let rotate = isAdd ? 0 : CGFloat(Double.pi)
        //        seekToViewImage.transform = CGAffineTransform(rotationAngle: rotate)
        
        let targetTime = HKPlayer.formatSecondsToString(toSecound, duration: totalDuration)
        timeSlider.value = Float(toSecound / totalDuration)
        currentTimeL.text = targetTime
    }
    
    // MARK: - UI update related function
    /**
     Update UI details when player set with the resource
     
     - parameter resource: video resouce
     - parameter index:    defualt definition's index
     */
    func prepareUI(for resource: HKPlayerResource, selectedIndex index: Int) {
        self.resource = resource
        self.selectedIndex = index
        titleLabel.text = resource.name
        prepareChooseDefinitionView()
        fadeOutControlViewWithAnimation()
    }
    
    func playStateDidChange(isPlaying: Bool) {
        fadeOutControlViewWithAnimation()
        playButton.isSelected = isPlaying
        play1Btn.isSelected = isPlaying
    }
    
    /**
     auto fade out controll view with animtion
     */
    func fadeOutControlViewWithAnimation() {
        cancelAutoFadeOutAnimation()
        delayItem = DispatchWorkItem { [weak self] in
            if self?.playerState != .end {
                self?.controlViewAnimation(isShow: false)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + HKPlayerManager.share.animateDelayInterval,
                                      execute: delayItem!)
    }
    
    /**
     cancel auto fade out controll view with animtion
     */
    func cancelAutoFadeOutAnimation() {
        delayItem?.cancel()
    }
    
    /**
     Implement of the control view animation, override if need's custom animation
     
     - parameter isShow: is to show the controlview
     */
    func controlViewAnimation(isShow: Bool) {
        self.isShowing = isShow
        
        UIView.animate(withDuration: 0.24, animations: {
            self.topView.snp.remakeConstraints {
                $0.top.equalTo(self.mainView).offset(isShow ? 0 : (self.isFullscreen ? -58 : -44))
                $0.left.right.equalTo(self.mainView)
                $0.height.equalTo(self.isFullscreen ? 58 : 44)
            }
            
            self.bottomView.snp.remakeConstraints {
                $0.bottom.equalTo(self.mainView).offset(isShow ? 0 : (self.isFullscreen ? 200 : 50))
                $0.left.right.equalTo(self.mainView)
                $0.height.equalTo(self.isFullscreen ? 200 : 50)
            }
            if self.isFullscreen {
                self.lockBtn.isHidden = !isShow
            }
            self.centerView.snp.remakeConstraints {
                $0.center.equalToSuperview()
                $0.height.equalTo(56)
                $0.width.equalTo(220)
            }
            if isShow, self.player?.isReminder == false {
                self.centerView.alpha = 1.0
            } else {
                self.centerView.alpha = 0
            }
            self.mainView.backgroundColor = UIColor(white: 0, alpha: isShow ? (self.isFullscreen ? 0.65 : 0.16) : 0)
            self.layoutIfNeeded()
        }) { (_) in
            self.fadeOutControlViewWithAnimation()
        }
    }
    
    /**
     Implement of the UI update when screen orient changed
     
     - parameter isFull: is for full screen
     */
    func updateUI(_ isFull: Bool) {
        isFullscreen = isFull
        fullscreenButton.isSelected = isFull
        titleLabel.isHidden = !isFull
        chooseDefinitionView.isHidden = !HKPlayerManager.share.enableChooseDefinition || !isFull
        if isFull {
            if HKPlayerManager.share.topBarInCase.rawValue == 2 {
                topView.isHidden = true
            } else {
                topView.isHidden = false
            }
        } else {
            if HKPlayerManager.share.topBarInCase.rawValue >= 1 {
                topView.isHidden = true
            } else {
                topView.isHidden = false
            }
        }
        
        leftView.snp.remakeConstraints {  make in
            make.top.leading.bottom.equalTo(self.mainView)
            make.width.equalTo(isFullscreen ? (kScreenHeight * 0.45) : (kScreenWidth * 0.45))
        }
        
        rightView.snp.remakeConstraints {  make in
            make.top.trailing.bottom.equalTo(self.mainView)
            make.width.equalTo(isFullscreen ? (kScreenHeight * 0.45) : (kScreenWidth * 0.45))
        }
        
        backBtn.snp.remakeConstraints { (make) in
            make.width.height.equalTo(44)
            make.leading.equalToSuperview().offset(isFullscreen ? 0 : marge)
            make.bottom.equalToSuperview()
        }
        
        //        rate1Button.snp.remakeConstraints {  make in
        //            make.width.equalTo(40)
        //            make.height.equalTo(20)
        //            make.trailing.equalToSuperview().offset(isFullscreen ? -leading - 10 : -10)
        //            make.centerY.equalTo(self.backBtn)
        //        }
        
        // Bottom views
        //            backwordBtn.isHidden = true
        playButton.isHidden = isFullscreen
        //            forwordBtn.isHidden = true
        backword1Button.isHidden = false
        play1Btn.isHidden = false
        forword1Button.isHidden = false
        if isFullscreen {
            play1Btn.snp.remakeConstraints { (make) in
                make.width.height.equalTo(48)
                make.center.equalToSuperview()
            }
            
            backword1Button.snp.remakeConstraints {  make in
                make.width.height.equalTo(48)
                make.trailing.equalTo(play1Btn.snp.leading).offset(-38)
                make.centerY.equalToSuperview()
            }
            
            forword1Button.snp.remakeConstraints { (make) in
                make.width.height.equalTo(48)
                make.leading.equalTo(play1Btn.snp.trailing).offset(38)
                make.centerY.equalToSuperview()
            }
        } else {
            forword1Button.isHidden = true
            backword1Button.isHidden = true
            play1Btn.isHidden = true
            //                forword1Button.setImage(UIImage(named: "back"),  for: .normal)
            //                backword1Button.setImage(UIImage(named: "Fast forward"),  for: .normal)
            //                play1Btn.setImage(UIImage(named: "play"),  for: .normal)
            //                play1Btn.setImage(UIImage(named: "normal"),  for: .selected)
            
            //                play1Btn.snp.remakeConstraints { (make) in
            //                    make.width.height.equalTo(42)
            //                    make.center.equalToSuperview()
            //                }
            //
            //                backword1Button.snp.remakeConstraints {  make in
            //                    make.width.height.equalTo(32)
            //                    make.trailing.equalTo(play1Btn.snp.leading).offset(-36)
            //                    make.centerY.equalToSuperview()
            //                }
            //
            //                forword1Button.snp.remakeConstraints { (make) in
            //                    make.width.height.equalTo(32)
            //                    make.leading.equalTo(play1Btn.snp.trailing).offset(36)
            //                    make.centerY.equalToSuperview()
            //                }
        }
        
        currentTimeL.snp.remakeConstraints {  make in
            if isFullscreen {
                make.bottom.equalTo(timeSlider.snp.top).offset(4)
                make.left.equalToSuperview().offset(leading)
            } else {
                make.centerY.equalTo(playButton)
                make.left.equalTo(playButton.snp.right)
            }
            make.height.equalTo(17)
        }
        
        //        centerTimeLabel.snp.remakeConstraints {  make in
        //            make.centerY.equalTo(self.currentTimeL)
        //            make.leading.equalTo(self.currentTimeL.snp.trailing)
        //        }
        
        totalTimeLabel.snp.remakeConstraints {  make in
            make.centerY.equalTo(self.currentTimeL)
            if isFullscreen {
                make.right.equalToSuperview().offset(-leading)
            } else {
                make.right.equalTo(fullscreenButton.snp.left).offset(-marge)
            }
        }
        
        timeSlider.snp.remakeConstraints {  make in
            if isFullscreen {
                make.bottom.equalTo(fullscreenButton.snp.top)
                make.left.equalToSuperview().offset(leading)
                make.right.equalToSuperview().offset(-leading)
            } else {
                make.centerY.equalTo(playButton)
                make.left.equalTo(currentTimeL.snp.right).offset(marge)
                make.right.equalTo(totalTimeLabel.snp.left).offset(-marge)
            }
            make.height.equalTo(30)
        }
        
        progressView.snp.remakeConstraints {  make in
            make.leading.trailing.equalTo(self.timeSlider)
            make.centerY.equalTo(self.timeSlider)
            make.height.equalTo(4)
        }
        
        nextBtn.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-leading)
            make.left.equalToSuperview().offset(marge)
        }
        
        fullscreenButton.snp.remakeConstraints {  make in
            make.width.height.equalTo(40)
            if isFullscreen {
                make.bottom.equalToSuperview().offset(-leading)
                make.trailing.equalToSuperview().offset(-marge)
            } else {
                make.centerY.equalTo(playButton)
                make.right.equalToSuperview().offset(-marge)
            }
        }
        
        ccButton.removeFromSuperview()
        if isFullscreen {
            bottomWrapperView.addSubview(ccButton)
        } else {
            topWrapperView.addSubview(ccButton)
        }
        
        ccButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            if isFullscreen {
                make.centerY.equalTo(fullscreenButton)
                make.right.equalTo(fullscreenButton.snp.left).offset(-marge)
            } else {
                make.trailing.equalTo(-marge)
                make.centerY.equalTo(self.backBtn)
            }
        }
        
        epsButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalTo(fullscreenButton)
            make.right.equalTo(ccButton.snp.left).offset(-marge)
        }
        //        self.rate1Button.isHidden = false
        //        self.rateButton.isHidden = true
        self.ccButton.isHidden = false
        
        self.topView.snp.remakeConstraints {
            $0.top.equalTo(self.mainView.snp.top).offset(self.isShowing ? 0 : (isFullscreen ? -58 : -44))
            $0.left.right.equalTo(self.mainView)
            $0.height.equalTo(isFullscreen ? 58 : 44)
        }
        self.bottomView.snp.remakeConstraints {
            $0.bottom.equalTo(self.mainView.snp.bottom).offset(self.isShowing ? 0 :  (isFullscreen ? 120 : 50))
            //            $0.bottom.equalTo(self.mainView.snp.bottom)
            $0.left.right.equalTo(self.mainView)
            $0.height.equalTo(isFullscreen ? 120 : 50)
        }
        
        self.centerView.snp.remakeConstraints {
            $0.center.equalTo(self.mainView)
            $0.width.equalTo(220)
            $0.height.equalTo(56)
        }
        
        //        self.player?.sliderView.snp.remakeConstraints { make in
        //            make.width.equalTo(204)
        //            make.height.equalTo(40)
        //            make.centerX.equalToSuperview()
        //            if isUrl {
        //                make.top.equalToSuperview().offset(isFullscreen ? 40 : 10)
        //            } else {
        //                make.top.equalToSuperview().offset(isFullscreen ? 40 : kNavBarHeight + 32)
        //            }
        //        }
        //        self.player?.sliderView.backgroundColor = isFullscreen ? UIColor(white: 0, alpha: 0.7) : UIColor(white: 1, alpha: 0.0marge)
        //        self.player?.sliderView.layoutIfNeeded()
        //
        //        self.player?.forwardView.snp.remakeConstraints { make in
        //            make.width.equalTo(13marge)
        //            make.height.equalTo(40)
        //            make.centerX.equalToSuperview()
        //            if isUrl {
        //                make.top.equalToSuperview().offset(isFullscreen ? 40 : 10)
        //            } else {
        //                make.top.equalToSuperview().offset(isFullscreen ? 40 : kNavBarHeight + 32)
        //            }
        //
        //        }
        //        self.player?.forwardView.backgroundColor = isFullscreen ? UIColor(white: 0, alpha: 0.7) : UIColor(white: 1, alpha: 0.0marge)
        //        self.player?.forwardView.layoutIfNeeded()
        //
        //        if isFullscreen {
        //            MTAleartManager.shared.speedView.cons1.constant = 29
        //            MTAleartManager.shared.speedView.cons2.constant = 20
        //            MTAleartManager.shared.speedView.cons3.constant = leading
        //            MTAleartManager.shared.speedView.cons4.constant = leading
        //            MTAleartManager.shared.speedView.cons5.constant = leading
        //            MTAleartManager.shared.speedView.cons6.constant = 145
        //            MTAleartManager.shared.speedView.cons7.constant = 32
        //            MTAleartManager.shared.speedView.colorView.isHidden = false
        //            MTAleartManager.shared.speedView.backgroundColor = .clear
        //            MTAleartManager.shared.speedView.backView.backgroundColor = .clear
        //        } else {
        //            MTAleartManager.shared.speedView.cons1.constant = 26
        //            MTAleartManager.shared.speedView.cons2.constant = 34
        //            MTAleartManager.shared.speedView.cons3.constant = 12
        //            MTAleartManager.shared.speedView.cons4.constant = 0
        //            MTAleartManager.shared.speedView.cons5.constant = 0
        //            MTAleartManager.shared.speedView.cons6.constant = kBottomSafeAreaHeight + 1marge6
        //            MTAleartManager.shared.speedView.cons7.constant = marge2
        //            if isUrl {
        //                MTAleartManager.shared.speedView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        //                MTAleartManager.shared.speedView.backView.backgroundColor = UIColor.dark45ColorWithAlpha()
        //                MTAleartManager.shared.speedView.colorView.isHidden = true
        //            } else {
        //                MTAleartManager.shared.speedView.backgroundColor = .clear
        //                MTAleartManager.shared.speedView.backView.backgroundColor = .clear
        //                MTAleartManager.shared.speedView.colorView.isHidden = false
        //            }
        //        }
        //        MTAleartManager.shared.speedView.layoutSubviews()
        //
        //        if isUrl {
        //            if isFullscreen {
        //                MTAleartManager.shared.subtitlesView.verView.isHidden = true
        //                MTAleartManager.shared.subtitlesView.tapView.isHidden = true
        //                MTAleartManager.shared.subtitlesView.horView.isHidden = false
        //                MTAleartManager.shared.subtitlesView.horTapView.isHidden = false
        //                MTAleartManager.shared.subtitlesView.backgroundColor = .clear
        //                MTAleartManager.shared.subtitlesView.colorView.isHidden = false
        //
        //                MTAleartManager.shared.subtitlesListView.verView.isHidden = true
        //                MTAleartManager.shared.subtitlesListView.verTapView.isHidden = true
        //                MTAleartManager.shared.subtitlesListView.horView.isHidden = false
        //                MTAleartManager.shared.subtitlesListView.horTapView.isHidden = false
        //                MTAleartManager.shared.subtitlesListView.backgroundColor = .clear
        //                MTAleartManager.shared.subtitlesListView.colorView.isHidden = false
        //            } else {
        //                MTAleartManager.shared.subtitlesView.verView.isHidden = false
        //                MTAleartManager.shared.subtitlesView.tapView.isHidden = false
        //                MTAleartManager.shared.subtitlesView.horView.isHidden = true
        //                MTAleartManager.shared.subtitlesView.horTapView.isHidden = true
        //                MTAleartManager.shared.subtitlesView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        //                MTAleartManager.shared.subtitlesView.colorView.isHidden = true
        //
        //                MTAleartManager.shared.subtitlesListView.verView.isHidden = false
        //                MTAleartManager.shared.subtitlesListView.verTapView.isHidden = false
        //                MTAleartManager.shared.subtitlesListView.horView.isHidden = true
        //                MTAleartManager.shared.subtitlesListView.horTapView.isHidden = true
        //                MTAleartManager.shared.subtitlesListView.backgroundColor = UIColor(white: 0, alpha: 0.7)
        //                MTAleartManager.shared.subtitlesListView.colorView.isHidden = true
        //            }
        //            MTAleartManager.shared.subtitlesView.layoutSubviews()
        //            MTAleartManager.shared.subtitlesListView.layoutSubviews()
        //        }
        //
        //        self.player?.bringSubviewToFront(self.player!.forwardView)
        //        self.player?.bringSubviewToFront(self.player!.sliderView)
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineHeightMultiple = 1.0
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0, alpha: 0.75)
        shadow.shadowBlurRadius = 7
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        self.subtileAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: isFullscreen ? 16 : 12, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.strokeColor: UIColor.red, NSAttributedString.Key.strokeWidth: -0.3, NSAttributedString.Key.paragraphStyle: paragraph, NSAttributedString.Key.shadow: shadow]
        
        subtitleBackView.snp.remakeConstraints {  make in
            make.bottom.equalTo(self.snp.bottom).offset(isFullscreen ? -24 : -16)
            make.centerX.equalTo(self.snp.centerX)
            make.width.lessThanOrEqualTo(self.snp.width).offset(isFullscreen ? -57 : -20).priority(750)
        }
        
        self.layoutIfNeeded()
        self.player?.layoutIfNeeded()
        
    }
    
    /**
     Call when video play's to the end, override if you need custom UI or animation when played to the end
     */
    func showPlayToTheEndView() {
        //        replayBtn.isHidden = false
    }
    
    func hidePlayToTheEndView() {
        //        replayBtn.isHidden = true
    }
    
    func showLoader() {
        ProgressHUD.showLoading()
        //        loadingIndicator.isHidden = false
        //        loadingIndicator.selectAnimation()
    }
    
    func hideLoader() {
        ProgressHUD.dismiss()
        //        loadingIndicator.isHidden = true
        //        loadingIndicator.defaultAnimation()
    }
    
    func hideSeekToView() {
        seekToView.isHidden = true
    }
    
    func showCoverWithLink(_ cover:String) {
        self.showCover(url: URL(string: cover))
    }
    
    func showCover(url: URL?) {
        if let url = url {
            DispatchQueue.global(qos: .default).async { [weak self] in
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async(execute: { [weak self] in
                    guard let self = self else { return }
                    if let data = data {
                        self.ImageView.image = UIImage(data: data)
                    } else {
                        self.ImageView.image = nil
                    }
                    //                    self.hideLoader()
                });
            }
        }
    }
    
    func hideCoverImageView() {
        self.ImageView.isHidden = true
    }
    
    func prepareChooseDefinitionView() {
        guard let resource = resource else {
            return
        }
        for item in chooseDefinitionView.subviews {
            item.removeFromSuperview()
        }
        
        for i in 0..<resource.definitions.count {
            //            let button = BMPlayerClearityChooseButton()
            let button = UIButton()
            if i == 0 {
                button.tag = selectedIndex
            } else if i <= selectedIndex {
                button.tag = i - 1
            } else {
                button.tag = i
            }
            
            button.setTitle("\(resource.definitions[button.tag].definition)", for: UIControl.State())
            chooseDefinitionView.addSubview(button)
            button.addTarget(self, action: #selector(self.onDefinitionSelected(_:)), for: UIControl.Event.touchUpInside)
            button.snp.makeConstraints({ (make) in
                //                guard let `self` = self else { return }
                make.top.equalTo(chooseDefinitionView.snp.top).offset(35 * i)
                make.width.equalTo(50)
                make.height.equalTo(25)
                make.centerX.equalTo(chooseDefinitionView)
            })
            
            if resource.definitions.count == 1 {
                button.isEnabled = false
                button.isHidden = true
            }
        }
    }
    
    func prepareToDealloc() {
        self.delayItem = nil
    }
    
    // MARK: - Action Response
    /**
     Call when some action button Pressed
     
     - parameter button: action Button
     */
    @objc func onButtonPressed(_ button: UIButton) {
        fadeOutControlViewWithAnimation()
        if let type = HKButtonType(rawValue: button.tag) {
            switch type {
            case .play, .replay:
                if  playerState == .end {
                    hidePlayToTheEndView()
                }
            case .lock:
                self.lockBtn.isSelected = !self.lockBtn.isSelected
                HKPlayerManager.share.isLock = self.lockBtn.isSelected
                self.setLockStatus(self.lockBtn.isSelected)
            default:
                break
            }
        }
        delegate?.controlView(controlView: self, didPressButton: button)
    }
    
    private func setLockStatus(_ lock: Bool = false) {
        self.backBtn.isEnabled = !lock
        self.nextBtn.isEnabled = !lock
        self.ccButton.isEnabled = !lock
        self.epsButton.isEnabled = !lock
        self.fullscreenButton.isEnabled = !lock
        self.playButton.isEnabled = !lock
        self.play1Btn.isEnabled = !lock
        self.forword1Button.isEnabled = !lock
        self.backword1Button.isEnabled = !lock
        self.timeSlider.isEnabled = !lock
    }
    /**
     Call when the tap gesture tapped
     
     - parameter gesture: tap gesture
     */
    @objc func onTapGestureTapped(_ gesture: UITapGestureRecognizer) {
        if  playerState == .end {
            return
        }
        controlViewAnimation(isShow: !isShowing)
    }
    
    @objc func ondoubleGestureRecognized(_ gesture: UITapGestureRecognizer) {
        guard let player = player else { return }
        guard  playerState == .ready ||  playerState == .waiting ||  playerState == .finished else { return }
        
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }
    
    @objc func onleftGestureRecognized(_ gesture: UITapGestureRecognizer) {
        self.backword()
    }
    
    @objc func onrightGestureRecognized(_ gesture: UITapGestureRecognizer) {
        self.forword()
    }
    
    func backword() {
        guard let player = player else { return }
        if player.currentPosition > 1 {
            if player.currentPosition > 15 {
                player.seek(player.currentPosition - 15)
            } else {
                player.seek(0)
            }
        }
    }
    
    func forword() {
        guard let player = player else { return }
        if player.totalDuration - player.currentPosition > 15 {
            player.seek(player.currentPosition + 15)
        } else {
            player.seek(player.totalDuration)
        }
    }
    
    // MARK: - handle UI slider actions
    @objc func progressSliderToucMTegan(_ sender: UISlider)  {
        self.player?.tempIsPlaying = self.player?.isPlaying ?? true
        self.player?.pause()
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchDown)
    }
    
    @objc func progressSliderValueChanged(_ sender: UISlider)  {
        hidePlayToTheEndView()
        cancelAutoFadeOutAnimation()
        let currentTime = Double(sender.value) * totalDuration
        currentTimeL.text = HKPlayer.formatSecondsToString(currentTime, duration: totalDuration)
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchDown)
    }
    
    @objc func progressSliderTouchEnded(_ sender: UISlider)  {
        fadeOutControlViewWithAnimation()
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchUpInside)
    }
    
    
    // MARK: - private functions
    fileprivate func showSubtile(from subtitle: HKSubtitles?, at time: TimeInterval) {
        DispatchQueue.main.async {
            if let subtitle = subtitle, let group = subtitle.search(for: time), HKPlayerManager.share.subtitleOn == true {
                self.subtitleBackView.isHidden = false
                self.subtitleL.attributedText = NSAttributedString(string: group.text, attributes: self.subtileAttribute)
            } else {
                self.subtitleBackView.isHidden = true
            }
        }
    }
    
    @objc fileprivate func onDefinitionSelected(_ button:UIButton) {
        let height = isSelectDefinition ? 35 : resource!.definitions.count * 40
        chooseDefinitionView.snp.updateConstraints { (make) in
            make.height.equalTo(height)
        }
        
        UIView.animate(withDuration: 0.3, animations: {[weak self] in
            self?.layoutIfNeeded()
        })
        isSelectDefinition = !isSelectDefinition
        if selectedIndex != button.tag {
            selectedIndex = button.tag
            delegate?.controlView(controlView: self, didChooseDefinition: button.tag)
        }
        prepareChooseDefinitionView()
    }
    
    @objc fileprivate func onReplyButtonPressed() {
        //        replayBtn.isHidden = true
    }
    
    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUIComponents()
        addSnapKitConstraint()
        customizeUIComponents()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUIComponents()
        addSnapKitConstraint()
        customizeUIComponents()
    }
    
    /// Add Customize functions here
    func customizeUIComponents() {
        
    }
    
    func setupUIComponents() {
        let graph = NSMutableParagraphStyle()
        graph.alignment = .center
        graph.lineHeightMultiple = 1.0
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0, alpha: 0.75)
        shadow.shadowBlurRadius = 7
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        self.subtileAttribute = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.strokeColor: UIColor.red, NSAttributedString.Key.strokeWidth: -0.3, NSAttributedString.Key.paragraphStyle: graph, NSAttributedString.Key.shadow: shadow]
        // Subtile view
        subtitleL.numberOfLines = 0
        subtitleL.textAlignment = .center
        subtitleBackView.backgroundColor = .clear
        subtitleBackView.addSubview(subtitleL)
        subtitleBackView.isHidden = true
        
        addSubview(subtitleBackView)
        
        // Mainview
        addSubview(mainView)
        mainView.addSubview(leftView)
        mainView.addSubview(rightView)
        mainView.addSubview(topView)
        mainView.addSubview(bottomView)
        mainView.addSubview(centerView)
        mainView.insertSubview(ImageView, at: 0)
        mainView.clipsToBounds = true
        mainView.backgroundColor = UIColor(white: 0, alpha: 0.4 )
        mainView.bringSubviewToFront(topView)
        
        leftView.backgroundColor   = UIColor.clear
        rightView.backgroundColor  = UIColor.clear
        
        // Top views
        topView.addSubview(topWrapperView)
        topWrapperView.addSubview(backBtn)
        //        topWrapperView.addSubview(rate1Button)
        
        topWrapperView.addSubview(titleLabel)
        topWrapperView.addSubview(chooseDefinitionView)
        
        backBtn.tag = HKButtonType.back.rawValue
        backBtn.setImage(UIImage(named: "play_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        //        rate1Button.tag = HKButtonType.rate.rawValue
        //        rate1Button.setTitle("\(self.playRate)X", for: .normal)
        //        rate1Button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        //        rate1Button.backgroundColor = .clear
        //        rate1Button.layer.cornerRadius = 2
        //        rate1Button.layer.borderColor = UIColor.white.cgColor
        //        rate1Button.layer.borderWidth = 1
        //        rate1Button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        //        rate1Button.isHidden = true
        
        ccButton.tag = HKButtonType.cc.rawValue
        ccButton.setImage(UIImage(named: "play_captions"), for: .normal)
        ccButton.setImage(UIImage(named: "play_unCaptions"), for: .disabled)
        ccButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        //        ccButton.isHidden = true
        
        epsButton.tag = HKButtonType.eps.rawValue
        epsButton.setImage(UIImage(named: "play_eps"), for: .normal)
        epsButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        titleLabel.textColor = UIColor.white
        titleLabel.font      = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        chooseDefinitionView.clipsToBounds = true
        
        // Bottom views
        bottomView.addSubview(bottomWrapperView)
        bottomWrapperView.addSubview(playButton)
        //        bottomWrapperView.addSubview(forwordBtn)
        //        bottomWrapperView.addSubview(backwordBtn)
        bottomWrapperView.addSubview(currentTimeL)
        //        bottomWrapperView.addSubview(centerTimeLabel)
        bottomWrapperView.addSubview(totalTimeLabel)
        bottomWrapperView.addSubview(progressView)
        bottomWrapperView.addSubview(timeSlider)
        bottomWrapperView.addSubview(nextBtn)
        bottomWrapperView.addSubview(epsButton)
        bottomWrapperView.addSubview(fullscreenButton)
        //        bottomWrapperView.addSubview(airPlayButton)
        //        bottomWrapperView.addSubview(rateButton)
        
        //        bottomWrapperView.setColorLayerVertical(colorO: UIColor.clear, colorT: UIColor(white: 0, alpha: 0.65), frame: CGRect(x: 0, y: 0, width: kScreenHeight, height: 200))
        
        playButton.tag = HKButtonType.play.rawValue
        playButton.setImage(UIImage(named: "play_play"),  for: .normal)
        playButton.setImage(UIImage(named: "play_pause"), for: .selected)
        playButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        //        forwordBtn.tag = HKButtonType.forword.rawValue
        //        forwordBtn.setImage(UIImage(named: "back"),  for: .normal)
        //        forwordBtn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        //
        //        backwordBtn.tag = HKButtonType.backword.rawValue
        //        backwordBtn.setImage(UIImage(named: "Fast forward"),  for: .normal)
        //        backwordBtn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        currentTimeL.textColor  = UIColor.white
        currentTimeL.font       = UIFont.systemFont(ofSize: 10, weight: .medium)
        currentTimeL.text       = "00:00"
        currentTimeL.textAlignment = NSTextAlignment.center
        
        //        centerTimeLabel.textColor    = UIColor(white: 1, alpha: 0.5)
        //        centerTimeLabel.font         = UIFont.systemFont(ofSize: 12, weight: .regular)
        //        centerTimeLabel.text         = "/"
        //        centerTimeLabel.textAlignment   = NSTextAlignment.center
        
        totalTimeLabel.textColor    = UIColor.white
        totalTimeLabel.font         = UIFont.systemFont(ofSize: 10, weight: .medium)
        totalTimeLabel.text         = "00:00"
        totalTimeLabel.textAlignment   = NSTextAlignment.center
        
        
        timeSlider.maximumValue = 1.0
        timeSlider.minimumValue = 0.0
        timeSlider.value        = 0.0
        timeSlider.setThumbImage(IMG("play_timeslider"), for: .normal)
        timeSlider.maximumTrackTintColor = UIColor.hex("#FFFFFF", alpha: 0.5)
        timeSlider.minimumTrackTintColor = UIColor.hex("#FF4131")
        
        //        timeSlider.setMinimumTrackImage(UIImage(named: "play_timeslider"), for: .normal)
        
        timeSlider.addTarget(self, action: #selector(progressSliderToucMTegan(_:)),
                             for: UIControl.Event.touchDown)
        
        timeSlider.addTarget(self, action: #selector(progressSliderValueChanged(_:)),
                             for: UIControl.Event.valueChanged)
        
        timeSlider.addTarget(self, action: #selector(progressSliderTouchEnded(_:)),
                             for: [UIControl.Event.touchUpInside,UIControl.Event.touchCancel, UIControl.Event.touchUpOutside])
        
        progressView.tintColor      = UIColor.hex("#FF4131", alpha: 0.4)
        //        progressView.trackTintColor = UIColor.hex("#FF4131", alpha: 0.4)
        
        mainView.addSubview(lockBtn)
        
        nextBtn.tag = HKButtonType.next.rawValue
        nextBtn.setImage(UIImage(named: "play_next"), for: .normal)
        nextBtn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        lockBtn.tag = HKButtonType.lock.rawValue
        lockBtn.setImage(UIImage(named: "play_unlock"), for: .normal)
        lockBtn.setImage(UIImage(named: "play_lock"), for: .selected)
        lockBtn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        lockBtn.isHidden = true
        
        fullscreenButton.tag = HKButtonType.fullscreen.rawValue
        fullscreenButton.setImage(UIImage(named: "play_offscreen"), for: .normal)
        fullscreenButton.setImage(UIImage(named: "play_fullscreen"), for: .selected)
        fullscreenButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        //        airPlayButton.activeTintColor = .white
        //        airPlayButton.tintColor = .white
        
        //        rateButton.tag = HKButtonType.rate.rawValue
        //        rateButton.setTitle("\(self.playRate)X", for: .normal)
        //        rateButton.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        //        rateButton.backgroundColor = .clear
        //        rateButton.layer.cornerRadius = 4
        //        rateButton.layer.borderColor = UIColor.white.cgColor
        //        rateButton.layer.borderWidth = 1
        //        rateButton.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        centerView.addSubview(centerWrapperView)
        centerWrapperView.addSubview(play1Btn)
        centerWrapperView.addSubview(backword1Button)
        centerWrapperView.addSubview(forword1Button)
        
        play1Btn.tag = HKButtonType.play.rawValue
        play1Btn.setImage(UIImage(named: "play_play_full"),  for: .normal)
        play1Btn.setImage(UIImage(named: "play_pause_full"), for: .selected)
        play1Btn.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        forword1Button.tag = HKButtonType.forword.rawValue
        forword1Button.setImage(UIImage(named: "play_forward"),  for: .normal)
        forword1Button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        backword1Button.tag = HKButtonType.backword.rawValue
        backword1Button.setImage(UIImage(named: "play_backward"),  for: .normal)
        backword1Button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        
        //        mainView.addSubview(loadingIndicator)
        //        loadingIndicator.frame = CGRect(x: 0, y: 0, width: 70, height: 70)
        //        loadingIndicator.type  = BMPlayerConf.loaderType
        //        loadingIndicator.color = BMPlayerConf.tintColor
        
        // View to show when slide to seek
        addSubview(seekToView)
        //        seekToView.addSubview(seekToViewImage)
        seekToView.addSubview(seekToEffView)
        seekToView.addSubview(seekToLabel)
        seekToView.addSubview(offsetToLabel)
        
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame.size = CGSize(width: 134, height: 72)
        seekToEffView.addSubview(blurView)
        
        seekToLabel.font                  = UIFont.systemFont(ofSize: 18)
        seekToLabel.textColor             = .white
        seekToLabel.textAlignment         = .center
        offsetToLabel.font                = UIFont.systemFont(ofSize: 12)
        offsetToLabel.textColor           = .white
        offsetToLabel.textAlignment       = .center
        seekToView.backgroundColor        = UIColor(white: 1, alpha: 0.08)
        seekToView.layer.cornerRadius     = 2
        seekToView.layer.masksToBounds    = true
        seekToView.isHidden               = true
        seekToEffView.layer.cornerRadius  = 2
        seekToEffView.layer.masksToBounds = true
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGestureTapped(_:)))
        addGestureRecognizer(tapGesture)
        
        if HKPlayerManager.share.enablePlayControlGestures {
            doubleGesture = UITapGestureRecognizer(target: self, action: #selector(ondoubleGestureRecognized(_:)))
            doubleGesture.numberOfTapsRequired = 2
            doubleGesture.delegate = self
            addGestureRecognizer(doubleGesture)
            
            tapGesture.require(toFail: doubleGesture)
        }
        
        leftGesture = UITapGestureRecognizer(target: self, action: #selector(onleftGestureRecognized(_:)))
        leftGesture.numberOfTapsRequired = 2
        leftView.addGestureRecognizer(leftGesture)
        
        tapGesture.require(toFail: leftGesture)
        
        rightGesture = UITapGestureRecognizer(target: self, action: #selector(onrightGestureRecognized(_:)))
        rightGesture.numberOfTapsRequired = 2
        rightView.addGestureRecognizer(rightGesture)
        
        tapGesture.require(toFail: rightGesture)
    }
    
    func addSnapKitConstraint() {
        // Main  view
        mainView.snp.makeConstraints {  make in
            make.edges.equalTo(self)
        }
        
        leftView.snp.makeConstraints {  make in
            make.top.leading.bottom.equalTo(self.mainView)
            make.width.equalTo(kScreenWidth * 0.45)
        }
        
        rightView.snp.makeConstraints {  make in
            make.top.trailing.bottom.equalTo(self.mainView)
            make.width.equalTo(kScreenWidth * 0.45)
        }
        
        ImageView.snp.makeConstraints {  make in
            make.edges.equalTo(self.mainView)
        }
        
        topView.snp.makeConstraints {  make in
            make.top.leading.trailing.equalTo(self.mainView)
        }
        
        topWrapperView.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints {  make in
            make.bottom.leading.trailing.equalTo(self.mainView)
        }
        
        bottomWrapperView.snp.makeConstraints { (make) in
            make.height.equalTo(200)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        centerView.snp.makeConstraints {  make in
            make.bottom.leading.trailing.equalTo(self.mainView)
        }
        
        centerWrapperView.snp.makeConstraints { (make) in
            make.height.equalTo(56)
            make.top.leading.trailing.equalToSuperview()
        }
        
        // Top views
        backBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.leading.equalToSuperview().offset(marge)
            make.bottom.equalToSuperview()
        }
        
        //        rate1Button.snp.makeConstraints {  make in
        //            make.width.equalTo(40)
        //            make.height.equalTo(20)
        //            make.trailing.equalToSuperview().offset(-10)
        //            make.centerY.equalTo(self.backBtn)
        //        }
        
        //        ccButton.snp.makeConstraints {  make in
        //            make.width.height.equalTo(40)
        //            make.trailing.equalTo(-marge)
        //            make.centerY.equalTo(self.backBtn)
        //        }
        
        lockBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(backBtn)
            make.width.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {  make in
            make.leading.equalTo(self.backBtn.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-130)
            make.centerY.equalTo(self.backBtn)
        }
        
        chooseDefinitionView.snp.makeConstraints {  make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(self.titleLabel.snp.top).offset(-4)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        // Bottom views
        
        //        backwordBtn.snp.makeConstraints {  make in
        //            make.width.height.equalTo(40)
        //            make.leading.equalToSuperview().offset(4)
        //            make.bottom.equalToSuperview().offset(-1marge)
        //        }
        
        playButton.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.equalTo(marge)
            make.bottom.equalToSuperview().offset(-marge)
        }
        
        //        forwordBtn.snp.makeConstraints { (make) in
        //            make.width.height.equalTo(40)
        //            make.leading.equalTo(playButton.snp.trailing).offset(14)
        //            make.centerY.equalTo(backwordBtn)
        //        }
        
        currentTimeL.snp.makeConstraints {  make in
            make.centerY.equalTo(self.playButton)
            make.left.equalTo(self.playButton.snp.right).offset(marge)
            make.height.equalTo(17)
        }
        
        //        centerTimeLabel.snp.makeConstraints {  make in
        //            make.centerY.equalTo(self.currentTimeL)
        //            make.leading.equalTo(self.currentTimeL.snp.trailing)
        //        }
        
        totalTimeLabel.snp.makeConstraints {  make in
            make.centerY.equalTo(self.playButton)
            make.right.equalTo(self.fullscreenButton.snp.left).offset(-marge)
        }
        
        timeSlider.snp.makeConstraints {  make in
            make.centerY.equalTo(self.playButton)
            make.left.equalTo(currentTimeL.snp.right).offset(marge)
            make.right.equalTo(totalTimeLabel.snp.left).offset(-marge)
            make.height.equalTo(30)
        }
        
        progressView.snp.makeConstraints {  make in
            make.leading.trailing.equalTo(self.timeSlider)
            make.centerY.equalTo(self.timeSlider).offset(1)
            make.height.equalTo(4)
        }
        
        fullscreenButton.snp.makeConstraints {  make in
            make.width.height.equalTo(40)
            make.bottom.right.equalToSuperview().offset(-marge)
        }
        
        //        airPlayButton.snp.makeConstraints {  make in
        //            make.width.height.equalTo(36)
        //            make.centerY.equalTo(self.playButton)
        //            make.trailing.equalTo(self.fullscreenButton.snp.leading)
        //        }
        
        //        rateButton.snp.makeConstraints {  make in
        //            make.width.equalTo(30)
        //            make.height.equalTo(20)
        //            make.centerY.equalTo(self.playButton)
        //            make.trailing.equalTo(self.fullscreenButton.snp.leading).offset(-marge)
        //        }
        
        play1Btn.snp.makeConstraints { (make) in
            make.width.height.equalTo(56)
            make.center.equalToSuperview()
        }
        
        backword1Button.snp.makeConstraints {  make in
            make.width.height.equalTo(32)
            make.trailing.equalTo(play1Btn.snp.leading).offset(-48)
            make.centerY.equalToSuperview()
        }
        
        forword1Button.snp.makeConstraints { (make) in
            make.width.height.equalTo(32)
            make.leading.equalTo(play1Btn.snp.trailing).offset(48)
            make.centerY.equalToSuperview()
        }
        
        //        loadingIndicator.snp.makeConstraints {  make in
        //            make.center.equalTo(self.mainView)
        //            make.width.height.equalTo(70)
        //        }
        
        // View to show when slide to seek
        seekToView.snp.makeConstraints {  make in
            make.centerX.equalTo(self.snp.centerX)
            make.top.equalToSuperview().offset(kNavBarHeight + 32)
            make.width.equalTo(134)
            make.height.equalTo(72)
        }
        
        seekToEffView.snp.makeConstraints {  make in
            make.center.equalTo(self.snp.center)
            make.width.equalTo(134)
            make.height.equalTo(72)
        }
        
        //        seekToViewImage.snp.makeConstraints {  make in
        //            make.leading.equalTo(self.seekToView.snp.leading).offset(15)
        //            make.centerY.equalTo(self.seekToView.snp.centerY)
        //            make.height.equalTo(15)
        //            make.width.equalTo(25)
        //        }
        
        seekToLabel.snp.makeConstraints {  make in
            make.centerX.equalTo(self.seekToView)
            make.top.equalTo(self.seekToView).offset(11)
            make.height.equalTo(25)
        }
        
        offsetToLabel.snp.makeConstraints {  make in
            make.centerX.equalTo(self.seekToView)
            make.top.equalTo(self.seekToLabel.snp.bottom).offset(marge)
            make.height.equalTo(17)
        }
        
        //        replayBtn.snp.makeConstraints {  make in
        //            make.center.equalTo(self.mainView)
        //            make.width.height.equalTo(50)
        //        }
        
        subtitleBackView.snp.makeConstraints {  make in
            make.bottom.equalTo(self.snp.bottom).offset(-16)
            make.centerX.equalTo(self.snp.centerX)
            make.width.lessThanOrEqualTo(self.snp.width).offset(-20).priority(750)
        }
        
        subtitleL.snp.makeConstraints {  make in
            make.leading.equalTo(self.subtitleBackView.snp.leading).offset(10)
            make.trailing.equalTo(self.subtitleBackView.snp.trailing).offset(-10)
            make.top.equalTo(self.subtitleBackView.snp.top).offset(2)
            make.bottom.equalTo(self.subtitleBackView.snp.bottom).offset(-2)
        }
    }
    
    fileprivate func BMImageResourcePath(_ fileName: String) -> UIImage? {
        let bundle = Bundle(for: HKPlayer.self)
        return UIImage(named: fileName, in: bundle, compatibleWith: nil)
    }
}

extension HKPlayerControlView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if HKPlayerManager.share.isLock {
            return false
        }
        return true
    }
}
