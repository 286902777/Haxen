//
//  ListDetailCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit

class ListDetailCell: UICollectionViewCell {
    
    lazy var imageV:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var videoV:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "play")
        view.isHidden = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 48
        self.layer.masksToBounds = true
        self.addSubview(imageV)
        self.addSubview(videoV)

        imageV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        videoV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 64, height: 64))
        }
    }
    
    func setModel(_ model: photoVideoModel) {
        model.image.getPhotoImage(complete: { [weak self] image in
            guard let self = self else { return }
             self.imageV.image = image
        })
        videoV.isHidden = model.typeID == 0 ? true : false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
