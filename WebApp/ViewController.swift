//
//  ViewController.swift
//  SmartNote
//
//  Created by Deger on 2017/5/13.
//  Copyright © 2017年 Luofei. All rights reserved.
//

import Cocoa
import WebKit
import ReachabilitySwift

class ViewController: NSViewController, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler  {

    var webView: WKWebView!
    var coverView : NSVisualEffectView!
    let siteManager = SiteManager()
    var site : Site
    var reachability : Reachability!
    
    override init?(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.site = self.siteManager.site
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        self.site = self.siteManager.site
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkAppVersion()
        
        var frame = self.view.frame
        frame.size.width = CGFloat(site.width)
        frame.size.height = CGFloat(site.height)
        self.view.frame = frame
        
        self.siteManager.downloadSite { [weak self] site in
            if let weakSelf = self {
                weakSelf.site = weakSelf.siteManager.site
                weakSelf.checkAppVersion()
            }
        }
        
        //提交默认数据
        //com.apple.developer.icloud-container-environment Production
//        self.siteManager.uploadDefaultSite()
        
        
        self.setupWebView()
        self.setupCoverView()
        self.setupReachability()
    }
    
    func backToStartPage() {
        let request = URLRequest(url: URL(string: self.site.start)!)
        webView.load(request)
    }
    
    func checkAppVersion() {
        if let dic = Bundle.main.infoDictionary,
            let version = dic["CFBundleShortVersionString"] as? String {
            if version.compare(self.site.minVersion) == ComparisonResult.orderedAscending {
                //强制升级
                let alert = NSAlert()
                alert.informativeText = "您的版本已经太旧，请到App Store更新版本"
                alert.messageText = "更新提示"
                alert.runModal()
                NSApp.terminate(self)
            }
        }
    }

    func setupWebView() {
        
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        
        let userScript = WKUserScript(source: site.js, injectionTime: WKUserScriptInjectionTime.atDocumentEnd, forMainFrameOnly: false)
        contentController.removeAllUserScripts()
        contentController.addUserScript(userScript)
        contentController.add(self, name: "callbackHandler" )
        
        webConfiguration.userContentController = contentController
        
        webView = MenulessWebView(frame: self.view.bounds, configuration: webConfiguration)
        webView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        self.view.addSubview(webView)
        self.backToStartPage()
        //Enable Developer Tool
                self.webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        

    }
    
    func setupCoverView() {
        coverView = NSVisualEffectView(frame: self.view.bounds)
        coverView.autoresizingMask = [.viewWidthSizable, .viewHeightSizable]
        coverView.isHidden = true
        let titleLabel = NSTextField(frame: NSRect(x: 0, y: self.view.bounds.size.height / 2, width: self.view.bounds.size.width, height: 50))
        titleLabel.isBezeled = false
        titleLabel.isEditable = false
        titleLabel.drawsBackground = false
        titleLabel.isSelectable = false
        titleLabel.stringValue = "无法连接服务器"
        titleLabel.font = NSFont.systemFont(ofSize: 30)
        titleLabel.alignment = .center
        titleLabel.autoresizingMask = [.viewWidthSizable, .viewMinYMargin, .viewMaxYMargin]
        coverView.addSubview(titleLabel)
        self.view.addSubview(coverView)
    }
    
    func setupReachability() {
        if let url = URL(string: self.site.start),
            let host = url.host {
            reachability = Reachability(hostname: host)
            reachability.whenReachable = { reachability in
                DispatchQueue.main.async { [weak self] in
                    if let weakSelf = self {
                        weakSelf.coverView.isHidden = true
                        weakSelf.webView.isHidden = false
                        weakSelf.backToStartPage()
                    }
                }
            }
            reachability.whenUnreachable = { reachability in
                DispatchQueue.main.async { [weak self] in
                    if let weakSelf = self {
                        weakSelf.coverView.isHidden = false
                        weakSelf.webView.isHidden = true
                    }
                }
            }
            
            do {
                try reachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        }
    }
    
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "callbackHandler") {
            print("JavaScript is sending a message \(message.body)")
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow);
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let inNewWindow = navigationAction.targetFrame == nil
        if let url = navigationAction.request.url {
            if inNewWindow {
                NSWorkspace.shared().open(url)
                decisionHandler(.cancel)
                return
            } else {
                let isMainFrame = navigationAction.targetFrame!.isMainFrame
                print("will", url, isMainFrame)
                if let page = webPage(url.absoluteString) {
                    if page.invalid {
                        decisionHandler(.cancel)
                        self.backToStartPage()
                        return
                    } else {
                        updateFrame(page)
                    }
                }
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation", error)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFailnavigation", error)
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        print("runJavaScriptAlertPanelWithMessage", message)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        print("runJavaScriptConfirmPanelWithMessage", message)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        print("runJavaScriptTextInputPanelWithPrompt", prompt)
    }
    

    @available(OSX 10.10, *)
    func webView(_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]?) -> Void) {
        if let window = self.view.window {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = parameters.allowsMultipleSelection
            panel.canChooseDirectories = false
            panel.allowedFileTypes = ["tif", "tiff", "jpg", "jpeg", "gif", "png"]
            panel.prompt = "请选择需要插入的图片".localized
            panel.beginSheet(window) { (response) in
                completionHandler(panel.urls)
            }
        }
    }
    
    func updateFrame(_ page : Page) {
        guard page.width > 0 && page.height > 0 else {
            return
        }
        if let window = self.view.window {
            var frame = window.frame;
            if Int(frame.size.width) == page.width && Int(frame.size.height) == page.height {
                return
            }
            
            frame.size.width = CGFloat(page.width)
            frame.size.height = CGFloat(page.height)
            if let screen = window.screen {
                frame.origin.x = (screen.frame.width - frame.width) / 2 + screen.frame.origin.x
                frame.origin.y = (screen.frame.height - frame.height) / 2 + screen.frame.origin.y
            }
            window.setFrame(frame, display: true)
            window.minSize = frame.size
        }
    }
    
    func webPage(_ url : String) -> Page? {
        for page in site.pages {
            if url.matchingStrings(regex: page.regex).count > 0 {
                return page
            }
        }
        return nil
    }
    
    @IBAction func onLogoutAction(_ sender: Any) {
        let storage = HTTPCookieStorage.shared
        if let cookies = storage.cookies {
            for cookie in cookies {
                storage.deleteCookie(cookie)
            }
        }
        
        
        if #available(OSX 10.11, *) {
            let store = WKWebsiteDataStore.default()
            store.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: Date.init(timeIntervalSince1970: 0), completionHandler: { 
                
            })
        } else {
            // Fallback on earlier versions
        }
        
        
        self.backToStartPage()
    }
    
    @IBAction func onCreateNoteAction(_ sender: Any) {
        let js = "var iframe = document.getElementById('cloud_app_notes').contentWindow;\n" +
        "var iframeScope = iframe.angular.element('#macos').scope();\n" +
        "iframeScope.newNote();\n" +
        "$scope.$apply(function(){ });\n"
        self.webView.evaluateJavaScript(js) { (result, error) in
            print(result ?? "", error ?? "")
        }
    }
}
