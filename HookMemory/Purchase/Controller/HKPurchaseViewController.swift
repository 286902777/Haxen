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
        if let data = HKUserManager.share.dataArr.first(where: {$0.oldPrice.isEmpty == false}) {
            self.buyView.selectData = data
        } else {
            self.buyView.selectData = HKUserManager.share.dataArr.first
        }
        HKUserManager.share.getPurchaseData()
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
            self.vipView.updateUI()
        } else {
            self.scrollView.contentSize = CGSize(width: kScreenWidth, height: imgH + 688)
            self.buyView.isHidden = false
            self.vipView.isHidden = true
            self.buyView.hdView.isHidden = !HKConfig.share.isForUser
        }
    }
}
