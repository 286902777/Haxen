//
//  MovieHistoryListViewController.swift
//  HookMemory
//
//  Created by HF on 2023/12/8.
//

import UIKit

class MovieHistoryListViewController: MovieBaseViewController {
    let movieCellIdentifier = "MovieSelectCellIdentifier"
    let cellW = floor((kScreenWidth - 48) / 3)
    var titleName: String = ""
    var listId: String = ""
    var dataArr: [MovieDataInfoModel] = []
    private var page: Int = 1
    private var isSelect: Bool = false

    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        collectionView.register(UINib(nibName: String(describing: MovieSelectCell.self), bundle: nil), forCellWithReuseIdentifier: movieCellIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
 
    private var bottomView: MovieHistoryBottomView = MovieHistoryBottomView.view()
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        initData()
    }
    
    func setUI() {
        cusBar.titleL.text = "Recently Played"
        cusBar.rightBtn.setImage(IMG("movie_edit"), for: .normal)
        view.addSubview(bottomView)
        view.addSubview(collectionView)
        bottomView.frame = CGRect(x: 0, y: kScreenHeight, width: 0, height: 0)
        self.bottomView.isHidden = true
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(cusBar.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top)
            make.left.right.equalToSuperview()
        }
    }
    
    override func rightAction() {
        self.isSelect = true
        self.bottomView.isHidden = false
        self.collectionView.reloadData()
        bottomView.frame = CGRect(x: 0, y: kScreenHeight - 98 - kBottomSafeAreaHeight, width: kScreenWidth, height: 98 + kBottomSafeAreaHeight)
        self.bottomView.show()
        self.bottomView.clickSelectBlock = { [weak self] select in
            guard let self = self else { return }
            let _ = self.dataArr.map({$0.isSelect = select})
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        self.bottomView.clickBlock = { [weak self] index in
            guard let self = self else { return }
            if index == 1 {
                let _ = self.dataArr.map({$0.isSelect = false})
                self.isSelect = false
                DispatchQueue.main.async {
                    self.bottomView.frame = CGRect(x: 0, y: kScreenHeight, width: 0, height: 0)
                    self.bottomView.isHidden = true
                    self.collectionView.reloadData()
                }
            } else {
                let selectArr = self.dataArr.filter({$0.isSelect == true})
                for (_, m) in selectArr.enumerated() {
                    DBManager.share.deleteVideoData(model: m)
                }
                self.dataArr = self.dataArr.filter({$0.isSelect == false})
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func initData() {
        self.dataArr = DBManager.share.selectHistoryVideoDatas()
        self.collectionView.reloadData()
    }
}

extension MovieHistoryListViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: movieCellIdentifier, for: indexPath) as! MovieSelectCell
        if let model = self.dataArr.safe(indexPath.item) {
            cell.setModel(isSelect: self.isSelect, model: model) {[weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    let vc = MovieHistorySelectController()
                    vc.clickBlock = { index in
                        if index == 0 {
                            DBManager.share.updateVideoData(model)
                            HKPlayerManager.share.gotoPlayer(controller: self, id: model.id, from: .home)
                        } else {
                            DBManager.share.deleteVideoData(model: model)
                            self.dataArr.remove(at: indexPath.item)
                            self.collectionView.reloadData()
                        }
                    }
                    vc.modalPresentationStyle = .overFullScreen
                    self.present(vc, animated: false)
                }
            } _: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    model.isSelect = !model.isSelect
                    self.bottomView.selectBtn.isSelected = self.dataArr.filter({$0.isSelect == false}).count == 0
                }
            }
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
        CGSize(width: cellW, height: cellW * 140 / 109 + 44)
    }
}
