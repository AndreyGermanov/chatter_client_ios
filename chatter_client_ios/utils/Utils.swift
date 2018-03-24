//
//  Utils.swift
//  chatter_client_ios
//
//  Created by user on 24.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation

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
