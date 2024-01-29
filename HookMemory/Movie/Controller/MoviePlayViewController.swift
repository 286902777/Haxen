//
//  MoviePlayViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/17.
//

import UIKit

class MoviePlayViewController: UIViewController {
    private var model: MovieVideoModel = MovieVideoModel()
    private var from: HKPlayerFrom = .home
    private var videoModel: MovieVideoInfoModel = MovieVideoInfoModel()
    private let videoHeight = kScreenWidth * 9 / 16
    private var controller = HKPlayerControlView()
    private var player: HKPlayer!
    private var currentTime: TimeInterval = 0
    private var isPlayAd: Bool = false
    private var videoId: String = ""
    private var videoUrl: String = ""
    private var ssnId: String = ""
    private var midSsnId: String = ""
    private var epsId: String = "" {
        didSet {
            self.controller.isMovie = epsId.count == 0
        }
    }
    private var epsName: String = ""
    private var ssn_eps: String = ""
    private var remView: HKPlayerRemindView = HKPlayerRemindView.view()
    private var captions: HKSubtitles? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.controller.update(subtitles: self?.captions)
            }
        }
    }

    var captionsSelectId = "" {
        didSet {
            self.player.subTitleSelectId = captionsSelectId
        }
    }
    
    private var catptionArr: [MovieCaption] = []
    private let MoviePlayHeadCellID = "MoviePlayHeadCell"
    private let MoviePlayHeadInfoCellID = "MoviePlayHeadInfoCell"
    private let MoviePlayLikeCellID = "MoviePlayLikeCell"
    private let HKPlayEpsListCellID = "HKPlayEpsListCell"
    private var showInfo: Bool = false {
        didSet {
            self.tableView.reloadData()
        }
    }
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(UINib(nibName: String(describing: MoviePlayHeadCell.self), bundle: nil), forCellReuseIdentifier: MoviePlayHeadCellID)
        table.register(UINib(nibName: String(describing: MoviePlayHeadInfoCell.self), bundle: nil), forCellReuseIdentifier: MoviePlayHeadInfoCellID)
        table.register(UINib(nibName: String(describing: MoviePlayLikeCell.self), bundle: nil), forCellReuseIdentifier: MoviePlayLikeCellID)
        table.register(UINib(nibName: String(describing: HKPlayEpsListCell.self), bundle: nil), forCellReuseIdentifier: HKPlayEpsListCellID)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.isHidden = true
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    private var seekTime: Double = 0 {
        didSet {
            self.player.seek(seekTime)
        }
    }
    
    private var getSourceTime : TimeInterval?
    private var statusH = kStatusBarHeight
    private var countPlayTime: Int = 30
    private var timer: Timer?
    private var playLock: Bool = false
    private var epsView: HKPlayerSelectEpsView?
    private var captionView: HKPlayerCaptionFullSetView?
    private var captionVC: HKPlayerCaptionSetView?
    init(model: MovieVideoModel, from: HKPlayerFrom) {
        self.model = model
        self.videoId = self.model.id
        self.ssnId = self.model.ssn_id
        self.epsId = self.model.eps_id
        self.from = from
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setupHKPlayerManager()
        setResource()
//        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                self.player.pause()
//                self.player.playerLayer?.playerLayer?.player = nil
//            }
//        }
//        
//        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
//            DispatchQueue.main.async { [weak self] in
//                guard let self = self else { return }
//                self.player.playerLayer?.playerLayer?.player = self.player.playerLayer?.player
//                self.player.play()
//            }
//        }
        
        NotificationCenter.default.addObserver(forName: UIDevice.orientationDidChangeNotification, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let device = UIDevice.current
                if device.orientation == .landscapeLeft || device.orientation == .landscapeRight{
                    ScreenisFull = true
                    self.onOrientationChanged(isLand: true)
                } else if device.orientation == .portrait || device.orientation == .portraitUpsideDown {
                    if self.playLock == false {
                        ScreenisFull = false
                        self.onOrientationChanged(isLand: false)
                    }
                }
            }
        }
        NotificationCenter.default.addObserver(forName: Noti_CaptionRefresh, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let model = DBManager.share.selectVideoData(id: self.videoId, ssn_id: self.ssnId, eps_id: self.epsId) {
                    if let m =
                        model.captions.first(where: {$0.short_name == HKPlayerManager.share.getLanguage()}) {
                        m.isSelect = true
                    } else {
                        model.captions.first?.isSelect = true
                    }
                    self.catptionArr = model.captions
                    if let caption = model.captions.first(where: { $0.isSelect == true}) {
                        self.captions = HKSubtitles(url: URL(fileURLWithPath: "\(HKCaptionManager.share.path)\(caption.local_address)"), encoding: .utf8)
                        self.captionsSelectId = caption.captionId
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate  {
            appdelegate.allowRotate = true
        }
        
        let device = UIDevice.current
        if device.orientation == .landscapeLeft || device.orientation == .landscapeRight{
            ScreenisFull = true
            self.onOrientationChanged(isLand: true)
        } else if device.orientation == .portrait || device.orientation == .portraitUpsideDown {
            if self.playLock == false {
                ScreenisFull = false
                self.onOrientationChanged(isLand: false)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let name = self.videoModel.ssn.ssn_list.first(where: {$0.isSelect == true})?.title

        HKLog.hk_movie_play_len(movie_id: self.model.id, movie_name: self.model.title, eps_id: self.epsId, eps_name: name ?? "", movie_type: self.model.isMovie ? "1" : "2", watch_len: "\(self.currentTime)", source: "\(from.rawValue)", if_success: self.currentTime > 0 ? "1" : "2")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ProgressHUD.dismiss()
        if self.navigationController == nil {
            if let appdelegate = UIApplication.shared.delegate as? AppDelegate  {
                appdelegate.allowRotate = false
                appdelegate.screenLock = false
            }
            self.player.playerLayer?.prepareToDeinit()
            self.controller.isReadyToPlayed = false
        }
    }
    
    deinit {
        cancelTimer()
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUI() {
        view.backgroundColor = UIColor.hex("#141414")
        player = HKPlayer(customControlView: controller)
        view.addSubview(player)
        player.sourceKey = self.model.id
        player.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(statusH)
            make.height.equalTo(self.videoHeight)
        }
        
        view.addSubview(remView)
        remView.snp.makeConstraints { make in
            make.center.equalTo(player)
            make.width.equalTo(280)
            make.height.equalTo(120)
        }
        
        remView.clickBlock = { [weak self] in
            guard let self = self else { return }
            self.uploadRedmin()
        }
        player.vc = self
        player.delegate = self
        player.backBlock = { [weak self] isFullScreen in
            guard let self = self else { return }
            self.tableView.isHidden = isFullScreen
            if isFullScreen {
                self.player.fullScreenButtonPressed()
            } else {
                self.player.playerLayer?.prepareToDeinit()
                self.controller.isReadyToPlayed = false
                HKConfig.showInterAD(type: .play, placement: .play) { _ in
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
        player.exitFullScreen = { [weak self] full in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.tableView.isHidden = full
            }
        }
        view.addSubview(self.tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(player.snp.bottom)
        }
        self.seekTime = self.model.playedTime
        self.controller.isMovie = epsId.count == 0
        self.view.layoutIfNeeded()
    }
    
    func setResource() {
        self.catptionArr.removeAll()
        controller.ccButton.isEnabled = false
        self.controller.playRate = 1.0
        self.player.playerLayer?.player?.rate = 1.0
        self.remView.isHidden = true
        self.player.isReminder = false
        self.player.playerLayer?.prepareToDeinit()
        self.controller.isReadyToPlayed = false
        var asset: HKPlayerResource?
        
        HKConfig.showInterAD(type: self.player.isFullScreen ? .other : .play, placement: .play) { [weak self] success in
            if success {
                self?.isPlayAd = true
            }
        }
        
        getVideoCaption()
        
        ProgressHUD.showLoading()
        let group = DispatchGroup()
        let dispatchQueue = DispatchQueue.global()
        group.enter()
        dispatchQueue.async { [weak self] in
            guard let self = self else { return }
            MovieAPI.share.movieInfo(ssn_id: self.ssnId, eps_id: self.epsId, id: self.videoId) { success, model in
                if success {
                    if let mod = model {
                        self.videoModel = mod
                        self.videoModel.ssn.ssn_list = self.videoModel.ssn.ssn_list.sorted(by: {Int($0.id) ?? 0 < Int($1.id) ?? 0})
                        if self.model.isMovie == false {
                            self.videoModel.ssn.ssn_list.first(where: {$0.id == self.ssnId})?.isSelect = true
                            self.videoModel.ssn.epss.first(where: {$0.id == self.epsId})?.isSelect = true
                        }
                    }
                }
                group.leave()
            }
        }
        group.enter()
        dispatchQueue.async {[weak self] in
            guard let self = self else { return }
            MovieAPI.share.getVideoLink(id: self.model.isMovie ? self.videoId : self.epsId, type: self.model.isMovie ? 1 : 0) { success, model in
                if success, let mod = model, let link = mod.play_address.AESECB_Decode() {
                    self.videoUrl = link
                }
                group.leave()
            }
        }
        group.notify(queue: dispatchQueue){ [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                self.tableView.isHidden = false
                self.tableView.reloadData()
                for (index, item) in self.videoModel.ssn.epss.enumerated() {
                    if item.isSelect {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.tableView.scrollToRow(at: IndexPath(row: index, section: 1), at: .top, animated: false)
                        }
                        break
                    }
                }
                
                if let url = URL(string: self.videoUrl) {
                    self.getSourceTime = Date().timeIntervalSince1970
                    self.remView.isHidden = true
                    self.player.isReminder = false
                    asset = HKPlayerResource(name: self.videoModel.data.title, definitions: [HKPlayerResourceConfig(url: url, definition: "480p")], cover: nil, subtitles: self.captions)

                    if self.isPlayAd == false {
                        let name = self.videoModel.ssn.ssn_list.first(where: {$0.isSelect == true})?.title
                        HKLog.hk_movie_play_sh(movie_id: self.videoId, movie_name: self.videoModel.data.title, eps_id: self.epsId, eps_name: name ?? "", source: "\(self.from.rawValue)", movie_type: self.model.isMovie ? "1" : "2")
                        self.player.setVideo(resource: asset!, sourceKey: self.videoId)
                    }
                } else {
                    self.tableView.isHidden = true
                    self.remView.isHidden = false
                    self.player.isReminder = true
                }
            }
        }
        HKADManager.share.tempDismissComplete = { [weak self] in
            guard let self = self else { return }
            if self.isPlayAd == true {
                if let a = asset {
                    let name = self.videoModel.ssn.ssn_list.first(where: {$0.isSelect == true})?.title
                    HKLog.hk_movie_play_sh(movie_id: self.videoId, movie_name: self.videoModel.data.title, eps_id: self.epsId, eps_name: name ?? "", source: "\(self.from.rawValue)", movie_type: self.model.isMovie ? "1" : "2")
                    self.player.setVideo(resource: a, sourceKey: self.videoId)
                }
                self.isPlayAd = false
            }
            HKADManager.share.tempDismissComplete = nil
        }
    }
    
    private func getVideoCaption() {
        MovieAPI.share.getCaptions(id: self.model.isMovie ? self.videoId : self.epsId, type: self.model.isMovie ? 1 : 0) { success, list in
            if let listArr = list {
                let m = MovieVideoModel()
                m.id = self.videoId
                m.ssn_id = self.ssnId
                m.eps_id = self.epsId
                var capArr:[MovieCaption] = []
                for (_, itemModel) in listArr.enumerated() {
                    if let item = itemModel {
                        let mod = MovieCaption()
                        mod.captionId = item.id
                        mod.display_name = item.display_name
                        mod.short_name = item.short_name
                        mod.name = item.name
                        mod.original_address = item.original_address
                        capArr.append(mod)
                    }
                }
                m.captions = capArr
                HKCaptionManager.share.downLoadCaptions(m)
            }
        }
    }
    func setupHKPlayerManager() {
        HKPlayerManager.share.allowLog = false
        HKPlayerManager.share.autoPlay = true
        HKPlayerManager.share.tintColor = .white
        HKPlayerManager.share.topBarInCase = .always
    }
    
//    func setResource() {
//        self.catptionArr.removeAll()
//        controller.ccButton.isEnabled = false
//        self.controller.playRate = 1.0
//        self.player.playerLayer?.player?.rate = 1.0
//        self.remView.isHidden = true
//        self.player.isReminder = false
//        self.player.playerLayer?.prepareToDeinit()
//        self.controller.isReadyToPlayed = false
//        var asset: HKPlayerResource?
//        MovieAPI.share.getVideoLink(id: self.model.isMovie ? self.videoId : self.epsId, type: self.model.isMovie ? 1 : 0) {[weak self] success, model in
//            guard let self = self else { return }
//            ProgressHUD.dismiss()
//            if success, let mod = model, let link = mod.play_address.AESECB_Decode(), let url = URL(string: link) {
//                DispatchQueue.main.async {
//                    self.remView.isHidden = true
//                    self.player.isReminder = false
//                    var name = self.model.title
//                    if self.videoModel.data.title.count > 0 {
//                        name = self.videoModel.data.title
//                    }
//                    asset = HKPlayerResource(name: name, definitions: [HKPlayerResourceConfig(url: url, definition: "480p")], cover: nil, subtitles: self.captions)
//                    self.player.setVideo(resource: asset!, sourceKey: self.videoId)
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.remView.isHidden = false
//                    self.player.isReminder = true
//                }
//            }
//        }
//    }
    
    func playerTransed(isFull: Bool) {
        if let vc = self.captionVC, isFull {
            vc.dismiss(animated: false) { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.changeScreenInterfaceOrientation(isFull)
                }
            }
        } else {
            self.changeScreenInterfaceOrientation(isFull)
        }
    }
    
    func changeScreenInterfaceOrientation(_ isFull: Bool) {
        self.player.snp.remakeConstraints { (make) in
            if isFull {
                make.edges.equalToSuperview()
            } else {
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(statusH)
                make.height.equalTo(self.videoHeight)
            }
        }
        if isFull == false {
            if let view = self.epsView {
                view.dismissView()
            }
            if let view = self.captionView {
                view.dismissView()
            }
            if #available(iOS 16.0, *) {
                self.setNeedsUpdateOfSupportedInterfaceOrientations()
                let scene = UIApplication.shared.connectedScenes.first
                guard let windowScene = scene as? UIWindowScene else { return }
                let orientation: UIInterfaceOrientationMask =  UIInterfaceOrientationMask.portrait
                let geometryPreferencesIOS = UIWindowScene.GeometryPreferences.iOS(interfaceOrientations: orientation)
                windowScene.requestGeometryUpdate(geometryPreferencesIOS) { error in
                    print("geometryPreferencesIOS error: \(error)")
                }
            } else {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
        }
    }
    
    func onOrientationChanged(isLand: Bool) {
        if self.playLock == false {
            self.player.isFullScreen = isLand
            self.playerTransed(isFull: isLand)
            self.player.setUpdateUI(isLand)
            self.tableView.isHidden = isLand
        }
    }
    
    // tv播放下一集
    func playNext() {
        for (index, item) in self.videoModel.ssn.epss.enumerated() {
            if self.epsId == item.id {
                if index == self.videoModel.ssn.epss.count - 1 {
                    for (ssnIdx, mod) in self.videoModel.ssn.ssn_list.enumerated() {
                        if self.ssnId == mod.id {
                            print(ssnIdx, self.ssnId, mod.id)
                            if let model = self.videoModel.ssn.ssn_list.safe(ssnIdx + 1) {
                                self.ssnId = model.id
                                MovieAPI.share.movieTVSSN(ssn_id: self.ssnId, id: self.videoId) { [weak self] success, ssnMod in
                                    guard let self = self else { return }
                                    if let first = ssnMod.eps_list.first {
                                        first.isSelect = true
                                        self.epsId = first.id
                                        self.epsName = first.title
                                        self.videoModel.ssn.epss = ssnMod.eps_list
                                        self.setResource()
                                        let _ = self.videoModel.ssn.ssn_list.map({$0.isSelect = false})
                                        self.videoModel.ssn.ssn_list.first(where: {$0.id == self.ssnId})?.isSelect = true
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                                                guard let self = self else { return }
                                                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 1), at: .none, animated: false)
                                            }
                                        }
                                    }
                                }
                                return
                            } else {
                                if let mod = DBManager.share.selectVideoData(id: self.videoId, ssn_id: self.ssnId, eps_id: self.epsId) {
                                    mod.playedTime = 0
                                    mod.playProgress = 0
                                    DBManager.share.updateVideoPlayData(model)
                                    self.setResource()
                                    return
                                }
                            }
                        }
                    }
                } else {
                    if let model = self.videoModel.ssn.epss.safe(index + 1) {
                        self.epsId = model.id
                        self.epsName = model.title
                        self.setResource()
                        return
                    }
                }
            }
        }
    }
    
    func setPlayerTimer() {
        if let _ = timer {
            countPlayTime = 30
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(recordTime), userInfo: nil, repeats: true)
            if let t = timer {
                RunLoop.main.add(t, forMode: .common)
            }
        }
    }
    
    @objc func recordTime() {
        countPlayTime -= 1
        if countPlayTime == 0 {
//            self.remView.isHidden = false
//            self.player.isReminder = true
            cancelTimer()
        }
    }
    
    func cancelTimer() {
        self.controller.hideLoader()
        if (timer != nil) {
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func uploadRedmin() {
        ProgressHUD.showSuccess("Thank you! Your reminder has been recorded.")
        let name = self.videoModel.ssn.ssn_list.first(where: {$0.isSelect == true})?.title
        HKLog.hk_movie_play_cl(kid: "1", movie_id: self.videoId, movie_name: self.model.title, eps_id: self.epsId, eps_name: name ?? "")
        MovieAPI.share.uploadRedmin(id: self.videoId, ssn_id: self.ssnId, eps_id:  self.ssnId, isMoive: self.model.isMovie) { success in
            
        }
    }
}

extension MoviePlayViewController: HKPlayerDelegate {
    // Call when player orinet changed
    func player(player: HKPlayer, playerOrientChanged isFullscreen: Bool) {
        player.snp.remakeConstraints { (make) in
            if isFullscreen {
                make.edges.equalToSuperview()
            } else {
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(statusH)
                make.height.equalTo(self.videoHeight)
            }
        }
    }
    
    func player(player: HKPlayer, playerIsPlaying playing: Bool) {
        print("playing: \(playing)")
    }
    
    func player(player: HKPlayer, playerStateDidChange state: HKPlayerState, errorInfo: String?) {
        print("play-state: \(state)")
        switch state {
        case .ready:
            break
        case .waiting:
            self.setPlayerTimer()
        case .end:
            self.cancelTimer()
            self.playNext()
        case .finished:
            self.cancelTimer()
        case .error:
            if let oldTime = self.getSourceTime {
                let time = Int((Date().timeIntervalSince1970 - oldTime))
                HKLog.hk_playback_status(movie_id: self.videoId, movie_name: self.videoModel.data.title, eps_id: self.epsId, eps_name: self.epsName, movie_type: "\(self.from.rawValue)", cache_len: self.model.isMovie ? "1" : "2", source: "\(time)", if_success: "2", errorinfo: errorInfo ?? "")
            }
        default:
            break
        }
    }
    
    func player(player: HKPlayer, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        let model: MovieVideoModel = MovieVideoModel()
        model.id = self.videoId
        model.ssn_id = self.ssnId
        model.eps_id = self.epsId
        model.totalTime = Double(totalTime)
        model.title = self.videoModel.data.title
        model.coverImageUrl = self.videoModel.data.cover
        model.isMovie = self.model.isMovie
        var ssn_num: String = ""
        for (index, item) in self.videoModel.ssn.ssn_list.enumerated() {
            if item.isSelect {
                ssn_num = "\(index + 1)"
            }
        }
        if let epsModel = self.videoModel.ssn.epss.filter({$0.isSelect == true}).first {
            let num = "\(epsModel.eps_num)"
            model.ssn_eps = "S\(ssn_num.changeTextNum()) E\(num.changeTextNum())"
        }
        if currentTime == totalTime {
            model.playedTime = 0
            model.playProgress = 0
        } else {
            model.playedTime = Double(currentTime)
            model.playProgress = Double(currentTime) / Double(totalTime)
        }
        
        self.currentTime = currentTime
        DBManager.share.updateVideoPlayData(model)
    }
    
    func player(player: HKPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        
    }
    
    func playerShowEpsView() {
        self.epsView = HKPlayerSelectEpsView.view()
        view.addSubview(epsView!)
        epsView?.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(-72)
        }
        let _ = self.videoModel.ssn.ssn_list.map({$0.isSelect = false})
        self.videoModel.ssn.ssn_list.filter({$0.id == self.ssnId}).first?.isSelect = true
        epsView?.setModel(self.videoId, self.videoModel.ssn) { [weak self] epsList, ssnId, epsId in
            guard let self = self else { return }
            self.videoModel.ssn.epss = epsList
            self.ssnId = ssnId
            self.epsId = epsId
            self.setResource()
        }
    }
    
    func playerNext() {
        self.playNext()
    }
    
    func playerShowCaptionView(_ isfull: Bool) {
        if isfull {
            self.captionView = HKPlayerCaptionFullSetView.view()
            view.addSubview(self.captionView!)
            self.captionView?.snp.makeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.right.equalTo(-48)
            }
            self.captionView?.setModel(self.catptionArr, view: view)
            self.captionView?.clickBlock = {[weak self] id in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let caption = self.catptionArr.first(where: { $0.captionId == id}) {
                        self.captions = HKSubtitles(url: URL(fileURLWithPath: "\(HKCaptionManager.share.path)\(caption.local_address)"), encoding: .utf8)
                        self.captionsSelectId = caption.captionId
                    }
                }
            }
        } else {
            let vc = HKPlayerCaptionSetView(list: self.catptionArr)
            vc.clickBlock = { [weak self] id in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if let caption = self.catptionArr.first(where: { $0.captionId == id}) {
                        self.captions = HKSubtitles(url: URL(fileURLWithPath: "\(HKCaptionManager.share.path)\(caption.local_address)"), encoding: .utf8)
                        self.captionsSelectId = caption.captionId
                    }
                }
            }
            vc.modalPresentationStyle = .overFullScreen
            self.captionVC = vc
            self.present(vc, animated: false)
        }
    }
    
    func playerScreenLock(_ lock: Bool) {
        print("lock....", lock)
        self.playLock = lock
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate  {
            appdelegate.screenLock = lock
        }
    }
}
extension MoviePlayViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let cell:MoviePlayHeadCell = tableView.dequeueReusableCell(withIdentifier: MoviePlayHeadCellID) as! MoviePlayHeadCell
                cell.setModel(self.videoModel, moreSelect: self.showInfo) { [weak self] show in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.showInfo = show
                    }
                } refreshBlock: { [weak self] in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.tableView.reloadRows(at: [indexPath], with: .none)
                    }
                }
                
                return cell
            } else {
                let cell:MoviePlayHeadInfoCell = tableView.dequeueReusableCell(withIdentifier: MoviePlayHeadInfoCellID) as! MoviePlayHeadInfoCell
                cell.setModel(self.videoModel)
                return cell
            }
        } else {
            if self.model.isMovie {
                let cell:MoviePlayLikeCell = tableView.dequeueReusableCell(withIdentifier: MoviePlayLikeCellID) as! MoviePlayLikeCell
                let arr = self.filterMovieList()
                if let model = arr.safe(indexPath.row) {
                    cell.setModel(model) { [weak self] index in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            if let mod = model.data.safe(index) {
                                self.videoId = mod.id
                                self.getVideoData(mod) { m in
                                    self.model = m
                                    self.from = .player
                                    HKLog.hk_movie_play_cl(kid: "2", movie_id: self.videoId, movie_name: m.title, eps_id: self.epsId, eps_name: m.title)
                                    self.getSeekTime()
                                }
                            }
                        }
                    }
                }
                return cell
            } else {
                let cell:HKPlayEpsListCell = tableView.dequeueReusableCell(withIdentifier: HKPlayEpsListCellID) as! HKPlayEpsListCell
                if let model = self.videoModel.ssn.epss.safe(indexPath.row) {
                    cell.setModel(model)
                }
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.model.isMovie == false, section != 0 {
            let view = MoviePlaySsnHeadView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 68))
            view.setModel(self.videoModel.ssn.ssn_list) { [weak self] id in
                guard let self = self else { return }
                self.midSsnId = id
                self.getTVData(id, section: section)
            }
            return view
        } 
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0, let model = self.videoModel.ssn.epss.safe(indexPath.row) {
            self.epsId = model.id
            self.epsName = model.title
            if self.midSsnId.count > 0 {
                 self.ssnId = self.midSsnId
            }
            self.model.ssn_id = self.ssnId
            self.model.eps_id = self.epsId
            self.model.playProgress = 0
            self.model.playedTime = 0
            DBManager.share.updateVideoData(self.model)
            let _ = self.videoModel.ssn.epss.map({$0.isSelect = false})
            model.isSelect = true
            self.getSeekTime()
            HKLog.hk_movie_play_cl(kid: "2", movie_id: self.videoId, movie_name: self.model.title, eps_id: self.epsId, eps_name: model.title)
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.model.isMovie == false, section != 0 {
            return 68
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.showInfo ? 2 : 1
        } else {
            if self.model.isMovie {
                return self.filterMovieList().count
            } else {
                return self.videoModel.ssn.epss.count
            }
        }
    }
    
    func filterMovieList() -> [MovieVideoInfoData2Model] {
        let arr = self.videoModel.data_2.filter({($0.data_type == 1 && $0.data.count > 0)})
        return arr
    }
    
    func getVideoData(_ model: MovieDataInfoModel, _ completion: @escaping (_ model: MovieVideoModel) -> ()) {
        if model.isMovie {
            let mod: MovieVideoModel = MovieVideoModel()
            mod.id = model.id
            self.videoId = model.id
            self.ssnId = ""
            self.epsId = ""
            mod.coverImageUrl = model.cover
            mod.isMovie = model.isMovie
            DBManager.share.updateVideoData(model)
            completion(mod)
        } else {
            MovieAPI.share.movieTVSeason(id: model.id) { [weak self] success, list in
                guard let self = self else { return }
                if success, let m = list.last, let mod = m {
                    MovieAPI.share.movieTVSSN(ssn_id: mod.id, id: model.id) { success, ssnMod in
                        if let ssnM = ssnMod.eps_list.first {
                            DispatchQueue.main.async {
                                let videoModel = MovieVideoModel()
                                videoModel.id = model.id
                                videoModel.title = model.title
                                videoModel.coverImageUrl = model.cover
                                videoModel.rate = model.rate
                                videoModel.ssn_eps = model.ss_eps
                                videoModel.country = model.country
                                videoModel.ssn_id = mod.id
                                videoModel.ssn_name = mod.title
                                videoModel.eps_id = ssnM.id
                                videoModel.eps_num = ssnM.eps_num
                                videoModel.eps_name = ssnM.title
                                videoModel.isMovie = false
                                self.ssnId = mod.id
                                self.epsId = ssnM.id
                                self.epsName = ssnM.title
                                self.videoId = model.id
                                DBManager.share.updateVideoData(videoModel)
                                completion(videoModel)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getTVData(_ ssnId: String, section: Int) {
        if let _ = self.videoModel.ssn.ssn_list.first(where: {$0.isSelect == true && $0.id == ssnId}) {
            return
        } else {
            let _ = self.videoModel.ssn.ssn_list.map({$0.isSelect = false})
            self.videoModel.ssn.ssn_list.first(where: {$0.id == ssnId})?.isSelect = true
        }
        MovieAPI.share.movieTVSSN(ssn_id: ssnId, id: self.videoId) { [weak self] success, ssnMod in
            guard let self = self else { return }
            ssnMod.eps_list.first(where: {$0.id == self.epsId})?.isSelect = true
            self.videoModel.ssn.epss = ssnMod.eps_list
            DispatchQueue.main.async {
                self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
                for (index, item) in self.videoModel.ssn.epss.enumerated() {
                    if item.isSelect {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            self.tableView.scrollToRow(at: IndexPath(row: index, section: section), at: .none, animated: false)
                        }
                    }
                }
            }
        }
    }
    
    func getSeekTime() {
        self.setResource()
        if let db = DBManager.share.selectVideoData(id: self.videoId, ssn_id: self.ssnId, eps_id: self.epsId) {
            self.seekTime = db.playedTime
        }
    }
}
