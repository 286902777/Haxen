//
//  MovieFilterViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/9.
//

import UIKit

class MovieFilterViewController: MovieBaseViewController {
    private let headerView: FilterView = FilterView(frame: CGRect(x: 0, y: -232, width: kScreenWidth, height: 232))
    let cellIdentifier = "MovieCellIdentifier"
    let cellW = floor((kScreenWidth - 48) / 3)
    var dataArr: [MovieDataInfoModel] = []
    var filterArr: [[MovieFilterCategoryInfoModel]] = []
    private var type: String = "1"
    private var genre: String = "100"
    private var pubdate: String = "100"
    private var cntyno: String = "100"
    private var page: Int = 1
    private var filterH: CGFloat = 232
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 232, left: 16, bottom: 16, right: 16)
        collectionView.register(UINib(nibName: String(describing: MovieCell.self), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(FilterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "FilterView")
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    
    private lazy var selectView: UIImageView = {
        let view = UIImageView()
        view.image = IMG("movie_filter_searchresult")
        view.isHidden = true
        return view
    }()
    private lazy var selectL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.text = "Movies · Action · 2023 · United"
        label.font = .font(weigth: .medium, size: 14)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addRefresh()
    }
    func setUpUI() {
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor.hex("#141414")
        let search = SearchView.view()
        let tap = UITapGestureRecognizer(target: self, action: #selector(pushSearch))
        search.addGestureRecognizer(tap)
        view.addSubview(search)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(search.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        collectionView.addSubview(headerView)
        view.addSubview(selectView)
        selectView.addSubview(selectL)
        selectView.snp.makeConstraints { make in
            make.top.equalTo(search.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(72)
        }
        selectL.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
    }
    func addRefresh() {
        let header = RefreshFilterGifHeader { [weak self] in
            guard let self = self else { return }
            self.page = 1
            self.dataArr.removeAll()
            self.initData()
        }

        collectionView.mj_header = header
        let footer = RefreshAutoNormalFooter { [weak self] in
            guard let self = self else { return }
            self.page += 1
            self.selectL.text = ""
            self.loadMoreData()
        }
        collectionView.mj_footer = footer
        collectionView.mj_header?.beginRefreshing()
    }
    
    override func refreshRequest() {
        self.collectionView.mj_header?.beginRefreshing()
    }
    
    func initData() {
        if HKConfig.share.isNet == false {
            self.collectionView.mj_header?.endRefreshing()
            self.showEmpty(.noNet, self.collectionView)
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.headerView.isHidden = true
                self.dataArr.removeAll()
                self.collectionView.reloadData()
            }
            return
        }
        ProgressHUD.showLoading()
        MovieAPI.share.movieFilterInfo { [weak self] success, model in
            guard let self = self else { return }
            ProgressHUD.dismiss()
            if !success {
                self.showEmpty(.noNet, self.collectionView)
            } else {
                self.dismissEmpty(self.collectionView)
                self.dataArr.append(contentsOf: model.minfo)
                let mod = model.filter
                self.filterArr = [mod.type, mod.genre, mod.pub, mod.country]
                self.type = "1"
                self.genre = "100"
                self.pubdate = "100"
                self.cntyno = "100"
                self.selectL.text = ""
                self.setFilterHeaderData()
            }
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.headerView.isHidden = false
                self.collectionView.reloadData()
            }
        }
    }

    private func setFilterHeaderData() {
        self.headerView.setModel(self.filterArr) { [weak self] index, id in
            guard let self = self else { return }
            switch index {
            case .type:
                self.type = id
            case .genre:
                self.genre = id
            case .pub:
                self.pubdate = id
            case .country:
                self.cntyno = id
            }
            self.getSelectInfo()
            self.filterData()
        }
    }
    
    private func getSelectInfo() {
        var arr: [String] = []
        for items in self.filterArr {
            for (index, item) in items.enumerated() {
                if index > 0, item.isSelect == true {
                    arr.append(item.title)
                }
            }
        }
        self.selectL.text = arr.joined(separator: " · ")
    }
    private func filterData() {
        self.page = 1
        self.dataArr.removeAll()
        self.loadMoreData()
    }
    
    private func loadMoreData() {
        ProgressHUD.showLoading()
        MovieAPI.share.movieFilterInfo(cntyno: self.cntyno, genre: self.genre, pubdate: self.pubdate, type: self.type, page: self.page) { [weak self] success, model in
            guard let self = self else { return }
            ProgressHUD.dismiss()
            if !success {
                self.showEmpty(.noNet, self.collectionView)
            } else {
                self.dataArr.append(contentsOf: model.minfo)
                if self.dataArr.count == 0 {
                    self.headerView.isHidden = true
                    self.showEmpty(.noContent, self.collectionView)
                } else {
                    self.headerView.isHidden = false
                    self.dismissEmpty(self.collectionView)
                }
            }
            self.collectionView.mj_footer?.endRefreshing()
            if model.minfo.count < MovieAPI.share.pageSize {
                self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                self.collectionView.mj_footer?.isHidden = true
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    @objc func pushSearch() {
        let vc = MovieSearchViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MovieFilterViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MovieCell
        if let model = self.dataArr.safe(indexPath.item) {
            cell.setModel(model: model)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = self.dataArr.safe(indexPath.item) {
            DBManager.share.updateVideoData(model)
            HKPlayerManager.share.gotoPlayer(controller: self, id: model.id, from: .net)
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

extension MovieFilterViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.selectL.text?.count == 0 {
            self.cusBar.backgroundColor = .clear
            self.selectView.isHidden = true
            return
        }
        
        if scrollView.contentOffset.y > 0 {
            self.cusBar.backgroundColor = UIColor.hex("#141414")
            self.selectView.isHidden = false
        } else {
            self.cusBar.backgroundColor = .clear
            self.selectView.isHidden = true
        }
    }
}
