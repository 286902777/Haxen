//
//  HKTabBarViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import UIKit

class HKTabBarViewController: UITabBarController {
    enum TabBarItemTitle: String {
        case home = "Home"
        case explore = "Explore"
        case setting = "Setting"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let homeNav = addChildVC(vc: MovieHomeViewController(),title: TabBarItemTitle.home.rawValue, image: "movie_home", selectImage: "movie_home_select")
        let exploreNav = addChildVC(vc: MovieFilterViewController(),title: TabBarItemTitle.explore.rawValue, image: "movie_explore", selectImage: "movie_explore_select")
        let setNav = addChildVC(vc: MovieSettingViewController(),title: TabBarItemTitle.setting.rawValue, image: "movie_setting", selectImage: "movie_setting_select")
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.hex("#FFFFFF", alpha: 0.5), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)], for: .selected)
        self.tabBar.barTintColor = UIColor.hex("#232323")
        self.tabBar.backgroundColor = .clear
        self.viewControllers = [homeNav, exploreNav, setNav]
    }
    
    func addChildVC(vc: UIViewController, title: String, image: String, selectImage: String) -> UINavigationController {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = IMG(image)
        vc.tabBarItem.selectedImage = UIImage(named: selectImage)?.withRenderingMode(.alwaysOriginal)
        return UINavigationController.init(rootViewController: vc)
    }
}

//extension HKTabBarViewController {
//    // 是否支持自动转屏
//    override var shouldAutorotate: Bool {
//        return false
//    }
//
//    // 支持哪些屏幕方向
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .portrait
//    }
//
//    // 默认的屏幕方向
//    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
//        return .portrait
//    }
//}
