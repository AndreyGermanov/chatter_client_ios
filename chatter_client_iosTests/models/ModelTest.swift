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
    var images = [String:Data]()
    override func setUp() {
        super.setUp()
        do {
            for i in 1...5 {
                images["simp\(i)"] =  try Data.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "simp\(i)", ofType: "png")!, isDirectory: false))
            }
        } catch {}
        let room1 = ChatRoom(id:"r1",name:"Room 1")
        let room2 = ChatRoom(id:"r2",name:"Room 2")
        appStore.dispatch(ChatState.changeRooms(rooms:[room1,room2]))
        let user1 = ChatUser(id:"u1")
        user1.room = room1;user1.login="user1";user1.email="user1@test.com";user1.first_name="First";
        user1.last_name="One";user1.gender="F";user1.birthDate=123456;user1.role=1;user1.lastActivityTime=900;user1.isLogin=true
        let user2 = ChatUser(id:"u2");user2.login="user2";user2.email="user2@test.com";user2.first_name="Second";
        user2.last_name="Two";user2.gender="M";user2.birthDate=654321;user2.role=2;user2.lastActivityTime=2;user1.isLogin=false
        user2.room = room2
        let users = [
            user1,
            user2
        ]        
        appStore.dispatch(ChatState.changeUsers(users:users))
        let messages = [
            ChatMessage(id:"12345",from_user:user1,text:"Testing message",room:room1),
            ChatMessage(id:"12345",from_user:user1,text:"Hi!",attachment:images["simp2"],to_user:user2),
            ChatMessage(id:"89656",from_user:user2,text:"Hello!",attachment:images["simp4"],to_user:user1)
        ]
        appStore.dispatch(ChatState.changeMessages(messages:messages))
    }
    
    override func tearDown() {
        appStore.dispatch(ChatState.changeMessages(messages:[ChatMessage]()))
        appStore.dispatch(ChatState.changeUsers(users:[ChatUser]()))
        appStore.dispatch(ChatState.changeRooms(rooms:[ChatRoom]()))
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
    
    func testCopy() {
        var messages:[ChatMessage] = appStore.state.chat.messages.copy()
        XCTAssertEqual(3,messages.count,"Should contain correct number of messages after copy")
        let message1 = messages[0]
        let message2 = messages[1]
        let message3 = messages[2]
        XCTAssertEqual("Testing message",message1.text,"Should copy 'text' field correctly")
        XCTAssertEqual("12345",message1.id,"Should copy 'id' field correctly")
        XCTAssertEqual("user1@test.com",message1.from_user.email,"Should copy 'from_user' field correctly")
        XCTAssertEqual("Room 1",message1.room!.name,"Should copy 'room' field correctly")
        XCTAssertEqual("Hi!",message2.text,"Should copy 'text' field correctly")
        XCTAssertEqual("12345",message2.id,"Should copy 'id' field correctly")
        XCTAssertEqual("user1",message2.from_user.login,"Should copy 'from_user' field correctly")
        XCTAssertEqual("user2@test.com",message2.to_user?.email,"Should copy 'to_user' field correctly")
        XCTAssertEqual(images["simp2"]!.bytes.crc32(),message2.attachment?.bytes.crc32(),"Should copy 'attachment' field correctly")
        XCTAssertEqual("Hello!",message3.text,"Should copy 'text' field correctly")
        XCTAssertEqual("89656",message3.id,"Should copy 'id' field correctly")
        XCTAssertEqual("user2",message3.from_user.login,"Should copy 'from_user' field correctly")
        XCTAssertEqual("user1@test.com",message3.to_user?.email,"Should copy 'to_user' field correctly")
        XCTAssertEqual(images["simp4"]!.bytes.crc32(),message3.attachment?.bytes.crc32(),"Should copy 'attachment' field correctly")
        XCTAssertEqual("Room 2",message2.to_user?.room?.name,"Should correctly copy nested object variables")
        
        var original_messages = appStore.state.chat.messages
        original_messages[0].text = "CHANGING MESSAGE"
        appStore.dispatch(ChatState.changeMessages(messages: original_messages))
        XCTAssertNotEqual("CHANGING MESSAGE",message1.text,"Copy should not contain links to the same object as original")
        XCTAssertEqual("CHANGING MESSAGE",appStore.state.chat.messages[0].text,"Original message should change")
    }
    
    func testCompare() {
        var messages:[ChatMessage] = appStore.state.chat.messages.copy()
        XCTAssertTrue(ChatMessage.compare(models1:messages,models2:appStore.state.chat.messages),"Should return true when compare copy with original")
        var original_messages = appStore.state.chat.messages
        var message1 = original_messages[0]
        original_messages.remove(at:0)
        original_messages.append(message1)
        appStore.dispatch(ChatState.changeMessages(messages: original_messages))
        XCTAssertFalse(ChatMessage.compare(models1:messages,models2:appStore.state.chat.messages),"Should return false if order of items changed")
        messages = original_messages.copy()
        XCTAssertTrue(ChatMessage.compare(models1:messages,models2:appStore.state.chat.messages),"Should return true when compare copy with original")
        original_messages[1].to_user?.login = "CHANGED"
        appStore.dispatch(ChatState.changeMessages(messages: original_messages))
        XCTAssertFalse(ChatMessage.compare(models1: messages, models2: appStore.state.chat.messages),"Should return false if something inside message changed")
    }
}
