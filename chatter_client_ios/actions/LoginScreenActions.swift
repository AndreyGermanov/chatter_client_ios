//
//  LoginScreenActions.swift
//  chatter_client_ios
//
//  Actions for Login Screen reducer
//
//  Created by user on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import ReSwift

/*
 * Action to change "Login" field
 */
struct changeLoginAction: Action {
    /// New login field value
    let login: String
}
