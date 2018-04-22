//
//  ChatUserTests.swift
//  chatter_client_iosTests
//
//  Created by user on 22.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import XCTest
@testable import chatter_client_ios

class ChatUserTests: XCTestCase {
    
    override func setUp() {
        appStore.dispatch(ChatState.changeRooms(rooms:[
            ChatRoom(id:"r1",name:"Room 1"),
            ChatRoom(id:"r2",name:"Room 2"),
            ChatRoom(id:"r3",name:"Room 3")
            ]
        ))
        let user1 = ChatUser(id:"u1")
        user1.email = "test@test.com"
        user1.room = appStore.state.chat.rooms[0]
        user1.isLogin = true
        let user2 = ChatUser(id:"u2")
        user2.email = "andrey@it-port.ru"
        user2.room = appStore.state.chat.rooms[1]
        appStore.dispatch(ChatState.changeUsers(users:[user1,user2]))
        let room1 = appStore.state.chat.rooms[0]
        let room2 = appStore.state.chat.rooms[1]
        let m1 = ChatMessage(id: "1", timestamp: 5, from_user: user1, text:  "Hi User2", attachment: nil, room: nil, to_user: user2)
        let m2 = ChatMessage(id: "2", timestamp: 2, from_user: user1, text: "Hi again",attachment:nil,room:nil,to_user:user2)
        let m3 = ChatMessage(id: "3", timestamp: 15, from_user: user2, text: "hello all",attachment:nil,room:room1,to_user:nil)
        let m4 = ChatMessage(id: "4", timestamp: 10, from_user:user1, text: "Hello world",attachment:nil,room:room1,to_user:nil)
        let m5 = ChatMessage(id: "5", timestamp: 5, from_user: user2, text: "Hi user1",attachment:nil,room:nil,to_user:user1)
        let m6 = ChatMessage(id: "6", timestamp: 1, from_user: user2,text: "Hi there",attachment:nil,room:room2,to_user:nil)
        let m7 = ChatMessage(id: "7", timestamp: 7, from_user: user2,text: "Warning!",attachment:nil,room:room2,to_user:nil)
        let m8 = ChatMessage(id: "8", timestamp: 3, from_user: user1,text: "How are you?",attachment:nil,room:nil,to_user:user2)
        let m9 = ChatMessage(id: "9", timestamp:3, from_user: user2,text: "Thank you fine",attachment:nil,room:nil,to_user:user1)
        let m10 = ChatMessage(id:"10", timestamp:1, from_user: user2,text: "How about you ?",attachment:nil,room:nil,to_user:user1)
        m1.unread = true; m2.unread = false; m3.unread = true; m4.unread = false; m5.unread = true; m6.unread = false;
        m7.unread = true; m8.unread = false; m9.unread = true; m10.unread = false
        appStore.dispatch(ChatState.changeMessages(messages:[m1,m2,m3,m4,m5,m6,m7,m8,m9,m10]))
        appStore.dispatch(UserState.changeUserUserIdAction(user_id: "u1"))
        super.setUp()
    }
    
    override func tearDown() {
        appStore.dispatch(ChatState.changeMessages(messages:[ChatMessage]()))
        appStore.dispatch(ChatState.changeUsers(users:[ChatUser]()))
        appStore.dispatch(ChatState.changeRooms(rooms:[ChatRoom]()))
        super.tearDown()
    }
    
    func testGetById() {
        var result = ChatUser.getById("12345")
        XCTAssertNil(result,"Should return null if user not found")
        result = ChatUser.getById("u2")
        XCTAssertNotNil(result,"Should return result if user found")
        XCTAssertEqual("andrey@it-port.ru",result!.email,"Should provide access to fields of returned results")
    }
    
    func testGetPrivateMessages() {
        var user = ChatUser.getById("u1")
        XCTAssertEqual(0,user!.getPrivateMessages().count,"Should not return anything, if user is the same as active user")
        user = ChatUser.getById("u2")
        let result = user!.getPrivateMessages()
        XCTAssertEqual(3,result.count,"Should return correct number of messages")
        XCTAssertEqual(1,result[0].timestamp,"Should sort by timestamp ascending")
        XCTAssertEqual(3,result[1].timestamp,"Should sort by timestamp ascending")
    }
    
    func testGetUnreadMessagesCount() {
        var user = ChatUser.getById("u1")
        XCTAssertEqual(0,user!.getUnreadMessagesCount(),"Should not have unread messages from myself")
        user = ChatUser.getById("u2")
        XCTAssertEqual(2,user!.getUnreadMessagesCount(),"Should return correct number of unread private messages from user")
    }
}
