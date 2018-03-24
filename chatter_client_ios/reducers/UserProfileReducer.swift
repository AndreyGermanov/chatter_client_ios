//
//  UserProfileReducer.swift
//  chatter_client_ios
//
//  Created by user on 24.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import ReSwift

/**
 *  Reducer, used to process Redux actions of User Profile screen.
 *
 * - Parameter action: Action to handle
 * - Parateter state: Input state
 * - Returns State after applying action to it
 */
func userProfileReducer(action:Action,state:UserProfileState) -> UserProfileState {
    var newState = state
    Logger.log(level:LogLevel.DEBUG_REDUX,message:"UserProfileReducer: Received action \(action)",
        className:"userProfileReducer",methodName:"userProfileReducer")
    switch action {
    case let action as changeUserProfileErrorsAction:
        newState.errors = action.errors
    case let action as changeUserProfileShowProgressIndicatorAction:
        newState.show_progress_indicator = action.showProgressIndicator
    case let action as changeUserProfilePopupMessageAction:
        newState.popup_message = action.popupMessage
    case let action as changeUserProfileLoginAction:
        newState.login = action.login
    case let action as changeUserProfilePasswordAction:
        newState.password = action.password
    case let action as changeUserProfileConfirmPasswordAction:
        newState.confirm_password = action.confirmPassword
    case let action as changeUserProfileFirstNameAction:
        newState.first_name = action.firstName
    case let action as changeUserProfileLastNameAction:
        newState.last_name = action.lastName
    case let action as changeUserProfileGenderAction:
        newState.gender = action.gender
    case let action as changeUserProfileBirthDateAction:
        newState.birthDate = action.birthDate
    case let action as changeUserProfileProfileImageAction:
        newState.profileImage = action.profileImage
    case let action as changeUserProfileDefaultRoomAction:
        newState.default_room = action.defaultRoom
    case let action as changeUserProfileShowDatePickerDialogAction:
        newState.show_date_picker_dialog = action.showDatePickerDialog
    case let action as changeUserProfileRoomsAction:
        newState.rooms = action.rooms
    default:
        break
    }
    Logger.log(level:LogLevel.DEBUG_REDUX,message:"UserProfileReducer: UserProfileState after reducing - \(newState)",className:"userProfileReducer",methodName:"userProfileReducer")
    return newState
}

