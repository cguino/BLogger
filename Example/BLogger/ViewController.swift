//
//  ViewController.swift
//  BLogger
//
//  Created by Guinoiseau Cédric on 12/14/2016.
//  Copyright (c) 2016 Guinoiseau Cédric. All rights reserved.
//

import UIKit
import BLogger
import CocoaLumberjack

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
/*
 Override print to use BLogger.
 */
func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    //Swift.print(items[0], separator:separator, terminator: terminator)
    for item in items {
        let object = item as AnyObject
        BLogVerbose(object.description ?? "")
    }
}
/*
 Override NSLog to use BLogger.
 */
public func NSLog(_ format: String, _ args: CVarArg...) {
    let str = NSString(format: format as NSString, args) as String
    BLogVerbose(str)
}

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("[PRINT] This is a print")
        NSLog("This is a nslog")
        BLogError("This is an error")
        BLogWarn("This is a warning")
        BLogInfo("This is an info")
        BLogVerbose("This is a vervose")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            BLogger.writeEmailFromRoot(sender: self)
        }
    }
    
}

