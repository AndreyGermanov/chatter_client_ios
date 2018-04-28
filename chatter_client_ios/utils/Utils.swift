//
//  Utils.swift
//  chatter_client_ios
//
//  Created by user on 24.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import UIKit

/**
 * Extension to string, used to validate email addresses
 */
extension String {
    /// calculated variable which is true if current string instance is email address and false otherwise
    var isEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,20}"
        let emailTest  = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}

/**
 * Function used to construct and return simple Alert dialog with text message
 *
 * - Parameter message: Text message to display in dialog
 * - Returns: constructed UIAlertController to display Alert box
 */
func showAlert(_ message:String) -> UIAlertController {
    let dialog = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
    dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    return dialog
}

/**
 * Parses integer field from Any and returns either integer or nil
 *
 * - Parameter obj: Object to parse
 * - Returns: Int value or nil
 */
func parseAnyToInt(_ obj:Any?) -> Int? {
    if let obj = obj {
        if obj is String {
            if let result = Int(obj as! String) {
                return result
            }
        }
        if obj is NSNumber {
            return Int(truncating:obj as! NSNumber)
        }
        Logger.log(level:LogLevel.WARNING,message:"Could not convert \(obj) to Int",className:"",methodName:"parseAnyToInt")
    }
    return nil
}

/**
 * Extension to String class which converts String to Bool
 */
extension String {
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
}
