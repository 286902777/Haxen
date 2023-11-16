//
//  MovieSearchCell.swift
//  HookMemory
//
//  Created by HF on 2023/11/9.
//

import UIKit

class MovieSearchCell: UITableViewCell {
    lazy var searchV: UIImageView = {
        let view = UIImageView()
        view.image = IMG("movie_search")
        return view
    }()
    
    lazy var titleL: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .font(weigth: .medium, size: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.addUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func addUI() {
        self.addSubview(searchV)
        self.addSubview(titleL)
        searchV.snp.makeConstraints { make in
            make.left.equalTo(15)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 14, height: 14))
        }
        titleL.snp.makeConstraints { make in
            make.left.equalTo(searchV.snp.right).offset(16)
            make.right.equalTo(-16)
            make.centerY.equalTo(searchV)
        }
    }
    
    func setModel(_ text: String) {
        titleL.text = text
    }
    
//    private func setupSearch(text: String) {
//        var search = ""
//        var end = ""
//        let searchAttr =

//        let totalAttr = NSMutableAttributedString(string: "￥")
//        totalAttr.yy_font = UIFont.systemFont(ofSize: 20, weight: .medium)
//        totalAttr.yy_color = UIColor.k2B2F36
//
//        let integerPriceAttr = NSMutableAttributedString(string: integerPrice)
//        integerPriceAttr.yy_font = UIFont.systemFont(ofSize: 36, weight: .medium)
//        integerPriceAttr.yy_color = UIColor.k2B2F36
//        
//        totalAttr.append(integerPriceAttr)
//        
//        let pointPriceAttr = NSMutableAttributedString(string: pointPrice)
//        pointPriceAttr.yy_font = UIFont.systemFont(ofSize: 20, weight: .medium)
//        pointPriceAttr.yy_color = UIColor.k2B2F36
//        totalAttr.append(pointPriceAttr)
//        
//        orderPriceL.attributedText = totalAttr
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
