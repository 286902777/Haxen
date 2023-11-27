//
//  MoviePlayHeadInfoCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/22.
//

import UIKit

class MoviePlayHeadInfoCell: UITableViewCell {

    @IBOutlet weak var infoL: UILabel!
    
    @IBOutlet weak var collectH: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    var dataArr: [MovieVideoInfoDataModel.MovieCastsModel] = [] {
        didSet {
            collectH.constant = dataArr.count == 0 ? 0 : 120
        }
    }
    private let cellIdentifier = "MoviePlayHeadIconCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(UINib(nibName: String(describing: MoviePlayHeadIconCell.self), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setModel(_ model: MovieVideoInfoModel) {
        self.dataArr = model.data.casts
        self.infoL.text = model.data.description
        self.collectionView.reloadData()
    }
}

extension MoviePlayHeadInfoCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MoviePlayHeadIconCell
        if let model = self.dataArr.safe(indexPath.item) {
            cell.setModel(model)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 56, height: 106)
    }
}
