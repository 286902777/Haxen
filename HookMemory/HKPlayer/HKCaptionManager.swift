//
//  HKCaptionManager.swift
//  HookMemory
//
//  Created by HF on 2023/11/21.
//

import Foundation
import ZIPFoundation

enum HKCaptionStatus: Int {
    case none = -1
    case waiting
    case downloading
    case paused
    case failed
    case finished
    case networkPaused
}

class HKCaptionDownload: NSObject {
    var url: String
    var id: String
    var state: HKCaptionStatus = .waiting
    var progress: Float = 0.0
    var totalSize: Int64 = 0
    
    var task: URLSessionDownloadTask?
    var resumeData: Data?
    
    init(url: String, id: String) {
        self.url = url
        self.id = id
    }
    
    var done: Bool {
        return self.progress >= 1
    }
}

let maxDownloads = 3
class HKCaptionManager: NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    static let share = HKCaptionManager()
    let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    let session = URLSession(configuration: URLSessionConfiguration.default)
    var task: URLSessionDataTask?
    var model: MovieVideoModel = MovieVideoModel()
    private(set) var downloads: [HKCaptionDownload] = []
    
    lazy var downloadsSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var fileManager: FileManager = .default
    
    override init() {
        
        super.init()
        
        _ = self.downloadsSession
        
    }
    
    /// 加入下载队列
    private func addDownload(_ download: HKCaptionDownload, resume: Bool = true) {
        if resume {
            download.task?.resume()
        }
        download.state = .downloading
        self.downloads.append(download)
    }
    
    /// 获取下载模型
    func getDownload(url: String?) -> HKCaptionDownload? {
        if let video = self.downloads.first(where: { $0.url == url }) {
            return video
        }
        
        return nil
    }
    
    func getDownload(id: String) -> HKCaptionDownload? {
        if let video = self.downloads.first(where: { $0.id == id }) {
            return video
        }
        
        return nil
    }
    
    func getDownload(task: URLSessionDownloadTask) -> HKCaptionDownload? {
        if let video = self.downloads.first(where: { $0.task == task }) {
            return video
        }
        return nil
    }
    
    // MARK: - Download
    func downLoadCaptions(_ model: MovieVideoModel) {
        self.model = model
        for item in model.captions {
            self.startDownload(item)
        }
    }
    /// 开始下载
    func startDownload(_ caption: MovieCaption) {
        print("开始下载: \(caption.captionId)\(caption.name)")
        if caption.transferred_address.count > 0, let url = URL(string: caption.transferred_address) {
            let download = HKCaptionDownload(url: caption.original_address, id: caption.captionId)
            download.task = self.downloadsSession.downloadTask(with: url)
            self.addDownload(download)
        } else if caption.original_address.count > 0, let url = URL(string: caption.original_address) {
            let download = HKCaptionDownload(url: caption.original_address, id: caption.captionId)
            download.task = self.downloadsSession.downloadTask(with: url)
            self.addDownload(download)
        } else {
            
        }
    }
    
    // MARK: - URLSessionDownloadDelegate
    /// 下载完成
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
//        let url = downloadTask.originalRequest?.url?.absoluteString
        let download = self.getDownload(task: downloadTask)
        if let captionId = download?.id {
            
            var srcsURL = URL(fileURLWithPath: path)
            srcsURL.appendPathComponent("caption")
            do {
                try fileManager.createDirectory(at: srcsURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("file error")
            }
            var url = srcsURL
            url.appendPathComponent("\(captionId).zip")
            
            let fileManager = self.fileManager
            
            //Removing the file at the path, just in case one exists
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print("file error")
            }
            
            //Moving the downloaded file to the new location
            do {
                try fileManager.moveItem(at: location, to: url)
            } catch _ as NSError {
                print("file error")
            }
            
            DispatchQueue.main.async {
                self.unZip(localPath: url, captionId: captionId)
            }
        }
    }
    /// 下载进度
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("downProgress: \(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error as? NSError, error.code != -999 {
            DispatchQueue.main.async {
                if let downloadTask = task as? URLSessionDownloadTask, let _ = self.getDownload(task: downloadTask) {
                    
                }
            }
        }
    }
    
    func unZip(localPath: URL, captionId: String) {
        let manager = FileManager()
        var url = URL(fileURLWithPath: "\(self.path)/caption")
        url.appendPathComponent(captionId)
        do {
            try manager.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            try manager.unzipItem(at: localPath, to: url)
        } catch {
            print("ZIP archive failed with error:\(error)")
        }
        let local = self.captionLocalPath(captionId: captionId)
        if let c = self.model.captions.first(where: {$0.captionId == captionId}) {
            c.local_address = local
            DBManager.share.updateVideoCaptionsData(self.model)
            NotificationCenter.default.post(name: Noti_CaptionRefresh, object: nil)
        }
    }
    
    func captionLocalPath(captionId: String) -> String {
        let srcsPath = "\(path)/caption/\(captionId)"
        if let files = FileManager.default.subpaths(atPath: srcsPath) {
            for p in files {
                let path = "/caption/\(captionId)".appending("/\(p)")
                return path
            }
        }
        return ""
    }
}
