//
//  ListItemCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit

class ListItemCell: UICollectionViewCell {
    let imageV: UIImageView = UIImageView()
    let showImageV: UIImageView = UIImageView()

    let monthL: UILabel = UILabel()
    let weekL: UILabel = UILabel()
    let dayL: UILabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 24
        self.layer.masksToBounds = true
        self.addSubview(imageV)
        self.addSubview(showImageV)
        self.addSubview(monthL)
        self.addSubview(weekL)
        self.addSubview(dayL)
        imageV.contentMode = .scaleAspectFill
        monthL.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        weekL.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        dayL.font = UIFont.systemFont(ofSize: 20, weight: .semibold)

        imageV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        showImageV.backgroundColor = UIColor.hex("#141414", alpha: 0.15)
        showImageV.isHidden = true
        showImageV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        monthL.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        weekL.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(16)
        }
        dayL.snp.makeConstraints { make in
            make.top.equalTo(weekL.snp.bottom).offset(16)
            make.left.equalTo(16)
        }
        monthL.textColor = UIColor.hex("#141414")
    }
    
    func setModel(_ model: memoryModel) {
        if model.isMonth {
            monthL.isHidden = false
            weekL.isHidden = true
            dayL.isHidden = true
            imageV.image = UIImage(named: "month_bg")
        } else {
            monthL.isHidden = true
            weekL.isHidden = false
            dayL.isHidden = false
            imageV.image = UIImage(named: "day_bg")
        }
        
        monthL.text = model.month
        weekL.text = model.week
        dayL.text = model.day
        if let m = model.dModel.array.first {
            m.image.getPhotoImage(complete: { [weak self] image in
                guard let self = self else { return }
                 self.imageV.image = image
            })
            self.showImageV.isHidden = false
            weekL.textColor = .white
            dayL.textColor = .white
        } else {
            self.showImageV.isHidden = true
            weekL.textColor = UIColor.hex("#141414")
            dayL.textColor = UIColor.hex("#141414")
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
