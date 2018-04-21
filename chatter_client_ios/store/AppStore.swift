//
//  AppStore.swift
//  chatter_client_ios
//
//  Defines Redux Application Store and State
//
//  Created by user on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//
import UIKit
import ReSwift

/**
 *  Modes of Application (Application screens)
 */
enum AppScreens {
    case LOGIN_FORM, USER_PROFILE, CHAT, SYSTEM_SETTINGS
}

/**
 * Global Application State, which used by Redux store
 * to maintain Application user interface
 */
struct AppState: StateType {
    var current_activity = AppScreens.LOGIN_FORM
    var loginForm = LoginFormState()
    var userProfile = UserProfileState()
    var user = UserState()
    
    /**
     * Action used to change current application screen
     */
    struct ChangeActivityAction: Action {
        /// Screen to move to
        let activity: AppScreens
    }
}

/**
 * Redux store
 */
let appStore = Store<AppState>(
    reducer: rootReducer,
    state: nil
)
