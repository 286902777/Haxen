//
//  HKSheetController.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit

class HKSheetController: UIViewController {
    /// 点击空白区域是否收起弹窗
    var isGesture = true
    
    /// 取消按钮
    var isCancel = false
    private var dataArr: [[String: String]] = []
    var clickBlcok: ((_ index: Int)->())?

    private var tableHeight: CGFloat = 0

    private lazy var bgView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hex("#262626")
        view.layer.masksToBounds = true
        return view
    }()
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = .clear
        view.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        view.register(UINib(nibName: "HKSheetCell", bundle: nil), forCellReuseIdentifier: "HKSheetCell")
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

    private lazy var bottomBtn:UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel", for: .normal)
        btn.titleLabel?.font = UIFont.font(size: 14)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return btn
    }()

    /// 初始化方法
    /// - Parameters:
    ///   - tableHeight: tableHeight description

    init(list:[[String: String]], isCancel: Bool = false) {
        super.init(nibName: nil, bundle:nil)
        self.isCancel = isCancel
        self.modalPresentationStyle = .overFullScreen
        self.dataArr = list
        self.tableHeight = CGFloat(list.count * 62 + 20 + (isCancel ? 63 : 0)) + kBottomSafeAreaHeight
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.bgView.transform = CGAffineTransform.identity
        }
    }
    private func showAnimate() {
        view.backgroundColor = UIColor.hex("#141414",alpha: 0.5)
        bgView.transform = CGAffineTransform(translationX: 0, y: 0)
    }
    
    private func dismissAnimate() {
        self.view.backgroundColor = .clear
        self.dismiss(animated: false, completion: nil)
    }
    private func commentInit() {
        view.addSubview(bgView)
        bgView.frame = CGRect(x: 0, y: kScreenHeight - tableHeight, width: kScreenWidth, height: tableHeight)
        bgView.addCorner(conrners: [.topLeft, .topRight], radius: 16)

        bgView.addSubview(tableView)
        if self.isCancel {
            bgView.addSubview(lineL)
            bgView.addSubview(bottomBtn)
            bottomBtn.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(-kBottomSafeAreaHeight)
                make.height.equalTo(62)
            }
            lineL.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(bottomBtn.snp.top)
                make.height.equalTo(1)
            }
        }
        tableView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(self.isCancel ? lineL.snp.top : bgView)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        showAnimate()
        commentInit()
        self.tableView.reloadData()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isGesture {
            self.dismissAnimate()
        }
    }
    
    @objc func cancelAction() {
        dismiss(animated: false)
    }
}
extension HKSheetController : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        62
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HKSheetCell = tableView.dequeueReusableCell(withIdentifier: "HKSheetCell") as! HKSheetCell
        cell.setData(data: self.dataArr[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: false) {
            self.clickBlcok?(indexPath.row)
        }
    }
}

