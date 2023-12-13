//
//  DBManager.swift
//  HookMemory
//
//  Created by HF on 2023/11/3.
//

import Foundation
import CoreData

class DBManager {
    static let share = DBManager()
    static let applicationDocumentsDirectoryName = "com.coredata.hk"
    static let mainStoreFileName = "Data.sqlite"
    static let errorDomain = "DataManager"
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // 对应存储的模型CoreData.xcdatamodeld
        let modelURL = Bundle.main.url(forResource: "HookMemory", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    // 持久化协调器
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        do {
            // 自动升级选项设置
            let options = [
                NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true
            ]
            
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.storeURL as URL, options: options)
        }
        catch {
            fatalError("持久化存储错误: \(error).")
        }
        
        return persistentStoreCoordinator
    }()
    
    
    lazy var mainQueueContext: NSManagedObjectContext = {
        
        let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        // 避免多线程中出现问题，如果有属性和内存中都发生了改变，以内存中的改变为主
        moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return moc
    }()
    
    
    /// CoreData 文件存储目录
    //
    lazy var applicationSupportDirectory: URL = {
        
        let fileManager = FileManager.default
        var supportDirectory:URL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
        
        var saveUrl:URL = supportDirectory.appendingPathComponent(DBManager.applicationDocumentsDirectoryName)
        
        if fileManager.fileExists(atPath: saveUrl.path) == false {
            let path = saveUrl.path
            print("文件存储路径:\(path)")
            do {
                
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories:true, attributes:nil)
            }
            catch {
                fatalError("FlyElephant文件存储目录创建失败: \(path).")
            }
        }
        
        return saveUrl
    }()
    
    
    lazy var storeURL: URL = {
        return self.applicationSupportDirectory.appendingPathComponent(DBManager.mainStoreFileName)
    }()
    
    
    // 创建私有CoreData存储线程
    func newPrivateQueueContextWithNewPSC() throws -> NSManagedObjectContext {
        
        // 子线程中创建新的持久化协调器
        //
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: DBManager.share.managedObjectModel)
        
        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: DBManager.share.storeURL as URL, options: nil)
        
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        context.performAndWait() {
            
            context.persistentStoreCoordinator = coordinator
            
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
        }
        
        return context
    }
    
    // MARK: 增、删、改、查
    func updateData(model: photoVideoModel) {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        if let dataModel: DayDB = findDataWithModel(date: model.date) {
            var arr = dataModel.array as? [photoVideoModel] ?? []
            arr.append(model)
            dataModel.array = arr as NSObject
        } else {
            self.insertData(model: model)
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func insertData(model: photoVideoModel) {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        let dataModel = NSEntityDescription.insertNewObject(forEntityName: "DayDB", into: context) as! DayDB
        dataModel.date = model.date
        dataModel.month = model.month
        dataModel.day = model.day
        dataModel.array = [model] as NSObject
        
        do {
            try context.save()
        } catch { }
    }
    
    func deleteData(model: dayModel) {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        if let mod: DayDB = findDataWithModel(date: model.date)  {
            context.delete(mod)
        }
        if context.hasChanges {
            do {
                print("删除成功")
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func findDataWithModel(date: String) -> DayDB? {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "DayDB")
        
        fetchRequest.predicate = NSPredicate(format: "date=%@", date)
        
        do {
            let searchResults = try context.fetch(fetchRequest)
            if searchResults.count > 0 {
                let model:DayDB = searchResults[0] as! DayDB
                return model
            } else {
                return nil
            }
        } catch  {
            print(error)
        }
        return nil
    }
    
    func selectDatas() ->Array<dayModel> {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "DayDB")
        
        var dataArray = Array<dayModel>()
        do {
            let searchResults = try context.fetch(fetchRequest)
            if searchResults.count > 0 {
                dataArray.removeAll()
                for model in searchResults {
                    if let mod = model as? DayDB {
                        let m = dayModel()
                        m.date = mod.date ?? ""
                        m.array = mod.array as? [photoVideoModel] ?? []
                        dataArray.append(m)
                    }
                }
            }
            return dataArray
        } catch  {
            return dataArray
        }
    }
    
    // MARK: - Video 增、删、改、查

    func updateVideoData(_ model: MovieDataInfoModel) {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        if let m: VideoDB = findVideoDataWithModel(id: model.id) {
            m.title = model.title
            m.coverImageUrl = model.cover
            m.uploadTime = model.pub_date
            m.rate = model.rate
            m.isMovie = model.m_type != "tv_mflx"
            m.ssn_eps = model.ss_eps
            m.country = model.country
            m.updateTime = Double(Date().timeIntervalSince1970)
        } else {
            let m: MovieVideoModel = MovieVideoModel()
            m.id = model.id
            m.title = model.title
            m.coverImageUrl = model.cover
            m.uploadTime = model.pub_date
            m.rate = model.rate
            m.isMovie = model.m_type != "tv_mflx"
            m.ssn_eps = model.ss_eps
            m.country = model.country
            m.updateTime = Double(Date().timeIntervalSince1970)
            self.insertVideoData(mod: m)
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func updateVideoData(_ model: MovieVideoModel) {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        if let m: VideoDB = findVideoDataWithModel(id: model.id, ssn_id: model.ssn_id, eps_id: model.eps_id) {
            m.title = model.title
            m.coverImageUrl = model.coverImageUrl
            m.rate = model.rate
            m.ssn_eps = model.ssn_eps
            m.country = model.country
            m.isMovie = model.isMovie
            m.ssn_id = model.ssn_id
            m.ssn_name = model.ssn_name
            m.eps_id = model.eps_id
            m.eps_num = Int16(model.eps_num)
            m.eps_name = model.eps_name
            m.updateTime = Double(Date().timeIntervalSince1970)
        } else {
            model.updateTime = Double(Date().timeIntervalSince1970)
            self.insertVideoData(mod: model)
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func updateVideoPlayData(_ model: MovieVideoModel) {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        if let m: VideoDB = findVideoDataWithModel(id: model.id, ssn_id: model.ssn_id, eps_id: model.eps_id) {
            m.playProgress = model.playProgress
            m.totalTime = model.totalTime
            m.playedTime = model.playedTime
            m.updateTime = Double(Date().timeIntervalSince1970)
        } else {
            model.updateTime = Double(Date().timeIntervalSince1970)
            self.insertVideoData(mod: model)
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func updateVideoCaptionsData(_ model: MovieVideoModel) {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        if let m: VideoDB = findVideoDataWithModel(id: model.id, ssn_id: model.ssn_id, eps_id: model.eps_id) {
            m.captions = model.captions as [MovieCaption]
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
//    func updateVideoData(mod: MovieVideoModel) {
//        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
//        if let m: VideoDB = findVideoDataWithModel(key: mod.id) {
//            m.id = mod.id
//            m.isImport = mod.isImport
//            m.isMovie = mod.isMovie
//            m.title = mod.title
//            m.videoInfo = mod.videoInfo
//            m.country = mod.country
//            m.ssn_eps = mod.ssn_eps
//            m.ssn_id = mod.ssn_id
//            m.eps_id = mod.eps_id
//            m.eps_name = mod.eps_name
//            m.ssn_name = mod.ssn_name
//            m.eps_num = Int16(mod.eps_num)
//            m.rate = mod.rate
//            m.url = mod.url
//            m.path = mod.path
//            m.coverImageUrl = mod.coverImageUrl
//            m.uploadTime = mod.uploadTime
//            m.totalTime = mod.totalTime
//            m.playedTime = mod.playedTime
//            m.playProgress = mod.playProgress
//            m.dataSize = mod.dataSize
//            m.updateTime = mod.updateTime
//            m.format = mod.format
//            m.captions = mod.captions as NSObject
//            m.totalTime = mod.totalTime
//            m.playedTime = mod.playedTime
//            m.playProgress = mod.playProgress
//        } else {
//            self.insertVideoData(mod: mod)
//        }
//        
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
//        }
//    }
    
    func insertVideoData(mod: MovieVideoModel) {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        let m = NSEntityDescription.insertNewObject(forEntityName: "VideoDB", into: context) as! VideoDB
        m.id = mod.id
        m.isImport = mod.isImport
        m.isMovie = mod.isMovie
        m.title = mod.title
        m.videoInfo = mod.videoInfo
        m.country = mod.country
        m.ssn_eps = mod.ssn_eps
        m.ssn_id = mod.ssn_id
        m.eps_id = mod.eps_id
        m.eps_name = mod.eps_name
        m.ssn_name = mod.ssn_name
        m.eps_num = Int16(mod.eps_num)
        m.rate = mod.rate
        m.url = mod.url
        m.path = mod.path
        m.coverImageUrl = mod.coverImageUrl
        m.uploadTime = mod.uploadTime
        m.totalTime = mod.totalTime
        m.playedTime = mod.playedTime
        m.playProgress = mod.playProgress
        m.dataSize = mod.dataSize
        m.updateTime = Double(Date().timeIntervalSince1970)
        m.format = mod.format
        m.captions = mod.captions as [MovieCaption]
        do {
            try context.save()
        } catch { }
    }
    
    func deleteVideoData(model: MovieDataInfoModel) {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext

        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "VideoDB")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "updateTime", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "id=%@", model.id)

        do {
            let searchResults = try context.fetch(fetchRequest)
            if searchResults.count > 0 {
                for (_, item) in searchResults.enumerated() {
                    if let mod = item as? VideoDB {
                        context.delete(mod)
                    }
                }
            }
        } catch  {
            print(error)
        }
  
        if context.hasChanges {
            do {
                print("删除成功")
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func findVideoDataWithModel(id: String, ssn_id: String = "", eps_id: String = "") -> VideoDB? {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "VideoDB")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "updateTime", ascending: false)]
        if ssn_id.isEmpty, eps_id.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "id=%@", id)
        } else {
            fetchRequest.predicate = NSPredicate(format: "id=%@ AND ssn_id=%@ AND eps_id=%@", id, ssn_id, eps_id)
        }
        do {
            let searchResults = try context.fetch(fetchRequest)
            if searchResults.count > 0 {
//                for (idx, item) in searchResults.enumerated() {
//                    if let mod = item as? VideoDB {
//                        print(idx,mod.id, mod.ssn_id, mod.eps_id, mod.updateTime)
//                    }
//                }
                let model:VideoDB = searchResults.first as! VideoDB
                return model
            } else {
                return nil
            }
        } catch  {
            print(error)
        }
        return nil
    }
    
    func selectVideoData(id: String, ssn_id: String = "", eps_id: String = "") -> MovieVideoModel? {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "VideoDB")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "updateTime", ascending: false)]
        if ssn_id.isEmpty, eps_id.isEmpty {
            fetchRequest.predicate = NSPredicate(format: "id=%@", id)
        } else {
            fetchRequest.predicate = NSPredicate(format: "id=%@ AND ssn_id=%@ AND eps_id=%@", id, ssn_id, eps_id)
        }

        do {
            let searchResults = try context.fetch(fetchRequest)
            if let mod = searchResults.first as? VideoDB {
                let m = MovieVideoModel()
                m.id = mod.id ?? ""
                m.isImport = mod.isImport
                m.isMovie = mod.isMovie
                m.title = mod.title ?? ""
                m.videoInfo = mod.videoInfo ?? ""
                m.country = mod.country ?? ""
                m.ssn_eps = mod.ssn_eps ?? ""
                m.ssn_id = mod.ssn_id ?? ""
                m.eps_id = mod.eps_id ?? ""
                m.eps_name = mod.eps_name ?? ""
                m.ssn_name = mod.ssn_name ?? ""
                m.eps_num = Int(mod.eps_num)
                m.rate = mod.rate ?? ""
                m.url = mod.url ?? ""
                m.path = mod.path ?? ""
                m.coverImageUrl = mod.coverImageUrl ?? ""
                m.uploadTime = mod.uploadTime ?? ""
                m.totalTime = mod.totalTime
                m.playedTime = mod.playedTime
                m.playProgress = mod.playProgress
                m.dataSize = mod.dataSize ?? ""
                m.updateTime = mod.updateTime
                m.format = mod.format ?? ""
                m.captions = mod.captions ?? []
                return m
            }
            return nil
        } catch {
            return nil
        }
    }
    
    func selectHistoryVideoDatas() ->Array<MovieDataInfoModel> {
        let context:NSManagedObjectContext = DBManager.share.mainQueueContext
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "VideoDB")
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: "updateTime", ascending: false)]

        var dataArray = Array<MovieDataInfoModel>()
        do {
            let searchResults = try context.fetch(fetchRequest)
            if searchResults.count > 0 {
                dataArray.removeAll()
                for model in searchResults {
                    if let mod = model as? VideoDB {
                        if let _ = dataArray.first(where: {$0.id == mod.id}) {
                            continue
                        }
                        let m = MovieDataInfoModel()
                        m.id = mod.id ?? ""
                        m.title = mod.title ?? ""
                        m.m_type = mod.isMovie ? "" : "tv_mflx"
                        m.ssn_id = mod.ssn_id ?? ""
                        m.eps_id = mod.eps_id ?? ""
                        m.cover = mod.coverImageUrl ?? ""
                        m.country = mod.country ?? ""
                        m.rate = mod.rate ?? ""
                        m.playProgress = mod.playProgress
                        dataArray.append(m)
                    }
                }
            }
            return dataArray
        } catch  {
            return dataArray
        }
    }
}
