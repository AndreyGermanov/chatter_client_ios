//
//  LoginScreenActions.swift
//  chatter_client_ios
//
//  Actions for Login Screen reducer
//
//  Created by user on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import ReSwift

/// Base protocol for login form actions
protocol LoginFormAction : Action {}

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
    let errors:[String:LoginFormError]
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
struct registerUserAction: LoginFormAction,MessageCenterResponseListener {
    
    /// Link to message center instance, used to process request
    var messageCenter: MessageCenter = (UIApplication.shared.delegate as! AppDelegate).msgCenter
    
    /**
     * Method validates register form and send request to MessageCenter
     */
    func exec() {
        var errors = [String:LoginFormError]()
        appStore.dispatch(changeLoginFormErrorsAction(errors:errors))
        var state = appStore.state.loginForm
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
        if errors.count == 0 {
            if (!state.show_progress_indicator) {
                appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator:true))
                if let request = self.messageCenter.addToPendingRequests([
                    "sender": self,
                    "action": "register_user",
                    "login": state.login,
                    "email": state.email,
                    "password": state.password,
                    "confirm_password": state.confirm_password
                    ]) {
                    Logger.log(level:LogLevel.DEBUG,
                               message:"Added user registration request to MessageCenter pendingRequests queue. Request: \(request)",
                        className: "registerUserAction",methodName:"exec")
                } else {
                    Logger.log(level:LogLevel.WARNING,message:"Error constructing user register request for state: \(state)",
                        className:"registerUserAction",methodName:"exec")
                }
            } else {
                Logger.log(level:LogLevel.DEBUG,message:"Register action already in progress",
                           className: "registerUserAction",methodName:"exec")
            }
        } else {
            Logger.log(level:LogLevel.DEBUG,message:"Register form validation errors: \(errors)",
                className: "registerUserAction", methodName:"exec")
            appStore.dispatch(changeLoginFormErrorsAction(errors:errors))
        }
    }
    
    /**
     * Callback function, which called when MessageCenter receives response to request, which sent in "exec" method
     *
     * - Parameter request_id: Request ID, to which responses received
     * - Parameter response: Body of received response
     */
    func handleWebSocketResponse(request_id: String, response: [String : Any]) {
        Logger.log(level:LogLevel.DEBUG,
            message:"Received response to user registration request. Request ID: \(request_id), response body: \(response)",
            className:"registerUserAction",methodName:"handleWebSocketResponse")
        if let status = response["status"] as? String {
            if status == "ok" {
                appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
                appStore.dispatch(changeLoginFormErrorsAction(errors: [String:LoginFormError]()))
                appStore.dispatch(changeLoginFormPopupMessageAction(popupMessage: LoginFormError.RESULT_REGISTER_OK.message))
                appStore.dispatch(changeLoginFormModeAction(mode: .LOGIN))
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
                Logger.log(level:LogLevel.DEBUG,message:"User registration request \(request_id) processed successfully",
                    className:"registerUserAction",methodName:"handleWebSocketResponse")
            } else if status == "error" {
                if let status_code_string = response["status_code"] as? String {
                    if let status_code = LoginFormError(rawValue: status_code_string) {
                        appStore.dispatch(changeLoginFormErrorsAction(errors:["general":status_code]))
                        Logger.log(level:LogLevel.DEBUG,message:"User register error: \(status_code.rawValue)",
                            className:"registerUserAction",methodName:"handleWebSocketResponse")
                    } else {
                        appStore.dispatch(changeLoginFormErrorsAction(errors:["general":.RESULT_ERROR_UNKNOWN]))
                        Logger.log(level:LogLevel.DEBUG,message:"User register error: \(LoginFormError.RESULT_ERROR_UNKNOWN.rawValue)",
                            className:"registerUserAction",methodName:"handleWebSocketResponse")
                    }
                } else {
                    appStore.dispatch(changeLoginFormErrorsAction(errors:["general":.RESULT_ERROR_UNKNOWN]))
                    Logger.log(level:LogLevel.WARNING,message:"Server did not return correct status_code for request \(request_id)",
                        className:"registerUserAction",methodName:"handleWebSocketResponse")
                }
                appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
            } else  {
                appStore.dispatch(changeLoginFormErrorsAction(errors:["general":.RESULT_ERROR_UNKNOWN]))
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
                Logger.log(level:LogLevel.WARNING,message:"Server did not return correct status to user register request \(request_id)",
                    className:"registerUserAction",methodName:"handleWebSocketResponse")
            }
        } else {
            Logger.log(level:LogLevel.DEBUG,message:"Response for request \(request_id) does not contain 'status' field",
                className:"registerUserAction",methodName:"handleWebSocketResponse")
            _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
            appStore.dispatch(changeLoginFormErrorsAction(errors:["general":.RESULT_ERROR_UNKNOWN]))
            appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
        }
    }
}

