//
//  ListDetailViewController.swift
//  HookMemory
//
//  Created by HF on 2023/11/2.
//

import UIKit
import Photos
import IQKeyboardManagerSwift
import MobileCoreServices

class ListDetailViewController: BaseViewController {
    private var collectionView: UICollectionView?
    let contentH = 132
    var dataModel: dayModel = dayModel()
    private var layout:CustomLayout?
    let cellIdentifier = "ListDetailCell"
    var refreshBlock: (()->())?
    let contentV: UIView = UIView()

    lazy var textView: IQTextView = {
        let view = IQTextView()
        view.textColor = UIColor.hex("#141414")
        view.font = UIFont.font(size: 14)
        view.backgroundColor = .clear
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        view.isEditable = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavbar()
        setepUI()
        setContentView()
    }
    func setNavbar() {
        cusBar.rightBtn.setImage(UIImage(named: "add"), for: .normal)
    }
    
    func setepUI() {
        layout = CustomLayout()
        let H = Int(kScreenHeight - kNavBarHeight - kBottomSafeAreaHeight) - 144 - contentH
        layout?.itemSize = CGSize(width: Int(kScreenWidth)-80, height: H)
        let rect = CGRect(x: 0, y: Int(kNavBarHeight) + 48, width: Int(kScreenWidth) , height: H)
        collectionView = UICollectionView(frame: rect, collectionViewLayout: layout!)
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.delegate = self
        collectionView?.dataSource = self
        collectionView?.backgroundColor = .clear
        view.addSubview(collectionView!)
        collectionView?.register(ListDetailCell.self, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    func setContentView() {
        view.addSubview(contentV)
        contentV.addGradientLayer(colorO: UIColor.hex("#B3FFED"), colorT: UIColor.hex("#FFFFFF"), frame: CGRect(x: 0, y: 0, width: Int(kScreenWidth) - 96, height: contentH), top: true)
        contentV.layer.cornerRadius = 14
        contentV.layer.masksToBounds = true
        contentV.addSubview(textView)

        contentV.snp.makeConstraints { make in
            make.top.equalTo(self.collectionView!.snp.bottom).offset(32)
            make.left.equalTo(48)
            make.right.equalTo(-48)
            make.height.equalTo(contentH)
        }
        
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.collectionView?.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            if self.dataModel.array.count > 0 {
                self.collectionView?.scrollToItem(at: IndexPath(item: self.dataModel.array.count - 1, section: 0), at: .centeredHorizontally, animated: false)
                self.textView.text = self.dataModel.array.last?.content
            }
        }
    }
    
    override func rightAction() {
        super.rightAction()
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
extension ListDetailViewController:
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataModel.array.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ListDetailCell
        cell.setModel(self.dataModel.array[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = self.dataModel.array[indexPath.item]
        let cell: ListDetailCell = collectionView.cellForItem(at: indexPath) as! ListDetailCell
        if model.typeID == 0 {
            let vc = PhotoViewController()
            vc.imageData = cell.imageV.image
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            let vc = VideoViewController()
            vc.urlString = model.videoUrl
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cells = collectionView?.visibleCells {
            for cell in cells {
                if let c = collectionView, self.dataModel.array.count > 0 {
                    let w = c.contentSize.width / CGFloat(self.dataModel.array.count)
                    if abs(cell.frame.origin.x - scrollView.contentOffset.x) < w * 0.5 {
                        if let indexPath = c.indexPath(for: cell) {
                            self.textView.text = self.dataModel.array[indexPath.item].content
                        }
                    }
                }
            }
        }
    }
}

extension ListDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
                self.dataModel.array.append(mod)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    self.collectionView?.scrollToItem(at: IndexPath(item: self.dataModel.array.count - 1, section: 0), at: .centeredHorizontally, animated: true)
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
