//
//  FilterListCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/9.
//

import UIKit

class FilterListCell: UITableViewCell {
    var dataArr: [MovieFiterModel] = []
    typealias clickBlock = (_ type: Int) -> Void
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
    func setModel(_ text: String, clickBlock: clickBlock?) {
        self.clickHandle = clickBlock
        let model = MovieFiterModel()
        model.name = "text"
        let model1 = MovieFiterModel()
        model1.name = "2024-01"
        let model2 = MovieFiterModel()
        model2.name = "china"
        for _ in 0...4 {
            self.dataArr.append(model)
            self.dataArr.append(model1)
            self.dataArr.append(model2)
        }
        
        self.collectionView.reloadData()
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
        cell.setModel(dataArr[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.clickHandle?(indexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = self.dataArr[indexPath.item]
        return CGSize(width: model.width, height: 50)
    }
}
