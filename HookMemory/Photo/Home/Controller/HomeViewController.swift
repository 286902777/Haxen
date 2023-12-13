//
//  HomeViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit
import Photos
import AVFoundation
import MobileCoreServices
import AppTrackingTransparency

class HomeViewController: BaseViewController {
    private var collectionView: UICollectionView?
    private var layout:CustomLayout?
    let CustomViewCellIdentifier = "CustomViewCellIdentifier"
    let NoDataCellIdentifier = "NoDataCellIdentifier"
    let photoH = 84
    var dataArray: [dayModel] = []
    let calendar = Calendar.current
    let date = Date() // 当前日期
    
    lazy var photoBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "Photograph"), for: .normal)
        btn.addTarget(self, action: #selector(pushListVC), for: .touchUpInside)
        return btn
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavbar()
        setepUI()
        getAllDay()
        requestData()
        NotificationCenter.default.addObserver(self, selector: #selector(netWorkChange), name: Notification.Name("netStatus"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func netWorkChange() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            switch appDelegate.netStatus {
            case .reachable(_):
                HKConfig.share.appRequest()
            default:
                break
            }
        }
    }
    
    func setNavbar() {
        cusBar.setBackHidden(true)
        cusBar.leftL.isHidden = false
        if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            cusBar.leftL.text = appName
        }
        
        cusBar.titleL.isHidden = true
        cusBar.middleBtn.isHidden = false
        cusBar.vipBtn.isHidden = false
        cusBar.vipBtn.setImage(UIImage(named: "setting"), for: .normal)
        cusBar.rightBtn.setImage(UIImage(named: "setting"), for: .normal)
        cusBar.middleBtn.setImage(UIImage(named: "schedule"), for: .normal)
        cusBar.NaviBarBlock = { [weak self] index in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                    appDelegate.setTrackingAuth()
                }
            }
            switch index {
            case 0:
                self.navigationController?.popViewController(animated: true)
            case 1:
                let vc = SettingViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            case 2:
                let vc = ListViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            default:
                let vc = HKPurchaseViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func setepUI() {
        view.addSubview(photoBtn)
        photoBtn.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-30)
            make.centerX.equalToSuperview()
            make.height.equalTo(photoH)
            make.width.equalTo(photoH)
        }
        layout = CustomLayout()
        let H = Int(kScreenHeight - kNavBarHeight - kBottomSafeAreaHeight) - 144 - photoH
        layout?.itemSize = CGSize(width: Int(kScreenWidth)-80, height: H)
        let rect = CGRect(x: 0, y: Int(kNavBarHeight) + 48, width: Int(kScreenWidth) , height: H)
        collectionView = UICollectionView(frame: rect, collectionViewLayout: layout!)
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .clear
        view.addSubview(collectionView!)
        collectionView?.register(CustomViewCell.self, forCellWithReuseIdentifier: CustomViewCellIdentifier)
        collectionView?.register(NoDataCell.self, forCellWithReuseIdentifier: NoDataCellIdentifier)
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
                    
                    let model = dayModel()
                    model.date = day.formatString()
                    model.month = day.formatMonthString()
                    model.day = "\(dayComponents.day ?? 1)"
                    let m = String(format:"%02d", dayComponents.month!)
                    let d = String(format:"%02d", dayComponents.day!)
                    let td = "\(dayComponents.year!)-\(m)-\(d)"

                    if let hModel = dbArray.filter({$0.date == model.date}).first {
                        model.array = hModel.array
                    }
                    dataArray.append(model)
                    if toDay == td {
                        initData()
                        return
                    }
                }
            }
        }
    }
    
    // 初始化数据
    func initData() {
        collectionView?.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if self.dataArray.count > 1 {
                self.collectionView?.scrollToItem(at: IndexPath(item: self.dataArray.count - 1, section: 0), at: .centeredHorizontally, animated: false)
            }
        }
    }

    func requestData() {
        MovieAPI.share.movieHomeList { success, list in
            if success {
                if let arr = list, let mod = arr.last??.data.first {
                    if mod.cover.isEmpty == false {
                        let imageV: UIImageView = UIImageView()
                        imageV.setImage(with: mod.cover)
                    }
                }
            }
        }
    }
    
    @objc func pushListVC() {
        let authStatus = PHPhotoLibrary.authorizationStatus()
        switch authStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.presentPhotoPickerController()
                    }
                }
            })
        case .limited, .authorized:
            self.presentPhotoPickerController()
        default:
            let alert = UIAlertController(title: "", message: "Do you need to use an album", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                
            })
            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                let url = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(url!)
            }
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true)
        }
    }
    
    func presentPhotoPickerController() {
        let sheet = HKSheetController.init(list: [["image":"photo", "name":"Photo"],["image":"video", "name":"Video"]])
        sheet.clickBlcok = { [weak self] index in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if index == 0 {
                    self.openCamera()
                } else {
                    self.openAudioSession()
                }
            }
        }
        self.present(sheet, animated: false)
    }
    
    func openCamera() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { (res) in
                //此处可以判断权限状态来做出相应的操作，如改变按钮状态
                if res{
                    DispatchQueue.main.async {
                        let vc = UIImagePickerController()
                        vc.allowsEditing = false
                        vc.delegate = self
                        vc.sourceType = .camera
                        vc.mediaTypes = [kUTTypeImage as String]
                        vc.cameraCaptureMode = .photo
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        case .authorized:
            DispatchQueue.main.async {
                let vc = UIImagePickerController()
                vc.allowsEditing = false
                vc.delegate = self
                vc.sourceType = .camera
                vc.mediaTypes = [kUTTypeImage as String]
                vc.cameraCaptureMode = .photo
                self.present(vc, animated: true, completion: nil)
            }
        default:
            let alert = UIAlertController(title: "", message: "Do you need to use an camera", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                
            })
            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                let url = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(url!)
            }
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true)
        }
    }
    
    func openAudioSession() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.audio) { granted in
                if granted{
                    DispatchQueue.main.async {
                        let vc = UIImagePickerController()
                        vc.allowsEditing = false
                        vc.delegate = self
                        vc.sourceType = .camera
                        vc.mediaTypes = [kUTTypeMovie as String]
                        vc.cameraCaptureMode = .video
                        self.present(vc, animated: true, completion: nil)
                    }
                }
            }
        case .authorized:
            DispatchQueue.main.async {
                let vc = UIImagePickerController()
                vc.allowsEditing = false
                vc.delegate = self
                vc.sourceType = .camera
                vc.mediaTypes = [kUTTypeMovie as String]
                vc.cameraCaptureMode = .video
                self.present(vc, animated: true, completion: nil)
            }
        default:
            let alert = UIAlertController(title: "", message: "Do you need to use an microphone", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
                
            })
            let ok = UIAlertAction(title: "Ok", style: .default) { _ in
                let url = URL(string: UIApplication.openSettingsURLString)
                UIApplication.shared.open(url!)
            }
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true)
        }
    }
}
// MARK: -- delegate and datasource
extension HomeViewController:
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
        if self.dataArray[indexPath.item].array.count == 0 {
            let noCell = collectionView.dequeueReusableCell(withReuseIdentifier: NoDataCellIdentifier, for: indexPath) as! NoDataCell
            return noCell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomViewCellIdentifier, for: indexPath) as! CustomViewCell
            let mod = self.dataArray[indexPath.item]
            cell.setModel(model: mod) {[weak self] in
                guard let self = self else { return }
                let vc = HKSheetController.init(list: [["image":"seeall", "name":"See All"],["image":"delete", "name":"Delete"]], isCancel: true)
                vc.clickBlcok = { index in
                    if index == 0 {
                        let vc = ListDetailViewController()
                        vc.dataModel = mod
                        vc.refreshBlock = {
                            self.getAllDay()
                        }
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else {
                        DBManager.share.deleteData(model: self.dataArray[indexPath.item])
                        self.getAllDay()
                    }
                }
                self.present(vc, animated: false, completion: nil)
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mod = self.dataArray[indexPath.item]
        if mod.array.count > 0 {
            let vc = ListDetailViewController()
            vc.dataModel = mod
            vc.refreshBlock = {
                self.getAllDay()
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let model = photoVideoModel()
        model.date = Date().formatString()
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            image.saveImage() { imageUrl in
                model.image = imageUrl ?? ""
            }
        } else if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            self.getThumbnailImage(videoURL: videoURL) { image in
                if let img = image {
                    img.saveImage() { imageUrl in
                        model.image = imageUrl ?? ""
                    }
                } else {
                    toast("Video acquisition failed")
                }
            }
            model.videoUrl = videoURL.absoluteString
//            model.typeID = 1
        } else {
            toast("Video acquisition failed")
        }
        dismiss(animated: true) {
            let vc = AddViewController()
            vc.model = model
            vc.doneBlock = { [weak self] mod in
                guard let self = self else { return }
                if let m = self.dataArray.last {
                    m.array.append(mod)
                    DispatchQueue.main.async {
                        self.collectionView?.reloadData()
                    }
                }
                DBManager.share.updateData(model: mod)
            }
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func getThumbnailImage(videoURL: URL, completion: @escaping (UIImage?) -> Void) {
        let asset = AVAsset(url: videoURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMake(value: 0, timescale: 1)
        imageGenerator.generateCGImagesAsynchronously(forTimes: [time as NSValue]) { _, cgImage,_, _, _ in
            if let cgImage = cgImage {
                let image = UIImage(cgImage: cgImage)
                completion(image)
            } else {
                completion(nil)
            }
        }
    }
    
    func getVideoImageFromPHAsset(videoAsset: PHAsset?, key: String, data: Data, complete: @escaping (UIImage?)->()) {
        guard let asset = videoAsset else { return }
        let option = PHImageRequestOptions()
        option.resizeMode = .fast
        PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: kScreenWidth, height: kScreenHeight), contentMode: .default, options: option) { result, info in
            DispatchQueue.main.async {
                complete(result)
            }
        }
    }
}
