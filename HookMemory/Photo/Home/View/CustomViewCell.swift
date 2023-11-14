//
//  ListItemCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit

class CustomViewCell: UICollectionViewCell {
    lazy var dayL:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.font(weigth: .semibold, size: 24)
        return label
    }()
    
    lazy var contentL:UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont.font(size: 14)
        return label
    }()
    
    lazy var moreBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "home_more"), for: .normal)
        return btn
    }()
    
    lazy var imageV:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var smegmaTopV:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "smegmaTop")
        return view
    }()
    
    lazy var smegmaBottomV:UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "smegmaBottom")
        return view
    }()
    typealias moreBlock = () -> Void
    var moreHandle : moreBlock?
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 48
        self.layer.masksToBounds = true
        self.addSubview(imageV)
        self.addSubview(smegmaTopV)
        self.addSubview(smegmaBottomV)
        self.addSubview(dayL)
        self.addSubview(moreBtn)
        self.addSubview(contentL)
        imageV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        smegmaTopV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        smegmaBottomV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
 
        moreBtn.snp.makeConstraints { make in
            make.right.equalTo(-6)
            make.top.equalTo(17)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        dayL.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalTo(moreBtn)
            make.top.equalTo(24)
        }
        contentL.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalTo(-25)
            make.height.equalTo(40)
        }
        moreBtn.addTarget(self, action: #selector(clickMoreAction), for: .touchUpInside)
    }
    
    func setModel(model: dayModel, _ moreHandle: moreBlock?){
        self.dayL.text = model.date
        if let m = model.array.last {
            self.contentL.text = m.content
            m.image.getPhotoImage(complete: { [weak self] image in
                guard let self = self else { return }
                 self.imageV.image = image
            })
        }
        self.moreHandle = moreHandle
    }
    
    @objc func clickMoreAction() {
        self.moreHandle?()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
