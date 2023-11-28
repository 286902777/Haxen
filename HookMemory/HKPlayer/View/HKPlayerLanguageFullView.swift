//
//  HKPlayerLanguageFullView.swift
//  HookMemory
//
//  Created by HF on 2023/11/25.
//

import UIKit

class HKPlayerLanguageFullView: UIView {
    
    @IBOutlet weak var bgView: UIView!
    
    @IBAction func clickAction(_ sender: Any) {
        self.removeFromSuperview()
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var backBlock: (()->())?
    var clickBlock: ((_ id: String)->())?
    private let cellIdentifier = "HKPlayerLanguageCell"
    private var dataArr: [MovieCaption] = []
    class func view() -> HKPlayerLanguageFullView {
        let view = Bundle.main.loadNibNamed(String(describing: HKPlayerLanguageFullView.self), owner: nil)?.first as! HKPlayerLanguageFullView
        view.bgView.backgroundColor = UIColor.hex("#FFFFFF", alpha: 0.05)
        view.bgView.effectView(CGSize(width: 308, height: kScreenWidth))
        let tap = UITapGestureRecognizer(target: view, action: #selector(dismissView))
        view.addGestureRecognizer(tap)
        return view
    }
    
    @objc func dismissView() {
        self.backBlock?()
        self.removeFromSuperview()
    }
    func setModel(_ list: [MovieCaption]) {
        self.tableView.register(UINib(nibName: String(describing: HKPlayerLanguageCell.self), bundle: nil), forCellReuseIdentifier: cellIdentifier)
        self.dataArr = list
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
}

extension HKPlayerLanguageFullView: UITableViewDelegate, UITableViewDataSource {
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
