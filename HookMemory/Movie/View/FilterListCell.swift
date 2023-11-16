//
//  FilterListCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/9.
//

import UIKit

class FilterListCell: UITableViewCell {  
    var dataArr: [MovieFilterCategoryInfoModel] = []
    typealias clickBlock = (_ id: String) -> Void
    var clickHandle : clickBlock?
    let cellIdentifier = "FilterCellIdentifier"
    @IBOutlet weak var collectionView: UICollectionView!
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib(nibName: String(describing: FilterCell.self), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }  
    func setModel(_ arr: [MovieFilterCategoryInfoModel], clickBlock: clickBlock?) {
        self.clickHandle = clickBlock
        if let m = arr.first {
            m.isSelect = true
        }
        self.dataArr = arr
        self.collectionView.reloadData()
        self.collectionView.scrollToItem(at: IndexPath.init(item: 0, section: 0), at: .left, animated: false)
    }
}

extension FilterListCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        self.dataArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! FilterCell
        if let model = dataArr.safe(indexPath.item) {
            cell.setModel(model)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let _ = dataArr.map{$0.isSelect = false}
        dataArr[indexPath.item].isSelect = true
        self.collectionView.reloadData()
        self.clickHandle?(dataArr[indexPath.item].id)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = self.dataArr[indexPath.item]
        return CGSize(width: model.isSelect ? (model.width + 16) : model.width, height: 50)
    }
}
