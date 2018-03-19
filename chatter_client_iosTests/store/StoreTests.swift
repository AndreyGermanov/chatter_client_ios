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
  
    func newState(state: AppState) {
        print(state.current_activity)
    }
    
    typealias StoreSubscriberStateType = AppState
    
    
    override func setUp() {
        super.setUp()
        appStore.subscribe(self)
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testChangeActivity() {
        appStore.dispatch(ChangeActivityAction(activity:AppScreens.USER_PROFILE))
        XCTAssertEqual(AppScreens.USER_PROFILE, appStore.state.current_activity)
    }
    
}
