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
    private var isShow: Bool = false
    private var dataArr: [String] = []
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
        if let arr = UserDefaults.standard.object(forKey: HKKeys.history) as? [String] {
            self.dataArr = arr
        }
        var count = self.dataArr.count
        var isTwo: Bool = false
        let data = self.setShowBtn(self.dataArr)
        if data.1 {
            isTwo = true
        }
        if isShow == false {
            count = data.0
        }
        let minW: CGFloat = 40
        self.histroyArr.removeAll()
        for i in 0 ... count {
            let model = MovieHistoryModel()
            if i == count {
                if isTwo {
                    model.type = self.isShow ? .dismiss : .show
                    self.histroyArr.append(model)
                }
            } else {
                model.text = self.dataArr.safe(i) ?? ""
                model.width = max(minW, ceil(model.text.getStrW(strFont: .font(size: 12), h: 16) + 16))
                self.histroyArr.append(model)
            }
        }
        self.collectionView.reloadData()
    }
    
    func setShowBtn(_ arr: [String]) -> (Int, Bool) {
        let marge: CGFloat = 16
        let space: CGFloat = 8
        let lineH: CGFloat = 8
        let btnH: CGFloat = 24
        var width: CGFloat = 0
        var hight: CGFloat = 0
        let minW: CGFloat = 40
        for i in 0 ..< arr.count {
            if let t = arr.safe(i) {
                let w = ceil(t.getStrW(strFont: .font(size: 12), h: 16) + space * 2)
                width = width + max(w, minW) + space
                if width > kScreenWidth - 2 * marge {
                    width = max(w, minW)
                    if hight > btnH {
                        let count = (width - kScreenWidth - 2 * marge) < (minW + marge) ? i - 1 : i
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
            if model.type == .text {
                self.clickBlock?(model.text)
            } else {
                self.isShow = model.type == .show
                self.upDateHistory()
            }
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let model = self.histroyArr.safe(indexPath.item) {
            return CGSize(width: model.width, height: 24)
        }
        return CGSize(width: 0, height: 0)
    }
}

extension MovieHistoryView: HKPlayLayoutDelegate {
    func playLayoutSizeForItem(atIndexPath indexPath: IndexPath) -> CGSize {
        if let model = self.histroyArr.safe(indexPath.item) {
            return CGSize(width: model.width, height: 24)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func playLayoutLineHeight() -> CGFloat {
        24
    }
    
    func playLayoutLineWidth() -> CGFloat {
        kScreenWidth - 32
    }
    
    func playLayoutSpacingBetweenItems(inSection section: Int) -> CGFloat {
        8
    }
    
    func playLayoutSpacingBetweenLines(inSection section: Int) -> CGFloat {
        8
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
    var type: historyType = .text
}
