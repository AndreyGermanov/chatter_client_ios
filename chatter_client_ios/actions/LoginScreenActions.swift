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

/// Base protocol for login form actions
protocol LoginFormAction : Action {}

/**
 * Action to change "Login" field
 */
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

/// Login form error definitions
enum LoginFormError:String {
    case RESULT_ERROR_FIELD_IS_EMPTY = "RESULT_ERROR_FIELD_IS_EMPTY"
    case RESULT_ERROR_INCORRECT_EMAIL = "RESULT_ERROR_INCORRECT_EMAIL"
    case RESULT_ERROR_INCORRECT_LOGIN = "RESULT_ERROR_INCORRECT_LOGIN"
    case RESULT_ERROR_INCORRECT_PASSWORD = "RESULT_ERROR_INCORRECT_PASSWORD"
    case RESULT_ERROR_EMAIL_EXISTS = "RESULT_ERROR_EMAIL_EXISTS"
    case RESULT_ERROR_LOGIN_EXISTS = "RESULT_ERROR_LOGIN_EXISTS"
    case RESULT_ERROR_ACTIVATION_EMAIL = "RESULT_ERROR_ACTIVATION_EMAIL"
    case RESULT_ERROR_NOT_ACTIVATED = "RESULT_ERROR_NOT_ACTIVATED"
    case RESULT_ERROR_ALREADY_LOGIN = "RESULT_ERROR_ALREADY_LOGIN"
    case RESULT_ERROR_CONNECTION_ERROR = "RESULT_ERROR_CONNECTION_ERROR"
    case RESULT_ERROR_PASSWORDS_SHOULD_MATCH = "RESULT_ERROR_PASSWORDS_SHOULD_MATCH"
    case RESULT_ERROR_UNKNOWN = "RESULT_ERROR_UNKNOWN"
}
extension LoginFormError: RawRepresentable {
    typealias  RawValue = String
    /// Extension function used to get text representation of each error
    func getMessage() -> String {
        switch self {
        case .RESULT_ERROR_CONNECTION_ERROR: return "Connection error."
        case .RESULT_ERROR_PASSWORDS_SHOULD_MATCH: return "Passwords should match."
        case .RESULT_ERROR_FIELD_IS_EMPTY: return "Value of this field is required."
        case .RESULT_ERROR_INCORRECT_EMAIL: return "Incorrect email format."
        case .RESULT_ERROR_INCORRECT_LOGIN: return "Incorrect login."
        case .RESULT_ERROR_INCORRECT_PASSWORD: return "Incorrect password."
        case .RESULT_ERROR_EMAIL_EXISTS: return "User with provided email already exists."
        case .RESULT_ERROR_LOGIN_EXISTS: return "User with provided login already exists."
        case .RESULT_ERROR_ACTIVATION_EMAIL: return "Failed to send activation email. Please contact support."
        case .RESULT_ERROR_NOT_ACTIVATED: return "Please, activate this account. Open activation email."
        case .RESULT_ERROR_ALREADY_LOGIN: return "User already in the system."
        case .RESULT_ERROR_UNKNOWN: return "Unknown error. Please, contact support."
        }
    }
}
