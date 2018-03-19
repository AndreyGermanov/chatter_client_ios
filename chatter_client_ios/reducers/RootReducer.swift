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
func rootReducer(action:Action,state:AppState?) -> AppState {
    var newState = state ?? AppState()
    switch action {
    case let action as ChangeActivityAction:
        newState.current_activity = action.activity
    default:
        break
    }
    return newState
}
