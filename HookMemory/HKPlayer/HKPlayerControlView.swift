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
    
    let leading: CGFloat = 88
    let marge: CGFloat = 8
    let space: CGFloat = 72

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
    var topWrapView = UIView()
    var backBtn = UIButton(type : .custom)
    //    var rate1Button = UIButton(type : .custom)
    var ccButton = UIButton(type : .custom)
    var epsButton = UIButton(type : .custom)
    var titleL = UILabel()
    var definitionChooseView = UIView()
    
    /// bottom view
    var bottomWrapView = UIView()
    var currentTimeL = UILabel()
    //    var centerTimeLabel = UILabel()
    var totalTimeL   = UILabel()
    
    /// Progress slider
    var timeSlider = HKTimeSlider()
    
    /// load progress view
    var progressView = UIProgressView()
    
    /* play button
     playBtn.isSelected = player.isPlaying
     */
    var playBtn = UIButton(type: .custom)
    //    var forwordBtn = UIButton(type: .custom)
    //    var backwordBtn = UIButton(type: .custom)
    
    
    var centerWrapView = UIView()
    var play1Btn = UIButton(type: .custom)
    var forwordBtn = UIButton(type: .custom)
    var backwordBtn = UIButton(type: .custom)
    
    var lockBtn = UIButton(type: .custom)
    /* fullScreen button
     fullscreenBtn.isSelected = player.isFullscreen
     */
    var nextBtn = UIButton(type: .custom)
    var fullscreenBtn = UIButton(type: .custom)
    //    var rateButton = UIButton(type: .custom)
    
    var subtitleL    = UILabel()
    var subtitleBackView = UIView()
    var subtileAttr: [NSAttributedString.Key : Any]?
    
    /// Activty Indector for loading
    
    lazy var loadingView: HKPlayerLoadingView = {
        let view = HKPlayerLoadingView.view()
        return view
    }()
    
    var seekToView       = UIView()
    var seekEffView    = UIView()
    var seekToViewImage  = UIImageView()
    var seekToL      = UILabel()
    var offsetToL    = UILabel()
    
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
        currentTimeL.text = HKPlayer.secondsToFormat(currentTime, duration: totalTime)
        totalTimeL.text   = HKPlayer.secondsToFormat(totalTime, duration: totalTime)
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
            playBtn.isSelected = false
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
        seekToL.text = HKPlayer.secondsToFormat(self.player?.panPosition ?? 0, duration: totalDuration)
        
        if let _ = self.player?.currentPosition {
            let offset = toSecound - (self.player?.panPosition ?? 0)
            offsetToL.text  = "\(offset > 0 ? "+ " : "- ")\(HKPlayer.secondsToFormat(offset, duration: totalDuration))"
        }
                
        let targetTime = HKPlayer.secondsToFormat(toSecound, duration: totalDuration)
        timeSlider.value = Float(toSecound / totalDuration)
        currentTimeL.text = targetTime
    }
    
    func forOrBackSeekToView(_ forword: Bool = false, to toSecound: TimeInterval, total totalDuration:TimeInterval, isAdd: Bool) {
        seekToView.isHidden = false
        seekToL.text = HKPlayer.secondsToFormat(toSecound, duration: totalDuration)
        
        if let _ = self.player?.currentPosition {
            let offset: TimeInterval = forword ? 15 : -15
            offsetToL.text  = "\(offset > 0 ? "+ " : "- ")\(HKPlayer.secondsToFormat(offset, duration: totalDuration))"
        }
                
        let targetTime = HKPlayer.secondsToFormat(toSecound, duration: totalDuration)
        timeSlider.value = Float(toSecound / totalDuration)
        currentTimeL.text = targetTime
        if seekToView.isHidden == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self = self else { return }
                self.seekToView.isHidden = true
            }
        }
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
        titleL.text = resource.name
        preparedefinitionChooseView()
        fadeOutControlViewWithAnimation()
    }
    
    func playStateDidChange(isPlaying: Bool) {
        fadeOutControlViewWithAnimation()
        playBtn.isSelected = isPlaying
        play1Btn.isSelected = isPlaying
    }
    
    /**
     auto fade out controll view with animtion
     */
    func fadeOutControlViewWithAnimation() {
        cancelFadeOutAnimation()
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
    func cancelFadeOutAnimation() {
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
           
            self.centerView.snp.remakeConstraints {
                $0.center.equalToSuperview()
                $0.height.equalTo(56)
                $0.width.equalTo(220)
            }

            if isShow, self.player?.isReminder == false {
                self.centerView.alpha = 1.0
                if self.isFullscreen {
                    self.lockBtn.isHidden = false
                }
            } else {
                self.centerView.alpha = 0
                self.lockBtn.isHidden = true
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
    func setUpdateUI(_ isFull: Bool) {
        isFullscreen = isFull
        fullscreenBtn.isSelected = isFull
        titleL.isHidden = !isFull
        definitionChooseView.isHidden = !HKPlayerManager.share.enableChooseDefinition || !isFull
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
        if isFullscreen, self.isShowing {
            self.lockBtn.isHidden = false
        } else {
            self.lockBtn.isHidden = true
        }
        leftView.snp.remakeConstraints {  make in
            make.top.bottom.equalTo(self.mainView)
            make.left.equalTo(self.space)
            make.width.equalTo(isFullscreen ? ((kScreenHeight - 144) * 0.45) : (kScreenWidth * 0.45))
        }
        
        rightView.snp.remakeConstraints {  make in
            make.top.trailing.bottom.equalTo(self.mainView)
            make.trailing.equalTo(-self.space)
            make.width.equalTo(isFullscreen ? ((kScreenHeight - 144) * 0.45) : (kScreenWidth * 0.45))
        }
        
        backBtn.snp.remakeConstraints { (make) in
            make.width.height.equalTo(44)
            make.leading.equalToSuperview().offset(isFullscreen ? space : marge)
            make.bottom.equalToSuperview()
        }
  
        playBtn.isHidden = isFullscreen
        backwordBtn.isHidden = false
        play1Btn.isHidden = false
        forwordBtn.isHidden = false
        if isFullscreen {
            play1Btn.snp.remakeConstraints { (make) in
                make.width.height.equalTo(48)
                make.center.equalToSuperview()
            }
            
            backwordBtn.snp.remakeConstraints {  make in
                make.width.height.equalTo(48)
                make.trailing.equalTo(play1Btn.snp.leading).offset(-38)
                make.centerY.equalToSuperview()
            }
            
            forwordBtn.snp.remakeConstraints { (make) in
                make.width.height.equalTo(48)
                make.leading.equalTo(play1Btn.snp.trailing).offset(38)
                make.centerY.equalToSuperview()
            }
        } else {
            forwordBtn.isHidden = true
            backwordBtn.isHidden = true
            play1Btn.isHidden = true
        }
        
        currentTimeL.snp.remakeConstraints {  make in
            if isFullscreen {
                make.bottom.equalTo(timeSlider.snp.top).offset(4)
                make.left.equalToSuperview().offset(leading)
            } else {
                make.centerY.equalTo(playBtn)
                make.left.equalTo(playBtn.snp.right)
            }
            make.height.equalTo(17)
        }
        
        totalTimeL.snp.remakeConstraints {  make in
            make.centerY.equalTo(self.currentTimeL)
            if isFullscreen {
                make.right.equalToSuperview().offset(-leading)
            } else {
                make.right.equalTo(fullscreenBtn.snp.left).offset(-marge)
            }
        }
        
        timeSlider.snp.remakeConstraints {  make in
            if isFullscreen {
                make.bottom.equalTo(fullscreenBtn.snp.top)
                make.leading.equalToSuperview().offset(leading)
                make.trailing.equalToSuperview().offset(-leading)
            } else {
                make.centerY.equalTo(playBtn)
                make.leading.equalTo(currentTimeL.snp.trailing).offset(marge)
                make.trailing.equalTo(totalTimeL.snp.leading).offset(-marge)
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
        
        fullscreenBtn.snp.remakeConstraints {  make in
            make.width.height.equalTo(40)
            if isFullscreen {
                make.bottom.equalToSuperview().offset(-16)
                make.trailing.equalToSuperview().offset(-leading + marge)
            } else {
                make.centerY.equalTo(playBtn)
                make.right.equalToSuperview().offset(-marge)
            }
        }
        
        ccButton.removeFromSuperview()
        if isFullscreen {
            bottomWrapView.addSubview(ccButton)
        } else {
            topWrapView.addSubview(ccButton)
        }
        
        ccButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            if isFullscreen {
                make.centerY.equalTo(fullscreenBtn)
                make.right.equalTo(fullscreenBtn.snp.left).offset(-marge)
            } else {
                make.trailing.equalTo(-marge)
                make.centerY.equalTo(self.backBtn)
            }
        }
        
        epsButton.snp.remakeConstraints { make in
            make.width.height.equalTo(40)
            make.centerY.equalTo(fullscreenBtn)
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
                
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        paragraph.lineHeightMultiple = 1.0
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0, alpha: 0.75)
        shadow.shadowBlurRadius = 7
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        self.subtileAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: isFullscreen ? 16 : 12, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.strokeColor: UIColor.red, NSAttributedString.Key.strokeWidth: -0.3, NSAttributedString.Key.paragraphStyle: paragraph, NSAttributedString.Key.shadow: shadow]
        
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
        loadingView.isHidden = false
        loadingView.showAnimation()
    }
    
    func hideLoader() {
        loadingView.isHidden = true
        loadingView.dismissAnimation()
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
    
    func preparedefinitionChooseView() {
        guard let resource = resource else {
            return
        }
        for item in definitionChooseView.subviews {
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
            definitionChooseView.addSubview(button)
            button.addTarget(self, action: #selector(self.onDefinitionSelected(_:)), for: UIControl.Event.touchUpInside)
            button.snp.makeConstraints({ (make) in
                //                guard let `self` = self else { return }
                make.top.equalTo(definitionChooseView.snp.top).offset(35 * i)
                make.width.equalTo(50)
                make.height.equalTo(25)
                make.centerX.equalTo(definitionChooseView)
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
    @objc func clickBtnAction(_ button: UIButton) {
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
        self.fullscreenBtn.isEnabled = !lock
        self.playBtn.isEnabled = !lock
        self.play1Btn.isEnabled = !lock
        self.forwordBtn.isEnabled = !lock
        self.backwordBtn.isEnabled = !lock
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
    @objc func progressSliderTouch(_ sender: UISlider)  {
        self.player?.tempIsPlaying = self.player?.isPlaying ?? true
        self.player?.pause()
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchDown)
    }
    
    @objc func progressSliderChanged(_ sender: UISlider)  {
        hidePlayToTheEndView()
        cancelFadeOutAnimation()
        let currentTime = Double(sender.value) * totalDuration
        currentTimeL.text = HKPlayer.secondsToFormat(currentTime, duration: totalDuration)
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchDown)
    }
    
    @objc func progressSliderEnded(_ sender: UISlider)  {
        fadeOutControlViewWithAnimation()
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchUpInside)
    }
    
    @objc func tapProgressSlider(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.timeSlider)
        let v: Double = point.x / self.timeSlider.frame.size.width
        fadeOutControlViewWithAnimation()
//        delegate?.controlView(controlView: self, value: v, onSliderEvent: .touchUpInside)
    }
    
    // MARK: - private functions
    fileprivate func showSubtile(from subtitle: HKSubtitles?, at time: TimeInterval) {
        DispatchQueue.main.async {
            if let subtitle = subtitle, let group = subtitle.search(for: time), HKPlayerManager.share.subtitleOn == true {
                self.subtitleBackView.isHidden = false
                self.subtitleL.attributedText = NSAttributedString(string: group.text, attributes: self.subtileAttr)
            } else {
                self.subtitleBackView.isHidden = true
            }
        }
    }
    
    @objc fileprivate func onDefinitionSelected(_ button:UIButton) {
        let height = isSelectDefinition ? 35 : resource!.definitions.count * 40
        definitionChooseView.snp.updateConstraints { (make) in
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
        preparedefinitionChooseView()
    }
    
    @objc fileprivate func onReplyButtonPressed() {
        //        replayBtn.isHidden = true
    }
    
    // MARK: - Init
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
        setConstraint()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUI()
        setConstraint()
    }
    
    func setUI() {
        let graph = NSMutableParagraphStyle()
        graph.alignment = .center
        graph.lineHeightMultiple = 1.0
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0, alpha: 0.75)
        shadow.shadowBlurRadius = 7
        shadow.shadowOffset = CGSize(width: 2, height: 2)
        self.subtileAttr = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12, weight: .medium), NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.strokeColor: UIColor.red, NSAttributedString.Key.strokeWidth: -0.3, NSAttributedString.Key.paragraphStyle: graph, NSAttributedString.Key.shadow: shadow]
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
        topView.addSubview(topWrapView)
        topWrapView.addSubview(backBtn)
        //        topWrapView.addSubview(rate1Button)
        
        topWrapView.addSubview(titleL)
        topWrapView.addSubview(definitionChooseView)
        
        backBtn.tag = HKButtonType.back.rawValue
        backBtn.setImage(UIImage(named: "play_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)
        
        ccButton.tag = HKButtonType.cc.rawValue
        ccButton.setImage(UIImage(named: "play_captions"), for: .normal)
        ccButton.setImage(UIImage(named: "play_unCaptions"), for: .disabled)
        ccButton.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)
        
        epsButton.tag = HKButtonType.eps.rawValue
        epsButton.setImage(UIImage(named: "play_eps"), for: .normal)
        epsButton.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)
        
        titleL.textColor = UIColor.white
        titleL.font      = UIFont.systemFont(ofSize: 14, weight: .medium)
        
        definitionChooseView.clipsToBounds = true
        
        // Bottom views
        bottomView.addSubview(bottomWrapView)
        bottomWrapView.addSubview(playBtn)
        bottomWrapView.addSubview(currentTimeL)
        bottomWrapView.addSubview(totalTimeL)
        bottomWrapView.addSubview(progressView)
        bottomWrapView.addSubview(timeSlider)
        bottomWrapView.addSubview(nextBtn)
        bottomWrapView.addSubview(epsButton)
        bottomWrapView.addSubview(fullscreenBtn)
        
        playBtn.tag = HKButtonType.play.rawValue
        playBtn.setImage(UIImage(named: "play_play"),  for: .normal)
        playBtn.setImage(UIImage(named: "play_pause"), for: .selected)
        playBtn.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)
        
        currentTimeL.textColor  = UIColor.white
        currentTimeL.font       = UIFont.systemFont(ofSize: 10, weight: .medium)
        currentTimeL.text       = "00:00"
        currentTimeL.textAlignment = NSTextAlignment.center
        
        totalTimeL.textColor    = UIColor.white
        totalTimeL.font         = UIFont.systemFont(ofSize: 10, weight: .medium)
        totalTimeL.text         = "00:00"
        totalTimeL.textAlignment   = NSTextAlignment.center
        
        currentTimeL.setContentHuggingPriority(.required, for: .horizontal)
        totalTimeL.setContentHuggingPriority(.required, for: .horizontal)
        timeSlider.maximumValue = 1.0
        timeSlider.minimumValue = 0.0
        timeSlider.value        = 0.0
        timeSlider.setThumbImage(IMG("play_timeslider"), for: .normal)
        timeSlider.maximumTrackTintColor = UIColor.hex("#FFFFFF", alpha: 0.5)
        timeSlider.minimumTrackTintColor = UIColor.hex("#FF4131")
                
        timeSlider.addTarget(self, action: #selector(progressSliderTouch(_:)),
                             for: .touchDown)
        
        timeSlider.addTarget(self, action: #selector(progressSliderChanged(_:)),
                             for: .valueChanged)
        
        timeSlider.addTarget(self, action: #selector(progressSliderEnded(_:)),
                             for: [.touchUpInside, .touchCancel, .touchUpOutside])
        
        progressView.tintColor = UIColor.hex("#FF4131", alpha: 0.4)
        
        mainView.addSubview(lockBtn)
        
        nextBtn.tag = HKButtonType.next.rawValue
        nextBtn.setImage(UIImage(named: "play_next"), for: .normal)
        nextBtn.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)
        
        lockBtn.tag = HKButtonType.lock.rawValue
        lockBtn.setImage(UIImage(named: "play_unlock"), for: .normal)
        lockBtn.setImage(UIImage(named: "play_lock"), for: .selected)
        lockBtn.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)
        lockBtn.isHidden = true
        
        fullscreenBtn.tag = HKButtonType.fullscreen.rawValue
        fullscreenBtn.setImage(UIImage(named: "play_offscreen"), for: .normal)
        fullscreenBtn.setImage(UIImage(named: "play_fullscreen"), for: .selected)
        fullscreenBtn.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)
        
        centerView.addSubview(centerWrapView)
        centerWrapView.addSubview(play1Btn)
        centerWrapView.addSubview(backwordBtn)
        centerWrapView.addSubview(forwordBtn)
        
        play1Btn.tag = HKButtonType.play.rawValue
        play1Btn.setImage(UIImage(named: "play_play_full"),  for: .normal)
        play1Btn.setImage(UIImage(named: "play_pause_full"), for: .selected)
        play1Btn.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)
        
        forwordBtn.tag = HKButtonType.forword.rawValue
        forwordBtn.setImage(UIImage(named: "play_forward"),  for: .normal)
        forwordBtn.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)
        
        backwordBtn.tag = HKButtonType.backword.rawValue
        backwordBtn.setImage(UIImage(named: "play_backward"),  for: .normal)
        backwordBtn.addTarget(self, action: #selector(clickBtnAction(_:)), for: .touchUpInside)

        addSubview(seekToView)

        seekToView.addSubview(seekEffView)
        seekToView.addSubview(seekToL)
        seekToView.addSubview(offsetToL)
        
        let blur = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame.size = CGSize(width: 134, height: 72)
        seekEffView.addSubview(blurView)
        
        seekToL.font                  = UIFont.systemFont(ofSize: 18)
        seekToL.textColor             = .white
        seekToL.textAlignment         = .center
        offsetToL.font                = UIFont.systemFont(ofSize: 12)
        offsetToL.textColor           = .white
        offsetToL.textAlignment       = .center
        seekToView.backgroundColor        = UIColor(white: 1, alpha: 0.08)
        seekToView.layer.cornerRadius     = 2
        seekToView.layer.masksToBounds    = true
        seekToView.isHidden               = true
        seekEffView.layer.cornerRadius  = 2
        seekEffView.layer.masksToBounds = true
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGestureTapped(_:)))
        addGestureRecognizer(tapGesture)
        
        if HKPlayerManager.share.enablePlayControlGestures {
            doubleGesture = UITapGestureRecognizer(target: self, action: #selector(ondoubleGestureRecognized(_:)))
            doubleGesture.numberOfTapsRequired = 2
//            doubleGesture.delegate = self
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
    
    func setConstraint() {
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
        
        topWrapView.snp.makeConstraints { (make) in
            make.height.equalTo(44)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints {  make in
            make.bottom.leading.trailing.equalTo(self.mainView)
        }
        
        bottomWrapView.snp.makeConstraints { (make) in
            make.height.equalTo(200)
            make.bottom.leading.trailing.equalToSuperview()
        }
        
        centerView.snp.makeConstraints {  make in
            make.bottom.leading.trailing.equalTo(self.mainView)
        }
        
        centerWrapView.snp.makeConstraints { (make) in
            make.height.equalTo(56)
            make.top.leading.trailing.equalToSuperview()
        }
        
        // Top views
        backBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.leading.equalToSuperview().offset(marge)
            make.bottom.equalToSuperview()
        }
        
        lockBtn.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(backBtn)
            make.width.height.equalTo(40)
        }
        titleL.snp.makeConstraints {  make in
            make.leading.equalTo(self.backBtn.snp.trailing).offset(6)
            make.trailing.equalToSuperview().offset(-130)
            make.centerY.equalTo(self.backBtn)
        }
        
        definitionChooseView.snp.makeConstraints {  make in
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(self.titleL.snp.top).offset(-4)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        playBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(40)
            make.left.equalTo(marge)
            make.bottom.equalToSuperview().offset(-marge)
        }

        currentTimeL.snp.makeConstraints {  make in
            make.centerY.equalTo(self.playBtn)
            make.left.equalTo(self.playBtn.snp.right).offset(marge)
            make.height.equalTo(17)
        }
        
        totalTimeL.snp.makeConstraints {  make in
            make.centerY.equalTo(self.playBtn)
            make.right.equalTo(self.fullscreenBtn.snp.left).offset(-marge)
        }
        
        progressView.snp.makeConstraints {  make in
            make.leading.trailing.equalTo(self.timeSlider)
            make.centerY.equalTo(self.timeSlider)
            make.height.equalTo(4)
        }
        
        fullscreenBtn.snp.makeConstraints {  make in
            make.width.height.equalTo(40)
            make.bottom.right.equalToSuperview().offset(-marge)
        }
    
        play1Btn.snp.makeConstraints { (make) in
            make.width.height.equalTo(48)
            make.center.equalToSuperview()
        }
        
        backwordBtn.snp.makeConstraints {  make in
            make.width.height.equalTo(48)
            make.trailing.equalTo(play1Btn.snp.leading).offset(-38)
            make.centerY.equalToSuperview()
        }
        
        forwordBtn.snp.makeConstraints { (make) in
            make.width.height.equalTo(48)
            make.leading.equalTo(play1Btn.snp.trailing).offset(38)
            make.centerY.equalToSuperview()
        }

        mainView.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(80)
        }

        seekToView.snp.makeConstraints {  make in
            make.center.equalTo(self)
            make.width.equalTo(134)
            make.height.equalTo(72)
        }
        
        seekEffView.snp.makeConstraints {  make in
            make.center.equalTo(self.snp.center)
            make.width.equalTo(134)
            make.height.equalTo(72)
        }
        
        seekToL.snp.makeConstraints {  make in
            make.centerX.equalTo(self.seekToView)
            make.top.equalTo(self.seekToView).offset(11)
            make.height.equalTo(25)
        }
        
        offsetToL.snp.makeConstraints {  make in
            make.centerX.equalTo(self.seekToView)
            make.top.equalTo(self.seekToL.snp.bottom).offset(marge)
            make.height.equalTo(17)
        }
        
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
}

//extension HKPlayerControlView: UIGestureRecognizerDelegate {
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
//        if HKPlayerManager.share.isLock {
//            return false
//        }
//        return true
//    }
//}
