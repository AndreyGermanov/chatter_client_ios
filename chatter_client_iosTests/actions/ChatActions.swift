//
//  ChatActions.swift
//  chatter_client_iosTests
//
//  Created by user on 23.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import XCTest
@testable import chatter_client_ios

class ChatActions: XCTestCase {
 
    var messageCenter: MessageCenter = (UIApplication.shared.delegate as! AppDelegate).msgCenter
    
    override func setUp() {
        super.setUp()
        appStore.dispatch(UserState.changeUserLoginAction(login:""))
        appStore.dispatch(UserState.changeUserEmailAction(email:""))
        appStore.dispatch(UserState.changeUserFirstNameAction(firstName: ""))
        appStore.dispatch(UserState.changeUserLastNameAction(lastName: ""))
        appStore.dispatch(UserState.changeUserGenderAction(gender: .M))
        appStore.dispatch(UserState.changeUserBirthDateAction(birthDate: 0))
        appStore.dispatch(UserState.changeUserProfileImageAction(profileImage: nil))
        appStore.dispatch(UserState.changeUserUserIdAction(user_id: ""))
        appStore.dispatch(UserState.changeUserSessionIdAction(session_id: ""))
        appStore.dispatch(UserState.changeUserIsLoginAction(isLogin: false))
        appStore.dispatch(UserState.changeUserDefaultRoomAction(default_room: ""))
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
    
    func testLogout() {
        appStore.dispatch(UserState.changeUserLoginAction(login:"andrey"))
        appStore.dispatch(UserState.changeUserEmailAction(email:"test@test.com"))
        appStore.dispatch(UserState.changeUserFirstNameAction(firstName: "Andrey"))
        appStore.dispatch(UserState.changeUserLastNameAction(lastName: "Germanov"))
        appStore.dispatch(UserState.changeUserGenderAction(gender: .M))
        appStore.dispatch(UserState.changeUserBirthDateAction(birthDate: 1234567890))
        appStore.dispatch(UserState.changeUserProfileImageAction(profileImage: nil))
        appStore.dispatch(UserState.changeUserUserIdAction(user_id: "12345"))
        appStore.dispatch(UserState.changeUserSessionIdAction(session_id: "56789"))
        appStore.dispatch(UserState.changeUserIsLoginAction(isLogin: true))
        appStore.dispatch(UserState.changeUserDefaultRoomAction(default_room: "r1"))
        appStore.dispatch(AppState.ChangeActivityAction(activity: .CHAT))
        ChatState.logout().exec()
        XCTAssertEqual(ChatScreenError.RESULT_ERROR_CONNECTION_ERROR,appStore.state.chat.errors["general"],"Should return connection error")
        messageCenter.testingModeConnected = true
        ChatState.logout().exec()
        XCTAssertEqual(true,appStore.state.chat.showProgressIndicator,"Should show progress indicator before sending requet")
        XCTAssertEqual(1,messageCenter.pendingRequests.count,"Should add request to pending requests queue")
        messageCenter.processPendingRequests()
        var request_id = messageCenter.lastRequestObject["request_id"]!
        XCTAssertEqual(0,messageCenter.pendingRequests.count,"Should remove request from pending requests queue")
        XCTAssertEqual(1,messageCenter.requestsWaitingResponses.count,"Should add request to requestsWaitingResponse queue")
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text:
            """
            {"request_id":"\(request_id)","status_code":"BOBOO"}
            """)
        XCTAssertEqual(ChatScreenError.RESULT_ERROR_UNKNOWN_ERROR,appStore.state.chat.errors["general"],"Should contain unknown error")
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponse queue")
        ChatState.logout().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text:
            """
            {"request_id":"\(request_id)","status_code":"INTERNAL_ERROR","status":"error"}
            """)
        XCTAssertEqual(ChatScreenError.INTERNAL_ERROR,appStore.state.chat.errors["general"],"Should contain internal error")
        ChatState.logout().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text:
            """
            {"request_id":"\(request_id)","status_code":"RESULT_OK","status":"ok"}
            """)
        XCTAssertEqual(ChatScreenError.INTERNAL_ERROR,appStore.state.chat.errors["general"],"Should contain internal error")
        appStore.dispatch(UserState.changeUserLoginAction(login:""))
        appStore.dispatch(UserState.changeUserEmailAction(email:""))
        appStore.dispatch(UserState.changeUserFirstNameAction(firstName: ""))
        appStore.dispatch(UserState.changeUserLastNameAction(lastName: ""))
        appStore.dispatch(UserState.changeUserGenderAction(gender: .M))
        appStore.dispatch(UserState.changeUserBirthDateAction(birthDate: 0))
        appStore.dispatch(UserState.changeUserProfileImageAction(profileImage: nil))
        appStore.dispatch(UserState.changeUserUserIdAction(user_id: ""))
        appStore.dispatch(UserState.changeUserSessionIdAction(session_id: ""))
        appStore.dispatch(UserState.changeUserIsLoginAction(isLogin: false))
        appStore.dispatch(UserState.changeUserDefaultRoomAction(default_room: ""))
        appStore.dispatch(AppState.ChangeActivityAction(activity: .LOGIN_FORM))
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponse queue")
    }
}
