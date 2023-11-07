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
//        let dataModel = NSEntityDescription.insertNewObject(forEntityName: "DayDB", into: context) as! DayDB
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
    
}

