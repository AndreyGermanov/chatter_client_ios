//
//  UserActions.swift
//  chatter_client_ios
//
//  User state and actions to mutate it
//
//  Created by Andrey Germanov on 24.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import ReSwift

/// Base protocol for User profile screen actions
protocol UserAction: Action {}

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
    var profileImage: Data?

    /**
     * Action to change "Login" field
     */
    struct changeUserLoginAction: UserAction {
        /// New login field value
        let login: String
    }

    /**
     * Action to change "user_id" field
     */
    struct changeUserUserIdAction: UserAction {
        /// New user_id field value
        let user_id: String
    }

    /**
     * Action to change "session_id" field
     */
    struct changeUserSessionIdAction: UserAction {
        /// New session_id field value
        let session_id: String
    }

    /**
     * Action to change "isLogin" field
     */
    struct changeUserIsLoginAction: UserAction {
        /// New isLogin field value
        let isLogin: Bool
    }

    /**
     * Action to change "email" field
     */
    struct changeUserEmailAction: UserAction {
        /// New email field value
        let email: String
    }

    /**
     * Action to change "first_name" field
     */
    struct changeUserFirstNameAction: UserAction {
        /// New first_name field value
        let firstName: String
    }

    /**
     * Action to change "last_name" field
     */
    struct changeUserLastNameAction: UserAction {
        /// New last_name field value
        let lastName: String
    }

    /**
     * Action to change "last_name" field
     */
    struct changeUserGenderAction: UserAction {
        /// New gender field value
        let gender: Gender
    }

    /**
     * Action to change "birthDate" field
     */
    struct changeUserBirthDateAction: UserAction {
        /// New birthDate field value
        let birthDate: Int
    }

    /**
     * Action to change "profileImage" field
     */
    struct changeUserProfileImageAction: UserAction {
        /// New profileImage field value
        let profileImage: Data?
    }

    /**
     * Action to change "default_room" field
     */
    struct changeUserDefaultRoomAction: UserAction {
        /// New default_room field value
        let default_room: String
    }

    /**
     * Utility function which cleans all user information
     * and logs him out
     */
    static func logoutUser() {
        appStore.dispatch(UserState.changeUserEmailAction(email: ""))
        appStore.dispatch(UserState.changeUserLoginAction(login: ""))
        appStore.dispatch(UserState.changeUserGenderAction(gender: .M))
        appStore.dispatch(UserState.changeUserBirthDateAction(birthDate: 0))
        appStore.dispatch(UserState.changeUserUserIdAction(user_id: ""))
        appStore.dispatch(UserState.changeUserSessionIdAction(session_id: ""))
        appStore.dispatch(UserState.changeUserDefaultRoomAction(default_room: ""))
        appStore.dispatch(UserState.changeUserFirstNameAction(firstName: ""))
        appStore.dispatch(UserState.changeUserLastNameAction(lastName: ""))
        appStore.dispatch(UserState.changeUserIsLoginAction(isLogin: false))
        appStore.dispatch(UserState.changeUserProfileImageAction(profileImage: nil))
        UserDefaults.standard.removeObject(forKey: "user_id")
        UserDefaults.standard.removeObject(forKey: "session_id")
        if (appStore.state.current_activity != .LOGIN_FORM) {
            appStore.dispatch(AppState.ChangeActivityAction(activity: .LOGIN_FORM))
        }
        appStore.dispatch(LoginFormState.changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
    }
}
