//
//  MoviePlaySsnHeadView.swift
//  HookMemory
//
//  Created by HF on 2023/11/23.
//

import UIKit

class MoviePlaySsnHeadView: UIView {
    private let cellIdentifier = "HKPlayerSelectSsnCell"
    private var dataArr: [MovieVideoInfoSsnlistModel] = []
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        collectionView.register(UINib(nibName: String(describing: HKPlayerSelectSsnCell.self), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        collectionView.contentInsetAdjustmentBehavior = .never
        return collectionView
    }()
    lazy var lineV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#FFFFFF", alpha: 0.1)
        return view
    }()
    typealias clickBlock = (_ id: String) -> Void
    var clickHandle : clickBlock?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUI()
    }
    
    func setUI() {
        self.backgroundColor = UIColor.hex("#141414")
        self.addSubview(collectionView)
        self.collectionView.snp.makeConstraints { make in
            make.top.equalTo(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(36)
        }
        self.addSubview(lineV)
        self.lineV.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.collectionView.snp.bottom)
            make.height.equalTo(1)
            make.bottom.equalTo(-15)
        }
    }
    
    func setModel(_ list: [MovieVideoInfoSsnlistModel], clickBlock: clickBlock?) {
        self.clickHandle = clickBlock
        self.dataArr = list
        self.collectionView.reloadData()
        for (index, item) in self.dataArr.enumerated() {
            if item.isSelect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let self = self else { return }
                    self.collectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
                }
            }
        }
    }
}

extension MoviePlaySsnHeadView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! HKPlayerSelectSsnCell
        if let model = self.dataArr.safe(indexPath.item) {
            cell.setModel(model)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = self.dataArr.safe(indexPath.item) {
            self.clickHandle?(model.id)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        22
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var w: CGFloat = 0
        if let model = self.dataArr.safe(indexPath.item) {
            if model.isSelect {
                w = model.title.getStrW(strFont: .font(weigth: .medium, size: 18), h: 36)
            } else {
                w = model.title.getStrW(strFont: .font(size: 14), h: 36)
            }
        }
        return CGSize(width: w + 2, height: 36)
    }
}
