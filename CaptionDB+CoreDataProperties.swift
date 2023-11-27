//
//  CaptionDB+CoreDataProperties.swift
//  HookMemory
//
//  Created by HF on 2023/11/21.
//
//

import Foundation
import CoreData


extension CaptionDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CaptionDB> {
        return NSFetchRequest<CaptionDB>(entityName: "CaptionDB")
    }

    @NSManaged public var captionId: String?
    @NSManaged public var name: String?
    @NSManaged public var short_name: String?
    @NSManaged public var display_name: String?
    @NSManaged public var original_address: String?
    @NSManaged public var transferred_address: String?
    @NSManaged public var local_address: String?
    @NSManaged public var captionShip: NSSet?

}

// MARK: Generated accessors for captionShip
extension CaptionDB {

    @objc(addCaptionShipObject:)
    @NSManaged public func addToCaptionShip(_ value: VideoDB)

    @objc(removeCaptionShipObject:)
    @NSManaged public func removeFromCaptionShip(_ value: VideoDB)

    @objc(addCaptionShip:)
    @NSManaged public func addToCaptionShip(_ values: NSSet)

    @objc(removeCaptionShip:)
    @NSManaged public func removeFromCaptionShip(_ values: NSSet)

}

extension CaptionDB : Identifiable {

}
