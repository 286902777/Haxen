//
//  UIImage+Extension.swift
//  HookMemory
//
//  Created by HF on 2023/11/6.
//

import Foundation
import UIKit
import Photos

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
