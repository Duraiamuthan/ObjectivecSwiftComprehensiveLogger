//
//  DeveloperConsole.swift
//  OmniclientSwift
//
//  Created by Durai on 04/02/16.
//  Copyright © 2016 Ericsson Research. All rights reserved.
//

import UIKit
import AudioToolbox
import Foundation

class DeveloperConsole: UIViewController {
    var isContainee:Bool?
    @IBOutlet weak var txtVuConsole: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtVuConsole.text=DeveloperConsoleManager.sharedInstance.getConsoleLog(isContainee!,isOldFileRequired: false)
        txtVuConsole.editable=false
        let caretRect:CGRect=txtVuConsole .caretRectForPosition(txtVuConsole.endOfDocument)
        txtVuConsole .scrollRectToVisible(caretRect, animated: true)
        self.title = "Developer Console Logs"
        let btnClearLog : UIBarButtonItem = UIBarButtonItem(title: "Clear Logs", style: UIBarButtonItemStyle.Plain, target: self, action: "clearLogs:")
        self.navigationItem.rightBarButtonItem = btnClearLog
        
//        let attributedString = NSMutableAttributedString(string:txtVuConsole.text)
//        let strings = txtVuConsole.text .componentsSeparatedByString(" : ")
//        for var i=0;i<strings.count;i=i+1{
//            if i%2 != 0{
//                let range = (txtVuConsole.text as NSString).rangeOfString(strings[i])
//                attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.redColor() , range: range)
//            }
//        }
//        txtVuConsole.attributedText = attributedString
//        print("Strings:\(strings)")
    }
    
    func clearLogs(barbuttonnItem: UIBarButtonItem){
        DeveloperConsoleManager.sharedInstance.clearConsoleLog(isContainee!,canOldFileExist: false)
        txtVuConsole.text=""
    }
}
