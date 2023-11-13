//
//  ListViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit

class ListViewController: BaseViewController {
    var dataArray: [memoryModel] = []
    let m: CGFloat = 16
    let cellIdentifier = "ListItemCell"
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let W = floor((kScreenWidth - 4 * m) / 3)
        layout.itemSize = CGSize(width: W, height: W * 134 / 103)
        layout.minimumLineSpacing = m
        layout.minimumInteritemSpacing = m
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 26, left: 0, bottom: 0, right: 0)
        collectionView.register(ListItemCell.self, forCellWithReuseIdentifier: cellIdentifier)
        return collectionView
    }()
    
    let calendar = Calendar.current
    let date = Date() // 当前日期
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setepUI()
        getAllDay()
        collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if self.dataArray.count > 0 {
                collectionView.scrollToItem(at: IndexPath(item: self.dataArray.count - 1, section: 0), at: .bottom, animated: false)
            }
        }
    }
    
    func setepUI() {
        cusBar.titleL.text = "All Memory"
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.cusBar.snp.bottom)
            make.left.equalTo(m)
            make.right.equalTo(-m)
            make.bottom.equalToSuperview()
        }
    }
    
    func formatYMD(_ format: String = "yyyy-MM-dd") -> String {
        
        let formater: DateFormatter = DateFormatter()
        
        formater.dateFormat = format
        
        return formater.string(from: Date())
    }
    
    func formatYear(_ format: String = "yyyy") -> String {
        
        let formater: DateFormatter = DateFormatter()
        
        formater.dateFormat = format
        
        return formater.string(from: Date())
    }
    
    func formatMonth(_ format: String = "MM") -> String {
        
        let formater: DateFormatter = DateFormatter()
        
        formater.dateFormat = format
        
        return formater.string(from: Date())
    }
    
    func getAllDay() {
        let dbArray: [dayModel] = DBManager.share.selectDatas()
        let toDay = formatYMD()
        let weeks = ["Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        // 获取当前月份的第一天
        let months = Int(formatMonth()) ?? 12
        let toYear = formatYear()
        for i in 1...months {
            let s: String = String (format:"%02d" , i)
            let toDateString = "\(toYear)-\(s)-01"
            if let getDate = dateFormatter.date(from: toDateString) {
                // 生成一个日期范围
                var toDate = getDate
                if i == months {
                    toDate = date
                }
                let range = calendar.dateInterval(of: .month, for: toDate)!
                let mod: memoryModel = memoryModel()
                mod.isMonth = true
                mod.month = toDate.formatMonthString()
                dataArray.append(mod)
                // 遍历日期范围内的每一天
                var days = [Date]()
                var currentDate = range.start
                while currentDate < range.end {
                    days.append(currentDate)
                    currentDate = calendar.date(byAdding: DateComponents(day: 1), to: currentDate)!
                }
                
                // 输出结果
                for day in days {
                    let dayComponents = calendar.dateComponents([.year, .month, .day, .weekday, .weekdayOrdinal], from: day)
                    
                    let model = memoryModel()
                    model.day = "\(dayComponents.day ?? 1)"
                    let m = String(format:"%02d", dayComponents.month!)
                    let d = String(format:"%02d", dayComponents.day!)
                    let td = "\(dayComponents.year!)-\(m)-\(d)"
                    let dStr = day.formatString()
                    model.date = dStr
                    if let hModel = dbArray.filter({$0.date == dStr}).first {
                        model.dModel = hModel
                    }
                    if toDay == td {
                        model.week = "Today"
                        dataArray.append(model)
                        return
                    } else {
                        model.week = "\(weeks[dayComponents.weekday! - 1])"
                        dataArray.append(model)
                    }
                }
            }
        }
    }
}
// MARK: -- delegate and datasource
extension ListViewController:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ListItemCell
        cell.setModel(self.dataArray[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.dataArray[indexPath.item]
        if model.isData, model.dModel.array.count > 0 {
            let vc = ListDetailViewController()
            vc.dataModel = model.dModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
