//
//  HKBuyView.swift
//  HookMemory
//
//  Created by HF on 2023/12/13.
//

import UIKit

class HKBuyView: UIView {
    
    @IBOutlet weak var preLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var backView: UIView! 
    @IBOutlet weak var priLabel: UILabel!
    
    @IBOutlet weak var priStackView: UIStackView!
    @IBOutlet weak var hdView: UIView! {
        didSet {
            hdView.isHidden = !HKConfig.share.isForUser
        }
    }
    @IBOutlet weak var stackRight: NSLayoutConstraint! {
        didSet {
            stackRight.constant = HKConfig.share.isForUser ? 16 : kScreenWidth * 0.5 + 6
        }
    }
    @IBOutlet weak var adView: UIView!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.contentInsetAdjustmentBehavior = .never
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.delegate = self
            tableView.dataSource = self
            tableView.backgroundColor = .clear
            tableView.separatorStyle = .none
            tableView.rowHeight = 93
            tableView.register(UINib.init(nibName: String(describing: HKPurchaseCell.self), bundle: nil), forCellReuseIdentifier: String(describing: HKPurchaseCell.self))
        }
    }
    
    @IBOutlet weak var infoLabel: UILabel! {
        didSet {
            let markStr: String = "Cancel anytime."
            let world: String = "*Auto-renewal for \(purMoneyMonth) per month. Cancel anytime."
            let worldAttrStr: NSMutableAttributedString = NSMutableAttributedString(string: world)
            let markStrRange: Range = world.range(of: markStr)!
            let location = world.distance(from: world.startIndex, to: markStrRange.lowerBound)
            let range: NSRange = NSRange(location: location, length: markStr.count)
             
            worldAttrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(white: 1, alpha: 0.5).cgColor, range: range)
             
            infoLabel.attributedText = worldAttrStr
            
        }
    }
    
    @IBOutlet weak var payView: UIView! {
        didSet {
            payView.clipsToBounds = true
            if HKConfig.share.isForUser {
                payView.addGradientLayer(colorO: UIColor.hex("#FF6B3D"), colorT: UIColor.hex("#FF4131"), frame: CGRect(x: 0, y: 0, width: kScreenWidth - 32, height: 44))
            } else {
                payView.addGradientLayer(colorO: UIColor.hex("#89F3B7"), colorT: UIColor.hex("#4EDAD0"), frame: CGRect(x: 0, y: 0, width: kScreenWidth - 32, height: 44))
            }
            let tap = UITapGestureRecognizer(target: self, action: #selector(pushPay(gesture:)))
            payView.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var payMoneyLabel: UILabel!
    
    @IBOutlet weak var termLabel: UILabel! {
        didSet {
            let markStr: String = "Terms of service"
            let world: String = "·Terms of service"
            let worldAttrStr: NSMutableAttributedString = NSMutableAttributedString(string: world)
            let markStrRange: Range = world.range(of: markStr)!
            let location = world.distance(from: world.startIndex, to: markStrRange.lowerBound)
            let range: NSRange = NSRange(location: location, length: markStr.count)
            self.termRange = range
             
            worldAttrStr.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range)
             
            termLabel.attributedText = worldAttrStr
            
            termLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(pushTerms(gesture:)))
            termLabel.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var privaLabel: UILabel! {
        didSet {
            let markStr: String = "Privacy policy"
            let world: String = "·Privacy policy"
            let worldAttrStr: NSMutableAttributedString = NSMutableAttributedString(string: world)
            let markStrRange: Range = world.range(of: markStr)!
            let location = world.distance(from: world.startIndex, to: markStrRange.lowerBound)
            let range: NSRange = NSRange(location: location, length: markStr.count)
            self.privcyRange = range
             
            worldAttrStr.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range)
             
            privaLabel.attributedText = worldAttrStr
            
            privaLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(pushPrivacy(gesture:)))
            privaLabel.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var restoreLabel: UILabel! {
        didSet {
            let markStr: String = "restore"
            let world: String = "If the ad still appears after purchase,tap restore."
            let worldAttrStr: NSMutableAttributedString = NSMutableAttributedString(string: world)
            let markStrRange: Range = world.range(of: markStr)!
            let location = world.distance(from: world.startIndex, to: markStrRange.lowerBound)
            let range: NSRange = NSRange(location: location, length: markStr.count)
            self.restoreRange = range
             
            worldAttrStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 18, weight: .medium), range: range)
            worldAttrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.hex("#FFFFFF").cgColor, range: range)
            worldAttrStr.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.hex("#FFFFFF").cgColor, range: range)
            worldAttrStr.addAttribute(NSAttributedString.Key.underlineStyle, value: 2, range: range)
             
            restoreLabel.attributedText = worldAttrStr
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(gotoRestore(gesture:)))
            restoreLabel.addGestureRecognizer(tap)
        }
    }
    
    var restoreRange: NSRange?
    var termRange: NSRange?
    var privcyRange: NSRange?
    
    var selectData: HKUserData? {
        didSet {
            DispatchQueue.main.async {
                if let selectData = self.selectData {
                    let markStr: String = "Cancel anytime."
                    var world: String = ""
                    switch selectData.premiumID {
                    case .month:
                        self.payMoneyLabel.text = purMoneyMonth
                        if selectData.oldPrice.isEmpty {
                            world = "*Auto-renewal for \(purMoneyMonth) per month. Cancel anytime."
                        } else {
                            world = "*\(purMoneyMonth) for the 1st month. Next recurring monthly renewal will be $\(selectData.oldPrice). Cancel anytime."
                        }
                    case .week:
                        self.payMoneyLabel.text = purMoneyWeek
                        if selectData.oldPrice.isEmpty {
                            world = "*Auto-renewal for \(purMoneyWeek) per weak. Cancel anytime."
                        } else {
                            world = "*\(purMoneyWeek) for the 1st week. Next recurring weekly renewal will be $\(selectData.oldPrice). Cancel anytime."
                        }
                    case .year:
                        self.payMoneyLabel.text = purMoneyYear
                        if selectData.oldPrice.isEmpty {
                            world = "*Auto-renewal for \(purMoneyYear) per year. Cancel anytime."
                        } else {
                            world = "*\(purMoneyYear) for the 1st year. Next recurring annually renewal will be $\(selectData.oldPrice). Cancel anytime."
                        }
                    }
                    let worldAttrStr: NSMutableAttributedString = NSMutableAttributedString(string: world)
                    let markStrRange: Range = world.range(of: markStr)!
                    let location = world.distance(from: world.startIndex, to: markStrRange.lowerBound)
                    let range: NSRange = NSRange(location: location, length: markStr.count)
                    
                    worldAttrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(white: 1, alpha: 0.5).cgColor, range: range)
                    
                    self.infoLabel.attributedText = worldAttrStr
                }
            }
        }
    }
    
    class func view() -> HKBuyView {
        let view = Bundle.main.loadNibNamed(String(describing: HKBuyView.self), owner: nil)?.first as! HKBuyView
        return view
    }
    
    @objc func pushTerms(gesture: UITapGestureRecognizer) {
        HKLog.log("pushTerms")
        let vc = WebViewController()
        vc.titleName = "Terms of Service"
        vc.url = "https://haxen24.com/terms/"
        vc.hidesBottomBarWhenPushed = true
        HKConfig.currentVC()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func pushPrivacy(gesture: UITapGestureRecognizer) {
        HKLog.log("pushPrivacy")
        let vc = WebViewController()
        vc.titleName = "Privacy Policy"
        vc.url = "https://haxen24.com/privacy/"
        vc.hidesBottomBarWhenPushed = true
        HKConfig.currentVC()?.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func pushPay(gesture: UITapGestureRecognizer) {
        HKLog.log("pushPay")
        HKUserManager.share.buyProduct(self.selectData?.premiumID.rawValue ?? HKUserID.month.rawValue, from: .buy)
    }
    
    @objc func gotoRestore(gesture: UITapGestureRecognizer) {
        
        if let restoreRange = self.restoreRange {
            if gesture.didTapAttributedTextInLabel(label: self.restoreLabel, inRange: restoreRange) {
                HKLog.log("gotoRestore")
                HKUserManager.share.restore()
            }
        }
        
    }

}

extension HKBuyView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        HKUserManager.share.dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: HKPurchaseCell.self)) as! HKPurchaseCell
        cell.selectionStyle = .none
        
        let data = HKUserManager.share.dataArr[indexPath.row]
        if data.premiumID == self.selectData?.premiumID {
            cell.isChoose = true
        } else {
            cell.isChoose = false
        }
        
        cell.titleLabel.text = data.title
        cell.costLabel.text = data.price
        cell.tipLabel.isHidden = data.tag.count == 0
        cell.tipLabel.text = data.tag
        
        if data.isLine {
            let worldAttrStr: NSMutableAttributedString = NSMutableAttributedString(string: data.subTitle)
            worldAttrStr.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 1, range: NSRange(location: 0, length: data.subTitle.count))
            cell.infoLabel.attributedText = worldAttrStr
        } else {
            cell.infoLabel.text = data.subTitle
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = HKUserManager.share.dataArr[indexPath.row]
        self.selectData = data
        tableView.reloadData()
    }
    
}

extension UIGestureRecognizer {
 
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
 
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
 
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
 
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
 
}

