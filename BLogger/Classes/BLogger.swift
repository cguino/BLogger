//
//  BLogger.swift
//  Pods
//
//  Created by BeApp on 14/12/2016.
//
//

import Foundation
import CocoaLumberjack
import MessageUI


//public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
//    //Swift.print(items[0], separator:separator, terminator: terminator)
//    for item in items {
//        if let object = item as? AnyObject {
//            BLogVerbose(object.description ?? "")
//        }
//    }
//}

public func BLogError(_ log: String) {
    DDLogError(log)
}

public func BLogWarn(_ log: String) {
    DDLogWarn(log)
}

public func BLogInfo(_ log: String) {
    DDLogInfo(log)
}

public func BLogVerbose(_ log: String) {
    DDLogVerbose(log)
}


public class BLogger: NSObject {
    
    static public var colorEnable: Bool {
        get {
            return DDTTYLogger.sharedInstance().colorsEnabled
        }
        set {
            DDTTYLogger.sharedInstance().colorsEnabled = newValue
        }
    }
    
    static public func startLogger() {
        DDLog.add(DDTTYLogger.sharedInstance()) // TTY = Xcode console
        DDLog.add(DDASLLogger.sharedInstance()) // ASL = Apple System Logs
        
        BLogger.colorEnable = true
        
        if let path = getLogPath(), let document = DDLogFileManagerDefault(logsDirectory: path) {
            let fileLogger = DDFileLogger(logFileManager: document)
            fileLogger?.rollingFrequency = TimeInterval(60*60*24)  // 24 hours
            fileLogger?.logFileManager.maximumNumberOfLogFiles = 7
            DDLog.add(fileLogger)
            BLogger.logger.ddFileLogger = fileLogger
        }
    }
    
    static public func writeEmailFromRoot(sender: UIViewController) {
        if MFMailComposeViewController.canSendMail() {
            let composeVC = MFMailComposeViewController()
            composeVC.mailComposeDelegate = BLogger.logger
            //composeVC.setToRecipients(["your-email@company.com"])
            composeVC.setSubject("Beapp feedback for app")
            composeVC.setMessageBody("", isHTML: false)
            
            let attachmentData = NSMutableData()
            for logFileData in BLogger.logger.logFileDataArray {
                attachmentData.append(logFileData)
            }
            composeVC.addAttachmentData(attachmentData as Data, mimeType: "text/plain", fileName: "diagnostic.log")
            sender.present(composeVC, animated: true, completion: nil)
        }
    }
    
    //MARK: - private
    /* singleton */
    static let logger = BLogger()
    
    /* logger */
    var ddFileLogger: DDFileLogger!
    
    //MARK: - private
    
    private var logFileDataArray: [Data] {
        get {
            let logFilePaths = ddFileLogger.logFileManager.sortedLogFilePaths as! [String]
            var logFileDataArray = [Data]()
            for logFilePath in logFilePaths {
                let fileURL = URL(fileURLWithPath: logFilePath)
                if let logFileData = try? Data(contentsOf: fileURL, options: Data.ReadingOptions.mappedIfSafe) {
                    // Insert at front to reverse the order, so that oldest logs appear first.
                    logFileDataArray.insert(logFileData, at: 0)
                }
            }
            return logFileDataArray
        }
    }
    
    static private func getLogPath() -> String? {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path
    }
    
}


extension BLogger: MFMailComposeViewControllerDelegate {
    /*!
     @method     messageComposeViewController:didFinishWithResult:
     @abstract   Delegate callback which is called upon user's completion of message composition.
     @discussion This delegate callback will be called when the user completes the message composition.
     How the user chose to complete this task will be given as one of the parameters to the
     callback.  Upon this call, the client should remove the view associated with the controller,
     typically by dismissing modally.
     @param      controller   The MFMessageComposeViewController instance which is returning the result.
     @param      result       MessageComposeResult indicating how the user chose to complete the composition process.
     */
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
