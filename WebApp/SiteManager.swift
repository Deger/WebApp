//
//  SiteManager.swift
//  SmartNote
//
//  Created by Deger on 2017/5/13.
//  Copyright © 2017年 Luofei. All rights reserved.
//

import Foundation
import CloudKit

class SiteManager : NSObject {
    var site : Site
    
    override init() {
        if let site = NSKeyedUnarchiver.unarchiveObject(withFile:SiteManager.sitePath()) as? Site, site.pages.count > 0 {
            self.site = site
        } else {
            self.site = SiteManager.defaultSite()
        }
        super.init()
    }
    
    func downloadSite(completionHandler: @escaping (Site?) -> Void) -> Void {
        let publicDB = CKContainer.default().publicCloudDatabase
        
        let query = CKQuery(recordType: "Page", predicate: NSPredicate(value: true))
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let records = records, records.count > 0 {
                var pages : [Page] = []
                for record in records {
                    let page = Page(regex: record["regex"] as! String,
                                    js: record["js"] as! String?,
                                    width: record["width"] as! Int,
                                    height: record["height"] as! Int,
                                    invalid: record["invalid"] as! Bool)
                    pages.append(page)
                }
                let defaultID = CKRecordID(recordName: "DefaultSite")
                publicDB.fetch(withRecordID: defaultID) { (siteRecord, error) in
//                    print(siteRecord ?? "", error ?? "")
                    if let siteRecord = siteRecord {
                        let site = Site(start: siteRecord["start"] as! String,
                                        js: siteRecord["js"] as! String,
                                        width: siteRecord["width"] as! Int,
                                        height: siteRecord["height"]  as! Int,
                                        pages: pages,
                                        minVersion: siteRecord["minVersion"]  as! String)
                        self.site = site
                        completionHandler(site)
                        self.saveSite(site)
                    } else {
                        completionHandler(nil)
                    }
                }
            } else {
                completionHandler(nil)
            }
        }
    }
    
    
    func saveSite(_ site : Site) {
        NSKeyedArchiver.archiveRootObject(site, toFile: SiteManager.sitePath())
    }

    
    func uploadDefaultSite() {
        let site = SiteManager.defaultSite()
        let publicDB = CKContainer.default().publicCloudDatabase
        let defaultID = CKRecordID(recordName: "DefaultSite")
        //Delete the old one
        publicDB.delete(withRecordID: defaultID) { (record, error) in
            let siteRecord = CKRecord(recordType: "Site", recordID: defaultID)
            siteRecord.setValue(site.start, forKey: "start")
            siteRecord.setValue(site.js, forKey: "js")
            siteRecord.setValue(site.width, forKey: "width")
            siteRecord.setValue(site.height, forKey: "height")
            siteRecord.setValue(site.minVersion, forKey: "minVersion")
            let siteReference = CKReference(record: siteRecord, action: .deleteSelf)
            //Save the new one
            publicDB.save(siteRecord, completionHandler: { (record, error) in
                print(record ?? "", error ?? "")
                //Save the pages
                for page in site.pages {
                    let pageRecord = CKRecord(recordType: "Page")
                    pageRecord["regex"] = page.regex as NSString
                    pageRecord.setValue(page.js, forKey: "js")
                    pageRecord.setValue(page.width, forKey: "width")
                    pageRecord.setValue(page.height, forKey: "height")
                    pageRecord.setValue(page.invalid, forKey: "invalid")
                    pageRecord.setObject(siteReference, forKey: "site")
                    publicDB.save(pageRecord, completionHandler: { (record, error) in
                        print(record ?? "", error ?? "")
                    })
                }
            })
        }
    }
    
    
    static private func sitePath() -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        return documentsPath + "/site.db"
    }

    
    
}
