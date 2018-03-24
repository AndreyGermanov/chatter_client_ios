//
//  UserActions.swift
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

class UserActions: XCTestCase {

    var messageCenter: MessageCenter = MessageCenter()
    
    override func setUp() {
        super.setUp()
        appStore.dispatch(changeUserLoginAction(login:""))
        appStore.dispatch(changeUserEmailAction(email:""))
        appStore.dispatch(changeUserFirstNameAction(firstName: ""))
        appStore.dispatch(changeUserLastNameAction(lastName: ""))
        appStore.dispatch(changeUserGenderAction(gender: .M))
        appStore.dispatch(changeUserBirthDateAction(birthDate: 0))
        appStore.dispatch(changeUserProfileImageAction(profileImage: nil))
        appStore.dispatch(changeUserUserIdAction(user_id: ""))
        appStore.dispatch(changeUserSessionIdAction(session_id: ""))
        appStore.dispatch(changeUserIsLoginAction(isLogin: false))
        appStore.dispatch(changeUserDefaultRoomAction(default_room: ""))
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
        appStore.dispatch(changeUserLoginAction(login:"test"))
        XCTAssertEqual("test",appStore.state.user.login)
    }
    
    func testChangeEmailFieldAction() {
        appStore.dispatch(changeUserEmailAction(email:"test@test.com"))
        XCTAssertEqual("test@test.com",appStore.state.user.email)
    }
    
    func testChangeFirstNameFieldAction() {
        appStore.dispatch(changeUserFirstNameAction(firstName:"test"))
        XCTAssertEqual("test",appStore.state.user.first_name)
    }
    
    func testChangeLastNameFieldAction() {
        appStore.dispatch(changeUserLastNameAction(lastName:"test"))
        XCTAssertEqual("test",appStore.state.user.last_name)
    }
    
    func testChangeGenderFieldAction() {
        appStore.dispatch(changeUserGenderAction(gender:.F))
        XCTAssertEqual(Gender.F,appStore.state.user.gender)
    }
    
    func testChangeBirthDateFieldAction() {
        appStore.dispatch(changeUserBirthDateAction(birthDate:1234567890))
        XCTAssertEqual(1234567890,appStore.state.user.birthDate)
    }
    
    func testChangeIsLoginFieldAction() {
        appStore.dispatch(changeUserIsLoginAction(isLogin:true))
        XCTAssertEqual(true,appStore.state.user.isLogin)
    }
    
    func testChangeDefaultRoomFieldAction() {
        appStore.dispatch(changeUserDefaultRoomAction(default_room:"test"))
        XCTAssertEqual("test",appStore.state.user.default_room)
    }
    
    func testChangeUserIdFieldAction() {
        appStore.dispatch(changeUserUserIdAction(user_id:"test"))
        XCTAssertEqual("test",appStore.state.user.user_id)
    }
    
    func testChangeSessionIdFieldAction() {
        appStore.dispatch(changeUserSessionIdAction(session_id:"test"))
        XCTAssertEqual("test",appStore.state.user.session_id)
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
}
