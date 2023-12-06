//
//  MovieSettingViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/10.
//


import UIKit

class MovieSettingViewController: MovieBaseViewController {
    let cellIdentifier = "SettingCell"
    let dataArr: [String] = ["Privacy Policy","Terms of Service", "Feedback", "About"]
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(SettingCell.self, forCellReuseIdentifier: cellIdentifier)
        table.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setepUI()
    }
    

    
    func setepUI() {
        view.addSubview(tableView)
        self.cusBar.backBtn.isHidden = true
        self.cusBar.rightBtn.isHidden = true
        self.cusBar.titleL.text = "Setting"
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.cusBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
}

extension MovieSettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SettingCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SettingCell
        cell.titleL.text = dataArr[indexPath.row]
        if indexPath.row == dataArr.count - 1 {
            cell.arrowV.isHidden = true
            cell.subTitleL.isHidden = false
            if HKConfig.app_version.isEmpty == false {
                cell.subTitleL.text = "v\(HKConfig.app_version)"
            }
        } else {
            cell.arrowV.isHidden = false
            cell.subTitleL.isHidden = true
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = WebViewController()
            vc.titleName = self.dataArr[indexPath.row]
            vc.url = "https://haxen24.com/privacy/"
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = WebViewController()
            vc.titleName = self.dataArr[indexPath.row]
            vc.url = "https://haxen24.com/terms/"
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let vc = FeedBackViewController()
            vc.titleName = dataArr[indexPath.row]
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}
