//
//  ViewController.swift
//  Logger
//
//  Created by Durai on 24/09/16.
//  Copyright © 2016 Durai Amuthan.H. All rights reserved.
//

import UIKit
import WebKit
import WBWebViewConsole

class ViewController: UIViewController {

    var webView: WBWKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = WBWKWebView(frame: self.view.bounds)
        webView.JSBridge.interfaceName="WKWebViewBridge"
        webView.JSBridge.readyEventName="WKWebViewBridgeReady"
        webView.JSBridge.invokeScheme="wkwebview-bridge://invoke"
        webView.loadRequest(getUrlRequestForLan())
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func getUrlRequestForLan() -> NSURLRequest{
        let url = NSURL(string: "https://www.google.com")!
        let isReachable = NetworkManager.sharedManager().isInternetReachable()
        let urlRequestCache:NSURLRequest!
        if isReachable != 0  {
            urlRequestCache = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 60)
        }else{
            urlRequestCache = NSURLRequest(URL: url, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 60)
        }
        return urlRequestCache
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

