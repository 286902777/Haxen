//
//  HKTabBarViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import UIKit

class HKTabBarViewController: UITabBarController {
    enum TabBarItemTitle: String {
        case home = "首页"
        case study = "学习"
        case setting = "设置"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let movieNav = addChildVC(vc: MovieHomeViewController(),title: TabBarItemTitle.home.rawValue, image: "play", selectImage: "play")
        let setNav = addChildVC(vc: MovieFilterViewController(),title: TabBarItemTitle.setting.rawValue, image: "play", selectImage: "play")
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.hex("#000000"), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9)], for: .normal)
        
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 9)], for: .selected)
        
        self.tabBar.backgroundColor = .white
        self.viewControllers = [movieNav, setNav]
    }
    
    func addChildVC(vc: UIViewController, title: String, image: String, selectImage: String) -> UINavigationController {
        vc.tabBarItem.title = title
        vc.tabBarItem.image = IMG(image)
        vc.tabBarItem.selectedImage = IMG(selectImage)
        return UINavigationController.init(rootViewController: vc)
    }
}
