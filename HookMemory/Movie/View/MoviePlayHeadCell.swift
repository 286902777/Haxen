//
//  MoviePlayHeadCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/22.
//

import UIKit

class MoviePlayHeadCell: UITableViewCell {

    @IBOutlet weak var titleL: UILabel!
    
    @IBOutlet weak var scroL: UILabel!
    
    @IBOutlet weak var yearL: UILabel!
    
    @IBOutlet weak var ctrNoL: UILabel!
    
    @IBOutlet weak var midView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var moreBtn: UIButton!
    
    @IBOutlet weak var collectH: NSLayoutConstraint!
    
    typealias refreshBlock = () -> Void
    var refreshHandle : refreshBlock?
    typealias clickMoreBlock = (_ show: Bool) -> Void
    var clickMoreHandle : clickMoreBlock?
    
    var dataArr: [MovieVideoInfoDataModel.MovieGenreModel] = []
    private let cellIdentifier = "MoviePlayHeadCategoryCell"
    private var height: CGFloat = 0 {
        didSet {
            if height != oldValue, height > 0 {
                self.refreshHandle?()
            }
        }
    }
    private lazy var layout: HKPlayLayout = {
        $0.delegate = self
        return $0
    }(HKPlayLayout())
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.midView.layer.cornerRadius = 2
        self.midView.layer.masksToBounds = true
        self.scroL.textColor = UIColor.hex("#FF4131")
        self.scroL.font = UIFont(name: "Fjalla One Regular", size: 32)
        collectionView.setCollectionViewLayout(self.layout, animated: false)
        collectionView.register(UINib(nibName: String(describing: MoviePlayHeadCategoryCell.self), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func clickMoreBtn(_ sender: Any) {
        self.moreBtn.isSelected = !self.moreBtn.isSelected
        self.clickMoreHandle?(self.moreBtn.isSelected)
    }
    
    func setModel(_ model: MovieVideoInfoModel, moreSelect: Bool = false, clickMoreBlock: clickMoreBlock?, refreshBlock: refreshBlock?) {
        self.moreBtn.isSelected = moreSelect
        self.clickMoreHandle = clickMoreBlock
        self.refreshHandle = refreshBlock
        self.titleL.text = model.data.title
        self.scroL.text = model.data.rate
        self.yearL.text = model.data.year
        self.ctrNoL.text = model.data.country
        self.dataArr = model.data.genre_dict
        self.collectionView.reloadData()
        self.collectionView.layoutIfNeeded()
        self.collectH.constant = self.collectionView.contentSize.height
        self.height = self.collectionView.contentSize.height
    }
}

extension MoviePlayHeadCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MoviePlayHeadCategoryCell
        if let model = self.dataArr.safe(indexPath.item) {
            cell.nameL.text = model.title
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var w: CGFloat = 0
        if let model = self.dataArr.safe(indexPath.item) {
            w = model.title.getStrW(strFont: UIFont.systemFont(ofSize: 12), h: 16)
        }
        return CGSize(width: w + 16, height: 24)
    }
}

extension MoviePlayHeadCell: HKPlayLayoutDelegate {
    func playLayoutSizeForItem(atIndexPath indexPath: IndexPath) -> CGSize {
        var w: CGFloat = 0
        if let model = self.dataArr.safe(indexPath.item) {
            w = model.title.getStrW(strFont: UIFont.systemFont(ofSize: 12), h: 16)
        }
        return CGSize(width: w + 16, height: 24)
    }
    
    func playLayoutLineHeight() -> CGFloat {
        24
    }
    
    func playLayoutLineWidth() -> CGFloat {
        kScreenWidth - 104
    }
    
    func playLayoutSpacingBetweenItems(inSection section: Int) -> CGFloat {
        8
    }
    
    func playLayoutSpacingBetweenLines(inSection section: Int) -> CGFloat {
        8
    }
    
    func playLayoutLineInsetLeft(inSection section: Int) -> CGFloat {
        16
    }
}
