//
//  MovieHistoryView.swift
//  HookMemory
//
//  Created by HF on 2023/12/8.
//

import UIKit

class MovieHistoryView: UIView {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var clickBlock: ((_ text: String) -> ())?
    var clickDeleteBlock: (() -> ())?

    let cellIdentifier = "MoviePlayHeadCategoryCell"

    private var histroyArr: [MovieHistoryModel] = []
    
    private lazy var layout: HKPlayLayout = {
        $0.delegate = self
        return $0
    }(HKPlayLayout())
    
    @IBAction func ClickDeleteAction(_ sender: Any) {
        self.clickDeleteBlock?()
    }
    
    class func view() -> MovieHistoryView {
        let view = Bundle.main.loadNibNamed(String(describing: MovieHistoryView.self), owner: nil)?.first as! MovieHistoryView
        view.setCollectionLayout()
        return view
    }
    
    func setCollectionLayout() {
        self.collectionView.setCollectionViewLayout(self.layout, animated: false)
        self.collectionView.register(UINib(nibName: String(describing: MoviePlayHeadCategoryCell.self), bundle: nil), forCellWithReuseIdentifier: cellIdentifier)
        self.upDateHistory()
    }
    
    func upDateHistory() {
        self.histroyArr.removeAll()
        let minW: CGFloat = 40
        if let arr = UserDefaults.standard.object(forKey: HKKeys.history) as? [String] {
            for i in 0 ..< arr.count {
                let model = MovieHistoryModel()
                model.text = arr.safe(i) ?? ""
                model.width = max(minW, ceil(model.text.getStrW(strFont: .font(size: 14), h: 20) + 32))
                self.histroyArr.append(model)
            }
        }
       
       
        self.collectionView.reloadData()
    }
    
    func setShowBtn(_ arr: [String]) -> (Int, Bool) {
        let marge: CGFloat = 16
        let space: CGFloat = 12
        let lineH: CGFloat = 16
        let btnH: CGFloat = 40
        var width: CGFloat = 0
        var hight: CGFloat = 0
        let minW: CGFloat = 40
        for i in 0 ..< arr.count {
            if let t = arr.safe(i) {
                let w = ceil(t.getStrW(strFont: .font(size: 16), h: 20) + marge * 2)
                width = width + max(w, minW) + space
                if width > kScreenWidth - 2 * marge {
                    width = max(w, minW)
                    if hight > btnH {
                        let count = (width - kScreenWidth - 2 * marge) < (minW + space) ? i - 1 : i
                        return (count, true)
                    } else {
                        hight = btnH + lineH
                    }
                }
            }
        }
        return (arr.count, false)
    }
}

extension MovieHistoryView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        histroyArr.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! MoviePlayHeadCategoryCell
        if let model = self.histroyArr.safe(indexPath.item) {
            cell.setHistoryModel(model)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let model = self.histroyArr.safe(indexPath.item) {
            self.clickBlock?(model.text)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let model = self.histroyArr.safe(indexPath.item) {
            return CGSize(width: model.width, height: 40)
        }
        return CGSize(width: 0, height: 0)
    }
}

extension MovieHistoryView: HKPlayLayoutDelegate {
    func playLayoutSizeForItem(atIndexPath indexPath: IndexPath) -> CGSize {
        if let model = self.histroyArr.safe(indexPath.item) {
            return CGSize(width: model.width, height: 40)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func playLayoutLineHeight() -> CGFloat {
        40
    }
    
    func playLayoutLineWidth() -> CGFloat {
        kScreenWidth - 32
    }
    
    func playLayoutSpacingBetweenItems(inSection section: Int) -> CGFloat {
        12
    }
    
    func playLayoutSpacingBetweenLines(inSection section: Int) -> CGFloat {
        16
    }
    
    func playLayoutLineInsetLeft(inSection section: Int) -> CGFloat {
        0
    }
}

class MovieHistoryModel: BaseModel {
    enum historyType: Int {
        case text
        case show
        case dismiss
    }
    var text: String = ""
    var width: CGFloat = 40
}
