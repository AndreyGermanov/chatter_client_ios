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
 *  Modes of Login Form screen
 */
enum LoginFormMode:Int {
    case LOGIN=0, REGISTER=1
}

/**
 * Genders of user
 */
enum Gender: String {
    case M = "M"
    case F = "F"
}

/**
 * Describes state of "Login Form" screen.
 * Part of global applicaiton state
 */
struct LoginFormState {
    var mode: LoginFormMode = .LOGIN
    var login = ""
    var email = ""
    var password = ""
    var confirm_password = ""
    var show_progress_indicator = false
    var errors = [String:LoginFormError]()
    var popup_message = ""
}

/**
 * Describes state of "User Profile" screen.
 * Part of global application state.
 */
struct UserProfileState {
    var login = ""
    var password = ""
    var confirm_password = ""
    var first_name = ""
    var last_name = ""
    var gender: Gender = .M
    var birthDate = 0
    var default_room = ""
    var profileImage: Data? = nil
    var rooms = [[String:String]]()
    var show_progress_indicator = false
    var popup_message = ""
    var show_date_picker_dialog = false
    var errors = [String:UserProfileError]()
}

/**
 * Describes state of current application user
 * Part of global application state.
 */
struct UserState {
    var user_id = ""
    var session_id = ""
    var isLogin = false
    var login = ""
    var email = ""
    var first_name = ""
    var last_name = ""
    var gender: Gender = .M
    var birthDate = 0
    var default_room = ""
    var profileImage: Data? = nil
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
}

/**
 * Redux store
 */
let appStore = Store<AppState>(
    reducer: rootReducer,
    state: nil
)
