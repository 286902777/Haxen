//
//  HKPlayerItem.swift
//  HookMemory
//
//  Created by HF on 2023/11/17.
//

import Foundation
import AVFoundation

class HKPlayerResource {
    let name: String
    let cover: URL?
    var subtitle: HKSubtitles?
    let definitions: [HKPlayerResourceConfig]
    
    convenience init(url: URL, name: String = "", cover: URL? = nil, subtitle: URL? = nil) {
        let definition = HKPlayerResourceConfig(url: url, definition: "")
        
        var subtitles: HKSubtitles? = nil
        if let subtitle = subtitle {
            subtitles = HKSubtitles(url: subtitle)
        }
        
        self.init(name: name, definitions: [definition], cover: cover, subtitles: subtitles)
    }

    init(name: String = "", definitions: [HKPlayerResourceConfig], cover: URL? = nil, subtitles: HKSubtitles? = nil) {
        self.name        = name
        self.cover       = cover
        self.subtitle    = subtitles
        self.definitions = definitions
    }
}

class HKPlayerResourceConfig {
    let url: URL
    let definition: String
    
    var options: [String : Any]?
    
    var avURLAsset: AVURLAsset {
        get {
            return AVURLAsset(url: url)
        }
    }
    
    init(url: URL, definition: String, options: [String : Any]? = nil) {
        self.url        = url
        self.definition = definition
        self.options    = options
    }
}
