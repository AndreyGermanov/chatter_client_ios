//
//  Model.swift
//  chatter_client_iosTests
//
//  Created by user on 22.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import XCTest
@testable import chatter_client_ios

class ModelTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let users = [
            ChatUser(id:"u1")
        ]
        appStore.dispatch(ChatState.changeUsers(users:users))
        let messages = [
            ChatMessage(id:"12345",from_user:users[0],text:"Testing message"),
            ChatMessage(id:"12345",from_user:users[0]),
            ChatMessage(id:"89656",from_user:users[0])
        ]
        appStore.dispatch(ChatState.changeMessages(messages:messages))
    }
    
    override func tearDown() {
        appStore.dispatch(ChatState.changeMessages(messages:[ChatMessage]()))
        appStore.dispatch(ChatState.changeUsers(users:[ChatUser]()))
        super.tearDown()
    }
    
    func testGetModelById() {
        var result = Model.getModelById(id: "12345", collection: nil)
        XCTAssertNil(result, "Should return nil if no collection provided")
        result = Model.getModelById(id:"5678", collection: appStore.state.chat.messages)
        XCTAssertNil(result, "Should return nil if item not found in collection")
        result = Model.getModelById(id:"12345",collection:appStore.state.chat.messages)
        XCTAssertNotNil(result,"Should return item if correct id provided")
        let message = result as? ChatMessage
        XCTAssertNotNil(message, "Should return correct type of result")
        XCTAssertEqual("Testing message",message!.text,"Should provide access to field values")
    }
}
