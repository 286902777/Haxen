//
//  HKPurchaseViewController.swift
//  HookMemory
//
//  Created by HF on 2023/12/13.
//

import UIKit

class HKPurchaseViewController: UIViewController {
    lazy var scrollView: UIScrollView = {
        let scrollv = UIScrollView()
        scrollv.bounces = false
        scrollv.contentInsetAdjustmentBehavior = .never
        scrollv.translatesAutoresizingMaskIntoConstraints = false
        scrollv.showsVerticalScrollIndicator = false
        scrollv.showsHorizontalScrollIndicator = false
        scrollv.backgroundColor = .clear
        return scrollv
    }()
    
    var buyView: HKBuyView = HKBuyView.view()
    
    var vipView: HKUserVipView = HKUserVipView.view()
    
    var isTab: Bool = true
    
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
        self.navigationController?.navigationBar.isHidden = true
        self.buyView.selectData = HKUserManager.share.dataArr.first
        HKUserManager.share.getPurchaseData()
        HKUserManager.share.isVip = !HKUserManager.share.isVip
        self.updateViews()
    }
    
    func setUI() {
        view.backgroundColor = UIColor.hex("#141414")
        self.buyView.isHidden = true
        self.vipView.isHidden = true
        if self.isTab == false {
            self.cusBar.isHidden = false
            view.addSubview(self.cusBar)
            self.cusBar.NaviBarBlock = { [weak self] _ in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            }
            self.cusBar.snp.makeConstraints { make in
                make.left.top.right.equalToSuperview()
                make.height.equalTo(kNavBarHeight)
            }
        } else {
            self.cusBar.isHidden = true
        }
        
        self.view.addSubview(scrollView)

        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.isTab ? kStatusBarHeight : self.cusBar.snp.bottom)
            if self.isTab {
                make.bottom.equalToSuperview()
            } else {
                make.bottom.equalTo(view.safeAreaLayoutGuide)
            }
        }
        self.scrollView.addSubview(self.vipView)
        self.scrollView.addSubview(self.buyView)
        vipView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenWidth)
        }
        
        buyView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenWidth)
        }
    }
    
    func updateViews() {
        let imgH = kScreenWidth / 375 * 136
        if HKUserManager.share.isVip {
            self.buyView.isHidden = true
            self.vipView.isHidden = false
            self.vipView.hdView.isHidden = !HKConfig.share.isForUser
            self.scrollView.contentSize = CGSize(width: kScreenWidth, height: imgH + 570)

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
            self.scrollView.contentSize = CGSize(width: kScreenWidth, height: imgH + 688)
            self.buyView.isHidden = false
            self.vipView.isHidden = true
            self.buyView.hdView.isHidden = !HKConfig.share.isForUser
        }
    }
}

//extension HKPurchaseViewController: UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let setY = scrollView.contentOffset.y
//        if setY < 0 {
//            self.cusBar.titleL.alpha = 0
//        } else if setY >= 44 {
//            self.cusBar.titleL.alpha = 1
//        } else {
//            let alpha = setY / 44
//            self.cusBar.titleL.alpha = alpha
//        }
//    }
//}
