//
//  DayDB+CoreDataProperties.swift
//  HookMemory
//
//  Created by HF on 2023/11/21.
//
//

import Foundation
import CoreData


extension DayDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DayDB> {
        return NSFetchRequest<DayDB>(entityName: "DayDB")
    }

    @NSManaged public var array: NSObject?
    @NSManaged public var date: String?
    @NSManaged public var day: String?
    @NSManaged public var month: String?
    @NSManaged public var dayShip: MemoryDB?

}

extension DayDB : Identifiable {

}
