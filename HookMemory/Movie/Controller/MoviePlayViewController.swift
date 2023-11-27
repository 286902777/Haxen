//
//  MoviePlayViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/17.
//

import UIKit

class MoviePlayViewController: UIViewController {
    private var model: MovieVideoModel = MovieVideoModel()
    private var from: HKPlayerFrom = .net
    private var videoModel: MovieVideoInfoModel = MovieVideoInfoModel()
    private let videoHeight = kScreenWidth * 9 / 16
    private var controller = HKPlayerControlView()
    private var player: HKPlayer!
    private var videoId: String = ""
    private var ssnId: String = ""
    private var epsId: String = "" {
        didSet {
            self.controller.isMovie = epsId.count == 0
        }
    }
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
        requestData()
        setupHKPlayerManager()
        setUI()
        setResource()
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: .main) { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.player.pause()
                self.player.playerLayer?.playerLayer?.player = nil
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.player.playerLayer?.playerLayer?.player = self.player.playerLayer?.player
                self.player.play()
            }
        }
        
        NotificationCenter.default.addObserver(forName: Noti_WindowInterface, object: nil, queue: .main) { [weak self] noti in
            DispatchQueue.main.async {
                if let self = self, let land = noti.userInfo?["isLandscape"] as? Int {
                    let isLand = land == 1
                    ScreenisFull = isLand
                    self.changeOrientation(isLand: isLand)
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
        self.setCoverImage()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        DispatchQueue.main.async {
            self.player.updateUI(self.player.isFullScreen)
            self.playerTransed(isFull: self.player.isFullScreen)
            self.player.playOrientChanged?(self.player.isFullScreen)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
        if let appdelegate = UIApplication.shared.delegate as? AppDelegate  {
            appdelegate.allowRotate = false
        }
        ProgressHUD.dismiss()
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setUI() {
        view.backgroundColor = UIColor.hex("#141414")
        player = HKPlayer(customControlView: controller)
        view.addSubview(player)
        player.sourceKey = self.model.id
        player.snp.makeConstraints { (make) in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(kStatusBarHeight)
            make.height.equalTo(self.videoHeight)
        }
        
        view.addSubview(remView)
        remView.snp.makeConstraints { make in
            make.center.equalTo(player)
            make.width.equalTo(280)
            make.height.equalTo(120)
        }
        
        player.vc = self
        player.delegate = self
        player.backBlock = { [unowned self] (isFullScreen) in
            if isFullScreen {
                self.player.fullScreenButtonPressed()
            } else {
                self.player.playerLayer?.prepareToDeinit()
                self.controller.isReadyToPlayed = false
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        view.addSubview(self.tableView)
        tableView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(player.snp.bottom)
        }
        self.seekTime = self.model.playedTime
        self.controller.isMovie = epsId.count == 0
        self.view.layoutIfNeeded()
    }
    
    func requestData() {
        ProgressHUD.showLoading()
        MovieAPI.share.movieInfo(ssn_id: self.ssnId, eps_id: self.epsId, id: self.videoId) {  [weak self] success, model in
            guard let self = self else { return }
            if success {
                DispatchQueue.main.async {
                    if let mod = model {
                        self.videoModel = mod
                        if self.model.isMovie == false {
                            self.videoModel.ssn.ssn_list.first(where: {$0.id == self.ssnId})?.isSelect = true
                            self.videoModel.ssn.epss.first(where: {$0.id == self.epsId})?.isSelect = true
                        }
                        self.tableView.isHidden = false
                        self.tableView.reloadData()
                        for (index, item) in self.videoModel.ssn.epss.enumerated() {
                            if item.isSelect {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                                    guard let self = self else { return }
                                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 1), at: .none, animated: false)
                                }
                            }
                        }
                    } else {
                        ProgressHUD.dismiss()
                        self.tableView.isHidden = true
                    }
                }
            }
        }
    }
    
    func setupHKPlayerManager() {
        HKPlayerManager.share.allowLog = false
        HKPlayerManager.share.autoPlay = true
        HKPlayerManager.share.tintColor = .white
        HKPlayerManager.share.topBarInCase = .always
    }
    
    func setResource() {
        self.catptionArr.removeAll()
        controller.ccButton.isEnabled = false
        
        MovieAPI.share.getCaptions(id: self.model.isMovie ? self.videoId : self.epsId, type: self.model.isMovie ? 1 : 0) { [weak self] success, list in
            guard let self = self else { return }
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
        
        self.controller.playRate = 1.0
        self.player.playerLayer?.player?.rate = 1.0
        //        self.controller.rateButton.setTitle("\(self.controller.playRate)X", for: .normal)
        //        self.controller.rate1Button.setTitle("\(self.controller.playRate)X", for: .normal)
        self.remView.isHidden = true
        self.player.isReminder = false
        self.player.playerLayer?.prepareToDeinit()
        self.controller.isReadyToPlayed = false
        var asset: HKPlayerResource?
        MovieAPI.share.getVideoLink(id: self.model.isMovie ? self.videoId : self.epsId, type: self.model.isMovie ? 1 : 0) {[weak self] success, model in
            guard let self = self else { return }
            if success, let mod = model, let link = mod.play_address.AESECB_Decode(), let url = URL(string: link) {
                DispatchQueue.main.async {
                    self.remView.isHidden = true
                    self.player.isReminder = false
                    asset = HKPlayerResource(name: self.model.title, definitions: [HKPlayerResourceConfig(url: url, definition: "480p")], cover: nil, subtitles: self.captions)
                    self.player.setVideo(resource: asset!, sourceKey: self.videoId)
                }
            } else {
                DispatchQueue.main.async {
                    self.remView.isHidden = false
                    self.player.isReminder = true
                }
            }
        }
    }
    
    func playerTransed(isFull: Bool) {
        self.player.snp.remakeConstraints { (make) in
            if isFull {
                make.top.bottom.equalToSuperview()
                make.leading.equalTo(72)
                make.trailing.equalTo(-72)
            } else {
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(kStatusBarHeight)
                make.height.equalTo(self.videoHeight)
            }
        }
    }
    
    func setCoverImage() {
        if let video = DBManager.share.selectVideoData(id: self.videoId) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                let imageV = UIImageView()
                imageV.setImage(with: video.coverImageUrl) { image in
                    if let img = image, img.size.width > img.size.height {
                        self.player.fullScreenButtonPressed()
                    }
                }
            }
        }
    }
    
    func changeOrientation(isLand: Bool) {
        self.player.updateUI(isLand)
        self.player.isFullScreen = isLand
        self.playerTransed(isFull: isLand)
        self.player.playOrientChanged?(isLand)
        self.tableView.isHidden = isLand
    }
}


