//
//  MovieHomeViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import UIKit
import MJRefresh

class MovieHomeViewController: MovieBaseViewController {
    let cellIdentifier = "MovieListCell"
    private var dataArr: [MovieHomeModel?] = []
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(UINib(nibName: String(describing: MovieListCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.contentInset = UIEdgeInsets(top: 22, left: 0, bottom: 0, right: 0)
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        addRefresh()
    }
    
    func setUpUI() {
        let search = SearchView.view()
        let tap = UITapGestureRecognizer(target: self, action: #selector(pushSearch))
        search.addGestureRecognizer(tap)
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
            self.initData()
        }
        tableView.mj_header = header
        tableView.mj_header?.beginRefreshing()
    }
    
    override func initData() {
        MovieAPI.share.movieHomeList { [weak self] success, list in
            guard let self = self else { return }
            if !success {
                self.showEmpty(.noNet, self.tableView)
            } else {
                self.dismissEmpty(self.tableView)
                self.dataArr = list ?? []
                self.dataArr.removeFirst()
            }
            self.tableView.mj_header?.endRefreshing()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
            }
        }
    }
    
    override func reloadNetWorkData() {
        tableView.mj_header?.beginRefreshing()
    }
    
    @objc func pushSearch() {
        let vc = MovieSearchViewController()
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension MovieHomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MovieListCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! MovieListCell
        if let model = self.dataArr[indexPath.row] {
            cell.setModel(model: model, clickMoreBlock: { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    let vc = MovieListViewController()
                    if let mod = model.data.first {
                        vc.titleName = mod.name
                        vc.listId = mod.id
                    }
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }, clickBlock: { movieId in
                
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let H = ceil((kScreenWidth - 40 - 23) / 3 * 138 / 104) + 76 + 42
        return H
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataArr.count
    }
}
