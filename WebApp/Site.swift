//
//  Site.swift
//  SmartNote
//
//  Created by Deger on 2017/5/13.
//  Copyright © 2017年 Luofei. All rights reserved.
//

import Foundation

class Site : NSObject, NSCoding {
    let start : String
    let js : String
    let width : Int
    let height : Int
    let pages : [Page]
    let minVersion : String
    
    
    init(start : String, js : String, width : Int, height : Int, pages : [Page], minVersion : String) {
        self.start = start
        self.js = js
        self.width = width
        self.height = height
        self.pages = pages
        self.minVersion = minVersion
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.start, forKey: "start")
        aCoder.encode(self.js, forKey: "js")
        aCoder.encode(self.width, forKey: "width")
        aCoder.encode(self.height, forKey: "height")
        aCoder.encode(self.pages, forKey: "pages")
        aCoder.encode(self.minVersion, forKey: "minVersion")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let start = aDecoder.decodeObject(forKey: "start") as? String,
            let js = aDecoder.decodeObject(forKey: "js") as? String,
            let pages = aDecoder.decodeObject(forKey: "pages") as? [Page],
            let minVersion = aDecoder.decodeObject(forKey: "minVersion") as? String
            else {
                return nil
        }
        
        
        
        let width = aDecoder.decodeInteger(forKey: "width")
        let height = aDecoder.decodeInteger(forKey: "height")
        self.init(start: start, js: js, width: width, height: height, pages: pages, minVersion: minVersion)
    }
}
