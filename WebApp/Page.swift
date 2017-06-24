//
//  Page.swift
//  SmartNote
//
//  Created by Deger on 2017/5/13.
//  Copyright © 2017年 Luofei. All rights reserved.
//

import Foundation

class Page : NSObject, NSCoding {
    let regex : String
    let js : String?
    let width : Int
    let height : Int
    let invalid : Bool
    
    init(regex : String, js : String? = nil, width : Int = 0, height : Int = 0, invalid : Bool = false) {
        self.regex = regex
        self.js = js
        self.width = width
        self.height = height
        self.invalid = invalid
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.regex, forKey: "regex")
        aCoder.encode(self.js, forKey: "js")
        aCoder.encode(self.width, forKey: "width")
        aCoder.encode(self.height, forKey: "height")
        aCoder.encode(self.invalid, forKey: "invalid")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let regex = aDecoder.decodeObject(forKey: "regex") as? String,
            let js = aDecoder.decodeObject(forKey: "js") as? String? else {
            return nil
        }
        
        let width = aDecoder.decodeInteger(forKey: "width")
        let height = aDecoder.decodeInteger(forKey: "height")
        let invalid = aDecoder.decodeBool(forKey: "invalid")
        self.init(regex: regex, js: js, width: width, height: height, invalid: invalid)
    }
}
