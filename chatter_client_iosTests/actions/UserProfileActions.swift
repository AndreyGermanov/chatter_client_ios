//
//  UserProfileActions.swift
//  chatter_client_iosTests
//
//  Created by user on 24.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import XCTest
import ReSwift
import Starscream
@testable import chatter_client_ios

class UserProfileActions: XCTestCase {
    
    var messageCenter: MessageCenter = MessageCenter()
    
    override func setUp() {
        super.setUp()
        appStore.dispatch(changeUserProfileLoginAction(login:""))
        appStore.dispatch(changeUserProfileFirstNameAction(firstName: ""))
        appStore.dispatch(changeUserProfileLastNameAction(lastName: ""))
        appStore.dispatch(changeUserProfileGenderAction(gender: .M))
        appStore.dispatch(changeUserProfileBirthDateAction(birthDate: 0))
        appStore.dispatch(changeUserProfileProfileImageAction(profileImage: nil))
        appStore.dispatch(changeUserProfilePasswordAction(password: ""))
        appStore.dispatch(changeUserProfileConfirmPasswordAction(confirmPassword: ""))
        appStore.dispatch(changeUserProfileShowProgressIndicatorAction(showProgressIndicator: false))
        appStore.dispatch(changeUserProfileDefaultRoomAction(defaultRoom: ""))
        appStore.dispatch(changeUserProfileRoomsAction(rooms: [[String:String]]()))
        appStore.dispatch(changeUserProfileErrorsAction(errors: [String:UserProfileError]()))
        appStore.dispatch(changeUserProfilePopupMessageAction(popupMessage: ""))
        appStore.dispatch(ChangeActivityAction(activity: .USER_PROFILE))
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
        appStore.dispatch(changeUserProfileLoginAction(login:"test"))
        XCTAssertEqual("test",appStore.state.userProfile.login)
    }
    
    func testChangePopupMessageFieldAction() {
        appStore.dispatch(changeUserProfilePopupMessageAction(popupMessage:"test"))
        XCTAssertEqual("test",appStore.state.userProfile.popup_message)
    }
    
    func testChangeFirstNameFieldAction() {
        appStore.dispatch(changeUserProfileFirstNameAction(firstName:"test"))
        XCTAssertEqual("test",appStore.state.userProfile.first_name)
    }
    
    func testChangeLastNameFieldAction() {
        appStore.dispatch(changeUserProfileLastNameAction(lastName:"test"))
        XCTAssertEqual("test",appStore.state.userProfile.last_name)
    }
    
    func testChangeGenderFieldAction() {
        appStore.dispatch(changeUserProfileGenderAction(gender:.F))
        XCTAssertEqual(Gender.F,appStore.state.userProfile.gender)
    }
    
    func testChangeBirthDateFieldAction() {
        appStore.dispatch(changeUserProfileBirthDateAction(birthDate:1234567890))
        XCTAssertEqual(1234567890,appStore.state.userProfile.birthDate)
    }
    
    func testChangeShowProgressIndicatorFieldAction() {
        appStore.dispatch(changeUserProfileShowProgressIndicatorAction(showProgressIndicator:true))
        XCTAssertEqual(true,appStore.state.userProfile.show_progress_indicator)
    }
    
    func testChangeShowDatePickerDialogFieldAction() {
        appStore.dispatch(changeUserProfileShowDatePickerDialogAction(showDatePickerDialog:true))
        XCTAssertEqual(true,appStore.state.userProfile.show_date_picker_dialog)
    }
    
    func testChangeDefaultRoomFieldAction() {
        appStore.dispatch(changeUserProfileDefaultRoomAction(defaultRoom:"test"))
        XCTAssertEqual("test",appStore.state.userProfile.default_room)
    }
    
    func testChangePasswordFieldAction() {
        appStore.dispatch(changeUserProfilePasswordAction(password:"test"))
        XCTAssertEqual("test",appStore.state.userProfile.password)
    }
    
    func testChangeConfirmPasswordFieldAction() {
        appStore.dispatch(changeUserProfileConfirmPasswordAction(confirmPassword:"test"))
        XCTAssertEqual("test",appStore.state.userProfile.confirm_password)
    }
    
