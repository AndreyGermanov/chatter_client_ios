//
//  LoginScreenActions.swift
//  chatter_client_ios
//
//  State of Login Form and actions to mutate this state
//
//  Created by user on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import ReSwift

/// Base protocol for login form actions
protocol LoginFormAction: Action {}

/**
 *  Modes of Login Form screen
 */
enum LoginFormMode: Int {
    case LOGIN=0, REGISTER=1
}

/**
 * Describes state of "Login Form" screen.
 * Part of global applicaiton state
 */
struct LoginFormState {

    /// Login form state variables
    var mode: LoginFormMode = .LOGIN
    var login = ""
    var email = ""
    var password = ""
    var confirm_password = ""
    var show_progress_indicator = false
    var errors = [String: LoginFormError]()
    var popup_message = ""

    /**
     * Action to change "Login" field
     */
    struct changeLoginAction: LoginFormAction {
        /// New login field value
        let login: String
    }

    /**
     * Action to change "Email" field
     */
    struct changeEmailAction: LoginFormAction {
        let email: String
    }

    /**
     * Action to change "Password" field
     */
    struct changePasswordAction: LoginFormAction {
        let password: String
    }

    /**
     * Action to change "Confirm Password" field
     */
    struct changeLoginFormConfirmPasswordAction: LoginFormAction {
        let confirmPassword: String
    }

    /**
     * Action to change mode of login form
     */
    struct changeLoginFormModeAction: LoginFormAction {
        let mode: LoginFormMode
    }

    /**
     * Action to change Progress indicator in Login form
     */
    struct changeLoginFormShowProgressIndicatorAction: LoginFormAction {
        let progressIndicator: Bool
    }

    /**
     * Action to change errors array
     */
    struct changeLoginFormErrorsAction: LoginFormAction {
        let errors: [String: LoginFormError]
    }

    /**
     * Action to change popup message text
     */
    struct changeLoginFormPopupMessageAction: LoginFormAction {
        let popupMessage: String
    }

    /**
     * User register action. Used to validate login form, put user register request to MessageCenter
     * queue and process response from server
     */
    struct registerUserAction: LoginFormAction, MessageCenterResponseListener {

        /// Link to message center instance, used to process request
        var messageCenter: MessageCenter = (UIApplication.shared.delegate as! AppDelegate).msgCenter

