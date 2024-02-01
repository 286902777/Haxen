//
//  MovieListCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import UIKit

class MovieListCell: UITableViewCell {
    let cellW = floor((kScreenWidth - 40 - 23) / 3)
    let cellIdentifier = "MovieCell"
    typealias clickMoreBlock = () -> Void
    var clickMoreHandle : clickMoreBlock?
    var list: [MovieDataInfoModel] = []
    typealias clickBlock = (_ movieModel: MovieDataInfoModel) -> Void
    var clickHandle : clickBlock?
    
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var moreBtn: UIButton!
    
    private var history: Bool = false
    override func awakeFromNib() {
        super.awakeFromNib()
        titleL.font = UIFont(name: "Hind SemiBold", size: 22)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: String(describing: MovieCell.self), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        moreBtn.addTarget(self, action: #selector(moreAction), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @objc func moreAction() {
        self.clickMoreHandle?()
    }
    
    func setModel( model: MovieHomeModel, clickMoreBlock: clickMoreBlock?, clickBlock: clickBlock?) {
        self.clickMoreHandle = clickMoreBlock
        self.clickHandle = clickBlock
        if let mod = model.data.first {
            self.history = (mod.name == "History" && mod.id.isEmpty)
            self.titleL.text = mod.name
            self.list = mod.m20
            self.collectionView.reloadData()
        }
    }
}

extension MovieListCell: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        min(20, self.list.count) 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MovieCell
        if let model = self.list.safe(indexPath.item) {
            cell.setModel(model: model, self.history)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = self.list.safe(indexPath.item) {
            self.clickHandle?(model)
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: cellW, height: cellW * 3 / 2 + 44)
    }
}
