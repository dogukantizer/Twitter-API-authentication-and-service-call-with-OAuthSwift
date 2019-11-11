//
//  WebViewController.swift
//  TwitterApi
//
//  Created by Dogukan Tizer on 01.10.19.
//  Copyright © 2019 Dogukan Tizer. All rights reserved.
//

import OAuthSwift

#if os(iOS)
    import UIKit
    typealias WebView = UIWebView // WKWebView
#elseif os(OSX)
    import AppKit
    import WebKit
    typealias WebView = WKWebView
#endif

class WebViewController: OAuthWebViewController {

    var targetURL: URL?
    let webView: WebView = WebView()
    var viewController: MainViewController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.frame = UIScreen.main.bounds
        self.webView.scalesPageToFit = true
        self.webView.delegate = self
        self.view.addSubview(self.webView)
        loadAddressURL()
        
    }

    override func handle(_ url: URL) {
        targetURL = url
        super.handle(url)
        self.loadAddressURL()
    }

    func loadAddressURL() {
        guard let url = targetURL else {
            return
        }
        let req = URLRequest(url: url)
        DispatchQueue.main.async {
            self.webView.loadRequest(req)
        }
    }
}

extension WebViewController: UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if let url = request.url,
            url.absoluteString.hasPrefix(Constants.callback)  {
                
            OAuthSwift.handle(url: url)
            self.dismissWebViewController()
                
        }
        return true
    }
}