        /**
         * Method validates register form and send request to MessageCenter
         */
        func exec() {
            var state = appStore.state.loginForm
            var errors = [String: LoginFormError]()
            appStore.dispatch(changeLoginFormErrorsAction(errors: errors))
            state.login = state.login.trimmingCharacters(in: .whitespacesAndNewlines)
            state.email = state.email.trimmingCharacters(in: .whitespacesAndNewlines)
            state.password = state.password.trimmingCharacters(in: .whitespacesAndNewlines)
            state.confirm_password = state.confirm_password.trimmingCharacters(in: .whitespacesAndNewlines)
            if state.login.count==0 {
                errors["login"] = LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY
            }
            if state.email.count==0 {
                errors["email"] = LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY
            } else if !state.email.isEmail {
                errors["email"] = LoginFormError.RESULT_ERROR_INCORRECT_EMAIL
            }
            if state.password.count==0 {
                errors["password"] = LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY
            } else if state.confirm_password != state.password {
                errors["password"] = LoginFormError.RESULT_ERROR_PASSWORDS_SHOULD_MATCH
            }
            if errors.count == 0 && !messageCenter.isConnected() {
                errors["general"] = LoginFormError.RESULT_ERROR_CONNECTION_ERROR
            }
            if errors.count > 0 {
                Logger.log(level: LogLevel.DEBUG, message: "Register form validation errors: \(errors)",
                    className: "registerUserAction", methodName: "exec")
                appStore.dispatch(changeLoginFormErrorsAction(errors: errors))
                return
            }
            if state.show_progress_indicator {
                Logger.log(level: LogLevel.DEBUG, message: "Register action already in progress",
                           className: "registerUserAction", methodName: "exec")
                return
            }
            appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: true))
            if let request = self.messageCenter.addToPendingRequests([
                "sender": self,
                "action": "register_user",
                "login": state.login,
                "email": state.email,
                "password": state.password,
                "confirm_password": state.confirm_password
                ]) {
                Logger.log(level: LogLevel.DEBUG,
                           message: "Added user registration request to MessageCenter pendingRequests queue. Request: \(request)",
                    className: "registerUserAction", methodName: "exec")
            } else {
                Logger.log(level: LogLevel.WARNING, message: "Error constructing user register request for state: \(state)",
                    className: "registerUserAction", methodName: "exec")
            }
        }

        /**
         * Callback function, which called when MessageCenter receives response to request, which sent in "exec" method
         *
         * - Parameter request_id: Request ID, to which responses received
         * - Parameter response: Body of received response
         */
        func handleWebSocketResponse(request_id: String, response: [String: Any]) {
            Logger.log(level: LogLevel.DEBUG,
                       message: "Received response to user registration request. Request ID: \(request_id), response body: \(response)",
                className: "registerUserAction", methodName: "handleWebSocketResponse")
            let status = response["status"] as? String
            appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
            if status == nil {
                Logger.log(level: LogLevel.DEBUG, message: "Response for request \(request_id) does not contain 'status' field",
                    className: "registerUserAction", methodName: "handleWebSocketResponse")
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
                appStore.dispatch(changeLoginFormErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
                return
            }
            if status != "ok" && status != "error" {
                appStore.dispatch(changeLoginFormErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
                Logger.log(level: LogLevel.WARNING, message: "Server did not return correct status to user register request \(request_id)",
                    className: "registerUserAction", methodName: "handleWebSocketResponse")
                return
            }
            if status == "error" {
                if let status_code_string = response["status_code"] as? String {
                    if let status_code = LoginFormError(rawValue: status_code_string) {
                        appStore.dispatch(changeLoginFormErrorsAction(errors: ["general": status_code]))
                        Logger.log(level: LogLevel.DEBUG, message: "User register error: \(status_code.rawValue)",
                            className: "registerUserAction", methodName: "handleWebSocketResponse")
                    } else {
                        appStore.dispatch(changeLoginFormErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
                        Logger.log(level: LogLevel.DEBUG, message: "User register error: \(LoginFormError.RESULT_ERROR_UNKNOWN.rawValue)",
                            className: "registerUserAction", methodName: "handleWebSocketResponse")
                    }
                } else {
                    appStore.dispatch(changeLoginFormErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
                    Logger.log(level: LogLevel.WARNING, message: "Server did not return correct status_code for request \(request_id)",
                        className: "registerUserAction", methodName: "handleWebSocketResponse")
                }
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
                return
            }
            appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
            appStore.dispatch(changeLoginFormErrorsAction(errors: [String: LoginFormError]()))
            appStore.dispatch(changeLoginFormPopupMessageAction(popupMessage: LoginFormError.RESULT_REGISTER_OK.message))
            appStore.dispatch(changeLoginFormModeAction(mode: .LOGIN))
            _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
            Logger.log(level: LogLevel.DEBUG, message: "User registration request \(request_id) processed successfully",
                className: "registerUserAction", methodName: "handleWebSocketResponse")
        }
    }

    /**
     * User login action. Used to validate login form, put user login request to MessageCenter
     * queue and process response from server
     */
    struct loginUserAction: LoginFormAction, MessageCenterResponseListener {

        /// Link to message center instance, used to process request
        var messageCenter: MessageCenter = (UIApplication.shared.delegate as! AppDelegate).msgCenter

        /**
         * Method validates login form and send request to MessageCenter
         */
        func exec(user_id: String="", session_id: String="") {
            var state = appStore.state.loginForm
            var errors = [String: LoginFormError]()
            appStore.dispatch(changeLoginFormErrorsAction(errors: errors))
            var login = ""
            var password = ""
            if !user_id.isEmpty && !session_id.isEmpty {
                Logger.log(level: LogLevel.DEBUG,
                           message: "Started auto login action by user_id and session_id. User ID: \(user_id),Session ID: \(session_id).",
                    className: "LoginFormState", methodName: "loginUserAction.exec")
                login = user_id
                password = session_id
            } else {
                state.login = state.login.trimmingCharacters(in: .whitespacesAndNewlines)
                state.password = state.password.trimmingCharacters(in: .whitespacesAndNewlines)
                login = state.login
                password = state.password
                Logger.log(level: LogLevel.DEBUG, message: "Started login action by login and password. Login: \(login), password: \(password) ",
                    className: "LoginFormState", methodName: "loginUserAction.exec")
                if login.count==0 {
                    errors["login"] = LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY
                }
                if password.count==0 {
                    errors["password"] = LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY
                }
                if errors.count == 0 && !messageCenter.isConnected() {
                    errors["general"] = LoginFormError.RESULT_ERROR_CONNECTION_ERROR
                }
            }
            if errors.count > 0 {
                Logger.log(level: LogLevel.DEBUG, message: "Login form validation errors: \(errors)",
                    className: "loginUserAction", methodName: "exec")
                appStore.dispatch(changeLoginFormErrorsAction(errors: errors))
                return
            }
            if state.show_progress_indicator {
                Logger.log(level: LogLevel.DEBUG, message: "Login action already in progress",
                           className: "loginUserAction", methodName: "exec")
                return
            }
            appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: true))
            let request:[String:Any] = [
                "sender": self,
                "action": "login_user",
                "login": login,
                "password": password
            ]
            if let sent_request = self.messageCenter.addToPendingRequests(request) {
                Logger.log(level: LogLevel.DEBUG,
                           message: "Added user login request to MessageCenter pendingRequests queue. Request: \(sent_request)",
                    className: "loginUserAction", methodName: "exec")
            } else {
                Logger.log(level: LogLevel.WARNING, message: "Error constructing user login request for state: \(state). Request: \(request)",
                    className: "loginUserAction", methodName: "exec")
            }
        }

        /**
         * Callback function, which called when MessageCenter receives response to request, which sent in "exec" method
         *
         * - Parameter request_id: Request ID, to which responses received
         * - Parameter response: Body of received response
         */
        func handleWebSocketResponse(request_id: String, response: [String: Any]) {
            var response = response
            Logger.log(level: LogLevel.DEBUG,
                       message: "Received response to user login request. Request ID: \(request_id), response body: \(response)",
                className: "loginUserAction", methodName: "handleWebSocketResponse")
            if !self.validateLoginResponse(request_id: request_id, response: response) {
                return
            }
            appStore.dispatch(changeLoginFormErrorsAction(errors: [String: LoginFormError]()))
            if response["checksum"] != nil {
                if !self.processProfileImageResponse(request_id: request_id, response: response) {
                    return
                }
            }
            appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
            self.parseLoginResponse(request_id: request_id, response: response)
            _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
            UserDefaults.standard.setValue(appStore.state.user.user_id, forKey: "user_id")
            UserDefaults.standard.setValue(appStore.state.user.session_id, forKey: "session_id")
            Logger.log(level: LogLevel.DEBUG,
                       message: "User login request \(request_id) processed successfully. User profile: \(appStore.state.userProfile). User state: \(appStore.state.user)",
                className: "loginUserAction", methodName: "handleWebSocketResponse")
        }
        /**
         * Utility function which used to validate login response and make needed state
         * updates if response contains errors
         *
         * - Parameter request_id: ID of request, to which response received
         * - Parameter response: Body of response to validate
         * - Returns: true if no errors or false otherwise
         */
        func validateLoginResponse(request_id: String, response: [String: Any]) -> Bool {
            let status = response["status"] as? String
            if status == nil {
                Logger.log(level: LogLevel.DEBUG, message: "Response for request \(request_id) does not contain 'status' field",
                    className: "LoginFormState", methodName: "loginUserAction.validateLoginResponse")
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
                appStore.dispatch(changeLoginFormErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
                appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
                return true
            }
            if status != "ok" && status != "error" {
                appStore.dispatch(changeLoginFormErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
                Logger.log(level: LogLevel.WARNING, message: "Server did not return correct status to user login request \(request_id)",
                    className: "LoginFormState", methodName: "loginUserAction.validateLoginResponse")
                return true
            }
            if status == "error" {
                if let status_code_string = response["status_code"] as? String {
                    if let status_code = LoginFormError(rawValue: status_code_string) {
                        appStore.dispatch(changeLoginFormErrorsAction(errors: ["general": status_code]))
                        Logger.log(level: LogLevel.DEBUG, message: "User login error: \(status_code.rawValue)",
                            className: "LoginFormState", methodName: "loginUserAction.validateLoginResponse")
                    } else {
                        appStore.dispatch(changeLoginFormErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
                        Logger.log(level: LogLevel.DEBUG, message: "User login error: \(LoginFormError.RESULT_ERROR_UNKNOWN.rawValue)",
                            className: "LoginFormState", methodName: "loginUserAction.validateLoginResponse")
                    }
                } else {
                    appStore.dispatch(changeLoginFormErrorsAction(errors: ["general": .RESULT_ERROR_UNKNOWN]))
                    Logger.log(level: LogLevel.WARNING, message: "Server did not return correct status_code for request \(request_id)",
                        className: "LoginFormState", methodName: "loginUserAction.validateLoginResponse")
                }
                appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
                return false
            }
            return true
        }

        /**
         * Utility function, used to process login response with checksum of profile image
         * It checks if file with this checksum already arrived and set it as User Profile Image
         * Or if it did not arrive, create row in "responsesWaitingFile" queue with this file
         *
         * - Parameter: request_id - Request, for which response received
         * - Parameter: response - Body of response
         * - Returns: True if profile image processed and set successfully or false otherwise
         */
        func processProfileImageResponse(request_id: String, response: [String: Any]) -> Bool {
            var checksum = 0
            if response["checksum"] is String {
                checksum = Int(response["checksum"] as! String)!
            } else if response["checksum"] is NSNumber {
                checksum = Int(truncating: response["checksum"] as! NSNumber)
            }
            if let received_file = messageCenter.receivedFiles[checksum] as? [String: Any] {
                Logger.log(level: LogLevel.DEBUG, message: "File with checksum \(checksum) found in receivedFiles queue",
                    className: "LoginFormState", methodName: "loginUserAction.processProfileImageResponse")
                if let profileImage = received_file["data"] as? Data {
                    appStore.dispatch(UserProfileState.changeUserProfileProfileImageAction(profileImage: profileImage))
                    appStore.dispatch(UserState.changeUserProfileImageAction(profileImage: profileImage))
                    Logger.log(level: LogLevel.DEBUG, message: "Profile image download and set for \(request_id)",
                        className: "LoginFormState", methodName: "loginUserAction.processProfileImageResponse")
                    _ = messageCenter.removeFromReceivedFiles(checksum)
                    _ = messageCenter.removeFromResponsesWaitingFile(checksum)
                } else {
                    Logger.log(level: LogLevel.DEBUG, message: "Could not set profile image from \(request_id)",
                        className: "LoginFormState", methodName: "loginUserAction.processProfileImageResponse")
                    _ = messageCenter.removeFromReceivedFiles(checksum)
                    _ = messageCenter.removeFromResponsesWaitingFile(checksum)                        }
            } else {
                Logger.log(level: LogLevel.DEBUG, message: "File with checksum \(checksum) not found in receivedFiles queue",
                    className: "LoginFormState", methodName: "loginUserAction.processProfileImageResponse")
                _ = messageCenter.addToResponsesWaitingFile(checksum: checksum, response: response)
                _ = messageCenter.removeFromRequestsWaitingResponses(request_id)
                return false
            }
            return true
        }

        /**
         * Utility function used to parse successful login response body
         * and apply received values to UserState and UserProfileState
         *
         * - Parameter response: Response body to parse
         */
        func parseLoginResponse(request_id: String, response: [String: Any]) {
            var response = response
            appStore.dispatch(UserState.changeUserIsLoginAction(isLogin: true))
            appStore.dispatch(UserState.changeUserLoginAction(login: response["login"] as! String))
            appStore.dispatch(UserState.changeUserEmailAction(email: response["email"] as! String))
            appStore.dispatch(UserProfileState.changeUserProfileLoginAction(login: response["login"] as! String))
            appStore.dispatch(UserState.changeUserUserIdAction(user_id: response["user_id"] as! String))
            appStore.dispatch(UserState.changeUserSessionIdAction(session_id: response["session_id"] as! String))
            if let first_name = response["first_name"] as? String {
                appStore.dispatch(UserState.changeUserFirstNameAction(firstName: first_name))
                appStore.dispatch(UserProfileState.changeUserProfileFirstNameAction(firstName: first_name))
            } else {
                appStore.dispatch(UserState.changeUserFirstNameAction(firstName: ""))
                appStore.dispatch(UserProfileState.changeUserProfileFirstNameAction(firstName: ""))
            }
            if let last_name = response["last_name"] as? String {
                appStore.dispatch(UserState.changeUserLastNameAction(lastName: last_name))
                appStore.dispatch(UserProfileState.changeUserProfileLastNameAction(lastName: last_name))
            } else {
                appStore.dispatch(UserState.changeUserLastNameAction(lastName: ""))
                appStore.dispatch(UserProfileState.changeUserProfileLastNameAction(lastName: ""))
            }
            appStore.dispatch(UserState.changeUserGenderAction(gender: .M))
            appStore.dispatch(UserProfileState.changeUserProfileGenderAction(gender: .M))
            if (response["gender"] != nil) {
                if let gender = Gender(rawValue: response["gender"] as! String) {
                    appStore.dispatch(UserState.changeUserGenderAction(gender: gender))
                    appStore.dispatch(UserProfileState.changeUserProfileGenderAction(gender: gender))
                } else {
                    Logger.log(level: LogLevel.DEBUG,
                               message: "Could not parse gender for request \(request_id). Received gender: \(response["gender"]!)",
                        className: "LoginFormState", methodName: "loginUserAction.parseLoginResponse")
                }                }
            appStore.dispatch(UserState.changeUserBirthDateAction(birthDate: 0))
            appStore.dispatch(UserProfileState.changeUserProfileBirthDateAction(birthDate: 0))
            if response["birthDate"] != nil {
                var birthDate = 0
                if response["birthDate"] is String {
                    birthDate = Int(response["birthDate"] as! String)!
                } else if response["birthDate"] is NSNumber {
                    birthDate = Int(truncating: response["birthDate"] as! NSNumber)
                }
                appStore.dispatch(UserState.changeUserBirthDateAction(birthDate: birthDate))
                appStore.dispatch(UserProfileState.changeUserProfileBirthDateAction(birthDate: birthDate))
            }

            var rooms_to_apply = [[String: String]]()
            appStore.dispatch(UserProfileState.changeUserProfileRoomsAction(rooms: rooms_to_apply))
            if response["rooms"] is String {
                do {
                    let roomsStr = response["rooms"] as! String
                    response["rooms"] = try JSONSerialization.jsonObject(with: roomsStr.data(using: String.Encoding.utf8)!)
                } catch {
                    Logger.log(level: LogLevel.WARNING,
                               message: "Could not parse rooms JSON string \(response["rooms"]!) for \(request_id)",
                        className: "LoginFormState", methodName: "loginUserAction.parseLoginResponse")
                }
            }
            if let rooms = response["rooms"] as? NSArray {
                for room in rooms {
                    if let room = room as? [String: Any] {
                        if room["_id"] != nil && room["name"] != nil {
                            rooms_to_apply.append(["_id": room["_id"] as! String, "name": room["name"] as! String])
                        }
                    } else {
                        Logger.log(level: LogLevel.WARNING, message: "Could not decode room \(room) for \(request_id)",
                            className: "LoginFormState", methodName: "loginUserAction.parseLoginResponse")
                    }
                }
                appStore.dispatch(UserProfileState.changeUserProfileRoomsAction(rooms: rooms_to_apply))
            } else {
                Logger.log(level: LogLevel.WARNING, message: "Could not decode rooms for request \(request_id). Rooms: \(response["rooms"]!)",
                    className: "LoginFormState", methodName: "loginUserAction.parseLoginResponse")
            }
            if let default_room = response["default_room"] as? String {
                appStore.dispatch(UserState.changeUserDefaultRoomAction(default_room: default_room))
                appStore.dispatch(UserProfileState.changeUserProfileDefaultRoomAction(defaultRoom: default_room))
                appStore.dispatch(AppState.ChangeActivityAction(activity: .CHAT))
                //appStore.dispatch(ChatState.changeCurrentRoom(currentRoom: ChatRoom.getById(default_room)!))
            } else {
                appStore.dispatch(UserState.changeUserDefaultRoomAction(default_room: ""))
                appStore.dispatch(UserProfileState.changeUserProfileDefaultRoomAction(defaultRoom: ""))
                appStore.dispatch(AppState.ChangeActivityAction(activity: .USER_PROFILE))
            }
        }
    }
}

/// Login form error definitions
enum LoginFormError: String {
    case RESULT_ERROR_FIELD_IS_EMPTY = "RESULT_ERROR_FIELD_IS_EMPTY"
    case RESULT_ERROR_INCORRECT_EMAIL = "RESULT_ERROR_INCORRECT_EMAIL"
    case RESULT_ERROR_INCORRECT_LOGIN = "RESULT_ERROR_INCORRECT_LOGIN"
    case RESULT_ERROR_INCORRECT_PASSWORD = "RESULT_ERROR_INCORRECT_PASSWORD"
    case RESULT_ERROR_EMAIL_EXISTS = "RESULT_ERROR_EMAIL_EXISTS"
    case RESULT_ERROR_LOGIN_EXISTS = "RESULT_ERROR_LOGIN_EXISTS"
    case RESULT_ERROR_ACTIVATION_EMAIL = "RESULT_ERROR_ACTIVATION_EMAIL"
    case RESULT_ERROR_NOT_ACTIVATED = "RESULT_ERROR_NOT_ACTIVATED"
    case RESULT_ERROR_ALREADY_LOGIN = "RESULT_ERROR_ALREADY_LOGIN"
    case RESULT_ERROR_CONNECTION_ERROR = "RESULT_ERROR_CONNECTION_ERROR"
    case RESULT_ERROR_PASSWORDS_SHOULD_MATCH = "RESULT_ERROR_PASSWORDS_SHOULD_MATCH"
    case RESULT_ERROR_UNKNOWN = "RESULT_ERROR_UNKNOWN"
    case RESULT_REGISTER_OK = "RESULT_REGISTER_OK"
    case AUTHENTICATION_ERROR = "AUTHENTICATION_ERROR"
}
extension LoginFormError: RawRepresentable {
    typealias  RawValue = String
    /// Extension calculated variable used to get text representation of each error
    var message: String {
        switch self {
        case .RESULT_ERROR_CONNECTION_ERROR: return "Connection error."
        case .RESULT_ERROR_PASSWORDS_SHOULD_MATCH: return "Passwords should match."
        case .RESULT_ERROR_FIELD_IS_EMPTY: return "Value of this field is required."
        case .RESULT_ERROR_INCORRECT_EMAIL: return "Incorrect email format."
        case .RESULT_ERROR_INCORRECT_LOGIN: return "Incorrect login."
        case .RESULT_ERROR_INCORRECT_PASSWORD: return "Incorrect password."
        case .RESULT_ERROR_EMAIL_EXISTS: return "User with provided email already exists."
        case .RESULT_ERROR_LOGIN_EXISTS: return "User with provided login already exists."
        case .RESULT_ERROR_ACTIVATION_EMAIL: return "Failed to send activation email. Please contact support."
        case .RESULT_ERROR_NOT_ACTIVATED: return "Please, activate this account. Open activation email."
        case .RESULT_ERROR_ALREADY_LOGIN: return "User already in the system."
        case .RESULT_ERROR_UNKNOWN: return "Unknown error. Please, contact support."
        case .RESULT_REGISTER_OK: return "You are registered. Activation email sent. Please, open it and activate your account."
        case .AUTHENTICATION_ERROR: return "Authentication error. Please, login again."
        }
    }
}
