//
//  SiteManagerExtension.swift
//  SmartNote
//
//  Created by Deger on 2017/5/13.
//  Copyright © 2017年 Futu. All rights reserved.
//

import Foundation

extension SiteManager {
    static func defaultSite() -> Site {
        let start = "https://cloud.smartisan.com/#/contacts"
        
        //        let js: String = "window.webkit.messageHandlers.callbackHandler.postMessage('Hello from JavaScript');"
        let js = "function removeFirstElementByClassName(n) { " +
            "var element =  document.getElementsByClassName(n)[0]; " +
            "if (element) {element.parentNode.removeChild(element); } }" +
            //隐藏左侧导航
            "removeFirstElementByClassName('side-nav');" +
            "removeFirstElementByClassName('side-nav-mask');" +
            "removeFirstElementByClassName('main-menu');" +
            
            //隐藏载入中
            "removeFirstElementByClassName('main-loading');" +
            
            //隐藏广告按钮
            "removeFirstElementByClassName('ad');" +
            
            //隐藏图片插入
            "removeFirstElementByClassName('a-insert-image-button');" +
            
            //隐藏分享按钮
            "removeFirstElementByClassName('share-func-group');" +
            
            
            //隐藏dashboard
            "if (window == window.top) {" +
            "element = document.getElementsByClassName('header')[0];" +
            "if (element) {" +
            "element.parentNode.style.visibility='hidden';" +
            "}" +
        "}"
        var pages : [Page] = []
        
        pages.append(Page(regex: "https://account.smartisan.com/#/v2/login*", width: 350, height: 450)) //login
        pages.append(Page(regex: "https://account.smartisan.com/#/settings/embed*",  width: 1300, height: 822)) //dashboard
        pages.append(Page(regex: "https://api.weibo.com/*", width: 700, height: 450)) //weibo
        pages.append(Page(regex: "https://graph.qq.com/*",  width: 700, height: 450)) //qq
        pages.append(Page(regex: "https://account.smartisan.com/#/result/illegality*", invalid : true)) //微博取消
        pages.append(Page(regex: "https://account.smartisan.com/#/bindAccount*", width: 350, height: 450)) //账号绑定
        
        return Site(start: start, js: js, width: 1300, height: 822, pages: pages, minVersion: "0.7.0")
    }
    
    static func siteName() -> String{
        return "锤子联系人"
    }
}
