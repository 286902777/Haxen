//
//  FilterView.swift
//  HookMemory
//
//  Created by HF on 2023/11/8.
//

import UIKit

class FilterView: UIView {
    enum filterType: Int {
        case type = 0
        case genre
        case pub
        case country
    }
    
    let cellIdentifier = "FilterListCellIdentifier"
    typealias clickBlock = (_ index: filterType, _ id: String) -> Void
    var clickHandle : clickBlock?

    private var dataArr: [[MovieFilterCategoryInfoModel]] = []
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(UINib(nibName: String(describing: FilterListCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        table.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.isScrollEnabled = false
        table.showsVerticalScrollIndicator = false
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSubViews()
    }
    
    func setupSubViews() {
        self.backgroundColor = .clear
        self.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
     
    func setModel(_ arr: [[MovieFilterCategoryInfoModel]], clickBlock: clickBlock?) {
        self.clickHandle = clickBlock
        self.dataArr = arr
        if dataArr.count > 0 {
            self.tableView.reloadData()
        }
    }
}

extension FilterView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:FilterListCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! FilterListCell
        if self.dataArr.count > 0 {
            cell.setModel(self.dataArr[indexPath.row], clickBlock: { [weak self] id in
                guard let self = self else { return }
                self.clickHandle?(filterType(rawValue: indexPath.row) ?? .type, id)
            })
        }
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
