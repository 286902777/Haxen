//
//  MoviePlayLikeCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/23.
//

import UIKit

class MoviePlayLikeCell: UITableViewCell {
    private let cellW = floor((kScreenWidth - 40 - 23) / 3)

    @IBOutlet weak var titleL: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var collectH: NSLayoutConstraint!
    private let cellIdentifier = "MovieCell"
    typealias clickBlock = (_ index: Int) -> Void
    var clickHandle : clickBlock?

    var dataArr: [MovieDataInfoModel] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectH.constant = cellW * 3 / 2 + 44
        collectionView.register(UINib(nibName: String(describing: MovieCell.self), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setModel(_ model: MovieVideoInfoData2Model, clickBlock: clickBlock?) {
        self.clickHandle = clickBlock
        self.titleL.text = model.name
        self.dataArr = model.data
        self.collectionView.reloadData()
    }
}

extension MoviePlayLikeCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArr.count
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
        self.clickHandle?(indexPath.item)

    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: cellW, height: cellW * 3 / 2 + 44)
    }
}
