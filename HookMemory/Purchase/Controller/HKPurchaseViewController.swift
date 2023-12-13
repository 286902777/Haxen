//
//  HKPurchaseViewController.swift
//  HookMemory
//
//  Created by HF on 2023/12/13.
//

import UIKit

class HKPurchaseViewController: UIViewController {
    lazy var scrollView: UIScrollView = {
        let scrollv = UIScrollView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        scrollv.contentSize = CGSize(width: 0, height: 170 * (kScreenWidth / 375) + 648)
        scrollv.bounces = false
        scrollv.contentInsetAdjustmentBehavior = .never
        scrollv.translatesAutoresizingMaskIntoConstraints = false
        scrollv.showsVerticalScrollIndicator = false
        scrollv.showsHorizontalScrollIndicator = false
        scrollv.delegate = self
        return scrollv
    }()
    
    lazy var buyView: HKBuyView = {
        let view = HKBuyView.view()
        view.selectData = HKUserManager.share.dataArr.first
        self.scrollView.addSubview(view)
        return view
    }()
    
    lazy var vipView: HKUserVipView = {
        let view = HKUserVipView.view()
        self.scrollView.addSubview(view)
        return view
    }()
    
    lazy var cusBar: HookNavigationBar = HookNavigationBar.view()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HKUserManager.share.refreshReceipt(from: .update)

        setUI()
        NotificationCenter.default.addObserver(forName: Noti_VipChange, object: nil, queue: .main) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateViews()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateViews()
        HKUserManager.share.getPurchaseData()
    }
    
    func setUI() {
        self.view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            if HKConfig.share.isForUser {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        }
        self.scrollView.isHidden = false
        self.buyView.isHidden = true
        self.vipView.isHidden = true
        self.cusBar.isHidden = false
        self.cusBar.NaviBarBlock = { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        self.updateViews()
    }
    
    func updateViews() {
            if HKUserManager.share.isVip {
                self.buyView.isHidden = true
                self.vipView.isHidden = false
                self.scrollView.contentSize = CGSize(width: 0, height: kScreenHeight < 700 ? 700 : (kScreenHeight - kBottomSafeAreaHeight))
                self.vipView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight < 700 ? 700 : (kScreenHeight - kBottomSafeAreaHeight))
                self.vipView.hdView.isHidden = !HKConfig.share.isForUser
                
                if let status = UserDefaults.standard.value(forKey: HKKeys.auto_renew_status) as? String, let time = UserDefaults.standard.value(forKey: HKKeys.expires_date_ms) as? Double {
                    if status == "1" {
                        self.vipView.centerLabel.text = "Auto-Renewal Active"
                    } else {
                        let date = Date(timeIntervalSince1970: time / 1000)
                        let dateformatter = DateFormatter()
                        dateformatter.dateFormat = "yyyy-MM-dd"
                        let dateString = dateformatter.string(from: date as Date)
                        self.vipView.centerLabel.text = "Cancel On : \(dateString)"
                    }
                }
                
                if let premiumID = UserDefaults.standard.value(forKey: HKKeys.product_id) as? String, let data = HKUserManager.share.dataArr.first(where: { $0.premiumID.rawValue == premiumID }) {
                    self.vipView.planLabel.text = data.title
                }
            } else {
                self.buyView.isHidden = false
                self.vipView.isHidden = true
                self.scrollView.contentSize = CGSize(width: 0, height: 170 * (kScreenWidth / 375) + 648)
                self.buyView.hdView.isHidden = !HKConfig.share.isForUser
                
            }
            self.cusBar.backBtn.isHidden = HKConfig.share.isForUser
    }

}

extension HKPurchaseViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let setY = scrollView.contentOffset.y
        if setY < 0 {
            self.cusBar.backgroundColor = UIColor.clear
            self.cusBar.titleL.alpha = 0
        } else if setY >= 44 {
            self.cusBar.backgroundColor = UIColor.red
            self.cusBar.titleL.alpha = 1
        } else {
            let alpha = setY / 44
            self.cusBar.backgroundColor = UIColor.white
            self.cusBar.titleL.alpha = alpha
        }
    }
}
