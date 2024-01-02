//
//  VideoDB+CoreDataProperties.swift
//  HookMemory
//
//  Created by HF on 2024/1/2.
//
//

import Foundation
import CoreData


extension VideoDB {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VideoDB> {
        return NSFetchRequest<VideoDB>(entityName: "VideoDB")
    }

    @NSManaged public var captions: [MovieCaption]?
    @NSManaged public var country: String?
    @NSManaged public var coverImageUrl: String?
    @NSManaged public var dataSize: String?
    @NSManaged public var eps_id: String?
    @NSManaged public var eps_name: String?
    @NSManaged public var eps_num: Int16
    @NSManaged public var format: String?
    @NSManaged public var id: String?
    @NSManaged public var isImport: Bool
    @NSManaged public var isMovie: Bool
    @NSManaged public var path: String?
    @NSManaged public var playedTime: Double
    @NSManaged public var playProgress: Double
    @NSManaged public var rate: String?
    @NSManaged public var ssn_eps: String?
    @NSManaged public var ssn_id: String?
    @NSManaged public var ssn_name: String?
    @NSManaged public var title: String?
    @NSManaged public var totalTime: Double
    @NSManaged public var updateTime: Double
    @NSManaged public var uploadTime: String?
    @NSManaged public var url: String?
    @NSManaged public var videoInfo: String?
    @NSManaged public var delete: Bool
    @NSManaged public var videoShip: CaptionDB?

}

extension VideoDB : Identifiable {

}
