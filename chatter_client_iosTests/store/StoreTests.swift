//
//  StoreTests.swift
//  chatter_client_iosTests
//
//  Created by user on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import XCTest
import ReSwift
@testable import chatter_client_ios

class StoreTests: XCTestCase,StoreSubscriber {
    
    typealias StoreSubscriberStateType = AppState
    
    func newState(state: AppState) {
        print(state.current_activity)
    }

    override func setUp() {
        super.setUp()
        appStore.dispatch(ChangeActivityAction(activity:AppScreens.USER_PROFILE))
        appStore.subscribe(self)
    }

    override func tearDown() {
        super.tearDown()
    }
    
    func testChangeActivity() {
        appStore.dispatch(ChangeActivityAction(activity:AppScreens.USER_PROFILE))
        XCTAssertEqual(AppScreens.USER_PROFILE, appStore.state.current_activity)
    }
}
