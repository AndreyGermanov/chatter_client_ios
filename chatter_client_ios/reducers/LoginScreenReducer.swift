//
//  LoginScreenReducer.swift
//  chatter_client_ios
//
//  Created by user on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import ReSwift

/**
 *  Reducer, used to process Redux actions of Login form.
 *
 * - Parameter action: Action to handle
 * - Parateter state: Input state
 * - Returns State after applying action to it
 */
func loginFormReducer(action:Action,state:LoginFormState) -> LoginFormState {
    var newState = state
    Logger.log(level:LogLevel.DEBUG_REDUX,message:"LoginFormReducer: Received action \(action)",className:"loginFormReducer",methodName:"loginFormReducer")
    switch action {
    case let action as changeLoginAction:
        newState.login = action.login
    case let action as changePasswordAction:
        newState.password = action.password
    case let action as changeLoginFormConfirmPasswordAction:
        newState.confirm_password = action.confirmPassword
    case let action as changeLoginFormModeAction:
        newState.mode = action.mode
        newState.errors = [String:LoginFormError]()
    case let action as changeEmailAction:
        newState.email = action.email
    case let action as changeLoginFormErrorsAction:
        newState.errors = action.errors
    case let action as changeLoginFormShowProgressIndicatorAction:
        newState.show_progress_indicator = action.progressIndicator
    case let action as changeLoginFormPopupMessageAction:
        newState.popup_message = action.popupMessage
    default:
        break
    }
    Logger.log(level:LogLevel.DEBUG_REDUX,message:"LoginFormReducer: LoginFormState after reducing - \(newState)",className:"loginFormReducer",methodName:"loginFormReducer")
    return newState
}
