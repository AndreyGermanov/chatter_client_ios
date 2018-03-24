//
//  LoginFormActions.swift
//  chatter_client_iosTests
//
//  Created by user on 23.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import XCTest
import ReSwift
import Starscream
import CryptoSwift
@testable import chatter_client_ios

class LoginFormActions: XCTestCase,MessageCenterResponseListener {
    
    var messageCenter: MessageCenter = MessageCenter()

    override func setUp() {
        super.setUp()
        appStore.dispatch(changeLoginAction(login:""))
        appStore.dispatch(changePasswordAction(password:""))
        appStore.dispatch(changeLoginFormConfirmPasswordAction(confirmPassword: ""))
        appStore.dispatch(changeLoginFormModeAction(mode:.LOGIN))
        appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator: false))
        appStore.dispatch(changeLoginFormErrorsAction(errors:[String:LoginFormError]()))
        appStore.dispatch(changeEmailAction(email:""))
        messageCenter.testingMode = true
        messageCenter.testingModeConnected = false
        messageCenter.lastRequestText = ""
        messageCenter.lastResponseText = ""
        messageCenter.lastResponseObject = nil
        messageCenter.lastReceivedFile = Data()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    //MARK: Unit tests
    func testChangeLoginFieldAction() {
        appStore.dispatch(changeLoginAction(login:"test"))
        XCTAssertEqual("test",appStore.state.loginForm.login)
    }
    
    func testChangeEmailFieldAction() {
        appStore.dispatch(changeEmailAction(email:"test"))
        XCTAssertEqual("test",appStore.state.loginForm.email)
    }
    
    func testChangePasswordFieldAction() {
        appStore.dispatch(changePasswordAction(password:"test"))
        XCTAssertEqual("test",appStore.state.loginForm.password)
    }
 
    func testChangeConfirmPasswordFieldAction() {
        appStore.dispatch(changeLoginFormConfirmPasswordAction(confirmPassword:"test"))
        XCTAssertEqual("test",appStore.state.loginForm.confirm_password)
    }
    
    func testChangeModeFieldAction() {
        appStore.dispatch(changeLoginFormErrorsAction(errors:["general":.RESULT_ERROR_CONNECTION_ERROR]))
        XCTAssertEqual(appStore.state.loginForm.errors["general"], LoginFormError.RESULT_ERROR_CONNECTION_ERROR,"Should contain error")
        appStore.dispatch(changeLoginFormModeAction(mode:.REGISTER))
        XCTAssertEqual(LoginFormMode.REGISTER,appStore.state.loginForm.mode,"Should switch to new mode")
        XCTAssertEqual(0,appStore.state.loginForm.errors.count,"Should reset all errors after switch to new mode")
    }
    
    func testChangeProgressIndicatorFieldAction() {
        appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator:true))
        XCTAssertEqual(true,appStore.state.loginForm.show_progress_indicator)
    }
    
    func testChangePopuMessageFieldAction() {
        appStore.dispatch(changeLoginFormPopupMessageAction(popupMessage:"Test message"))
        XCTAssertEqual("Test message",appStore.state.loginForm.popup_message)
    }

    func testChangeErrorsFieldAction() {
        var errors = [String:LoginFormError]()
        errors["general"] = LoginFormError.RESULT_ERROR_CONNECTION_ERROR
        appStore.dispatch(changeLoginFormErrorsAction(errors:errors))
        let result_errors = appStore.state.loginForm.errors
        XCTAssertEqual(LoginFormError.RESULT_ERROR_CONNECTION_ERROR,result_errors["general"])
        XCTAssertEqual(result_errors["general"]?.message,"Connection error.","Should return correct error description")
    }
    
    //MARK: Features tests
    
    /**
     * Test user register feature
     */
    func testRegisterUserAction() {
        messageCenter.testingMode = true
        // Form validation tests
        registerUserAction(messageCenter: messageCenter).exec()
        XCTAssertEqual(appStore.state.loginForm.errors["login"],LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY,
                     "Should return empty field error if no data provided")
        appStore.dispatch(changeLoginAction(login: "test"))
        registerUserAction(messageCenter:messageCenter).exec()
        XCTAssertEqual(appStore.state.loginForm.errors["email"],LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY,
                       "Should return empty field error if no email provided")
        XCTAssertEqual(appStore.state.loginForm.errors["password"],LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY,
                       "Should return empty field error if no password provided")
        appStore.dispatch(changeEmailAction(email: "ertf33df"))
        registerUserAction(messageCenter:messageCenter).exec()
        XCTAssertEqual(appStore.state.loginForm.errors["email"],LoginFormError.RESULT_ERROR_INCORRECT_EMAIL,
                       "Should return incorrect field error if incorrect email provided")
        appStore.dispatch(changeEmailAction(email:"ema@test.com"))
        appStore.dispatch(changeLoginFormConfirmPasswordAction(confirmPassword: "123"))
        registerUserAction(messageCenter:messageCenter).exec()
        XCTAssertEqual(appStore.state.loginForm.errors["password"],LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY,
            "Should return empty field error if no password provided")
        appStore.dispatch(changePasswordAction(password: "233"))
        registerUserAction(messageCenter:messageCenter).exec()
        XCTAssertEqual(appStore.state.loginForm.errors["password"],LoginFormError.RESULT_ERROR_PASSWORDS_SHOULD_MATCH,
                       "Should return empty field error if password and confirm password do not match")
        appStore.dispatch(changePasswordAction(password:"123"))
        registerUserAction(messageCenter:messageCenter).exec()
        // Check server connection
        XCTAssertEqual(appStore.state.loginForm.errors["general"],LoginFormError.RESULT_ERROR_CONNECTION_ERROR,
                       "Should return server connection error if not connected")
        messageCenter.testingModeConnected = true
        registerUserAction(messageCenter:messageCenter).exec()
        XCTAssertEqual(0,appStore.state.loginForm.errors.count,"Should clear all errors if data validated")
        XCTAssertEqual(true,appStore.state.loginForm.show_progress_indicator,
                        "Should show progress indicator before sending request to server")
        XCTAssertEqual(1,messageCenter.pendingRequests.count,"Should add request to pendingRequests queue")
        messageCenter.processPendingRequests()
        XCTAssertEqual(0,messageCenter.pendingRequests.count,"Should remove request from pendingRequests queue")
        XCTAssertEqual(1,messageCenter.requestsWaitingResponses.count,"Should add request to requestsWaitingResponses queue")
        // Check reaction to server responses
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: "BOO")
        XCTAssertEqual(true,appStore.state.loginForm.show_progress_indicator,"Should not react to incorrect server responses")
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: "{}")
        XCTAssertEqual(true,appStore.state.loginForm.show_progress_indicator,"Should not react to incorrect server responses")
        var response = [
            "request_id": "12345",
            "action":"register_user"
        ]
        var responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(true,appStore.state.loginForm.show_progress_indicator,"Should not react to responses with incorrect request_id")
        var request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive error")
        XCTAssertEqual(false,appStore.state.loginForm.show_progress_indicator,"Should remove progress indicator after receive error")
        XCTAssertEqual(LoginFormError.RESULT_ERROR_UNKNOWN,appStore.state.loginForm.errors["general"]!,
                       "Should receive UNKNOWN_ERROR if status of responses does not exist")
        registerUserAction(messageCenter:messageCenter).exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "error"
        response["status_code"] = "BOO!"
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive error")
        XCTAssertEqual(false,appStore.state.loginForm.show_progress_indicator,"Should remove progress indicator after receive error")
        XCTAssertEqual(LoginFormError.RESULT_ERROR_UNKNOWN,appStore.state.loginForm.errors["general"]!,
                       "Should receive UNKNOWN_ERROR if status_code of response is incorrect")
        registerUserAction(messageCenter:messageCenter).exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "error"
        response["status_code"] = "RESULT_ERROR_ACTIVATION_EMAIL"
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive error")
        XCTAssertEqual(false,appStore.state.loginForm.show_progress_indicator,"Should remove progress indicator after receive error")
        XCTAssertEqual(LoginFormError.RESULT_ERROR_ACTIVATION_EMAIL, appStore.state.loginForm.errors["general"]!,
                       "Should receive correct error object if status_code is correct")
        registerUserAction(messageCenter:messageCenter).exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "ok"
        response["status_code"] = "RESULT_OK"
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after success")
        XCTAssertEqual(false,appStore.state.loginForm.show_progress_indicator,"Should remove progress indicator after receive error")
        XCTAssertEqual(LoginFormMode.LOGIN,appStore.state.loginForm.mode,"Should switch to LOGIN screen")
        XCTAssertEqual(0,appStore.state.loginForm.errors.count,"Should remove all errors")
        XCTAssertEqual(LoginFormError.RESULT_REGISTER_OK.message,appStore.state.loginForm.popup_message,"Should show activation popup message")
    }

    /**
     * Test user login feature
     */
    func testLoginUserAction() {
        messageCenter.testingMode = true
        // Form validation tests
        loginUserAction(messageCenter: messageCenter).exec()
        XCTAssertEqual(appStore.state.loginForm.errors["login"],LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY,
                       "Should return empty field error if no data provided")
        appStore.dispatch(changeLoginAction(login: "test"))
        loginUserAction(messageCenter:messageCenter).exec()
        XCTAssertEqual(appStore.state.loginForm.errors["password"],LoginFormError.RESULT_ERROR_FIELD_IS_EMPTY,
                       "Should return empty field error if no password provided")
        appStore.dispatch(changePasswordAction(password: "test"))
        loginUserAction(messageCenter:messageCenter).exec()
        // Check server connection
        XCTAssertEqual(appStore.state.loginForm.errors["general"],LoginFormError.RESULT_ERROR_CONNECTION_ERROR,
                       "Should return server connection error if not connected")
        messageCenter.testingModeConnected = true
        loginUserAction(messageCenter:messageCenter).exec()
        XCTAssertEqual(0,appStore.state.loginForm.errors.count,"Should clear all errors if data validated")
        XCTAssertEqual(true,appStore.state.loginForm.show_progress_indicator,
                       "Should show progress indicator before sending request to server")
        XCTAssertEqual(1,messageCenter.pendingRequests.count,"Should add request to pendingRequests queue")
        messageCenter.processPendingRequests()
        XCTAssertEqual(0,messageCenter.pendingRequests.count,"Should remove request from pendingRequests queue")
        XCTAssertEqual(1,messageCenter.requestsWaitingResponses.count,"Should add request to requestsWaitingResponses queue")
        // Check reaction to server responses
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: "BOO")
        XCTAssertEqual(true,appStore.state.loginForm.show_progress_indicator,"Should not react to incorrect server responses")
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: "{}")
        XCTAssertEqual(true,appStore.state.loginForm.show_progress_indicator,"Should not react to incorrect server responses")
        var response:[String:Any] = [
            "request_id": "12345",
            "action":"login_user"
        ]
        var responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(true,appStore.state.loginForm.show_progress_indicator,"Should not react to responses with incorrect request_id")
        var request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive error")
        XCTAssertEqual(false,appStore.state.loginForm.show_progress_indicator,"Should remove progress indicator after receive error")
        XCTAssertEqual(LoginFormError.RESULT_ERROR_UNKNOWN,appStore.state.loginForm.errors["general"]!,
                       "Should receive UNKNOWN_ERROR if status of responses does not exist")
        loginUserAction(messageCenter:messageCenter).exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "error"
        response["status_code"] = "BOO!"
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive error")
        XCTAssertEqual(false,appStore.state.loginForm.show_progress_indicator,"Should remove progress indicator after receive error")
        XCTAssertEqual(LoginFormError.RESULT_ERROR_UNKNOWN,appStore.state.loginForm.errors["general"]!,
                       "Should receive UNKNOWN_ERROR if status_code of response is incorrect")
        loginUserAction(messageCenter:messageCenter).exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "error"
        response["status_code"] = "RESULT_ERROR_INCORRECT_LOGIN"
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive error")
        XCTAssertEqual(false,appStore.state.loginForm.show_progress_indicator,"Should remove progress indicator after receive error")
        XCTAssertEqual(LoginFormError.RESULT_ERROR_INCORRECT_LOGIN, appStore.state.loginForm.errors["general"]!,
                       "Should receive correct error object if status_code is correct")
        loginUserAction(messageCenter:messageCenter).exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "ok"
        response["user_id"] = "u1"
        response["session_id"] = "s1"
        response["login"] = "test"
        response["email"] = "test@test.com"
        response["first_name"] = "Bob"
        response["last_name"] = "Johnson"
        response["gender"] = "F"
        response["birthDate"] = "1234567890"
        let rooms:[[String:String]] = [["_id":"r1","name":"Room 1"],["_id":"r2","name":"Room 2"]]
        response["rooms"] = rooms
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        var userState = appStore.state.user
        var profileState = appStore.state.userProfile
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses")
        XCTAssertEqual(false,appStore.state.loginForm.show_progress_indicator,"Should remove progress indicator")
        XCTAssertEqual(AppScreens.USER_PROFILE,appStore.state.current_activity,"Should move to User profile screen if no default_room returned")
        XCTAssertEqual("u1",userState.user_id,"Should set correct user_id to User state")
        XCTAssertEqual("s1",userState.session_id,"Should set correct session_id User state")
        XCTAssertEqual("test",userState.login,"Should set correct login to User state")
        XCTAssertEqual("test",profileState.login,"Should set correct login to User profile")
        XCTAssertEqual("test@test.com",userState.email,"Should set correct email to User state")
        XCTAssertEqual("Bob",userState.first_name,"Should set correct first_name to User state")
        XCTAssertEqual("Johnson",userState.last_name,"Should set correct last_name to User state")
        XCTAssertEqual(Gender.F,userState.gender,"Should set correct gender to User state")
        XCTAssertEqual(1234567890,userState.birthDate,"Should set correct birthDate to User state")
        XCTAssertEqual("Bob",profileState.first_name,"Should set correct first_name to User profile")
        XCTAssertEqual("Johnson",profileState.last_name,"Should set correct last_name to User profile")
        XCTAssertEqual(Gender.F,profileState.gender,"Should set correct gender to User profile")
        XCTAssertEqual(1234567890,profileState.birthDate,"Should set correct birthDate to User profile")
        XCTAssertEqual("Room 2",profileState.rooms[1]["name"],"Should set correct rooms to User Profile")
        loginUserAction(messageCenter:messageCenter).exec()
        let bundle = Bundle.main
        let path = bundle.path(forResource: "apple", ofType: "png")!
        let data = try! Data.init(contentsOf: URL.init(fileURLWithPath: path, isDirectory: false))
        let checksum = Int(data.bytes.crc32())
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "ok"
        response["checksum"] = checksum
        response["default_room"] = "r1"
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses")
        XCTAssertEqual(true,appStore.state.loginForm.show_progress_indicator,"Should wait for profile image file")
        messageCenter.websocketDidReceiveData(socket: messageCenter.ws, data: data)
        XCTAssertEqual(AppScreens.CHAT,appStore.state.current_activity,"Should move to User profile screen if no default_room returned")
        userState = appStore.state.user
        profileState = appStore.state.userProfile
        XCTAssertNotNil(userState.profileImage,"Should set profile image to User")
        XCTAssertNotNil(profileState.profileImage,"Should set profile image to User profile")
        XCTAssertEqual(checksum,Int(userState.profileImage!.bytes.crc32()),"Should set correct profile image to User")
        XCTAssertEqual(checksum,Int(profileState.profileImage!.bytes.crc32()),"Should set correct profile image to User Profile")
        XCTAssertEqual(0,messageCenter.receivedFiles.count,"Should remove request from receivedFiels queue")
        XCTAssertEqual(0,messageCenter.responsesWaitingFile.count,"Should remove request from responsesWaitingFile queue")
        XCTAssertTrue(userState.isLogin,"Should switch user login status to TRUE")
    }
    
    func handleWebSocketResponse(request_id: String, response: [String : Any]) {
        
    }
}
