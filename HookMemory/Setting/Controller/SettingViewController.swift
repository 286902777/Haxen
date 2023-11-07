//
//  SettingViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit

class SettingViewController: BaseViewController {
    let cellIdentifier = "SettingCell"
    let dataArr: [String] = ["About us","Feedback", "Share", "Evaluate"]
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
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setepUI()
    }
    
    func setepUI() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(self.cusBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:SettingCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! SettingCell
        cell.titleL.text = dataArr[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let vc = AboutUsViewController()
            vc.titleName = dataArr[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = FeedBackViewController()
            vc.titleName = dataArr[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        case 2:
            let url: String = "https://www.baidu.com"
            let activityController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            present(activityController, animated: true, completion: nil)
        default:
            if let url = URL(string: "itms-apps://itunes.apple.com/app/id123456789?action=write-review") {
                UIApplication.shared.open(url)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}
