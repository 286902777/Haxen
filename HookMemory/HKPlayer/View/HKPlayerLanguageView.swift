//
//  HKPlayerLanguageView.swift
//  HookMemory
//
//  Created by HF on 2023/11/24.
//

import UIKit

class HKPlayerLanguageView: UIViewController {
    /// 点击空白区域是否收起弹窗
    var dataArr: [MovieCaption] = []
    var clickBlock: ((_ id: String)->())?

    private let height: CGFloat = 450

    var bgView: UIView = UIView()
    private let cellIdentifier = "HKPlayerLanguageCell"
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.register(UINib(nibName: String(describing: HKPlayerLanguageCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        view.separatorStyle = .none
        if #available(iOS 15.0, *) {
            view.sectionHeaderTopPadding = 0
        }
        return view
    }()
    private lazy var lineL:UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.hex("#FFFFFF",alpha: 0.1)
        return label
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.bgView.transform = CGAffineTransform.identity
        }
    }
    
    private func showAnimate() {
        bgView.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    private func commentInit() {
        view.addSubview(bgView)
        view.backgroundColor = .clear
        bgView.frame = CGRectMake(0, kScreenHeight - height, kScreenWidth, height)
        bgView.effectView(CGSize(width: kScreenWidth, height: height))
        bgView.addCorner(conrners: [.topLeft, .topRight], radius: 24)
        bgView.addSubview(tableView)
        let backBtn = UIButton()
        backBtn.setImage(IMG("play_back"), for: .normal)
        backBtn.addTarget(self, action: #selector(clickBackAction), for: .touchUpInside)
        bgView.addSubview(backBtn)
        let titleL = UILabel()
        titleL.textColor = .white
        titleL.font = .font(weigth: .medium, size: 20)
        titleL.text = "Switch Language"
        titleL.textAlignment = .center
        bgView.addSubview(titleL)
        backBtn.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.left.equalTo(8)
            make.top.equalTo(24)
        }
        titleL.snp.makeConstraints { make in
            make.centerY.equalTo(backBtn)
            make.centerX.equalToSuperview()
        }
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(backBtn.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        commentInit()
        self.tableView.reloadData()
        for (index, model) in self.dataArr.enumerated() {
            if model.isSelect {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    guard let self = self else { return }
                    self.tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: .none, animated: false)
                }
            }
        }
    }
    
    @objc func clickBackAction () {
        self.dismiss(animated: false)
    }
}
extension HKPlayerLanguageView : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        64
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HKPlayerLanguageCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! HKPlayerLanguageCell
        if let model = self.dataArr.safe(indexPath.row) {
            cell.setModel(model)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _ = self.dataArr.map({$0.isSelect = false})
        if let model = self.dataArr.safe(indexPath.row) {
            model.isSelect = true
            clickBlock?(model.captionId)
        }
        tableView.reloadData()
    }
}

