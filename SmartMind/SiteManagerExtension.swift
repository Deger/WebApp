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
        let start = "http://naotu.baidu.com/home"
        
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
        
        return Site(start: start, js: js, width: 1300, height: 822, pages: pages, minVersion: "0.7.0")
    }
    
    static func siteName() -> String{
        return "百度脑图"
    }
}
