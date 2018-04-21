//
//  UserReducer.swift
//  chatter_client_ios
//
//  Created by user on 24.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import ReSwift

/**
 *  Reducer, used to process Redux actions of current user state.
 *
 * - Parameter action: Action to handle
 * - Parateter state: Input state
 * - Returns State after applying action to it
 */
func userReducer(action:Action,state:UserState) -> UserState {
    var newState = state
    Logger.log(level:LogLevel.DEBUG_REDUX,message:"UserReducer: Received action \(action)",
        className:"userReducer",methodName:"userReducer")
    switch action {
    case let action as UserState.changeUserIsLoginAction:
        newState.isLogin = action.isLogin
    case let action as UserState.changeUserLoginAction:
        newState.login = action.login
    case let action as UserState.changeUserEmailAction:
        newState.email = action.email
    case let action as UserState.changeUserFirstNameAction:
        newState.first_name = action.firstName
    case let action as UserState.changeUserLastNameAction:
        newState.last_name = action.lastName
    case let action as UserState.changeUserGenderAction:
        newState.gender = action.gender
    case let action as UserState.changeUserBirthDateAction:
        newState.birthDate = action.birthDate
    case let action as UserState.changeUserProfileImageAction:
        newState.profileImage = action.profileImage
    case let action as UserState.changeUserDefaultRoomAction:
        newState.default_room = action.default_room
    case let action as UserState.changeUserUserIdAction:
        newState.user_id = action.user_id
    case let action as UserState.changeUserSessionIdAction:
        newState.session_id = action.session_id
    default:
        break
    }
    Logger.log(level:LogLevel.DEBUG_REDUX,message:"UserReducer: UserState after reducing - \(newState)",
        className:"userReducer",methodName:"userReducer")
    return newState
}
