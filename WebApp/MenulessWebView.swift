//
//  MenulessWebView.swift
//  SmartNote
//
//  Created by Deger on 2017/5/13.
//  Copyright © 2017年 Luofei. All rights reserved.
//

import Cocoa
import WebKit

class MenulessWebView: WKWebView {
//    override func willOpenMenu(_ menu: NSMenu, with event: NSEvent) {
//        menu.removeAllItems()
//    }
    
    /*
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()
        if let items = pboard.pasteboardItems {
            for item in items {
                for type in item.types {
                    if let value = item.string(forType: type) {
                        NSLog("DnD type(\(type)): \(value)")
                    }
                }
            }
        }
        return true
    }
 */
}
