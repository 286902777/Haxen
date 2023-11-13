//
//  HKRefresh.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import Foundation
import MJRefresh

class RefreshGifHeader: MJRefreshGifHeader{
    private var images: [UIImage] = []
    func getImages() -> [UIImage] {
        if images.count == 0 {
            if let arr = self.getGifToImages("sss.gif") {
                images = arr
            }
        }
        return images
    }
    
    func getGifToImages(_ name: String) -> [UIImage]? {
        guard let path = Bundle.main.path(forResource: name, ofType: nil) else {
            return nil
        }
        guard let data = NSData(contentsOfFile: path) else {
            return nil
        }
        
        guard let imgSource: CGImageSource = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        // 获取组成gif的图片总数量（gif都是由很多张图片组成）
        let imageCount = CGImageSourceGetCount(imgSource)
        
        var images = [UIImage]()
        for i in 0...imageCount {
            guard let cgImage = CGImageSourceCreateImageAtIndex(imgSource, i, nil) else {
                continue
            }
            // 获取到所有的image
            let image = UIImage(cgImage: cgImage)
            images.append(image)
        }
        return images
    }
    
    override func prepare() {
        super.prepare()
        self.setImages([UIImage(named: "play") as Any], for: .idle)
        var imageArr: [UIImage] = []
        for i in 0...10 {
            if i % 2 == 0 {
                imageArr.append(UIImage(named: "play") ?? UIImage())
            } else {
                imageArr.append(UIImage(named: "video") ?? UIImage())
            }
        }
        self.gifView?.isHidden = true
        if let gifV = self.gifView {
            let view = UIView(frame: gifV.frame)
//            let animation = 
        }
    
        self.setImages(imageArr, for: .refreshing)
        self.mj_h = 80
        self.stateLabel?.isHidden = true
        self.lastUpdatedTimeLabel?.isHidden = true
        switch self.state {
        case .idle:
            break
        case .pulling:
            break
        case .refreshing:
            break
        default:
            break
        }
    }
}

class RefreshAutoNormalFooter: MJRefreshAutoNormalFooter {

    override func prepare() {
        super.prepare()
        self.mj_h = 65
        self.stateLabel?.font = UIFont.systemFont(ofSize: 12)
        self.stateLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        self.setTitle("", for: .idle)
        self.setTitle("", for: .refreshing)
        self.setTitle("No more content", for: .noMoreData)
    }

}

class RefreshNormalHeader: MJRefreshNormalHeader {
    override func prepare() {
        super.prepare()
        self.mj_h = 50
        self.stateLabel?.font = UIFont.systemFont(ofSize: 12)
        self.stateLabel?.textColor = #colorLiteral(red: 0.6784313725, green: 0.6941176471, blue: 0.7254901961, alpha: 1)
        self.lastUpdatedTimeLabel?.isHidden = true
        self.setTitle("下拉即可刷新", for: .idle)
        self.setTitle("松开立即刷新", for: .pulling)
        self.setTitle("数据加载中", for: .refreshing)
    }
}
