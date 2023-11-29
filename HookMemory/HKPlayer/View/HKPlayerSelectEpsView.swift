//
//  HKPlayerSelectEpsView.swift
//  HookMemory
//
//  Created by HF on 2023/11/22.
//

import UIKit

class HKPlayerSelectEpsView: UIView {
    
    @IBOutlet weak var epsView: UIView!
    @IBOutlet weak var ssnCollectionView: UICollectionView!
    
    @IBOutlet weak var epsCollectionView: UICollectionView!
    let ssnCellId = "HKPlayerSelectSsnCell"
    let epsCellId = "HKPlayerSelectEpsCell"
    typealias clickBlock = (_ list: [MovieVideoInfoEpssModel], _ ssnId: String, _ epsId: String) -> Void
    var clickHandle : clickBlock?
    private var videoId: String = ""
    private var ssnId: String = ""
    private var epsId: String = ""
    private var ssnList: [MovieVideoInfoSsnlistModel] = []
    private var epsList: [MovieVideoInfoEpssModel] = []
    class func view() -> HKPlayerSelectEpsView {
        let view = Bundle.main.loadNibNamed(String(describing: HKPlayerSelectEpsView.self), owner: nil)?.first as! HKPlayerSelectEpsView
        return view
    }
    
    @objc func dismissView() {
        self.removeFromSuperview()
    }
    
    func setModel(_ id: String, _ model: MovieVideoInfoSSNModel, clickBlock: clickBlock?) {
        self.epsView.effectView(CGSize(width: 308, height: kScreenWidth))
        self.ssnCollectionView.register(UINib(nibName: String(describing: HKPlayerSelectSsnCell.self), bundle: nil), forCellWithReuseIdentifier: ssnCellId)
        self.epsCollectionView.register(UINib(nibName: String(describing: HKPlayerSelectEpsCell.self), bundle: nil), forCellWithReuseIdentifier: epsCellId)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        self.addGestureRecognizer(tap)
        tap.delegate = self
        self.clickHandle = clickBlock
        self.videoId = id
        self.ssnList = model.ssn_list
        self.epsList = model.epss
        self.epsId = model.epss.first(where: {$0.isSelect == true})?.id ?? ""
        self.ssnCollectionView.reloadData()
        self.epsCollectionView.reloadData()
        for (index, item) in self.ssnList.enumerated() {
            if item.isSelect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let self = self else { return }
                    self.ssnCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
                }
            }
        }
        for (index, item) in self.epsList.enumerated() {
            if item.isSelect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let self = self else { return }
                    self.epsCollectionView.scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: false)
                }
            }
        }
    }
    
    func getEpsListData(_ ssnId: String) {
        if let _ = self.ssnList.first(where: {$0.isSelect == true && $0.id == ssnId}) {
            return
        } else {
            let _ = self.ssnList.map({$0.isSelect = false})
            self.ssnList.first(where: {$0.id == ssnId})?.isSelect = true
            self.ssnCollectionView.reloadData()
        }
        MovieAPI.share.movieTVSSN(ssn_id: ssnId, id: self.videoId) { [weak self] success, ssnMod in
            guard let self = self else { return }
            ssnMod.eps_list.first(where: {$0.id == self.epsId})?.isSelect = true
            self.epsList = ssnMod.eps_list
            DispatchQueue.main.async {
                self.epsCollectionView.reloadData()
            }
        }
    }
}

extension HKPlayerSelectEpsView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == ssnCollectionView {
            return self.ssnList.count
        } else {
            return self.epsList.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == ssnCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ssnCellId, for: indexPath) as! HKPlayerSelectSsnCell
            if let model = self.ssnList.safe(indexPath.item) {
                cell.setModel(model)
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: epsCellId, for: indexPath) as! HKPlayerSelectEpsCell
            if let model = self.epsList.safe(indexPath.item) {
                cell.setModel(model)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == ssnCollectionView {
            if let model = self.ssnList.safe(indexPath.item) {
                self.ssnId = model.id
                self.getEpsListData(model.id)
            }
        } else {
            if let model = self.epsList.safe(indexPath.item) {
                self.epsId = model.id
                self.clickHandle?(self.epsList, self.ssnId, self.epsId)
                let _ = self.epsList.map({$0.isSelect = false})
                self.epsList.first(where: {$0.id == model.id})?.isSelect = true
                self.epsCollectionView.reloadData()
                self.dismissView()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == ssnCollectionView {
            var w: CGFloat = 0
            if let model = self.ssnList.safe(indexPath.item) {
                if model.isSelect {
                    w = model.title.getStrW(strFont: .font(weigth: .medium, size: 18), h: 36)
                } else {
                    w = model.title.getStrW(strFont: .font(size: 14), h: 36)
                }
            }
            return CGSize(width: w + 2, height: 36)
        } else {
            return CGSize(width: 48, height: 48)
        }
    }
}

extension HKPlayerSelectEpsView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view {
            if view.isDescendant(of: self.ssnCollectionView) || view.isDescendant(of: self.epsCollectionView) {
                return false
            }
        }
        return true
    }
}
