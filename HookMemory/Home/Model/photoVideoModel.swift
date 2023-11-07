//
//  photoVideoModel.swift
//  HookMemory
//
//  Created by HF on 2023/11/3.
//

import Foundation
import UIKit

class dayModel {
    var date: String = ""
    var month: String = ""
    var day: String = ""
    var array: [photoVideoModel] = []
}

class photoVideoModel: NSObject, NSCoding{
    var image = ""
    var videoUrl = ""
    var typeID: Int {
        get {
            if videoUrl.count > 0 {
                return 1
            } else {
                return 0
            }
        }
    }
    var date = ""
    var month = ""
    var day = ""
    var content = ""

    func encode(with aCoder: NSCoder) {
        aCoder.encode(image, forKey: "Core_image")
        aCoder.encode(videoUrl, forKey: "Core_videoUrl")
//        aCoder.encode(typeID, forKey: "Core_typeID");
        aCoder.encode(content, forKey: "Core_content");
        aCoder.encode(date, forKey: "Core_date");
        aCoder.encode(month, forKey: "Core_month");
        aCoder.encode(day, forKey: "Core_day");
    }
    
    required init?(coder aDecoder: NSCoder) {
        image = (aDecoder.decodeObject(forKey: "Core_image") as? String) ?? ""
        videoUrl = (aDecoder.decodeObject(forKey: "Core_videoUrl") as? String) ?? ""
//        typeID = (aDecoder.decodeObject(forKey: "Core_typeID") as? Int) ?? 0
        content = (aDecoder.decodeObject(forKey: "Core_content") as? String) ?? ""
        date = (aDecoder.decodeObject(forKey: "Core_date") as? String) ?? ""
        month = (aDecoder.decodeObject(forKey: "Core_month") as? String) ?? ""
        day = (aDecoder.decodeObject(forKey: "Core_day") as? String) ?? ""
    }
    
    override init() {
        super.init()
    }
    
}
