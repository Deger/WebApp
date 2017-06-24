//
//  AppDelegate.swift
//  SmartNote
//
//  Created by Deger on 2017/5/13.
//  Copyright © 2017年 Luofei. All rights reserved.
//

import Cocoa
import Fabric
import Crashlytics

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    lazy var feedbackController : FeedbackWindowController = FeedbackWindowController(windowNibName: "FeedbackWindowController")
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        UserDefaults.standard.register(defaults: ["NSApplicationCrashOnExceptions" : true])
        Fabric.with([Crashlytics.self, Answers.self])
        
        if let window = NSApplication.shared().mainWindow {
            window.title = SiteManager.siteName()
        }
        
        let key = "kLaunchCount"
        var count = UserDefaults.standard.integer(forKey: key)
        count = count + 1
        UserDefaults.standard.set(count, forKey: key)
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if let window = NSApplication.shared().windows.first {
            window.makeKeyAndOrderFront(self)
        }
        return true
    }
    
    @IBAction func onFeedbackAction(_ sender: Any) {
        self.feedbackController.window?.makeKeyAndOrderFront(self)
    }
}

