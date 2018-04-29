//
//  RootReducer.swift
//  chatter_client_ios
//
//  Created by user on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import ReSwift

/**
 *  Root reducer, used to process Redux actions. It is a hub
 *  for actions from all detail reducers
 *
 * - Parameter action: Action to handle
 * - Parateter state: Input state
 * - Returns State after applying action to it
 */
func rootReducer(action: Action, state: AppState?) -> AppState {
    var newState = state ?? AppState()
    Logger.log(level: LogLevel.DEBUG_REDUX, message: "RootReducer: Received action \(action)", className: "rootReducer", methodName: "rootReducer")
    switch action {
    case let action as AppState.ChangeActivityAction:
        newState.current_activity = action.activity
    case let action as LoginFormAction:
        newState.loginForm = loginFormReducer(action: action, state: newState.loginForm)
    case let action as UserAction:
        newState.user = userReducer(action: action, state: newState.user)
    case let action as UserProfileAction:
        newState.userProfile = userProfileReducer(action: action, state: newState.userProfile)
    case let action as ChatAction:
        newState.chat = chatScreenReducer(action: action, state: newState.chat)
    default:
        break
    }
    Logger.log(level: LogLevel.DEBUG_REDUX, message: "RootReducer: AppState after reducing - \(newState)", className: "rootReducer", methodName: "rootReducer")
    return newState
}
