//
//  HKSubtitles.swift
//  HookMemory
//
//  Created by HF on 2023/11/17.
//

import Foundation

class HKSubtitles {
    var groups: [Group] = []
    /// subtitles delay, positive:fast, negative:forward
    var delay: TimeInterval = 0
    
    struct Group: CustomStringConvertible {
        var index: Int
        var start: TimeInterval
        var end  : TimeInterval
        var text : String
        
        init(_ index: Int, _ start: NSString, _ end: NSString, _ text: NSString) {
            self.index = index
            self.start = Group.parseDuration(start as String)
            self.end   = Group.parseDuration(end as String)
            self.text  = text as String
        }
        
        static func parseDuration(_ fromStr:String) -> TimeInterval {
            var h: TimeInterval = 0.0, m: TimeInterval = 0.0, s: TimeInterval = 0.0, c: TimeInterval = 0.0
            let scanner = Scanner(string: fromStr)
            scanner.scanDouble(&h)
            scanner.scanString(":", into: nil)
            scanner.scanDouble(&m)
            scanner.scanString(":", into: nil)
            scanner.scanDouble(&s)
            scanner.scanString(",", into: nil)
            scanner.scanDouble(&c)
            let parse = (h * 3600.0) + (m * 60.0) + s + (c / 1000.0)
            return parse
        }
        
        var description: String {
            return "Subtile Group ==========\nindex : \(index),\nstart : \(start)\nend   :\(end)\ntext  :\(text)"
        }
    }
    
    init(url: URL, encoding: String.Encoding? = nil) {
        DispatchQueue.global(qos: .background).async {[weak self] in
            do {
                let string: String
                if let encoding = encoding {
                    string = try String(contentsOf: url, encoding: encoding)
                } else {
                    string = try String(contentsOf: url)
                }
                self?.groups = HKSubtitles.parseSubRip(string) ?? []
            } catch {
                print("| HKPlayer | [Error] failed to load \(url.absoluteString) \(error.localizedDescription)")
            }
        }
    }
    
    /**
     Search for target group for time
     
     - parameter time: target time
     
     - returns: result group or nil
     */
    func search(for time: TimeInterval) -> Group? {
        let result = groups.first(where: { group -> Bool in
            if group.start - delay <= time && group.end - delay >= time {
                return true
            }
            return false
        })
        return result
    }
    
    /**
     Parse str string into Group Array
     
     - parameter payload: target string
     
     - returns: result group
     */
    fileprivate static func parseSubRip(_ payload: String) -> [Group]? {
        var groups: [Group] = []
        let replacStr = payload.replacingOccurrences(of: "\n\n\n", with: "\nMTSPACE\n\n")
        let replacStr2 = replacStr.replacingOccurrences(of: "\r\n\r\n", with: "\n\n")
        let scanner = Scanner(string: replacStr2)
        while !scanner.isAtEnd {
            var indexString: NSString?
            scanner.scanUpToCharacters(from: .newlines, into: &indexString)
            
            var startString: NSString?
            scanner.scanUpTo(" --> ", into: &startString)
            
            // skip spaces and newlines by default.
            scanner.scanString("-->", into: nil)
            
            var endString: NSString?
            scanner.scanUpToCharacters(from: .newlines, into: &endString)
            
            var textString: NSString?
            scanner.scanUpTo("\n\n", into: &textString)
            
            if let text = textString {
                textString = text.trimmingCharacters(in: .whitespaces) as NSString
                textString = text.replacingOccurrences(of: "\r", with: "") as NSString
                textString = text.replacingOccurrences(of: "MTSPACE", with: "") as NSString
            }
            
            if let indexString = indexString,
               let index = Int(indexString as String),
               let start = startString,
               let end   = endString,
               let text  = textString {
                let group = Group(index, start, end, text)
                groups.append(group)
            }
        }
        return groups
    }
}
