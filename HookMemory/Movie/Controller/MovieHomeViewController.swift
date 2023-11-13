//
//  MovieHomeViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import UIKit
import MJRefresh

class MovieHomeViewController: UIViewController {
    let cellIdentifier = "MovieListCell"
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(UINib(nibName: String(describing: MovieListCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        view.backgroundColor = UIColor.hex("#141414")
        setUpUI()
        addRefresh()
    }
    
    func setUpUI () {
        let search = SearchView.view()
        view.addSubview(search)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(search.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        self.tableView.reloadData()
    }
    
    func addRefresh() {
        let header = RefreshGifHeader { [weak self] in
            guard let self = self else { return }
            self.requestData()
        }
        tableView.mj_header = header
        
        let footer = RefreshAutoNormalFooter {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.tableView.mj_footer?.endRefreshing()
                self.tableView.mj_footer?.endRefreshingWithNoMoreData()
            }
        }
        tableView.mj_footer = footer
    }
    
    func requestData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.tableView.mj_header?.endRefreshing()
            self.tableView.showTableEmpty(with: UIImage(named: "LOGO"), title: "title", btnTitle: "OK", offsetY: 10) {
                print("_________")
            } btnClickAction: {
                print("+++++++++++")
            }
        }
    }
    
    // MARK: - Empty
    func showEmpty() {
        tableView.showTableEmpty(with: UIImage(named: "LOGO"), title: "title", btnTitle: "OK", offsetY: 10) {
            print("_________")
        } btnClickAction: {
            print("+++++++++++")
        }
    }
    
    func dismissEmpty() {
        tableView.dismissEmpty()
    }
}

extension MovieHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MovieListCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! MovieListCell
        cell.setModel { index in
            
        } clickBlock: { [weak self] movieId in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let vc = MovieFilterViewController()
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let H = ceil((kScreenWidth - 40 - 23) / 3 * 138 / 104) + 76 + 42
        return H
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 22))
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        22
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
}
