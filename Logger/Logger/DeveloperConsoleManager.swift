//
//  DeveloperConsoleManager.swift
//  OmniclientSwift
//
//  Created by Durai on 05/02/16.
//  Copyright © 2016 Ericsson Research. All rights reserved.
//
//Usage:
//Objective c we can use nslog as usual it gets recorded here
//Swift ... define the function like below inside the class and use it
//func print(s:String) {
//    DeveloperConsoleManager.sharedInstance.writeOnConsoleLog(s)
//}

import Foundation
import MessageUI

class DeveloperConsoleManager :NSObject
{
    let documentsPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
    
    class var sharedInstance : DeveloperConsoleManager {
        struct Singleton {
            static let instance = DeveloperConsoleManager()
        }
        return Singleton.instance
    }
    
    func writeOnConsoleLog(var Log:String,let isContainee:Bool) {
        print(Log)
        let fileName:String  = isContainee ? containeeLogFileName:containerLogFileName
        let consolePath=documentsPath+"/"+fileName
        if let outputStream = NSOutputStream(toFileAtPath: consolePath, append: true) {
            outputStream.open()
            outputStream.write(Log, maxLength: Log.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
            outputStream.close()
        }
        ManageConsoleLog(isContainee)
    }
    
    func ManageConsoleLog(let isContainee:Bool){
        let fileName:String  = isContainee ? containeeLogFileName:containerLogFileName
        let oldFileName:String = isContainee ? containeeOldLogFileName:containerOldLogFileName
        let consolePath=documentsPath+"/"+fileName
        //print(consolePath)
        do {
            let fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(consolePath)
            let filesize = fileAttributes[NSFileSize]
            if filesize?.intValue >= 1048576{// 1mb 1048576
                let newConsolePath=documentsPath+"/"+oldFileName
                let text = try String(contentsOfFile: consolePath)
                if let outputStream =  NSOutputStream(toFileAtPath: newConsolePath, append: false){
                    outputStream.open()
                    outputStream.write(text, maxLength: text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
                    outputStream.close()
                }
                clearConsoleLog(isContainee,canOldFileExist: true)
            }
        }catch{
         print("couldn't get hold of OmniLogs")
        }
    }
    
    //As varags is not supported in Objective c we have created a separate function like this
    func writeObcLog(log:String) {
        let logg = log.trim()
        let  acceptedLoglevel = NSUserDefaults.standardUserDefaults().valueForKey("AcceptedLoglevel") as? Loglevel.RawValue
        if acceptedLoglevel != Loglevel.NONE.rawValue {
                var loggerString:String=getCurrentDateTimeStamp()
            loggerString=loggerString+" : "+logg+" \n"
                writeOnConsoleLog(loggerString,isContainee: false)
            }
    }
    
    
    func getConsoleLog(let isContainee:Bool,let isOldFileRequired:Bool)->String?{
        let fileName:String  = isContainee ? containeeLogFileName:containerLogFileName
        let oldFileName:String = isContainee ? containeeOldLogFileName:containerOldLogFileName
        let newconsoleLog:String=getContentsOfFile(fileName)
        var Log:String?
        if isOldFileRequired {
            let oldLogs = getContentsOfFile(oldFileName)
            if oldLogs != "No Logs found" && oldLogs != "Error reading console logs"{
                Log = oldLogs+"\n"+newconsoleLog
            }else{
                Log = newconsoleLog
            }
        }else{
            Log = newconsoleLog
        }
        
        return Log
    }
    
    func getContentsOfFile(let fileName:String)->String{
        var content:String?
        let filePath=documentsPath+"/"+fileName
        let checkValidation = NSFileManager.defaultManager()
        if (checkValidation.fileExistsAtPath(filePath)){
            do{
                let text = try String(contentsOfFile: filePath)
                content = text
            }
            catch{
                content="Error reading console logs"
            }
        }else{
            content="No Logs found"
        }
        return content!
    }
    
    
    func clearConsoleLog(let isContainee:Bool,let canOldFileExist:Bool){
        let fileName:String  = isContainee ? containeeLogFileName:containerLogFileName
        let oldfileName:String = isContainee ? containeeOldLogFileName:containerOldLogFileName
        let consolePath=documentsPath+"/"+fileName
        let consoleOldPath=documentsPath+"/"+oldfileName
        clear(consolePath)
        if !canOldFileExist{
            clear(consoleOldPath)
        }
    }
    
    func clear(filePath:String){
        let Log=""
        if let outputStream = NSOutputStream(toFileAtPath: filePath, append: false) {
            outputStream.open()
            outputStream.write(Log, maxLength: Log.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
            outputStream.close()
        }
    }
    
    
    func addCrashLog(let crashLog:String){
        let crashLogPath=documentsPath+"/"+crashLogFileName
        if !NSFileManager.defaultManager().fileExistsAtPath(crashLogPath){
            NSFileManager.defaultManager().createFileAtPath(crashLogPath, contents: nil, attributes: nil)
        }
        if let outputStream = NSOutputStream(toFileAtPath: crashLogPath, append: false) {
            outputStream.open()
            outputStream.write(crashLog, maxLength: crashLog.lengthOfBytesUsingEncoding(NSUTF8StringEncoding))
            outputStream.close()
        }
    }
  }

extension String
{
    func trim() -> String
    {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}