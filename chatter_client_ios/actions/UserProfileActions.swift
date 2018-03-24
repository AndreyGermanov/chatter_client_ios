//
//  UserProfileActions.swift
//  chatter_client_ios
//
//  Actions for User Profile screen reducer
//
//  Created by Andrey Germanov on 24.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import ReSwift

/// Base protocol for User profile screen actions
protocol UserProfileAction : Action {}

/**
 * Action to change "Login" field
 */
struct changeUserProfileLoginAction: UserProfileAction {
    /// New login field value
    let login: String
}

/**
 * Action to change "Password" field
 */
struct changeUserProfilePasswordAction: UserProfileAction {
    /// New password field value
    let password: String
}

/**
 * Action to change "Confirm Password" field
 */
struct changeUserProfileConfirmPasswordAction: UserProfileAction {
    /// New confirmPassword field value
    let confirmPassword: String
}

/**
 * Action to change "First Name" field
 */
struct changeUserProfileFirstNameAction: UserProfileAction {
    /// New first_name field value
    let firstName: String
}

/**
 * Action to change "Last Name" field
 */
struct changeUserProfileLastNameAction: UserProfileAction {
    /// New last_name field value
    let lastName: String
}

/**
 * Action to change "Gender field
 */
struct changeUserProfileGenderAction: UserProfileAction {
    /// New Gender field value
    let gender: Gender
}

/**
 * Action to change "Birt hDate" field
 */
struct changeUserProfileBirthDateAction: UserProfileAction {
    /// New birthDate field value
    let birthDate: Int
}

/**
 * Action to change "Default room" field
 */
struct changeUserProfileDefaultRoomAction: UserProfileAction {
    /// New default_room field value
    let defaultRoom: String
}

/**
 * Action to change "Default room" field
 */
struct changeUserProfilePopupMessageAction: UserProfileAction {
    /// New popup_message field value
    let popupMessage: String
}

/**
 * Action to change "Errors" field
 */
struct changeUserProfileErrorsAction: UserProfileAction {
    /// New errors field value
    let errors: [String:UserProfileError]
}

/**
 * Action to change "Profile image"
 */
struct changeUserProfileProfileImageAction: UserProfileAction {
    /// New profile image field value
    let profileImage: Data?
}

/**
 * Action to change "Show progress indicator" mode
 */
struct changeUserProfileShowProgressIndicatorAction: UserProfileAction {
    /// New show progress indicator field value
    let showProgressIndicator: Bool
}

/**
 * Action to change "Show datepicker dialog"
 */
struct changeUserProfileShowDatePickerDialogAction: UserProfileAction {
    /// New show date picker field value
    let showDatePickerDialog: Bool
}

/**
 * Action to change "rooms" list
 */
struct changeUserProfileRoomsAction: UserProfileAction {
    /// New show rooms value
    let rooms: [[String:String]]
}

/// User Profile Screen error definitions
enum UserProfileError:String {
    case RESULT_ERROR_FIELD_IS_EMPTY = "RESULT_ERROR_FIELD_IS_EMPTY"
    case RESULT_ERROR_INCORRECT_FIELD_VALUE = "RESULT_ERROR_INCORRECT_FIELD_VALUE"
    case RESULT_ERROR_CONNECTION_ERROR = "RESULT_ERROR_CONNECTION_ERROR"
    case RESULT_ERROR_PASSWORDS_SHOULD_MATCH = "RESULT_ERROR_PASSWORDS_SHOULD_MATCH"
    case RESULT_ERROR_UNKNOWN = "RESULT_ERROR_UNKNOWN"
    case INTERNAL_ERROR = "INTERNAL_ERROR"
    case AUTHENTICATION_ERROR = "AUTHENTICATION_ERROR"
    case RESULT_ERROR_IMAGE_UPLOAD = "RESULT_ERROR_IMAGE_UPLOAD"
    case RESULT_ERROR_INCORRECT_USER_ID = "RESULT_ERROR_INCORRECT_USER_ID"
    case RESULT_ERROR_INCORRECT_SESSION_ID = "RESULT_ERROR_INCORRECT_SESSION_ID"
    case RESULT_ERROR_EMPTY_REQUEST = "RESULT_ERROR_EMPTY_REQUEST"
}

extension UserProfileError: RawRepresentable {
    typealias  RawValue = String
    /// Extension calculated variable used to get text representation of each error
    var message: String {
        switch self {
        case .RESULT_ERROR_CONNECTION_ERROR: return "Connection error."
        case .RESULT_ERROR_PASSWORDS_SHOULD_MATCH: return "Passwords should match."
        case .RESULT_ERROR_FIELD_IS_EMPTY: return "Value of this field is required."
        case .RESULT_ERROR_INCORRECT_FIELD_VALUE: return "Incorrect field value."
        case .INTERNAL_ERROR: return "System error. Contact support."
        case .AUTHENTICATION_ERROR: return "Authentication error."
        case .RESULT_ERROR_IMAGE_UPLOAD: return "Error during profile image upload. Please, try again."
        case .RESULT_ERROR_INCORRECT_USER_ID: return "Incorrect user id. Please, login and try again."
        case .RESULT_ERROR_INCORRECT_SESSION_ID: return "Incorrect user session. Please, login and try again."
        case .RESULT_ERROR_EMPTY_REQUEST: return "Please, change data before sumbit"
        case .RESULT_ERROR_UNKNOWN: return "Unknown error. Please, contact support."
        }
    }
}
