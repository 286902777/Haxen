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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hex("#141414")
        addBackImage()
        addNavBar()
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.setTrackingAuth()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(netWorkChange), name: Notification.Name("netStatus"), object: nil)
    }

    deinit {
        ProgressHUD.dismiss()
        NetManager.cancelAllRequest()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func netWorkChange() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            switch appDelegate.netStatus {
            case .reachable(_):
                refreshRequest()
            default:
                noNetAction()
            }
        }
    }
    
    func refreshRequest() {
        
    }
    
    func noNetAction() {
        
    }

    func addBackImage() {
        let imageV = UIImageView()
        view.addSubview(imageV)
        imageV.image = UIImage.init(named: "movie_view_bg")
        imageV.contentMode = .scaleToFill
        view.sendSubviewToBack(imageV)
        imageV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func addNavBar() {
        self.navigationController?.navigationBar.barStyle = .black
        view.addSubview(self.cusBar)
        cusBar.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(kNavBarHeight)
        }
        cusBar.NaviBarBlock = { [weak self] tag in
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
        view.showTableEmpty(with: image, title: titleText, btnTitle: type == .noNet ? "Retry" : "", offsetY: 0) {
            
        } btnClickAction: { [weak self] in
            self?.refreshRequest()
        }
    }
    
    func dismissEmpty(_ view: UITableView) {
        view.dismissEmpty()
    }
    
    func showEmpty(_ type: HKEmptyView.emptyType = .noNet, _ view: UICollectionView) {
        let image = IMG(type == .noNet ? "movie_no_network" : "movie_no_concent")
        let titleText = type == .noNet ? "No network, please retry" : "No results found. Try different keywords."
        view.showTableEmpty(with: image, title: titleText, btnTitle: type == .noNet ? "Retry" : "", offsetY: 0) {
            
        } btnClickAction: { [weak self] in
            self?.refreshRequest()
        }
    }
    
    func dismissEmpty(_ view: UICollectionView) {
        view.dismissEmpty()
    }
}

extension MovieBaseViewController {
    // 是否支持自动转屏
    override var shouldAutorotate: Bool {
        return false
    }

    // 支持哪些屏幕方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    // 默认的屏幕方向
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}
