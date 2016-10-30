//
//  AppDelegate.swift
//  Logger
//
//  Created by Durai on 24/09/16.
//  Copyright © 2016 Durai Amuthan.H. All rights reserved.
//

import UIKit

//Adding global constants and global methods

let containeeLogFileName = "JSLogs.txt"
let containeeOldLogFileName = "OldJSLogs.txt"
let containerLogFileName = "nativeLogs.txt"
let containerOldLogFileName = "OldnativeLogs.txt"
let crashLogFileName="CrashLog.txt"
let SEPARATOR = "*^'`@#$`'^*"

public enum Loglevel:Int {
    case NONE = 0
    case VEERBOSE = 2
    case DEBUG = 3
    case INFO = 4
    case WARN = 5
    case ERROR = 6
}

public func writeLog(logs:AnyObject!...) {
    assert(logs.count>1,"Here is the sample syntax for writing log: writeLog(Loglevel.DEBUG.rawValue,obj)")
    let  acceptedLoglevel = NSUserDefaults.standardUserDefaults().valueForKey("AcceptedLoglevel") as? Loglevel.RawValue
    if acceptedLoglevel != Loglevel.NONE.rawValue {
        let currentLogLevel = logs[0] as! Loglevel.RawValue
        assert(currentLogLevel >= Loglevel.VEERBOSE.rawValue && currentLogLevel <= Loglevel.ERROR.rawValue,"Here is the sample syntax for writing log: writeLog(Loglevel.DEBUG.rawValue,obj)")
        var loggerString:String=getCurrentDateTimeStamp()
        for i:Int in 1 ..< logs.count {
            if let logg = logs[i] as AnyObject! {
                loggerString=loggerString+" : "+logg.description+" \n"
            }
        }
        if acceptedLoglevel  <= currentLogLevel {
            DeveloperConsoleManager.sharedInstance.writeOnConsoleLog(loggerString,isContainee: false)
        }
    }
}

func getCurrentDateTimeStamp() -> String {
    let todaysDate:NSDate = NSDate()
    let dateFormatter:NSDateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
    return dateFormatter.stringFromDate(todaysDate)
}

func setLogLevel(type:Loglevel){
    NSUserDefaults.standardUserDefaults().setValue(type.rawValue, forKey: "AcceptedLoglevel")
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        setLogLevel(Loglevel.VEERBOSE)
        
        let crashReporter: PLCrashReporter = PLCrashReporter.sharedReporter()
        if crashReporter.hasPendingCrashReport() {
            self.handleCrashReport()
        }
        
        do{
            try crashReporter.enableCrashReporterAndReturnError()
        }
        catch{
            writeLog(Loglevel.DEBUG.rawValue,"Could not enable crash reporter")
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func handleCrashReport() {
        let crashReporter: PLCrashReporter = PLCrashReporter.sharedReporter()
        let crashData: NSData!
        do {
            let crashData = try crashReporter.loadPendingCrashReportDataAndReturnError()
            let report = try PLCrashReport(data: crashData)
            let crashDump = PLCrashReportTextFormatter.stringValueForCrashReport(report, withTextFormat: PLCrashReportTextFormatiOS)
            
            DeveloperConsoleManager.sharedInstance.addCrashLog(crashDump)
            
            crashReporter.purgePendingCrashReport()
        }catch{
            writeLog(Loglevel.ERROR.rawValue,"Could not load crash report")
        }
        return
    }
}

