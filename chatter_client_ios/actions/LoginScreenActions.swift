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

/**
 * Action to change "Login" field
 */

protocol LoginFormAction : Action {
    
}

struct changeLoginAction: LoginFormAction {
    /// New login field value
    let login: String
}

/**
 * Action to change "Email" field
 */
struct changeEmailAction: LoginFormAction {
    let email: String
}

/**
 * Action to change "Password" field
 */
struct changePasswordAction: LoginFormAction {
    let password: String
}

/**
 * Action to change "Confirm Password" field
 */
struct changeLoginFormConfirmPasswordAction: LoginFormAction {
    let confirmPassword: String
}

/**
 * Action to change mode of login form
 */
struct changeLoginFormModeAction: LoginFormAction {
    let mode: LoginFormMode
}

/**
 * Action to change mode of login form
 */
struct changeLoginFormShowProgressIndicatorAction: LoginFormAction {
    let progressIndicator: Bool
}

/**
 * Action to change errors array
 */
struct changeLoginFormErrorsAction: LoginFormAction {
    let errors:[String:LoginFormError]
}

enum LoginFormError: String {
    case RESULT_ERROR_CONNECTION_ERROR = "RESULT_ERROR_CONNECTION_ERROR"
    case RESULT_ERROR_PASSWORDS_SHOULD_MATCH = "RESULT_ERROR_PASSWORDS_SHOULD_MATCH"
}
