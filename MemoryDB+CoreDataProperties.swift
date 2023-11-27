//
//  MemoryDB+CoreDataProperties.swift
//  HookMemory
//
//  Created by HF on 2023/11/21.
//
//

import Foundation
import CoreData


extension MemoryDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemoryDB> {
        return NSFetchRequest<MemoryDB>(entityName: "MemoryDB")
    }

    @NSManaged public var content: String?
    @NSManaged public var date: String?
    @NSManaged public var day: String?
    @NSManaged public var image: String?
    @NSManaged public var month: String?
    @NSManaged public var typeID: Int16
    @NSManaged public var url: String?
    @NSManaged public var memoryShip: DayDB?

}

extension MemoryDB : Identifiable {

}