extension MoviePlayViewController: HKPlayerDelegate {
    // Call when player orinet changed
    func player(player: HKPlayer, playerOrientChanged isFullscreen: Bool) {
        player.snp.remakeConstraints { (make) in
            if isFullscreen {
                make.top.equalTo(view.snp.top)
                make.leading.equalTo(view.snp.leading)
                make.trailing.equalTo(view.snp.trailing)
                make.height.equalTo(kScreenWidth)
            } else {
                make.leading.trailing.equalToSuperview()
                make.top.equalToSuperview().offset(kStatusBarHeight)
                make.height.equalTo(self.videoHeight)
            }
        }
    }
    
    func player(player: HKPlayer, playerIsPlaying playing: Bool) {
        print("playing: \(playing)")
    }
    
    func player(player: HKPlayer, playerStateDidChange state: HKPlayerState) {
        print("play-state: \(state)")
        switch state {
        case .end:
            break
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
        if currentTime == totalTime {
            model.playedTime = 0
            model.playProgress = 0
        } else {
            model.playedTime = Double(currentTime)
            model.playProgress = Double(currentTime) / Double(totalTime)
        }
        DBManager.share.updateVideoPlayData(model)
    }
    
    func player(player: HKPlayer, loadedTimeDidChange loadedDuration: TimeInterval, totalDuration: TimeInterval) {
        
    }
    
    func playerShowEpsView() {
        let epsView = HKPlayerSelectEpsView.view()
        view.addSubview(epsView)
        epsView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(-72)
        }
        epsView.setModel(self.videoId, self.videoModel.ssn) { [weak self] ssnId, epsId in
            guard let self = self else { return }
            self.ssnId = ssnId
            self.epsId = epsId
            self.setResource()
        }
    }
    
    func playerNext() {
        for (index, item) in self.videoModel.ssn.epss.enumerated() {
            if self.epsId == item.id {
                if index == self.videoModel.ssn.epss.count - 1 {
                    for (ssnIdx, mod) in self.videoModel.ssn.ssn_list.enumerated() {
                        if self.ssnId == mod.id {
                            if let model = self.videoModel.ssn.ssn_list.safe(ssnIdx + 1) {
                                self.ssnId = model.id
                                MovieAPI.share.movieTVSSN(ssn_id: self.ssnId, id: self.videoId) { [weak self] success, ssnMod in
                                    guard let self = self else { return }
                                    if let first = ssnMod.eps_list.first {
                                        first.isSelect = true
                                        self.epsId = first.id
                                        self.videoModel.ssn.epss = ssnMod.eps_list
                                        self.setResource()
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                    }
                                }
                            } else {
                                if let mod = DBManager.share.selectVideoData(id: self.videoId, ssn_id: self.ssnId, eps_id: self.epsId) {
                                    mod.playedTime = 0
                                    mod.playProgress = 0
                                    DBManager.share.updateVideoPlayData(model)
                                    self.setResource()
                                }                                
                            }
                        }
                    }
                } else {
                    if let model = self.videoModel.ssn.epss.safe(index + 1) {
                        self.epsId = model.id
                        self.requestData()
                        self.setResource()
                    }
                }
            }
        }
    }
    
    func playerShowCaptionView(_ isfull: Bool) {
        if isfull {
            let capView = HKPlayerCaptionFullSetView.view()
            view.addSubview(capView)
            capView.snp.makeConstraints { make in
                make.left.top.bottom.equalToSuperview()
                make.right.equalTo(-48)
            }
            capView.setModel(self.catptionArr, view: view)
            capView.clickBlock = {[weak self] id in
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
            self.present(vc, animated: false)
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
                                    self.getSeekTime()
                                    self.requestData()
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
                self.getTVData(id, section: section)
            }
            return view
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 0, let model = self.videoModel.ssn.epss.safe(indexPath.row) {
            self.epsId = model.id
            self.model.eps_id = model.id
            DBManager.share.updateVideoData(self.model)
            let _ = self.videoModel.ssn.epss.map({$0.isSelect = false})
            model.isSelect = true
            self.getSeekTime()
            self.tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.model.isMovie == false, section != 0 {
            return 68
        }
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
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

