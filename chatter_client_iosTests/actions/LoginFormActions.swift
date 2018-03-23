//
//  LoginFormActions.swift
//  chatter_client_iosTests
//
//  Created by user on 23.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import XCTest
import ReSwift
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
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
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
        appStore.dispatch(changeLoginFormModeAction(mode:.REGISTER))
        XCTAssertEqual(LoginFormMode.REGISTER,appStore.state.loginForm.mode)
    }
    
    func testChangeProgressIndicatorFieldAction() {
        appStore.dispatch(changeLoginFormShowProgressIndicatorAction(progressIndicator:true))
        XCTAssertEqual(true,appStore.state.loginForm.show_progress_indicator)
    }

    func testChangeErrorsFieldAction() {
        var errors = [String:LoginFormError]()
        errors["general"] = LoginFormError.RESULT_ERROR_CONNECTION_ERROR
        appStore.dispatch(changeLoginFormErrorsAction(errors:errors))
        let result_errors = appStore.state.loginForm.errors
        XCTAssertEqual(LoginFormError.RESULT_ERROR_CONNECTION_ERROR,result_errors["general"])
    }

    func handleWebSocketResponse(request_id: String, response: [String : Any]) {
        
    }
}
