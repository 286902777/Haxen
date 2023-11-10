//
//  MovieSearchViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/9.
//

import UIKit

class MovieSearchViewController: BaseViewController {
    let hostUrl = "http://google.com/complete/search?output=toolbar&q="
    let movieSearchCellIdentifier = "MovieSearchCellIdentifier"
    let movieCellIdentifier = "MovieCellIdentifier"
    var searchKeys: [String] = []
    lazy var tableView: UITableView = {
        let table = UITableView.init(frame: .zero, style: .plain)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.backgroundColor = .clear
        table.register(MovieSearchCell.self, forCellReuseIdentifier: movieSearchCellIdentifier)
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if #available(iOS 15.0, *) {
            table.sectionHeaderTopPadding = 0
        }
        table.isHidden = true
        table.contentInsetAdjustmentBehavior = .never
        return table
    }()
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout:layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView.register(UINib(nibName: String(describing: MovieCell.self), bundle: nil), forCellWithReuseIdentifier: movieCellIdentifier)
        return collectionView
    }()
    lazy var textField: UITextField = {
        let view = UITextField()
        view.backgroundColor = .white
        view.placeholder = "search"
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.returnKeyType = .search
        view.clearButtonMode = .whileEditing
        view.delegate = self
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setSearchBar()
        setUI()
    }
    
    func setSearchBar() {
        cusBar.titleL.isHidden = true
        cusBar.rightBtn.isHidden = true
        cusBar.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.left.equalTo(cusBar.backBtn.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
            make.centerY.equalTo(cusBar.backBtn)
        }
    }
    
    func setUI() {
        view.addSubview(tableView)
        view.addSubview(collectionView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(cusBar.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(cusBar.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        }
    }
    
    func searchText(_ text: String) {
        NetManager.requestXML(url: hostUrl + text) { [weak self] xml in
            guard let self = self else { return }
            self.getDataXML(xml)
        }
    }
    
    func getDataXML(_ xmlText: String) {
        if let data = xmlText.data(using: .utf8) {
            let xml = XMLParser(data: data)
            self.searchKeys.removeAll()
            xml.delegate = self
            xml.parse()
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.tableView.isHidden = false
                self.collectionView.isHidden = true
                self.tableView.reloadData()
            }
        }
    }
}

extension MovieSearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:MovieSearchCell = tableView.dequeueReusableCell(withIdentifier: movieSearchCellIdentifier) as! MovieSearchCell
        cell.setModel(self.searchKeys[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.isHidden = true
        self.collectionView.isHidden = false
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.searchKeys.count
    }
}

extension MovieSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        20
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: movieCellIdentifier, for: indexPath) as! MovieCell
        cell.backgroundColor = .red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 200)
    }
}

extension MovieSearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            searchText(text)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            searchText(text)
        }
    }
}

extension MovieSearchViewController: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "suggestion"{
            if let key = attributeDict["data"]{
                self.searchKeys.append(key)
            }
        }
    }
}
