//
//  MovieListViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/14.
//

import UIKit

class MovieListViewController: MovieBaseViewController {
    let movieCellIdentifier = "MovieCellIdentifier"
    let cellW = floor((kScreenWidth - 48) / 3)
    var titleName: String = ""
    var listId: String = ""
    var dataArr: [MovieDataInfoModel] = []
    private var page: Int = 1
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.register(UINib(nibName: String(describing: MovieCell.self), bundle: nil), forCellWithReuseIdentifier: movieCellIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        addRefresh()
        initData()
    }
    
    func setUI() {
        cusBar.titleL.text = self.titleName
        cusBar.rightBtn.setImage(IMG("movie_search"), for: .normal)
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(cusBar.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    func addRefresh() {
        let footer = RefreshAutoNormalFooter { [weak self] in
            guard let self = self else { return }
            self.page += 1
            self.initData()
        }
        collectionView.mj_footer = footer
        collectionView.mj_header?.beginRefreshing()
    }
    override func rightAction() {
        let vc = MovieSearchViewController()
        vc.from = .list
        self.navigationController?.pushViewController(vc, animated: true)
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
                self.dataArr.removeAll()
                self.collectionView.reloadData()
            }
            return
        }
        ProgressHUD.showLoading()
        MovieAPI.share.movieMoreList(id: self.listId, page: self.page) { [weak self] success, model in
            ProgressHUD.dismiss()
            guard let self = self else { return }
            if !success {
                self.showEmpty(.noNet, self.collectionView)
            } else {
                self.dismissEmpty(self.collectionView)
                self.dataArr.append(contentsOf: model.minfo)
            }
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.endRefreshing()
            if model.total == self.dataArr.count {
                self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                self.collectionView.mj_footer?.isHidden = true
            }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.collectionView.reloadData()
            }
        }
    }
}

extension MovieListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
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
            HKPlayerManager.share.gotoPlayer(controller: self, id: model.id, from: .list)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: cellW, height: cellW * 3 / 2 + 44)
    }
}
