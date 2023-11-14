//
//  NoDataCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit

class NoDataCell: UICollectionViewCell {
    
    lazy var imageV:UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "nocontent")
        return view
    }()
    
    lazy var titleL:UILabel = {
        let label = UILabel()
        label.text = "No content"
        label.font = UIFont.font(weigth: .medium, size: 24)
        label.textColor = UIColor.hex("#141414")
        return label
    }()
    
    lazy var noContentL:UILabel = {
        let label = UILabel()
        label.text = "Please click the button below to record a great day!"
        label.font = UIFont.font(weigth: .medium, size: 16)
        label.textColor = UIColor.hex("#141414")
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 48
        self.layer.masksToBounds = true
        self.addSubview(imageV)
        self.addSubview(titleL)
        self.addSubview(noContentL)
        let H = Int(kScreenHeight - kNavBarHeight - kBottomSafeAreaHeight) - 144 - 85

        let rect = CGRect(x: 0, y: 0, width: Int(kScreenWidth) - 80, height: H)

        self.addGradientLayer(colorO: UIColor.hex("#98F9E2"), colorT: UIColor.hex("#EEFFDD"), frame: rect, top: true)
        titleL.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.centerX.equalToSuperview()
        }
        imageV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleL.snp.bottom).offset(64)
            make.size.equalTo(CGSize(width: 140, height: 140))
        }
        noContentL.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(imageV.snp.bottom).offset(48)
            make.left.equalTo(22)
            make.right.equalTo(-22)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
