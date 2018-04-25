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
    var images = [String:Data]()
    
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
        do {
            for i in 1...5 {
                images["simp\(i)"] =  try Data.init(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "simp\(i)", ofType: "png")!, isDirectory: false))
                print(images["simp\(i)"]?.bytes.crc32())
            }
        } catch {}
        let room1 = ChatRoom(id: "r1", name: "Room 1")
        let room2 = ChatRoom(id: "r2", name: "Room 2")
        let room3 = ChatRoom(id: "r3", name: "Room 3")
        appStore.dispatch(ChatState.changeRooms(rooms:[room1,room2,room3]))
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
    
    func testLoadUsers() {
        /// Request sending sequence tests
        ChatState.loadUsers().exec()
        XCTAssertEqual(ChatScreenError.RESULT_ERROR_CONNECTION_ERROR,appStore.state.chat.errors["general"],
                       "Should return connection error if disconnected")
        messageCenter.testingModeConnected = true
        ChatState.loadUsers().exec()
        XCTAssertEqual(1,messageCenter.pendingRequests.count,"Should place request to pendingRequests queue")
        messageCenter.processPendingRequests()
        XCTAssertEqual(0,messageCenter.pendingRequests.count,"Should remove request from pending requests queue")
        XCTAssertEqual(1,messageCenter.requestsWaitingResponses.count,"Should place request to requests waiting responses queue")
        XCTAssertTrue(appStore.state.chat.showProgressIndicator,"Should show progress indicator")
        /// Server responses processing tests
        var request_id = messageCenter.lastRequestObject["request_id"]!
        var responseText = """
            {
                "request_id":"\(request_id)",
                "action":"get_users_list",
                "status":"error",
                "status_code":"INTERNAL_ERROR"
            }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses queue")
        XCTAssertFalse(appStore.state.chat.showProgressIndicator,"Should hide progress indicator")
        XCTAssertEqual(ChatScreenError.INTERNAL_ERROR,appStore.state.chat.errors["general"],"Should parse error messages correctly")
        ChatState.loadUsers().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_users_list",
            "status":"ok",
            "status_code":"RESULT_OK",
            "list":"#%$..!"
        }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses queue")
        XCTAssertFalse(appStore.state.chat.showProgressIndicator,"Should hide progress indicator")
        XCTAssertEqual(0,appStore.state.chat.users.count,"Should not load any users if users list has incorrect format")

        ChatState.loadUsers().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_users_list",
            "status":"ok",
            "status_code":"RESULT_OK",
            "list":"[{},[],{}]"
        }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(0,appStore.state.chat.users.count,"Should not load any users if users list has incorrect format")
        
        ChatState.loadUsers().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        var usersListText = """
            [{"_id":"u1"}]
        """.trimmingCharacters(in: .whitespacesAndNewlines)
        responseText = """
            {
                "request_id":"\(request_id)",
                "action":"get_users_list",
                "status":"ok",
                "status_code":"RESULT_OK",
                "list":\(usersListText)
            }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(1,appStore.state.chat.users.count,"When receive list as string Should add user with single _id " +
            "field and defaults for others \(appStore.state.chat.users)")
        XCTAssertEqual("M",ChatUser.getById("u1")!.gender,"Should contain defaults for fields")
        
        ChatState.loadUsers().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        usersListText = """
            [{
                "_id":"u1",
                "login":"User 1",
                "email":"user@user.com",
                "room":"NO ROOM",
                "profileImageChecksum": 12345678,
                "birthDate": "xoxoxox",
                "role": 2,
                "first_name": "John",
                "last_name": "Johnson",
                "isLogin": "false",
                "gender": "X",
                "lastActivityTime": 12345
            }]
        """.trimmingCharacters(in: .whitespacesAndNewlines)
        responseText = """
            {
                "request_id":"\(request_id)",
                "action":"get_users_list",
                "status":"ok",
                "status_code":"RESULT_OK",
                "list":\(usersListText)
            }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(1,appStore.state.chat.users.count,"Should update user, not add new one: \(appStore.state.chat.users)")
        var user = ChatUser.getById("u1")!
        XCTAssertEqual("User 1",user.login,"Should update 'login' correctly")
        XCTAssertEqual("user@user.com",user.email,"Should update 'email' correctly")
        XCTAssertEqual(0,user.birthDate,"Should not get incorrect 'birthDate' value")
        XCTAssertEqual("John",user.first_name,"Should update 'first_name' correctly")
        XCTAssertEqual("Johnson",user.last_name,"Should update 'last_name' correctly")
        XCTAssertEqual(false,user.isLogin,"Should update 'isLogin' correctly")
        XCTAssertEqual("M",user.gender,"Should not get incorrect 'gender' value")
        XCTAssertEqual(12345,user.lastActivityTime,"Should update 'lastActivityTime' correctly")
        XCTAssertEqual(12345678,user.profileImageChecksum,"Should update 'profileImageChecksum' correctly")
        XCTAssertNil(user.room,"Should not get room which does not exist")
        XCTAssertEqual(1,messageCenter.responsesWaitingFile.count,"Should add this response to 'responsesWaitingFile' queue")

        ChatState.loadUsers().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        usersListText = """
            [{
                "_id":"u1",
                "room":"r1",
                "profileImageChecksum": \(images["simp1"]!.bytes.crc32()),
                "birthDate": 1234567890,
                "isLogin": "true",
                "gender": "F",
            }]
        """.trimmingCharacters(in: .whitespacesAndNewlines)
        responseText = """
            {
                "request_id":"\(request_id)",
                "action":"get_users_list",
                "status":"ok",
                "status_code":"RESULT_OK",
                "list":\(usersListText)
            }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        user = ChatUser.getById("u1")!
        XCTAssertEqual(1,appStore.state.chat.users.count,"Should update user, not add new one: \(appStore.state.chat.users)")
        XCTAssertEqual(1234567890,user.birthDate,"Should set correct 'birthDate' value")
        XCTAssertEqual("r1",user.room!.id,"Should set correct 'room' value")
        XCTAssertEqual("F",user.gender,"Should set correct 'gender' value")
        XCTAssertEqual(true,user.isLogin,"Should set correct 'isLogin' value")
        XCTAssertEqual(2,messageCenter.responsesWaitingFile.count,"Should add this response to 'responsesWaitingFile' queue")
        messageCenter.websocketDidReceiveData(socket: messageCenter.ws, data: images["simp1"]!)
        XCTAssertNotNil(user.profileImage,"Should set received profile image")
        XCTAssertEqual(images["simp1"]!.bytes.crc32(),user.profileImage?.bytes.crc32(),"Should set correct profile image")
        XCTAssertEqual(0,messageCenter.receivedFiles.count,"Should remove received profile image from 'receivedFiles' queue")
        XCTAssertEqual(1,messageCenter.responsesWaitingFile.count,"Should remove response from 'responsesWaitingFile' queue")
        
        ChatState.loadUsers().exec() {
            print("CALLBACK STARTED")
        }
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        usersListText = """
            [
                {
                    "_id":"u1",
                    "room":"r1",
                    "profileImageChecksum": \(images["simp2"]!.bytes.crc32()),
                    "isLogin": true,
                },
                {
                    "_id":"u2",
                    "room":"r2",
                    "login":"User 2",
                    "profileImageChecksum": \(images["simp1"]!.bytes.crc32()),
                },
                {
                    "_id":"u3",
                    "room":"r3",
                    "login":"User 3",
                    "profileImageChecksum": \(images["simp3"]!.bytes.crc32()),
                },
                {
                    "_id":"u4",
                    "room":"r4",
                    "login":"User 4",
                    "profileImageChecksum": \(images["simp4"]!.bytes.crc32()),
                },
                {
                    "_id":"u5",
                    "room":"r5",
                    "login":"User 5",
                    "profileImageChecksum": \(images["simp5"]!.bytes.crc32()),
                }
            ]
            """.trimmingCharacters(in: .whitespacesAndNewlines)
        responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_users_list",
            "status":"ok",
            "status_code":"RESULT_OK",
            "list":\(usersListText)
        }
        """
        messageCenter.websocketDidReceiveData(socket: messageCenter.ws, data: images["simp3"]!)
        messageCenter.websocketDidReceiveData(socket: messageCenter.ws, data: images["simp5"]!)
        messageCenter.websocketDidReceiveData(socket: messageCenter.ws, data: images["simp1"]!)
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        messageCenter.websocketDidReceiveData(socket: messageCenter.ws, data: images["simp2"]!)
        messageCenter.websocketDidReceiveData(socket: messageCenter.ws, data: images["simp4"]!)
        XCTAssertEqual(5,appStore.state.chat.users.count,"Should receive all users")
        let user1 = ChatUser.getById("u1")!
        let user2 = ChatUser.getById("u2")!
        let user3 = ChatUser.getById("u3")!
        let user4 = ChatUser.getById("u4")!
        let user5 = ChatUser.getById("u5")!
        XCTAssertEqual(1, messageCenter.responsesWaitingFile.count,"Should remove all responses waiting file after finish")
        XCTAssertEqual(0, messageCenter.receivedFiles.count,"Should remove all records from receivedFiles queue")
        XCTAssertTrue(user1.isLogin,"Should set correct 'isLogin' field value")
        XCTAssertEqual(user1.profileImage!.bytes.crc32(),images["simp2"]!.bytes.crc32(),"Should set correct profile image for user1")
        XCTAssertEqual(user2.profileImage!.bytes.crc32(),images["simp1"]!.bytes.crc32(),"Should set correct profile image for user2")
        XCTAssertEqual(user3.profileImage!.bytes.crc32(),images["simp3"]!.bytes.crc32(),"Should set correct profile image for user3")
        XCTAssertEqual(user4.profileImage!.bytes.crc32(),images["simp4"]!.bytes.crc32(),"Should set correct profile image for user4")
        XCTAssertEqual(user5.profileImage!.bytes.crc32(),images["simp5"]!.bytes.crc32(),"Should set correct profile image for user5")
        XCTAssertEqual("User 1",user1.login,"Should set correct 'login' for user1")
        XCTAssertEqual("User 2",user2.login,"Should set correct 'login' for user2")
        XCTAssertEqual("User 3",user3.login,"Should set correct 'login' for user3")
        XCTAssertEqual("User 4",user4.login,"Should set correct 'login' for user4")
        XCTAssertEqual("User 5",user5.login,"Should set correct 'login' for user5")
        
        /// High Load test
        ChatState.loadUsers().exec() {
            print("CALLBACK STARTED")
        }
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        var users = [String]()
        let numberOfUsers = 1000
        for i in 1...numberOfUsers {
            users.append("""
            {
                "_id":"u\(i)",
                "room":"r1",
                "login":"User \(i)",
            }
            """)
        }
        usersListText = users.joined(separator:",")
        responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_users_list",
            "status":"ok",
            "status_code":"RESULT_OK",
            "list":[\(usersListText)]
        }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should empty requests waiting responses queue")
        XCTAssertEqual(numberOfUsers,appStore.state.chat.users.count,"Should contain correct number of received users")
        for i in 1...numberOfUsers {
            let user = ChatUser.getById("u\(i)")!
            XCTAssertEqual("User \(i)",user.login,"Should set correct login for user\(i)")
        }
    }
    
    func testLoadRooms() {
        appStore.dispatch(ChatState.changeRooms(rooms: [ChatRoom]()))
        /// Request sending sequence tests
        ChatState.loadRooms().exec()
        XCTAssertEqual(ChatScreenError.RESULT_ERROR_CONNECTION_ERROR,appStore.state.chat.errors["general"],
                       "Should return connection error if disconnected")
        messageCenter.testingModeConnected = true
        ChatState.loadRooms().exec()
        XCTAssertEqual(1,messageCenter.pendingRequests.count,"Should place request to pendingRequests queue")
        messageCenter.processPendingRequests()
        XCTAssertEqual(0,messageCenter.pendingRequests.count,"Should remove request from pending requests queue")
        XCTAssertEqual(1,messageCenter.requestsWaitingResponses.count,"Should place request to requests waiting responses queue")
        XCTAssertTrue(appStore.state.chat.showProgressIndicator,"Should show progress indicator")
        /// Server responses processing tests
        var request_id = messageCenter.lastRequestObject["request_id"]!
        var responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_rooms_list",
            "status":"error",
            "status_code":"INTERNAL_ERROR"
        }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses queue")
        XCTAssertFalse(appStore.state.chat.showProgressIndicator,"Should hide progress indicator")
        XCTAssertEqual(ChatScreenError.INTERNAL_ERROR,appStore.state.chat.errors["general"],"Should parse error messages correctly")
        ChatState.loadRooms().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_rooms_list",
            "status":"ok",
            "status_code":"RESULT_OK",
            "list":"#%$..!"
        }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(0,messageCenter.requestsWaitingResponses.count,"Should remove request from requestsWaitingResponses queue")
        XCTAssertFalse(appStore.state.chat.showProgressIndicator,"Should hide progress indicator")
        XCTAssertEqual(0,appStore.state.chat.rooms.count,"Should not load any rooms if rooms list has incorrect format")
        
        ChatState.loadRooms().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_rooms_list",
            "status":"ok",
            "status_code":"RESULT_OK",
            "list":"[{},[],{}]"
        }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(0,appStore.state.chat.rooms.count,"Should not load any rooms if rooms list has incorrect format")
        
        ChatState.loadRooms().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        var roomsListText = """
            [{"_id":"r1"}]
        """.trimmingCharacters(in: .whitespacesAndNewlines)
        responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_rooms_list",
            "status":"ok",
            "status_code":"RESULT_OK",
            "list":\(roomsListText)
        }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(0,appStore.state.chat.rooms.count,"Should not add room without 'name' field")
 
        ChatState.loadRooms().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        roomsListText = """
            [{"_id":"r1","name":"Room"}]
        """.trimmingCharacters(in: .whitespacesAndNewlines)
        responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_rooms_list",
            "status":"ok",
            "status_code":"RESULT_OK",
            "list":\(roomsListText)
        }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(1,appStore.state.chat.rooms.count,"Should add new room")
        var room = ChatRoom.getById("r1")!;
        XCTAssertEqual("Room",room.name,"Should set correct 'name' for new added room")

        ChatState.loadRooms().exec()
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        roomsListText = """
            [{
                "_id":"r1",
                "name":"Room 1",
            }]
        """.trimmingCharacters(in: .whitespacesAndNewlines)
        responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_rooms_list",
            "status":"ok",
            "status_code":"RESULT_OK",
            "list":\(roomsListText)
        }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(1,appStore.state.chat.rooms.count,"Should update room, not add new one: \(appStore.state.chat.rooms)")
        room = ChatRoom.getById("r1")!
        XCTAssertEqual("Room 1",room.name,"Should update 'name' correctly")
        
        ChatState.loadRooms().exec() {
            print("CALLBACK STARTED")
        }
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        roomsListText = """
            [
                {
                    "_id":"r1",
                    "name":"Room 1",
                },
                {
                    "_id":"r2",
                    "name":"Room 2",
                },
                {
                    "_id":"r3",
                    "name":"Room 3",
                },
                {
                    "_id":"r4",
                    "name":"Room 4",
                },
                {
                    "_id":"r5",
                    "name":"Room 5",
                }
            ]
            """.trimmingCharacters(in: .whitespacesAndNewlines)
        responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_rooms_list",
            "status":"ok",
            "status_code":"RESULT_OK",
            "list":\(roomsListText)
        }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(5,appStore.state.chat.rooms.count,"Should receive all rooms")
        let room1 = ChatRoom.getById("r1")!
        let room2 = ChatRoom.getById("r2")!
        let room3 = ChatRoom.getById("r3")!
        let room4 = ChatRoom.getById("r4")!
        let room5 = ChatRoom.getById("r5")!
        XCTAssertEqual("Room 1",room1.name,"Should set correct 'name' for room1")
        XCTAssertEqual("Room 2",room2.name,"Should set correct 'name' for room2")
        XCTAssertEqual("Room 3",room3.name,"Should set correct 'name' for room3")
        XCTAssertEqual("Room 4",room4.name,"Should set correct 'name' for room4")
        XCTAssertEqual("Room 5",room5.name,"Should set correct 'name' for room5")
        
        /// High Load test
        ChatState.loadRooms().exec() {
            print("CALLBACK STARTED")
        }
        messageCenter.processPendingRequests()
        request_id = messageCenter.lastRequestObject["request_id"]!
        var rooms = [String]()
        let numberOfRooms = 1000
        for i in 1...numberOfRooms {
            rooms.append("""
                {
                "_id":"r\(i)",
                "name":"Room \(i)",
                }
                """)
        }
        roomsListText = rooms.joined(separator:",")
        responseText = """
        {
            "request_id":"\(request_id)",
            "action":"get_rooms_list",
            "status":"ok",
            "status_code":"RESULT_OK",
            "list":[\(roomsListText)]
        }
        """
        messageCenter.websocketDidReceiveMessage(socket: messageCenter.ws, text: responseText)
        XCTAssertEqual(numberOfRooms,appStore.state.chat.rooms.count,"Should contain correct number of received rooms")
        for i in 1...numberOfRooms {
            let room = ChatRoom.getById("r\(i)")!
            XCTAssertEqual("Room \(i)",room.name,"Should set correct name for room\(i)")
        }
    }
}