/**
 * User login action. Used to validate login form, put user login request to MessageCenter
 * queue and process response from server
 */
struct loginUserAction: LoginFormAction,MessageCenterResponseListener {
    
    /// Link to message center instance, used to process request
    var messageCenter: MessageCenter = (UIApplication.shared.delegate as! AppDelegate).msgCenter
    
    /**
     * Method validates register form and send request to MessageCenter
     */
    func exec() {
        var errors = [String:LoginFormError]()
        appStore.dispatch(changeLoginFormErrorsAction(errors:errors))
        var state = appStore.state.loginForm
        state.login = state.login.trimmingCharacters(in: .whitespacesAndNewlines)
        state.password = state.password.trimmingCharacters(in: .whitespacesAndNewlines)
        if state.login.count==0 {
            errors["login"] = LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY
        }
        if state.password.count==0 {
            errors["password"] = LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY
        }
        if errors.count == 0 && !messageCenter.isConnected() {
            errors["general"] = LoginFormError.RESULT_ERROR_CONNECTION_ERROR
        }
        if errors.count == 0 {
            if (!state.show_progress_indicator) {
                appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator:true))
                if let request = self.messageCenter.addToPendingRequests([
                    "sender": self,
                    "action": "login_user",
                    "login": state.login,
                    "password": state.password,
                    ]) {
                    Logger.log(level:LogLevel.DEBUG,
                               message:"Added user login request to MessageCenter pendingRequests queue. Request: \(request)",
                        className: "loginUserAction",methodName:"exec")
                } else {
                    Logger.log(level:LogLevel.WARNING,message:"Error constructing user login request for state: \(state)",
                        className:"loginUserAction",methodName:"exec")
                }
            } else {
                Logger.log(level:LogLevel.DEBUG,message:"Login action already in progress",
                           className: "loginUserAction",methodName:"exec")
            }
        } else {
            Logger.log(level:LogLevel.DEBUG,message:"Login form validation errors: \(errors)",
                className: "loginUserAction", methodName:"exec")
            appStore.dispatch(changeLoginFormErrorsAction(errors:errors))
        }
    }
    
    /**
     * Callback function, which called when MessageCenter receives response to request, which sent in "exec" method
     *
     * - Parameter request_id: Request ID, to which responses received
     * - Parameter response: Body of received response
     */
    func handleWebSocketResponse(request_id: String, response: [String : Any]) {
        var response = response
        Logger.log(level:LogLevel.DEBUG,
                   message:"Received response to user login request. Request ID: \(request_id), response body: \(response)",
            className:"loginUserAction",methodName:"handleWebSocketResponse")
        if let status = response["status"] as? String {
            if status == "ok" {
                appStore.dispatch(changeLoginFormErrorsAction(errors: [String:LoginFormError]()))
                if response["checksum"] != nil {
                    var checksum = 0
                    if response["checksum"] is String {
                        checksum = Int(response["checksum"] as! String)!
                    } else if response["checksum"] is NSNumber {
                        checksum = Int(truncating: response["checksum"] as! NSNumber)
                    }
                    if let received_file = messageCenter.receivedFiles[checksum] as? [String:Any] {
                        Logger.log(level:LogLevel.DEBUG,message:"File witch checksum \(checksum) found in receivedFiles queue",
                            className:"loginUserAction",methodName:"handleWebSocketResponse")
                        if let profileImage = received_file["data"] as? Data {
                            appStore.dispatch(changeUserProfileProfileImageAction(profileImage: profileImage))
                            appStore.dispatch(changeUserProfileImageAction(profileImage:profileImage))
                            Logger.log(level:LogLevel.DEBUG,message:"Profile image download and set for \(request_id)",
                                className:"loginUserAction",methodName:"handleWebSocketResponse")
                            _ = messageCenter.removeFromReceivedFiles(checksum)
                            _ = messageCenter.removeFromResponsesWaitingFile(checksum)
                        } else {
                            Logger.log(level:LogLevel.DEBUG,message:"Could not set profile image from \(request_id)",
                                className:"loginUserAction",methodName:"handleWebSocketResponse")
                            _ = messageCenter.removeFromReceivedFiles(checksum)
                            _ = messageCenter.removeFromResponsesWaitingFile(checksum)                        }
                    } else {
                        Logger.log(level:LogLevel.DEBUG,message:"File with checksum \(checksum) not found in receivedFiles queue",
                            className:"loginUserAction",methodName:"handleWebSocketResponse")
                        _ = messageCenter.addToResponsesWaitingFile(checksum: checksum, response: response)
                        _ = messageCenter.removeFromRequestsWaitingResponses(request_id)
                        return
                    }
                } else {
                    
                }
                appStore.dispatch(changeUserIsLoginAction(isLogin: true))
                appStore.dispatch(changeUserLoginAction(login:response["login"] as! String))
                appStore.dispatch(changeUserEmailAction(email:response["email"] as! String))
                appStore.dispatch(changeUserProfileLoginAction(login:response["login"] as! String))
                appStore.dispatch(changeUserUserIdAction(user_id:response["user_id"] as! String))
                appStore.dispatch(changeUserSessionIdAction(session_id:response["session_id"] as! String))
                if let first_name = response["first_name"] as? String {
                    appStore.dispatch(changeUserFirstNameAction(firstName:first_name))
                    appStore.dispatch(changeUserProfileFirstNameAction(firstName:first_name))
                } else {
                    appStore.dispatch(changeUserFirstNameAction(firstName:""))
                    appStore.dispatch(changeUserProfileFirstNameAction(firstName:""))
                }
                if let last_name = response["last_name"] as? String {
                    appStore.dispatch(changeUserLastNameAction(lastName:last_name))
                    appStore.dispatch(changeUserProfileLastNameAction(lastName:last_name))
                } else {
                    appStore.dispatch(changeUserLastNameAction(lastName:""))
                    appStore.dispatch(changeUserProfileLastNameAction(lastName:""))
                }
                appStore.dispatch(changeUserGenderAction(gender:.M))
                appStore.dispatch(changeUserProfileGenderAction(gender:.M))
                if (response["gender"] != nil) {
                    if let gender = Gender(rawValue: response["gender"] as! String) {
                        appStore.dispatch(changeUserGenderAction(gender:gender))
                        appStore.dispatch(changeUserProfileGenderAction(gender:gender))
                    } else {
                        Logger.log(level:LogLevel.DEBUG,message:"Could not parse gender for request \(request_id). Received gender: \(response["gender"]!)",
                            className:"loginUserAction",methodName:"handleWebSocketResponse")
                    }                }
                appStore.dispatch(changeUserBirthDateAction(birthDate:0))
                appStore.dispatch(changeUserProfileBirthDateAction(birthDate:0))
                if response["birthDate"] != nil {
                    var birthDate = 0
                    if response["birthDate"] is String {
                        birthDate = Int(response["birthDate"] as! String)!
                    } else if response["birthDate"] is NSNumber {
                        birthDate = Int(truncating: response["birthDate"] as! NSNumber)
                    }
                    appStore.dispatch(changeUserBirthDateAction(birthDate:birthDate))
                    appStore.dispatch(changeUserProfileBirthDateAction(birthDate:birthDate))
                }
                appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
                var rooms_to_apply = [[String:String]]()
                appStore.dispatch(changeUserProfileRoomsAction(rooms: rooms_to_apply))
                if let rooms = response["rooms"] as? NSArray {
                    for room in rooms {
                        if let room = room as? [String:Any] {
                            if room["_id"] != nil && room["name"] != nil {
                                rooms_to_apply.append(["_id":room["_id"] as! String,"name":room["name"] as! String])
                            }
                        } else {
                            Logger.log(level:LogLevel.WARNING,message:"Could not decode room \(room) for \(request_id)",
                                className:"loginUserAction",methodName:"handleWebSocketResponse")
                        }
                    }
                    appStore.dispatch(changeUserProfileRoomsAction(rooms:rooms_to_apply))
                } else {
                    Logger.log(level:LogLevel.WARNING,message:"Could not decode rooms for request \(request_id). Rooms: \(response["rooms"]!)",
                        className:"loginUserAction",methodName:"handleWebSocketResponse")
                }
                if let default_room = response["default_room"] as? String {
                    appStore.dispatch(changeUserDefaultRoomAction(default_room: default_room))
                    appStore.dispatch(changeUserProfileDefaultRoomAction(defaultRoom: default_room))
                    appStore.dispatch(ChangeActivityAction(activity: .CHAT))
                } else {
                    appStore.dispatch(changeUserDefaultRoomAction(default_room: ""))
                    appStore.dispatch(changeUserProfileDefaultRoomAction(defaultRoom: ""))
                    appStore.dispatch(ChangeActivityAction(activity: .USER_PROFILE))
                }
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
                Logger.log(level:LogLevel.DEBUG,
                           message:"User login request \(request_id) processed successfully. User profile: \(appStore.state.userProfile). User state: \(appStore.state.user)",
                    className:"loginUserAction",methodName:"handleWebSocketResponse")
            } else if status == "error" {
                if let status_code_string = response["status_code"] as? String {
                    if let status_code = LoginFormError(rawValue: status_code_string) {
                        appStore.dispatch(changeLoginFormErrorsAction(errors:["general":status_code]))
                        Logger.log(level:LogLevel.DEBUG,message:"User login error: \(status_code.rawValue)",
                            className:"loginUserAction",methodName:"handleWebSocketResponse")
                    } else {
                        appStore.dispatch(changeLoginFormErrorsAction(errors:["general":.RESULT_ERROR_UNKNOWN]))
                        Logger.log(level:LogLevel.DEBUG,message:"User login error: \(LoginFormError.RESULT_ERROR_UNKNOWN.rawValue)",
                            className:"loginUserAction",methodName:"handleWebSocketResponse")
                    }
                } else {
                    appStore.dispatch(changeLoginFormErrorsAction(errors:["general":.RESULT_ERROR_UNKNOWN]))
                    Logger.log(level:LogLevel.WARNING,message:"Server did not return correct status_code for request \(request_id)",
                        className:"loginUserAction",methodName:"handleWebSocketResponse")
                }
                appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
            } else  {
                appStore.dispatch(changeLoginFormErrorsAction(errors:["general":.RESULT_ERROR_UNKNOWN]))
                _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
                Logger.log(level:LogLevel.WARNING,message:"Server did not return correct status to user login request \(request_id)",
                    className:"loginUserAction",methodName:"handleWebSocketResponse")
            }
        } else {
            Logger.log(level:LogLevel.DEBUG,message:"Response for request \(request_id) does not contain 'status' field",
                className:"loginUserAction",methodName:"handleWebSocketResponse")
            _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
            appStore.dispatch(changeLoginFormErrorsAction(errors:["general":.RESULT_ERROR_UNKNOWN]))
            appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
        }
    }
}

/// Login form error definitions
enum LoginFormError:String {
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
        }
    }
}
