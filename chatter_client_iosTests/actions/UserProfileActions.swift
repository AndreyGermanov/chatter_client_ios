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
        appStore.dispatch(changeUserProfileShowDatePickerDialogAction(showDatePickerDialog:false))
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
}
