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
    switch action {
    case let action as changeLoginAction:
        newState.login = action.login
    case let action as changePasswordAction:
        newState.password = action.password
    case let action as changeLoginFormConfirmPasswordAction:
        newState.confirm_password = action.confirmPassword
    case let action as changeLoginFormModeAction:
        newState.mode = action.mode
    case let action as changeEmailAction:
        newState.email = action.email
    case let action as changeLoginFormErrorsAction:
        newState.errors = action.errors
    case let action as changeLoginFormShowProgressIndicatorAction:
        newState.show_progress_indicator = action.progressIndicator
    default:
        break
    }
    return newState
}