    func testChangeProfileImageFieldAction() {
        do {
            let bundle = Bundle.main
            let path = bundle.path(forResource: "apple", ofType: "png")!
            let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path, isDirectory: false))
            let checksum = data.crc32()
            appStore.dispatch(changeUserProfileImageAction(profileImage:data))
            XCTAssertEqual(checksum, appStore.state.user.profileImage?.crc32())
        } catch {
            XCTFail("Could not load image from resource")
        }
    }
    
    func testChangeRoomsFieldAction() {
        appStore.dispatch(changeUserProfileRoomsAction(rooms:[["_id":"r1","name":"Room1"],["_id":"r2","name":"Room 2"],["_id":"r3","name":"Room 3"]]))
        XCTAssertEqual(3, appStore.state.userProfile.rooms.count)
        XCTAssertEqual("r2",appStore.state.userProfile.rooms[1]["_id"])
    }
    
    func testErrorsFieldAction() {
        appStore.dispatch(changeUserProfileErrorsAction(errors:["general":.RESULT_ERROR_CONNECTION_ERROR]))
        XCTAssertEqual(UserProfileError.RESULT_ERROR_CONNECTION_ERROR, appStore.state.userProfile.errors["general"])
    }
    
    /**
     * Test user profile update feature
     */
    func testUpdateUserProfileAction() {
        // Setup initial state
        messageCenter.testingMode = true
        let bundle = Bundle.main
        var path = bundle.path(forResource: "profile", ofType: "png")!
        var data = try! Data.init(contentsOf: URL.init(fileURLWithPath: path, isDirectory: false))
        appStore.dispatch(changeUserLoginAction(login:"test"))
        appStore.dispatch(changeUserFirstNameAction(firstName: "Bob"))
        appStore.dispatch(changeUserLastNameAction(lastName: "Johnson"))
        appStore.dispatch(changeUserGenderAction(gender: .M))
        appStore.dispatch(changeUserBirthDateAction(birthDate: 1234567890))
        appStore.dispatch(changeUserProfileImageAction(profileImage: nil))
        appStore.dispatch(changeUserDefaultRoomAction(default_room: "r1"))
        appStore.dispatch(changeUserProfileImageAction(profileImage: data))
        // Form validation tests
        appStore.dispatch(changeUserProfileLoginAction(login:"test"))
        appStore.dispatch(changeUserProfileFirstNameAction(firstName: "Bob"))
        appStore.dispatch(changeUserProfileLastNameAction(lastName: "Johnson"))
        appStore.dispatch(changeUserProfileGenderAction(gender: .M))
        appStore.dispatch(changeUserProfileBirthDateAction(birthDate: 1234567890))
        appStore.dispatch(changeUserProfileProfileImageAction(profileImage: nil))
        appStore.dispatch(changeUserProfilePasswordAction(password: ""))
        appStore.dispatch(changeUserProfileConfirmPasswordAction(confirmPassword: ""))
        appStore.dispatch(changeUserProfileDefaultRoomAction(defaultRoom: "r1"))
        appStore.dispatch(changeUserProfileRoomsAction(rooms: [["_id":"r1","name":"Room 1"],["_id":"r2","name":"Room 2"],["_id":"r3","name":"Room 3"]]))
        _ = updateUserProfileAction().exec()
        XCTAssertEqual(UserProfileError.RESULT_ERROR_INCORRECT_SESSION_ID, appStore.state.userProfile.errors["general"]!,
                       "Should return incorrect user_id error if user did not login")
        appStore.dispatch(changeUserSessionIdAction(session_id:"12345"))
        _ = updateUserProfileAction().exec()
        XCTAssertEqual(UserProfileError.RESULT_ERROR_INCORRECT_USER_ID, appStore.state.userProfile.errors["general"]!,
                       "Should return incorrect session_id if user did not login")
        appStore.dispatch(changeUserUserIdAction(user_id: "54321"))
        _ = updateUserProfileAction().exec()
        XCTAssertEqual(UserProfileError.RESULT_ERROR_EMPTY_REQUEST, appStore.state.userProfile.errors["general"]!,
                       "Should return 'Empty request error if user submit without changing anything")
        _ = updateUserProfileAction().exec()
        appStore.dispatch(changeUserProfileLoginAction(login:""))
        _ = updateUserProfileAction().exec()
        XCTAssertEqual(UserProfileError.RESULT_ERROR_FIELD_IS_EMPTY, appStore.state.userProfile.errors["login"]!,
                       "Should not submit if login no specified")
        appStore.dispatch(changeUserProfileLoginAction(login:"test"))
        appStore.dispatch(changeUserProfileFirstNameAction(firstName: ""))
        _ = updateUserProfileAction().exec()
        XCTAssertEqual(UserProfileError.RESULT_ERROR_FIELD_IS_EMPTY, appStore.state.userProfile.errors["first_name"]!,
                       "Should not submit if no fist_name specified")
        appStore.dispatch(changeUserProfileLastNameAction(lastName: ""))
        appStore.dispatch(changeUserProfileBirthDateAction(birthDate: 0))
        appStore.dispatch(changeUserProfileDefaultRoomAction(defaultRoom: ""))
        appStore.dispatch(changeUserProfilePasswordAction(password: "3434"))
        _ = updateUserProfileAction().exec()
        XCTAssertEqual(UserProfileError.RESULT_ERROR_FIELD_IS_EMPTY, appStore.state.userProfile.errors["last_name"]!,
                       "Should not submit if no last_name specified")
        XCTAssertEqual(UserProfileError.RESULT_ERROR_INCORRECT_FIELD_VALUE, appStore.state.userProfile.errors["birthDate"]!,
                       "Should not submit with incorrect birthDate")
        XCTAssertEqual(UserProfileError.RESULT_ERROR_FIELD_IS_EMPTY, appStore.state.userProfile.errors["default_room"]!,
                       "Should not submit without default_rooom")
        XCTAssertEqual(UserProfileError.RESULT_ERROR_PASSWORDS_SHOULD_MATCH, appStore.state.userProfile.errors["password"]!,
                       "Should one of password and confirm password is empty")
        appStore.dispatch(changeUserProfileFirstNameAction(firstName:"John"))
        appStore.dispatch(changeUserProfileLastNameAction(lastName:"Johnson"))
        appStore.dispatch(changeUserProfileGenderAction(gender:.M))
        appStore.dispatch(changeUserProfileBirthDateAction(birthDate:1234567890))
        appStore.dispatch(changeUserProfileDefaultRoomAction(defaultRoom:"r7"))
        appStore.dispatch(changeUserProfileConfirmPasswordAction(confirmPassword:"3435"))
        _ = updateUserProfileAction(messageCenter:messageCenter).exec()
        XCTAssertEqual(UserProfileError.RESULT_ERROR_INCORRECT_FIELD_VALUE, appStore.state.userProfile.errors["default_room"]!,
                       "Should not submit if specified default_room is not in list of available rooms")
        XCTAssertEqual(UserProfileError.RESULT_ERROR_PASSWORDS_SHOULD_MATCH, appStore.state.userProfile.errors["password"]!,
                       "Should not submit if specified confirm_password is not equal to password")
        appStore.dispatch(changeUserProfileConfirmPasswordAction(confirmPassword:"3434"))
        appStore.dispatch(changeUserProfileDefaultRoomAction(defaultRoom:"r2"))
        _ = updateUserProfileAction(messageCenter:messageCenter).exec()
        XCTAssertEqual(UserProfileError.RESULT_ERROR_CONNECTION_ERROR,appStore.state.userProfile.errors["general"]!,
                       "Should return connection error if not connected to server")
        // Request building and sending to server tests
        messageCenter.testingModeConnected = true
        path = bundle.path(forResource: "apple", ofType: "png")!
        data = try! Data.init(contentsOf: URL.init(fileURLWithPath: path, isDirectory: false))
        appStore.dispatch(changeUserProfileProfileImageAction(profileImage: data))
        let request_to_send = updateUserProfileAction(messageCenter:messageCenter).exec()!
        XCTAssertEqual(appStore.state.user.user_id, request_to_send["user_id"] as! String,
                       "Should set correct user_id to request")
        XCTAssertEqual(appStore.state.user.session_id,request_to_send["session_id"] as! String,
                      "Should set correct session_id to request")
        XCTAssertNotNil(request_to_send["sender"],"Request should contain link to sener object")
        XCTAssertEqual(request_to_send["first_name"] as! String,"John","Should send changed First Name")
        XCTAssertEqual(request_to_send["default_room"] as! String,"r2","Should send changed Default room")
        XCTAssertEqual(request_to_send["password"] as! String,"3434","Should send changed password")
        XCTAssertEqual(request_to_send["confirm_password"] as! String,"3434","Should send changed confirm password")
        XCTAssertEqual(Int(data.bytes.crc32()), request_to_send["profile_image_checksum"] as! Int,
                       "Should set correct checksum of profile image to send")
        XCTAssertNotNil(request_to_send["profile_image"],"Should send profile image if it changed")
        XCTAssertNil(request_to_send["login"],"Should not send the same login")
        XCTAssertNil(request_to_send["last_name"],"Should not send the same last name")
        XCTAssertNil(request_to_send["gender"],"Should not send the same gender")
        XCTAssertNil(request_to_send["birthDate"],"Should not send the same birthDate")
        XCTAssertEqual(1,messageCenter.pendingRequests.count,"Should add message to pending requests queue")
        XCTAssertEqual(true, appStore.state.userProfile.show_progress_indicator,"Should show progress indicator")
        messageCenter.processPendingRequests()
        XCTAssertEqual(0,messageCenter.pendingRequests.count,"Should remove request from pending requests queue")
        XCTAssertEqual(1, messageCenter.requestsWaitingResponses.count,"Should add request to requests waiting responses queue")
        // Check reaction to server responses
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: "BOO")
        XCTAssertEqual(true,appStore.state.userProfile.show_progress_indicator,"Should not react to incorrect server responses")
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: "{}")
        XCTAssertEqual(true,appStore.state.userProfile.show_progress_indicator,"Should not react to incorrect server responses")
        var response:[String:Any] = [
            "request_id": "12345",
            "action":"update_user"
        ]
        var responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(true,appStore.state.userProfile.show_progress_indicator,"Should not react to responses with incorrect request_id")
        var request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive error")
        XCTAssertEqual(false,appStore.state.userProfile.show_progress_indicator,"Should remove progress indicator after receive error")
        XCTAssertEqual(UserProfileError.RESULT_ERROR_UNKNOWN,appStore.state.userProfile.errors["general"]!,
                       "Should receive UNKNOWN_ERROR if status of responses does not exist")
        _ = updateUserProfileAction(messageCenter:messageCenter).exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "error"
        response["status_code"] = "BOO!"
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive error")
        XCTAssertEqual(false,appStore.state.userProfile.show_progress_indicator,"Should remove progress indicator after receive error")
        XCTAssertEqual(UserProfileError.RESULT_ERROR_UNKNOWN,appStore.state.userProfile.errors["general"]!,
                       "Should receive UNKNOWN_ERROR if status_code of response is incorrect")
        _ = updateUserProfileAction(messageCenter:messageCenter).exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "error"
        response["status_code"] = "INTERNAL_ERROR"
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive error")
        XCTAssertEqual(false,appStore.state.userProfile.show_progress_indicator,"Should remove progress indicator after receive error")
        XCTAssertEqual(UserProfileError.INTERNAL_ERROR, appStore.state.userProfile.errors["general"]!,
                       "Should receive correct error object if status_code is correct")
        
        _ = updateUserProfileAction(messageCenter:messageCenter).exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "error"
        response["status_code"] = "RESULT_ERROR_IMAGE_UPLOAD"
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive error")
        XCTAssertEqual(false,appStore.state.userProfile.show_progress_indicator,"Should remove progress indicator after receive error")
        XCTAssertEqual(UserProfileError.RESULT_ERROR_IMAGE_UPLOAD, appStore.state.userProfile.errors["general"]!,
                       "Should receive correct error object if status_code is correct")
        
        _ = updateUserProfileAction(messageCenter:messageCenter).exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "error"
        response["status_code"] = "RESULT_ERROR_PASSWORDS_SHOULD_MATCH"
        response["field"] = "password"
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive error")
        XCTAssertEqual(false,appStore.state.userProfile.show_progress_indicator,"Should remove progress indicator after receive error")
        print(appStore.state.userProfile.errors)
        XCTAssertEqual(UserProfileError.RESULT_ERROR_PASSWORDS_SHOULD_MATCH, appStore.state.userProfile.errors["password"]!,
                       "Should receive correct error object if status_code is correct")

        _ = updateUserProfileAction(messageCenter:messageCenter).exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"] as! String
        response["request_id"] = request_id
        response["status"] = "ok"
        responseString = try! String(data:JSONSerialization.data(withJSONObject:response,options: .sortedKeys),encoding: .utf8)!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseString)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses after receive success response")
        XCTAssertEqual(false,appStore.state.userProfile.show_progress_indicator,"Should remove progress indicator after receive success response")
        XCTAssertEqual(appStore.state.current_activity,AppScreens.CHAT,"Should move to Chat screen")
        XCTAssertEqual("", appStore.state.userProfile.password,"Should reset password after receive response")
        XCTAssertEqual("", appStore.state.userProfile.confirm_password,"Should reset confirm password after receive response")
        XCTAssertEqual("John",appStore.state.user.first_name,"Should change user first_name in user state")
        XCTAssertEqual("Johnson", appStore.state.user.last_name,"Should not change user last_name in user state")
        XCTAssertEqual("test",appStore.state.user.login,"Should not change login in user state")
        XCTAssertEqual(Gender.M,appStore.state.user.gender, "Should not change gender in user state")
        XCTAssertEqual("r2",appStore.state.user.default_room,"Should change default_room in user state")
        XCTAssertEqual(data.bytes.crc32(),appStore.state.user.profileImage!.bytes.crc32(),"Should change profileImage in user state")
    }
    
    /**
     * Test user profile cancel update feature
     */
    func testCancelUpdateUserProfileAction() {
        // Setup initial state
        messageCenter.testingMode = true
        let bundle = Bundle.main
        let path = bundle.path(forResource: "profile", ofType: "png")!
        let data = try! Data.init(contentsOf: URL.init(fileURLWithPath: path, isDirectory: false))
        appStore.dispatch(changeUserLoginAction(login:"test"))
        appStore.dispatch(changeUserFirstNameAction(firstName: "Bob"))
        appStore.dispatch(changeUserLastNameAction(lastName: "Johnson"))
        appStore.dispatch(changeUserGenderAction(gender: .M))
        appStore.dispatch(changeUserBirthDateAction(birthDate: 1234567890))
        appStore.dispatch(changeUserProfileImageAction(profileImage: data))
        appStore.dispatch(changeUserDefaultRoomAction(default_room: ""))
        appStore.dispatch(changeUserProfileImageAction(profileImage: data))
        // Test error responses
        cancelUserProfileUpdateAction().exec()
        XCTAssertEqual(UserProfileError.RESULT_ERROR_FIELD_IS_EMPTY, appStore.state.userProfile.errors["default_room"]!,
                       "Should return error about empty default_room field")
        XCTAssertEqual(AppScreens.USER_PROFILE, appStore.state.current_activity,
                       "Should not allow to move away from User profile screen in case of errors")
        // Test successfull response
        appStore.dispatch(changeUserDefaultRoomAction(default_room: "r2"))
        appStore.dispatch(changeUserProfilePasswordAction(password: "12345"))
        appStore.dispatch(changeUserProfileConfirmPasswordAction(confirmPassword: "52134"))
        cancelUserProfileUpdateAction().exec()
        XCTAssertEqual(AppScreens.CHAT,appStore.state.current_activity,"Should move to CHAT screen")
        let state = appStore.state.userProfile
        XCTAssertEqual("test", state.login,"Should revert login field")
        XCTAssertEqual("Bob",state.first_name,"Should revert first_name")
        XCTAssertEqual("Johnson", state.last_name,"Should revert last_name")
        XCTAssertEqual("r2", state.default_room,"Should revert default_room")
        XCTAssertEqual(Gender.M, state.gender, "Shold revert gender")
        XCTAssertEqual(1234567890,state.birthDate,"Should revert birthDate")
        XCTAssertEqual(data.bytes.crc32(), state.profileImage?.bytes.crc32(),"Should revert profileImage")
        XCTAssertEqual("",state.password,"Should clean password field")
        XCTAssertEqual("", state.confirm_password,"Should clean confirm_password")
    }
    
}
