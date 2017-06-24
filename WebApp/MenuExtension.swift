//
//  MenuExtension.swift
//  SmartNote
//
//  Created by Deger on 2017/5/13.
//  Copyright © 2017年 Luofei. All rights reserved.
//

import Cocoa

extension NSMenu
{
    func localized()  {
        for item in self.items {
            item.title = item.title.localized
            if item.hasSubmenu,
                let submenu = item.submenu {
                submenu.localized()
            }
        }
    }
}
