//
//  HKUserVipView.swift
//  HookMemory
//
//  Created by HF on 2023/12/13.
//

import UIKit
import MessageUI

class HKUserVipView: UIView {

    private var t: String = "1"
    @IBOutlet weak var planLabel: UILabel!
    
    @IBOutlet weak var centerLabel: UILabel!
    
    @IBOutlet weak var hdView: UIView! {
        didSet {
            hdView.isHidden = !HKConfig.share.isForUser
        }
    }
    
    @IBOutlet weak var adsImageV: UIImageView! {
        didSet {
            adsImageV.image = IMG(HKConfig.share.isForUser ? "purchase_greySelect" : "hpurchase_greySelect")
        }
    }
    @IBOutlet weak var stackRight: NSLayoutConstraint! {
        didSet {
            stackRight.constant = HKConfig.share.isForUser ? 16 : kScreenWidth * 0.5 + 6
        }
    }
    
    @IBOutlet weak var adView: UIView!
    
    @IBOutlet weak var emailLabel: UILabel!{
        didSet {
            let markStr: String = HKKeys.email
            let world: String = "Have questions or feedback? Email us at \(markStr)"
            let worldAttrStr: NSMutableAttributedString = NSMutableAttributedString(string: world)
            let markStrRange: Range = world.range(of: markStr)!
            let location = world.distance(from: world.startIndex, to: markStrRange.lowerBound)
            let range: NSRange = NSRange(location: location, length: markStr.count)
            self.emailRange = range
             
            worldAttrStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 12, weight: .medium), range: range)
            worldAttrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white.cgColor, range: range)
             
            emailLabel.attributedText = worldAttrStr
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
             
            worldAttrStr.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 16, weight: .medium), range: range)
            worldAttrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white.cgColor, range: range)
            worldAttrStr.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.white.cgColor, range: range)
            worldAttrStr.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range)
             
            restoreLabel.attributedText = worldAttrStr
            
            restoreLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(gotoRestore(gesture:)))
            restoreLabel.addGestureRecognizer(tap)
        }
    }
    
    @IBOutlet weak var termLabel: UILabel!{
        didSet {
            let markStr: String = "Terms of service"
            let world: String = "·Terms of service"
            let worldAttrStr: NSMutableAttributedString = NSMutableAttributedString(string: world)
            let markStrRange: Range = world.range(of: markStr)!
            let location = world.distance(from: world.startIndex, to: markStrRange.lowerBound)
            let range: NSRange = NSRange(location: location, length: markStr.count)
             
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
             
            worldAttrStr.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: range)
             
            privaLabel.attributedText = worldAttrStr
            
            privaLabel.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(pushPrivacy(gesture:)))
            privaLabel.addGestureRecognizer(tap)
        }
    }
    @IBOutlet weak var payBtn: UIButton! {
        didSet {
            payBtn.clipsToBounds = true
            if HKConfig.share.isForUser {
                payBtn.addGradientLayer(colorO: UIColor.hex("#FF6B3D"), colorT: UIColor.hex("#FF4131"), frame: CGRect(x: 0, y: 0, width: kScreenWidth - 32, height: 44))
            } else {
                payBtn.addGradientLayer(colorO: UIColor.hex("#89F3B7"), colorT: UIColor.hex("#4EDAD0"), frame: CGRect(x: 0, y: 0, width: kScreenWidth - 32, height: 44))
            }
        }
    }
    
    @IBOutlet weak var payL: UILabel!
    
    var restoreRange: NSRange?
    var emailRange: NSRange?
    
    class func view() -> HKUserVipView {
        let view = Bundle.main.loadNibNamed(String(describing: HKUserVipView.self), owner: nil)?.first as! HKUserVipView
        return view
    }
    
    func updateUI() {
        if let premiumID = UserDefaults.standard.value(forKey: HKKeys.product_id) as? String {
            if let data = HKUserManager.share.dataArr.first(where: { $0.premiumID.rawValue == premiumID }) {
                self.planLabel.text = data.title
                if data.oldPrice.isEmpty {
                    self.payBtn.setTitle("Pay \(data.price)", for: .normal)
                    self.payL.text = "Next monthly renewal will be at \(data.price). Cancel anytime"
                } else {
                    self.payBtn.setTitle("Pay \(data.oldPrice)", for: .normal)
                    self.payL.text = "Next monthly renewal will be at \(data.oldPrice). Cancel anytime"
                }
                switch data.premiumID {
                case .week:
                    self.t = "3"
                case .month:
                    self.t = "1"
                case .year:
                    self.t = "2"
                }
            }
        }
        if let status = UserDefaults.standard.value(forKey: HKKeys.auto_renew_status) as? String, let time = UserDefaults.standard.value(forKey: HKKeys.expires_date_ms) as? Double {
            if status == "1" {
                centerLabel.text = "Auto-Renewal Active"
                payBtn?.isHidden = true
                payL?.isHidden = true
            } else {
                let date = Date(timeIntervalSince1970: (time / 1000))
                let dateformatter = DateFormatter()
                dateformatter.dateFormat = "MMM-dd-yyyy"
                let dateString = dateformatter.string(from: date as Date)
                centerLabel.text = "Cancel On : \(dateString)"
                payBtn?.isHidden = false
                payL?.isHidden = false
            }
        }
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
    
    
    @objc func gotoRestore(gesture: UITapGestureRecognizer) {
        
        if let restoreRange = self.restoreRange {
            if gesture.didTapAttributedTextInLabel(label: self.restoreLabel, inRange: restoreRange) {
                HKLog.log("gotoRestore")
                HKLog.hk_vip_cl(kid: "2", type: self.t, source: "1")
                HKUserManager.share.restore()
            }
        }
        
    }
    
//    @objc func pushEmail(gesture: UITapGestureRecognizer) {
//        if let emailRange = self.emailRange {
//            if gesture.didTapAttributedTextInLabel(label: self.emailLabel, inRange: emailRange) {
//                HKLog.log("gotoEmail")
//                let feedback = MFMailComposeViewController()
//                feedback.mailComposeDelegate = self
//                feedback.setSubject("Feedback")
//                feedback.setToRecipients(["ellaluxis07@gmail.com"])
//                if MFMailComposeViewController.canSendMail() {
//                    HKConfig.currentVC()?.present(feedback, animated: true)
//                } else {
//                    toast("Email is temporarily unavailable")
//                }
//            }
//        }
//    }
    
    @IBAction func clickPayAction(_ sender: Any) {
        HKLog.log("pushPay")
        if let premiumID = UserDefaults.standard.value(forKey: HKKeys.product_id) as? String {
            HKLog.hk_vip_cl(kid: "1", type: self.t, source: "1")
            HKUserManager.share.goBuyProduct(premiumID, from: .buy)
        }
    }
}

extension HKUserVipView: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        HKLog.log("result: \(result)")
        switch result {
        case .cancelled:
            toast("Message has been Sent")
        case .saved:
            ProgressHUD.showSuccess("Message Saved")
        case .sent:
            ProgressHUD.showSuccess("Message has been Sent")
        case .failed:
            ProgressHUD.showError("Feedback Failed")
        default:
            ProgressHUD.showError("Feedback Failed")
        }
        controller.dismiss(animated: true)
    }
}
