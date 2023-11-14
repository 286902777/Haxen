//
//  UIImage+Extension.swift
//  HookMemory
//
//  Created by HF on 2023/11/6.
//

import Foundation
import UIKit
import Photos
import Kingfisher

extension UIImage {
    func saveImage(complete: @escaping (String?)->()){
        var url:String?
        PHPhotoLibrary.shared().performChanges({
            let result = PHAssetChangeRequest.creationRequestForAsset(from: self)
            let assetPlaceholder = result.placeholderForCreatedAsset
            //保存标志符
            url = assetPlaceholder?.localIdentifier
        }) { (isSuccess: Bool, error: Error?) in
            if isSuccess {
                print("保存成功!")
                complete(url)
            } else{
                print("保存失败：", error!.localizedDescription)
            }
        }
    }
}

func IMG(_ name: String) -> UIImage? {
    return UIImage.init(named: name)
}

extension UIImageView {
    typealias CompletionHandler = (_ image: UIImage?)->()
    func setImage(with url: String?, placeholder: String = "icon_placeholder", complete: CompletionHandler? = nil) {
        let placeImg = UIImage(named: placeholder)

        var targetUrl: String? = url
        
        // 解决url已被后台urlEncode，先将url Decode后，再Encode
        if let decodeUrl = url?.removingPercentEncoding {
            targetUrl = decodeUrl
        }
        
        guard let urlStr = targetUrl?.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            self.image = placeImg
            return
        }
        
        let imgUrl = URL(string: urlStr)
        self.kf.setImage(with: imgUrl, placeholder: placeImg, options: [.cacheSerializer(DefaultCacheSerializer.default)], progressBlock: nil) { (result) in
            switch result {
            case let .success(imgResult):
                complete?(imgResult.image.kf.normalized)
            case let .failure(error):
                print(error)
                break
            }
        }
    }
}
extension String {
    func getPhotoImage(complete: @escaping (UIImage?)->()) {
        if self.count == 0 {
            complete(nil)
        } else {
            let assetResult = PHAsset.fetchAssets(
                withLocalIdentifiers: [self], options: nil)
            let asset = assetResult[0]
            //获取保存的原图
            PHImageManager.default().requestImage(for: asset,
                                                  targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit,
                                                  options: nil, resultHandler: { (image, _:[AnyHashable : Any]?) in
                complete(image)
            })
        }
    }
}
