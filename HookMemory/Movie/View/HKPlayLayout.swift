//
//  HKPlayLayout.swift
//  HookMemory
//
//  Created by HF on 2023/11/23.
//

import UIKit
import SnapKit

protocol HKPlayLayoutDelegate: NSObjectProtocol {
    func playLayoutSizeForItem(atIndexPath indexPath: IndexPath) -> CGSize
    func playLayoutLineHeight() -> CGFloat
    func playLayoutSizeForHeader(inSection section: Int) -> CGSize
    func playLayoutSizeForFooter(inSection section: Int) -> CGSize
    func playLayoutSpacingBetweenItems(inSection section: Int) -> CGFloat
    func playLayoutSpacingBetweenLines(inSection section: Int) -> CGFloat
    func playLayoutLineWidth() -> CGFloat
    func playLayoutLineInsetLeft(inSection section: Int) -> CGFloat
    func playLayoutLineInsetRight(inSection section: Int) -> CGFloat
}

extension HKPlayLayoutDelegate {

    func playLayoutSpacingBetweenItems(inSection section: Int) -> CGFloat {
        return 0
    }
    func playLayoutSpacingBetweenLines(inSection section: Int) -> CGFloat {
        return 0
    }
    
    func playLayoutSizeForHeader(inSection section: Int) -> CGSize {
        return CGSize.zero
    }
       
    func playLayoutSizeForFooter(inSection section: Int) -> CGSize {
        return CGSize.zero
    }
    func playLayoutLineWidth() -> CGFloat {
        return 0
    }
    func playLayoutLineInsetLeft(inSection section: Int) -> CGFloat {
        return 0
    }
    func playLayoutLineInsetRight(inSection section: Int) -> CGFloat {
        return 0
    }
}


class HKPlayLayout: UICollectionViewFlowLayout {
    var cacheWidth: [IndexPath: CGFloat] = [:]
    var cellAttributes: [UICollectionViewLayoutAttributes] = []
    var isLoaded: Bool = false
    weak var delegate: HKPlayLayoutDelegate?
    var isHorizon = true {
        didSet {
            self.scrollDirection = isHorizon ? .horizontal : .vertical
        }
    }
    
    func reloadData() {
        self.cellAttributes.removeAll()
        self.cacheWidth.removeAll()
        self.isLoaded = false
        self.prepare()
    }
    
    override func prepare() {
        guard let collectionView = self.collectionView, let delegate = self.delegate else { return }
        
        self.cellAttributes.removeAll()
        self.cacheWidth.removeAll()
        
        let sectionContentWidth = delegate.playLayoutLineWidth()
            // collectionView.bounds.width - sectionInset.left - sectionInset.right - collectionView.contentInset.left - collectionView.contentInset.right
        let sections = collectionView.numberOfSections
        var lastOffsetY: CGFloat = 0

        for section in 0 ..< sections {
            let leftInset = delegate.playLayoutLineInsetLeft(inSection: section)
            let rightInset = delegate.playLayoutLineInsetRight(inSection: section)

            let itemSpacing = delegate.playLayoutSpacingBetweenItems(inSection: section)
            let lineSpacing = delegate.playLayoutSpacingBetweenLines(inSection: section)
            /// header
            let headerSize = delegate.playLayoutSizeForHeader(inSection: section)
            if headerSize.height > 0 {
                let sectionHeaderAttri = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                                                            with: IndexPath(item: 0, section: section))
                sectionHeaderAttri.frame = CGRect(x: leftInset, y: lastOffsetY, width: headerSize.width, height: headerSize.height)
                self.cellAttributes.append(sectionHeaderAttri)
                lastOffsetY += headerSize.height
            }
            /// cells
            let items = collectionView.numberOfItems(inSection: section)
            var lastOffsetX: CGFloat = leftInset
            var cellHeight: CGFloat = 0
            for item in 0 ..< items {
                let indexPath = IndexPath(item: item, section: section)
                let itemSize = delegate.playLayoutSizeForItem(atIndexPath: indexPath)
                let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                var x: CGFloat = lastOffsetX
                var y: CGFloat = lastOffsetY
                let leftSpacing = sectionContentWidth - leftInset - rightInset - lastOffsetX - itemSize.width - itemSpacing
                if leftSpacing >= 0 {
                    /// 继续拼接
                    x = lastOffsetX
                    y = lastOffsetY
                    lastOffsetX = (x + itemSize.width + itemSpacing)
                    cellHeight = itemSize.height
                } else {
                    /// 换行
                    lastOffsetY += (cellHeight + lineSpacing)
                    x = leftInset
                    y = lastOffsetY
                    lastOffsetX = (x + itemSize.width + itemSpacing)
                }
                attr.frame = CGRect(origin: CGPoint(x: x, y: y), size: itemSize)
                self.cellAttributes.append(attr)
            }
            if items > 0 {
                lastOffsetY += (lineSpacing + delegate.playLayoutLineHeight())
            }
            /// footer
            let footerSize = delegate.playLayoutSizeForFooter(inSection: section)
            if footerSize.height > 0 {
                let sectionFooterAttri = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                                                      with: IndexPath(item: items + 1, section: section))
                sectionFooterAttri.frame = CGRect(x: leftInset, y: lastOffsetY + delegate.playLayoutLineHeight(), width: footerSize.width, height: footerSize.height)
                lastOffsetY += footerSize.height + delegate.playLayoutLineHeight()
                self.cellAttributes.append(sectionFooterAttri)
            }
        }
//        self.isLoaded = true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return self.cellAttributes
    }
    
    override var collectionViewContentSize: CGSize {
        guard let collectionView = self.collectionView, let last = self.cellAttributes.last else { return CGSize.zero }
        return CGSize(width: collectionView.bounds.width - sectionInset.left - sectionInset.right - collectionView.contentInset.left - collectionView.contentInset.right, height: last.frame.maxY)
    }
}
