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

    var images = [String: Data]()
    override func setUp() {
        appStore.dispatch(ChatState.changeRooms(rooms: [
            ChatRoom(id: "r1", name: "Room 1"),
            ChatRoom(id: "r2", name: "Room 2"),
            ChatRoom(id: "r3", name: "Room 3")
            ]
        ))
        let user1 = ChatUser(id: "u1")
        user1.email = "test@test.com"
        user1.room = appStore.state.chat.rooms[0]
        user1.isLogin = true
        let user2 = ChatUser(id: "u2")
        user2.email = "andrey@it-port.ru"
        user2.room = appStore.state.chat.rooms[1]
        appStore.dispatch(ChatState.changeUsers(users: [user1, user2]))
        let room1 = appStore.state.chat.rooms[0]
        let room2 = appStore.state.chat.rooms[1]
        let m1 = ChatMessage(id: "1", timestamp: 5, from_user: user1, text: "Hi User2", attachment: nil, room: nil, to_user: user2)
        let m2 = ChatMessage(id: "2", timestamp: 2, from_user: user1, text: "Hi again", attachment: nil, room: nil, to_user: user2)
        let m3 = ChatMessage(id: "3", timestamp: 15, from_user: user2, text: "hello all", attachment: nil, room: room1, to_user: nil)
        let m4 = ChatMessage(id: "4", timestamp: 10, from_user: user1, text: "Hello world", attachment: nil, room: room1, to_user: nil)
        let m5 = ChatMessage(id: "5", timestamp: 5, from_user: user2, text: "Hi user1", attachment: nil, room: nil, to_user: user1)
        let m6 = ChatMessage(id: "6", timestamp: 1, from_user: user2, text: "Hi there", attachment: nil, room: room2, to_user: nil)
        let m7 = ChatMessage(id: "7", timestamp: 7, from_user: user2, text: "Warning!", attachment: nil, room: room2, to_user: nil)
        let m8 = ChatMessage(id: "8", timestamp: 3, from_user: user1, text: "How are you?", attachment: nil, room: nil, to_user: user2)
        let m9 = ChatMessage(id: "9", timestamp: 3, from_user: user2, text: "Thank you fine", attachment: nil, room: nil, to_user: user1)
        let m10 = ChatMessage(id: "10", timestamp: 1, from_user: user2, text: "How about you ?", attachment: nil, room: nil, to_user: user1)
        m1.unread = true; m2.unread = false; m3.unread = true; m4.unread = false; m5.unread = true; m6.unread = false
        m7.unread = true; m8.unread = false; m9.unread = true; m10.unread = false
        appStore.dispatch(ChatState.changeMessages(messages: [m1, m2, m3, m4, m5, m6, m7, m8, m9, m10]))
        appStore.dispatch(UserState.changeUserUserIdAction(user_id: "u1"))
        do {
            images["simp1"] = try Data(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "simp1", ofType: "png")!, isDirectory: false))
            images["simp2"] = try Data(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "simp2", ofType: "png")!, isDirectory: false))
        } catch {}
        super.setUp()
    }

    override func tearDown() {
        appStore.dispatch(ChatState.changeMessages(messages: [ChatMessage]()))
        appStore.dispatch(ChatState.changeUsers(users: [ChatUser]()))
        appStore.dispatch(ChatState.changeRooms(rooms: [ChatRoom]()))
        super.tearDown()
    }

    func testGetById() {
        var result = ChatUser.getById("12345")
        XCTAssertNil(result, "Should return null if user not found")
        result = ChatUser.getById("u2")
        XCTAssertNotNil(result, "Should return result if user found")
        XCTAssertEqual("andrey@it-port.ru", result!.email, "Should provide access to fields of returned results")
    }

    func testGetPrivateMessages() {
        var user = ChatUser.getById("u1")
        XCTAssertEqual(0, user!.getPrivateMessages().count, "Should not return anything, if user is the same as active user")
        user = ChatUser.getById("u2")
        let result = user!.getPrivateMessages()
        XCTAssertEqual(3, result.count, "Should return correct number of messages")
        XCTAssertEqual(1, result[0].timestamp, "Should sort by timestamp ascending")
        XCTAssertEqual(3, result[1].timestamp, "Should sort by timestamp ascending")
    }

    func testGetUnreadMessagesCount() {
        var user = ChatUser.getById("u1")
        XCTAssertEqual(0, user!.getUnreadMessagesCount(), "Should not have unread messages from myself")
        user = ChatUser.getById("u2")
        XCTAssertEqual(2, user!.getUnreadMessagesCount(), "Should return correct number of unread private messages from user")
    }

    func testToHashMap() {
        let room1 = ChatRoom.getById("r1")
        let user = ChatUser(id: "u1")
        user.birthDate = 123456
        user.email = "email@test.com"
        user.login = "user1"
        user.first_name = "Bob"
        user.last_name = "Johnson"
        user.gender  = "M"
        user.isLogin = true
        user.lastActivityTime = 575
        user.role = 2
        var hash = user.toHashMap()
        XCTAssertEqual(123456, hash["birthDate"] as! Int, "Should contain correct 'birthDate'")
        XCTAssertEqual("email@test.com", hash["email"] as! String, "Should contain correct 'email'")
        XCTAssertEqual("user1", hash["login"] as! String, "Should contain correct 'login'")
        XCTAssertEqual("Bob", hash["first_name"] as! String, "Should contain correct 'first_name'")
        XCTAssertEqual("Johnson", hash["last_name"] as! String, "Should contain correct 'last_name'")
        XCTAssertEqual("M", hash["gender"] as! String, "Should contain correct 'gender'")
        XCTAssertEqual(true, hash["isLogin"] as! Bool, "Should contain correct 'isLogin'")
        XCTAssertEqual(575, hash["lastActivityTime"] as! Int, "Should contain correct 'lastActivityTime'")
        XCTAssertEqual(2, hash["role"] as! Int, "Should contain correct 'role'")
        XCTAssertNil(hash["room"], "Should not contain 'room'")
        XCTAssertNil(hash["profileImage"], "Should not contain 'profileImage'")

        user.profileImage = images["simp1"]!
        user.room = room1
        hash = user.toHashMap()
        let hashProfileImage = hash["profileImage"] as! Data
        let hashedRoom = hash["room"] as! ChatRoom
        XCTAssertEqual(images["simp1"]?.bytes.crc32(), hashProfileImage.bytes.crc32(), "Should contain correct profileImage")
        XCTAssertEqual("r1", hashedRoom.id, "Should contain correct room")
        hashedRoom.name = "NEW ROOM"
        XCTAssertEqual("NEW ROOM", user.room!.name, "Room in hash map should be link to room, connected to user object (not copy)")
        user.profileImage = images["simp2"]
        XCTAssertEqual(images["simp1"]!.bytes.crc32(), (hash["profileImage"] as! Data).bytes.crc32(),
                       "Profile image inside hash should be copy of image in user object (not link)")
    }

    func testCopy() {
        let room1 = ChatRoom.getById("r1")
        let user = ChatUser(id: "u1")
        user.birthDate = 123456
        user.email = "email@test.com"
        user.login = "user1"
        user.first_name = "Bob"
        user.last_name = "Johnson"
        user.gender  = "M"
        user.isLogin = true
        user.lastActivityTime = 575
        user.role = 2
        user.room = room1
        user.profileImage = images["simp1"]!
        let user2 = user.copy()
        XCTAssertEqual(123456, user2.birthDate, "Should contain correct 'birthDate'")
        XCTAssertEqual("email@test.com", user2.email, "Should contain correct 'email'")
        XCTAssertEqual("user1", user2.login, "Should contain correct 'login'")
        XCTAssertEqual("Bob", user2.first_name, "Should contain correct 'first_name'")
        XCTAssertEqual("Johnson", user2.last_name, "Should contain correct 'last_name'")
        XCTAssertEqual("M", user2.gender, "Should contain correct 'gender'")
        XCTAssertEqual(true, user2.isLogin, "Should contain correct 'isLogin'")
        XCTAssertEqual(575, user2.lastActivityTime, "Should contain correct 'lastActivityTime'")
        XCTAssertEqual(2, user2.role, "Should contain correct 'role'")
        XCTAssertEqual(images["simp1"]!.bytes.crc32(), user2.profileImage!.bytes.crc32(), "Should contain the same 'profileImage'")
        XCTAssertEqual(user.room!.id, user2.room!.id, "'Room' object of copy should contain the same ID data inside'")
        XCTAssertEqual(user.room!.name, user2.room!.name, "'Room' object of copy should contain the same Name data inside")
        user.room!.name="NOROOM"
        XCTAssertNotEqual("NOROOM", user2.room!.name, "'Room' fields of original and copy should not point to the same Room object'")
    }

    func testEqual() {
        let room1 = ChatRoom.getById("r1")!
        let user = ChatUser(id: "u1")
        user.birthDate = 123456
        user.email = "email@test.com"
        user.login = "user1"
        user.first_name = "Bob"
        user.last_name = "Johnson"
        user.gender  = "M"
        user.isLogin = true
        user.lastActivityTime = 575
        user.role = 2
        user.room = room1
        user.profileImage = images["simp1"]!
        XCTAssertFalse(user.equals(nil), "Should return false if compare to nil")
        var user2 = user.copy()
        XCTAssertTrue(user.equals(user2), "Should be equal to it's copy")
        user2.room!.name = "NOROOM"
        XCTAssertFalse(user.equals(user2), "Should be not equal if change field inside subfield of object type")
        user2 = user.copy()
        let room2 = room1.copy()
        user2.room = room2
        XCTAssertTrue(user.equals(user2), "Should be equal if replace object subfield to object with the same content")
        user.email = "new@test.com"
        XCTAssertFalse(user.equals(user2), "Should fail if replace ordinary field")
    }
}
