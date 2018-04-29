//
//  UserProfileActions.swift
//  chatter_client_ios
//
//  User profile screen state and actions to mutate it
//
//  Created by Andrey Germanov on 24.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import ReSwift

/// Base protocol for User profile screen actions
protocol UserProfileAction: Action {}

/**
 * Genders of user
 */
enum Gender: String {
    case M = "M"
    case F = "F"
}

/**
 * Describes state of "User Profile" screen.
 * Part of global application state.
 */
struct UserProfileState {
    /// User profile state variables
    var login = ""
    var password = ""
    var confirm_password = ""
    var first_name = ""
    var last_name = ""
    var gender: Gender = .M
    var birthDate = 0
    var default_room = ""
    var profileImage: Data?
    var rooms = [[String: String]]()
    var show_progress_indicator = false
    var popup_message = ""
    var show_date_picker_dialog = false
    var errors = [String: UserProfileError]()

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
        let errors: [String: UserProfileError]
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
        let rooms: [[String: String]]
    }

    /**
     * User profile update action. Used to validate User profile form, put user update request to MessageCenter
     * queue and process response from server
     */
    struct updateUserProfileAction: UserProfileAction, MessageCenterResponseListener {

        /// Link to message center instance, used to process request
        var messageCenter: MessageCenter = (UIApplication.shared.delegate as! AppDelegate).msgCenter

        /**
         * Method validates user profile form and send request to MessageCenter
         */
        func exec() -> [String: Any]? {
            var errors: [String: UserProfileError] = [String: UserProfileError]()
            let state = appStore.state.userProfile
            let user = appStore.state.user
            var request = [String: Any]()
            appStore.dispatch(changeUserProfileErrorsAction(errors: errors))
            if (user.user_id.count==0) {
                errors["general"] = UserProfileError.RESULT_ERROR_INCORRECT_USER_ID
            }
            if (user.session_id.count==0) {
                errors["general"] = UserProfileError.RESULT_ERROR_INCORRECT_SESSION_ID
            }
            if (errors.count>0) {
                appStore.dispatch(changeUserProfileErrorsAction(errors: errors))
                return nil
            }
            appStore.dispatch(changeUserProfileLoginAction(login: state.login.trimmingCharacters(in: .whitespacesAndNewlines)))
            appStore.dispatch(changeUserProfileFirstNameAction(firstName: state.first_name.trimmingCharacters(in: .whitespacesAndNewlines)))
            appStore.dispatch(changeUserProfileLastNameAction(lastName: state.last_name.trimmingCharacters(in: .whitespacesAndNewlines)))
            appStore.dispatch(changeUserProfileDefaultRoomAction(defaultRoom: state.default_room.trimmingCharacters(in: .whitespacesAndNewlines)))
            if state.login.count == 0 {
                errors["login"] = .RESULT_ERROR_FIELD_IS_EMPTY
            } else if user.login != state.login {
                request["login"] = state.login
            }
            if state.password.count != 0 || state.confirm_password.count != 0 {
                if state.password != state.confirm_password {
                    errors["password"] = .RESULT_ERROR_PASSWORDS_SHOULD_MATCH
                } else if state.password.count > 0 {
                    request["password"] = state.password
                    request["confirm_password"] = state.confirm_password
                }
            }
            if state.first_name.count == 0 {
                errors["first_name"] = .RESULT_ERROR_FIELD_IS_EMPTY
            } else if user.first_name != state.first_name {
                request["first_name"] = state.first_name
            }
            if state.last_name.count == 0 {
                errors["last_name"] = .RESULT_ERROR_FIELD_IS_EMPTY
            } else if user.last_name != state.last_name {
                request["last_name"] = state.last_name
            }
            if state.gender != .M && state.gender != .F {
                errors["gender"] = .RESULT_ERROR_INCORRECT_FIELD_VALUE
            } else if state.gender != user.gender {
                request["gender"] = state.gender.rawValue
            }
            if state.birthDate == 0 || Double(state.birthDate) > Date().timeIntervalSince1970 {
                errors["birthDate"] = .RESULT_ERROR_INCORRECT_FIELD_VALUE
            } else if state.birthDate != user.birthDate {
                request["birthDate"] = state.birthDate
            }
            if state.default_room.count == 0 {
                errors["default_room"] = .RESULT_ERROR_FIELD_IS_EMPTY
            } else if (state.rooms.filter { it in return it["_id"] == state.default_room }).count == 0 {
                errors["default_room"] = .RESULT_ERROR_INCORRECT_FIELD_VALUE
            } else if state.default_room != user.default_room {
                request["default_room"] = state.default_room
            }
            if state.profileImage != nil {
                let state_profile_checksum = Int(state.profileImage!.bytes.crc32())
                var user_profile_checksum = 0
                if user.profileImage != nil {
                    user_profile_checksum = Int(user.profileImage!.bytes.crc32())
                }
                if (state_profile_checksum != user_profile_checksum) {
                    request["profile_image_checksum"] = state_profile_checksum
                    request["profile_image"] = state.profileImage
                }
            }
            if errors.count>0 {
                appStore.dispatch(changeUserProfileErrorsAction(errors: errors))
                Logger.log(level: LogLevel.DEBUG, message: "User Profile form validation errors: \(errors)",
                    className: "updateUserProfileAction", methodName: "exec")
                return nil
            }
            if request.count == 0 {
                errors = ["general": .RESULT_ERROR_EMPTY_REQUEST]
                Logger.log(level: LogLevel.DEBUG, message: "User Profile form validation errors: \(errors)",
                    className: "updateUserProfileAction", methodName: "exec")
                appStore.dispatch(changeUserProfileErrorsAction(errors: errors))
                return nil
            }
            if !messageCenter.isConnected() {
                Logger.log(level: LogLevel.WARNING, message: "Server connection error",
                           className: "updateUserProfileAction", methodName: "exec")
                appStore.dispatch(changeUserProfileErrorsAction(errors: ["general": .RESULT_ERROR_CONNECTION_ERROR]))
                return nil
            }
            if state.show_progress_indicator {
                Logger.log(level: LogLevel.DEBUG, message: "User profile update process already going",
                           className: "updateUserProfileAction", methodName: "exec")
                return nil
            }
            request["user_id"] = user.user_id
            request["session_id"] = user.session_id
            request["action"] = "update_user"
            request["sender"] = self
            if let sent_request = messageCenter.addToPendingRequests(request) {
                appStore.dispatch(changeUserProfileShowProgressIndicatorAction(showProgressIndicator: true))
                Logger.log(level: LogLevel.DEBUG, message: "Added User Profile change request to Message Center Pending requests queue. Request body: \(sent_request)",
                    className: "updateUserProfileAction", methodName: "exec")
            } else {
                Logger.log(level: LogLevel.WARNING, message: "Error construction user profile change request: \(request)",
                    className: "updateUserProfileAction", methodName: "exec")
            }
            return request
        }

        /**
         * Callback function, which called when MessageCenter receives response to request, which sent in "exec" method
         *
         * - Parameter request_id: Request ID, to which responses received
         * - Parameter response: Body of received response
         */
        func handleWebSocketResponse(request_id: String, response: [String: Any]) {
            Logger.log(level: LogLevel.DEBUG,
                       message: "Received response to user profile update request. Request ID: \(request_id), response body: \(response)",
                className: "updateUserProfileAction", methodName: "handleWebSocketResponse")
            appStore.dispatch(changeUserProfileShowProgressIndicatorAction(showProgressIndicator: false))
            _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
            if let status = response["status"] as? String {
                if status == "ok" {
                    let state = appStore.state.userProfile
                    appStore.dispatch(UserState.changeUserLoginAction(login: state.login))
                    appStore.dispatch(UserState.changeUserFirstNameAction(firstName: state.first_name))
                    appStore.dispatch(UserState.changeUserLastNameAction(lastName: state.last_name))
                    appStore.dispatch(UserState.changeUserGenderAction(gender: state.gender))
                    appStore.dispatch(UserState.changeUserDefaultRoomAction(default_room: state.default_room))
                    appStore.dispatch(UserState.changeUserProfileImageAction(profileImage: state.profileImage))
                    appStore.dispatch(changeUserProfilePasswordAction(password: ""))
                    appStore.dispatch(changeUserProfileConfirmPasswordAction(confirmPassword: ""))
                    appStore.dispatch(AppState.ChangeActivityAction(activity: .CHAT))
                } else if status == "error" {
                    if let status_code_string = response["status_code"] as? String {
                        if let status_code = UserProfileError(rawValue: status_code_string) {
                            var field = "general"
                            if (response["field"] != nil) {
                                field = response["field"] as! String
                            }
                            var errors = [String: UserProfileError]()
                            errors[field] = status_code
                            appStore.dispatch(changeUserProfileErrorsAction(errors: errors))
                            Logger.log(level: LogLevel.DEBUG, message: "User profile update error: \(status_code.rawValue)",
                                className: "updateUserProfileAction", methodName: "handleWebSocketResponse")
                        } else {
                            appStore.dispatch(changeUserProfileErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
                            Logger.log(level: LogLevel.DEBUG, message: "User profile update error: \(UserProfileError.RESULT_ERROR_UNKNOWN.rawValue)",
                                className: "updateUserProfileAction", methodName: "handleWebSocketResponse")
                        }
                    } else {
                        appStore.dispatch(changeUserProfileErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
                        Logger.log(level: LogLevel.WARNING, message: "Server did not return correct status_code for request \(request_id)",
                            className: "updateUserProfileAction", methodName: "handleWebSocketResponse")
                    }
                } else {
                    appStore.dispatch(changeUserProfileErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
                    Logger.log(level: LogLevel.WARNING, message: "Server did not return correct status to user profile update request \(request_id)",
                        className: "registerUserAction", methodName: "handleWebSocketResponse")
                }
            } else {
                Logger.log(level: LogLevel.DEBUG, message: "Response for request \(request_id) does not contain 'status' field",
                    className: "updateUserProfileAction", methodName: "handleWebSocketResponse")
                appStore.dispatch(changeUserProfileErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
            }
        }
    }

    /**
     * User profile update cancel action. Used to revert changes on "User Profile" screen when
     * user presses "Cancel button
     */
    struct cancelUserProfileUpdateAction: UserProfileAction {
        func exec() {
            appStore.dispatch(changeUserProfileErrorsAction(errors: [String: UserProfileError]()))
            if appStore.state.user.default_room.count  == 0 {
                appStore.dispatch(changeUserProfileErrorsAction(errors: ["default_room": UserProfileError.RESULT_ERROR_FIELD_IS_EMPTY]))
            } else {
                let state = appStore.state.user
                appStore.dispatch(AppState.ChangeActivityAction(activity: .CHAT))
                appStore.dispatch(changeUserProfileLoginAction(login: state.login))
                appStore.dispatch(changeUserProfileFirstNameAction(firstName: state.first_name))
                appStore.dispatch(changeUserProfileLastNameAction(lastName: state.last_name))
                appStore.dispatch(changeUserProfileGenderAction(gender: state.gender))
                appStore.dispatch(changeUserProfileBirthDateAction(birthDate: state.birthDate))
                appStore.dispatch(changeUserProfileDefaultRoomAction(defaultRoom: state.default_room))
                appStore.dispatch(changeUserProfileProfileImageAction(profileImage: state.profileImage))
                appStore.dispatch(changeUserProfilePasswordAction(password: ""))
                appStore.dispatch(changeUserProfileConfirmPasswordAction(confirmPassword: ""))
            }
        }
    }
}

/// User Profile Screen error definitions
enum UserProfileError: String {
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
