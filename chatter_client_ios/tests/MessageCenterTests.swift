//
//  MessageCenterTests.swift
//  chatter_client_ios
//
//  Created by user on 23.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation

class MessageCenterTests: MessageCenterResponseListener {

    var messageCenter: MessageCenter
    var lastWebSocketResponse: [String: Any]?
    var i = 1
    var i1 = 1
    var images = [String:Data]()
    

    init(msgCenter: MessageCenter) {
        self.messageCenter = msgCenter
        for i in 1...5 {
            do {
                images["simp\(i)"] = try Data(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "simp\(i)", ofType: "png")!, isDirectory: false))
            } catch {}
        }
        do {
            images["splash"] = try Data(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "splash", ofType: "jpg")!, isDirectory: false))
            images["splash2"] = try Data(contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "splash2", ofType: "jpg")!, isDirectory:
                false))
        } catch {}
    }

    func testTransferImage() {
        self.messageCenter.connect()
        sleep(2)

            //let bundle = Bundle.main
            //let path = bundle.path(forResource: "apple", ofType: "png")!
            //let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path, isDirectory: false))
            let request: [String: Any] = [
                "sender": self,
                "action": "login_user",
                "login": "andrey",
                "password": "123"
            ]
            _ = self.messageCenter.addToPendingRequests(request)
            self.messageCenter.processPendingRequests()
            sleep(2)
            sleep(10)
            if let response = self.lastWebSocketResponse {
                Logger.log(level: LogLevel.DEBUG, message: "Received final response \(response)",
                    className: "MessageCenterTests", methodName: "testTransferImage")
            }

    }

    func handleWebSocketResponse(request_id: String, response: [String: Any]) {
        self.lastWebSocketResponse = response
        let request_id = response["request_id"] as! String
        let status = response["status"] as! String
        if (status == "ok") {
            Logger.log(level: LogLevel.DEBUG, message: "Beginning to execute hander for request with id \(request_id). Request body: \(response)",
                className: "MessageCenterTests", methodName: "handleWebSocketResponse")
            if response["checksum"] != nil {
                let checksumNumber = response["checksum"] as! String
                let checksum = Int(checksumNumber)!
                if self.messageCenter.receivedFiles[checksum] != nil {
                    Logger.log(level: LogLevel.DEBUG, message: "Found file with checksum \(checksum) in receivedFiles",
                        className: "MessageCenterTests", methodName: "handleWebSocketResponse")
                    var record = self.messageCenter.receivedFiles[checksum] as! [String: Any]
                    self.lastWebSocketResponse!["profile_image"] = record["data"] as! Data
                    Logger.log(level: LogLevel.DEBUG, message: "Received final response \(self.lastWebSocketResponse!)",
                        className: "MessageCenterTests", methodName: "testTransferImage")
                    _ = self.messageCenter.removeFromReceivedFiles(checksum)
                } else {
                    Logger.log(level: LogLevel.DEBUG, message: "Not Found file with checksum \(checksum) in receivedFiles",
                        className: "MessageCenterTests", methodName: "handleWebSocketResponse")
                    _ = self.messageCenter.addToResponsesWaitingFile(checksum: checksum, response: response)
                    _ = self.messageCenter.removeFromPendingRequests(request_id)
                }
            } else {
                Logger.log(level: LogLevel.DEBUG, message: "Could not get checksum in response handler for request \(request_id)",
                    className: "MessageCenterTests", methodName: "handleWebSocketResponse")
            }
        }
    }
    
    @objc func play() {
        guard let to_user = ChatUser.getById(appStore.state.user.user_id) else {
            return
        }
        let users:[ChatUser] = appStore.state.chat.users.copy()
        if users.count == 0 {
            return
        }
        var i = self.i
        Logger.log(level:LogLevel.DEBUG,message:"Started timer",className:"MessageCenterTests",methodName:"loadTestState")
        if i>5 {
            i = 1
        }
        if i1>5 {
            i1 = 1
        }
        if let from_user = ChatUser.getById("u\(i)",collection:users) {
            let text = "Hi, hello, Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello," +
            "Hi, hello, Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello," +
            "Hi, hello, Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello," +
            "Hi, hello, Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,"
//            "Hi, hello, Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello," +
//            "Hi, hello, Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello," +
//            "Hi, hello, Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello,Hi, hello";
            let message = ChatMessage(id: "m\(appStore.state.chat.messages.count)",
                timestamp: Int.init(Date().timeIntervalSince1970/1000),
                from_user: from_user,
                text: text,
                attachment: nil,//images["splash"],
                room: nil,
                to_user: to_user)
            var messages:[ChatMessage] = appStore.state.chat.messages.copy()
            messages.append(message)
            appStore.dispatch(ChatState.changeMessages(messages: messages))
            Logger.log(level:LogLevel.DEBUG,message:"Pushed new message from user \(from_user.id)",
                className:"MessageCenterTests",methodName:"loadTestState")
            i = i + 1
            from_user.profileImage = self.images["simp\(i1)"]
            appStore.dispatch(ChatState.changeUsers(users: users))
            i1 = i1 + 1
        }
        self.i = i
    }
    
    func loadTestState() {
        let room1 = ChatRoom(id: "r1", name: "Room 1")
        let room2 = ChatRoom(id: "r2", name: "Room 2")
        appStore.dispatch(ChatState.changeRooms(rooms:[room1,room2]))
        let _ = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.play), userInfo: nil, repeats: true)
    }
    
    func loadUsers() {
        var users = [ChatUser]()
        for i in 1...5 {
            let user = ChatUser(id:"u\(i)")
            user.login = "user\(i)"
            user.email = "user\(i)@test.com"
            user.first_name = "User\(i)"
            user.last_name = "Userov\(i)"
            user.room = ChatRoom.getById("r1")
            users.append(user)
        }
        let user = ChatUser(id: appStore.state.user.user_id)
        users.append(user)
        appStore.dispatch(ChatState.changeUsers(users:users))
    }

}
