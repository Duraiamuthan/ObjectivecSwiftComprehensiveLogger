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
        view = webView
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.consoleDidAddMessage(_:)), name: WBWebViewConsoleDidAddMessageNotification, object: nil)
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
    
    func consoleDidAddMessage(message:NSNotification){
        let console =  message.object as! WBWebViewConsole
        let consoleMessage:WBWebViewConsoleMessage = console.messages[console.messages.count-1] as! WBWebViewConsoleMessage
                var currentLogLevel:Loglevel!
                switch consoleMessage.level.rawValue {
                case 2:
                    currentLogLevel = Loglevel.WARN
                case 3:
                    currentLogLevel = Loglevel.ERROR
                case 4:
                    currentLogLevel = Loglevel.DEBUG
                case 5:
                    currentLogLevel = Loglevel.INFO
                default:
                    currentLogLevel = Loglevel.VEERBOSE
                }
        
                let  acceptedLoglevel = NSUserDefaults.standardUserDefaults().valueForKey("AcceptedLoglevel") as? Loglevel.RawValue
                if acceptedLoglevel != Loglevel.NONE.rawValue {
                    if acceptedLoglevel  <= currentLogLevel.rawValue {
        var loggerString:String=getCurrentDateTimeStamp()
        loggerString=loggerString+" : "+consoleMessage.message+" \n"
        DeveloperConsoleManager.sharedInstance.writeOnConsoleLog(loggerString,isContainee: true)
                        print("Console message:\(consoleMessage.message)")
                    }
                }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

