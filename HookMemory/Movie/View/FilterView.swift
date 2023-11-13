//
//  FilterView.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import UIKit

class FilterView: UIView {
    let cellIdentifier = "FilterListCellIdentifier"
    private var dataArr: [[MovieFiterModel]] = []
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(UINib(nibName: String(describing: FilterListCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.isScrollEnabled = false
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    init(title: String) {
        super.init(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 200))
        setupSubViews()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews() {
        self.backgroundColor = .white
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        initData()
    }
     
    func initData() {
        var arr: [MovieFiterModel] = []
        for i in 0...8 {
            let model = MovieFiterModel()
            model.name = "text-\(i)"
            arr.append(model)
        }
        for _ in 0...4 {
            dataArr.append(arr)
        }
        self.tableView.reloadData()
    }
}

extension FilterView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FilterListCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! FilterListCell
        cell.setModel(self.dataArr[indexPath.row], clickBlock: { type in
            print(type)
        })
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        50
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
}
