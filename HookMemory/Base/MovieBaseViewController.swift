//
//  MovieBaseViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/10.
//

import UIKit
import AppTrackingTransparency

class MovieBaseViewController: UIViewController {
    lazy var cusBar: HookNavigationBar = {
        let view = HookNavigationBar.view()
        return view
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hex("#141414")
        addBackImage()
        addNavBar()
        addTracking()
        NotificationCenter.default.addObserver(self, selector: #selector(netWorkChange), name: Notification.Name("netStatus"), object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func netWorkChange() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            switch appDelegate.netStatus {
            case .reachable(_):
                initData()
            default:
                noNetAction()
            }
        }
    }
    
    func initData() {
        
    }
    
    func noNetAction() {
        
    }
    
    func addTracking() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    
                }
            }
        }
    }

    func addBackImage() {
        let imageV = UIImageView()
        view.addSubview(imageV)
        imageV.image = UIImage.init(named: "movie_view_bg")
        imageV.contentMode = .scaleToFill
        imageV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func addNavBar() {
        self.navigationController?.navigationBar.isHidden = true
        view.addSubview(self.cusBar)
        cusBar.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(kNavBarHeight)
        }
        cusBar.NaviBarBlock = { [weak self] tag in
            print(tag)
            guard let self = self else { return }
            switch tag {
            case 0:
                self.backAction()
            case 1:
                self.rightAction()
            default:
                self.middleAction()
            }
        }
    }
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func rightAction() {
        
    }
    
    func middleAction() {
        
    }
    
    // MARK: - Empty
    func showEmpty(_ type: HKEmptyView.emptyType = .noNet, _ view: UITableView) {
        let image = IMG(type == .noNet ? "movie_no_network" : "movie_no_concent")
        let titleText = type == .noNet ? "No network, please retry" : "No results found. Try different keywords."
        view.showTableEmpty(with: image, title: titleText, btnTitle: type == .noNet ? "Retry" : "", offsetY: kNavBarHeight) {
            
        } btnClickAction: { [weak self] in
            self?.reloadNetWorkData()
        }
    }
    
    func dismissEmpty(_ view: UITableView) {
        view.dismissEmpty()
    }
    
    func showEmpty(_ type: HKEmptyView.emptyType = .noNet, view: UICollectionView) {
        let image = IMG(type == .noNet ? "movie_no_network" : "movie_no_concent")
        let titleText = type == .noNet ? "No network, please retry" : "No results found. Try different keywords."
        view.showTableEmpty(with: image, title: titleText, btnTitle: type == .noNet ? "" : "Retry", offsetY: kNavBarHeight) {
            
        } btnClickAction: { [weak self] in
            self?.reloadNetWorkData()
        }
    }
    
    func dismissEmpty(_ view: UICollectionView) {
        view.dismissEmpty()
    }
    
    
    func reloadNetWorkData() {
        
    }
}
