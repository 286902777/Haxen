//
//  PhotoViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/3.
//

import UIKit

class PhotoViewController: BaseViewController {
    var imageData: UIImage?
    
    lazy var imageV:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(imageV)
        imageV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.bringSubviewToFront(cusBar)
        imageV.image = imageData
    }
}
