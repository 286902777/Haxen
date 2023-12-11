//
//  MovieSearchViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/9.
//

import UIKit

class MovieSearchViewController: MovieBaseViewController {
    enum searchFrom: Int {
        case home = 1
        case explore
        case list
    }
    let hostUrl = "https://suggestqueries.google.com/complete/search?client=youtube&q="
    let movieSearchCellIdentifier = "MovieSearchCellIdentifier"
    let movieCellIdentifier = "MovieCellIdentifier"
    var searchKeys: [String] = []
    var dataArr: [MovieDataInfoModel] = []
    private var page: Int = 1
    private var key: String = ""
    var from: searchFrom = .home
    let cellW = floor((kScreenWidth - 48) / 3)
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(MovieSearchCell.self, forCellReuseIdentifier: movieSearchCellIdentifier)
        table.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: 0, right: 0)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.isHidden = true
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isHidden = true
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        collectionView.register(UINib(nibName: String(describing: MovieCell.self), bundle: nil), forCellWithReuseIdentifier: movieCellIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    lazy var searchView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    var historyView: MovieHistoryView = MovieHistoryView.view()
    
    lazy var textField: UITextField = {
        let view = UITextField()
        view.textColor = UIColor.hex("#141414")
        view.font = .font(weigth: .medium, size: 12)
        view.backgroundColor = .clear
        view.returnKeyType = .search
        view.clearButtonMode = .never
        view.delegate = self
        return view
    }()
    
    lazy var clearBtn: UIButton = {
        let btn = UIButton()
        btn.isHidden = true
        btn.addTarget(self, action: #selector(clearAction), for: .touchUpInside)
        btn.setImage(IMG("movie_search_close"), for: .normal)
        return btn
    }()
    lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        btn.titleLabel?.font = .font(weigth: .medium, size: 12)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchBar()
        setUI()
        addRefresh()
        HKLog.hk_home_cl(kid: "2", c_id: "", c_name: "", ctype: "", secname: "", secid: "")
    }
    
    func setSearchBar() {
        cusBar.titleL.isHidden = true
        cusBar.rightBtn.isHidden = true
        cusBar.backBtn.isHidden = true
        cusBar.addSubview(searchView)
        cusBar.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { make in
            make.bottom.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 72, height: 44))
        }
        searchView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(cancelBtn.snp.left)
            make.height.equalTo(40)
            make.centerY.equalTo(cancelBtn)
        }
        searchView.addSubview(textField)
        searchView.addSubview(clearBtn)
        clearBtn.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.width.equalTo(0)
        }
        
        textField.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(clearBtn.snp.left).offset(-16)
            make.top.bottom.equalToSuperview()
        }
    }
    
    func setUI() {
        self.addHistoryView()
        view.addSubview(tableView)
        view.addSubview(collectionView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(cusBar.snp.bottom)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(cusBar.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        textField.becomeFirstResponder()
        textField.addTarget(self, action: #selector(changeKey), for: .editingChanged)
    }
    
    func addRefresh() {
        let footer = RefreshAutoNormalFooter { [weak self] in
            guard let self = self else { return }
            self.page += 1
            self.loadMoreData()
        }
        collectionView.mj_footer = footer
    }
    
    private func requestData() {
        if self.key.count == 0 {
            return
        }
        self.addHistoryText(self.key)
        self.page = 1
        self.dataArr.removeAll()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.isHidden = true
            self.collectionView.isHidden = false
        }
        self.loadMoreData()
    }

    override func refreshRequest() {
        self.requestData()
    }
    
    private func loadMoreData() {
        self.textField.resignFirstResponder()
        ProgressHUD.showLoading()
        MovieAPI.share.movieSearch(keyword: self.key, from: from, page: self.page) { [weak self] success, model in
            guard let self = self else { return }
            ProgressHUD.dismiss()
            if !success {
                self.collectionView.mj_footer?.isHidden = true
                self.showEmpty(.noNet, self.collectionView)
            } else {
                if model.movie_tv_list.count > 0 {
                    self.collectionView.mj_footer?.isHidden = false
                    self.dismissEmpty(self.collectionView)
                    self.dataArr.append(contentsOf: model.movie_tv_list)
                } else {
                    self.collectionView.mj_footer?.isHidden = true
                    self.showEmpty(.noContent, self.collectionView)
                }
            }
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            if model.movie_tv_list.count < MovieAPI.share.pageSize {
                self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                self.collectionView.mj_footer?.isHidden = true
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.isHidden = true
                self.collectionView.isHidden = false
                self.collectionView.reloadData()
            }
        }
    }
    
    func searchText(_ text: String) {
        NetManager.requestSearch(url: hostUrl + text) { [weak self] data in
            guard let self = self else { return }
            self.searchKeys.removeAll()
            if let arr = self.getSearchData(data) {
                for i in arr {
                    if let sub = i as? Array<Any> {
                        for s in sub {
                            if let keys = s as? Array<Any> {
                                self.searchKeys.append(keys.first as? String ?? "")
                            }
                        }
                    } else if i is String {
                        self.searchKeys.append(i as? String ?? "")
                    }
                }
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.isHidden = false
                self.removeHistoryView()
                self.collectionView.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
    
    func getSearchData(_ data: String) -> Array<Any>? {
        guard let start = data.range(of: "(") else {
            return nil
        }

        let stratRange = NSRange(start, in: data)
        let str = data.substring(withRange: NSRange(location: stratRange.location + 1, length: data.count - stratRange.location - 2))
        print(str)
        do {
            if let d = str.data(using: .utf8) {
                let arr = try JSONSerialization.jsonObject(with: d, options: .mutableContainers)
                return arr as? Array<Any>
            }
        } catch {
            print("error")
        }
        return nil
    }
    
    @objc func clearAction() {
        self.clearBtn.isHidden = true
        self.textField.text = ""
    }
    
    @objc func cancelAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func changeKey() {
        if let text = textField.text {
            searchText(text)
            clearBtn.isHidden = text.count == 0
            clearBtn.snp.updateConstraints { make in
                make.width.equalTo(text.count > 0 ? 44 : 0)
            }
        }
    }
    
    //MARK: - histroy
    func addHistoryView() {
        if let arr = UserDefaults.standard.object(forKey: HKKeys.history) as? [String], arr.count > 0 {
            view.addSubview(self.historyView)
            self.historyView.snp.makeConstraints { make in
                make.top.equalTo(cusBar.snp.bottom)
                make.bottom.equalTo(view.safeAreaLayoutGuide)
                make.left.right.equalToSuperview()
            }
            self.historyView.clickBlock = { [weak self] text in
                guard let self = self else { return }
                self.removeHistoryView()
                self.searchText(text)
            }
            self.historyView.clickDeleteBlock = {[weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let vc = MovieAlertController.init("Delete", "Do you want to delete the history record?")
                    vc.clickBlock = {
                        UserDefaults.standard.set([], forKey: HKKeys.history)
                        UserDefaults.standard.synchronize()
                        self.historyView.removeFromSuperview()
                    }
                    self.present(vc, animated: false)
                }
            }
        }
    }
    
    func removeHistoryView() {
        self.historyView.removeFromSuperview()
    }
    
    func addHistoryText(_ text: String) {
        if let arr = UserDefaults.standard.object(forKey: HKKeys.history) as? [String] {
            var list = arr.filter({$0 != text})
            list.insert(text, at: 0)
            UserDefaults.standard.set(list, forKey: HKKeys.history)
            UserDefaults.standard.synchronize()
        } else {
            UserDefaults.standard.set([text], forKey: HKKeys.history)
            UserDefaults.standard.synchronize()
        }
        self.historyView.upDateHistory()
    }
}

extension MovieSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MovieSearchCell = tableView.dequeueReusableCell(withIdentifier: movieSearchCellIdentifier) as! MovieSearchCell
        if let model = self.searchKeys.safe(indexPath.row) {
            cell.setModel(model)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.key = self.searchKeys[indexPath.row]
        self.textField.text = self.key
        self.requestData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        48
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.searchKeys.count
    }
}

extension MovieSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: movieCellIdentifier, for: indexPath) as! MovieCell
        if let model = self.dataArr.safe(indexPath.item) {
            cell.setModel(model: model)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = self.dataArr.safe(indexPath.item) {
            DBManager.share.updateVideoData(model)
            HKPlayerManager.share.gotoPlayer(controller: self, id: model.id, from: .search)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: cellW, height: cellW * 140 / 109 + 44)
    }
}

extension MovieSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            self.key = text
            self.requestData()
        }
        return true
    }
}

extension MovieSearchViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "suggestion"{
            if let key = attributeDict["data"]{
                self.searchKeys.append(key)
            }
        }
    }
}
