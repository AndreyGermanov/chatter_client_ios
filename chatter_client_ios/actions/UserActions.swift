//
//  UserActions.swift
//  chatter_client_ios
//
//  Actions for current user state
//
//  Created by Andrey Germanov on 24.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import ReSwift

/// Base protocol for User profile screen actions
protocol UserAction : Action {}

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


