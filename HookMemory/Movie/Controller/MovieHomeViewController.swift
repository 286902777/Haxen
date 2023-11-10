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
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(UINib(nibName: String(describing: MovieListCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
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
        let header = RefreshNormalHeader(refreshingBlock: { [weak self] in
            guard let self = self else { return }
            self.requestData()
        })
        tableView.mj_header = header
    }
    
    func requestData() {
        tableView.mj_header?.endRefreshing()
        tableView.showTableEmpty(with: UIImage(named: "LOGO"), title: "title", btnTitle: "OK", offsetY: 10) {
            print("_________")
        } btnClickAction: {
            print("+++++++++++")
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
        200
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
}
