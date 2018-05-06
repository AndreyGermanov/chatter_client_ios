//
//  ChatUser.swift
//  chatter_client_ios
//
//  ChatUser model definition
//
//  Created by user on 22.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation

/***
 * Definitions of user roles
 */
enum UserRole: Int {
    case USER = 1, ADMIN = 2
}

/**
 * Class represents user in chat
 */
class ChatUser: Model {
    /// User login name
    var login: String = ""
    /// User email
    var email: String = ""
    /// User First Name
    var first_name: String = ""
    /// User Last Name
    var last_name: String = ""
    /// User Gender
    var gender: String = "M"
    /// Date of Birth of user
    var birthDate: Int = 0
    /// Last activity time of user (when he send last message), or login or logout
    var lastActivityTime: Int = 0
    /// Room, in which user currently presents
    var room: ChatRoom?
    /// Is user login and active right now
    var isLogin: Bool = false
    /// Role of user
    var role: Int = 1
    /// Profile image
    var profileImage: Data?
    /// Profile image checksum
    var profileImageChecksum: Int = 0

    /**
     * Method returns instance of this class by ID
     *
     * - Parameter id: ID of item to return
     * - Parameter collection: Array of users to search in (optional)
     * - Returns: ChatUser instance or nothing if not found
     */
    static func getById(_ id: String, collection: [ChatUser]?=nil) -> ChatUser? {
        var users = collection
        if users == nil {
            users = appStore.state.chat.users
        }
        return getModelById(id: id, collection: users)
    }

    /**
     * Method returns array of private messages, sent by this user
     * to active user.
     *
     * - Parameter collection: Array of source messages (optional)
     * - Parameter users: Array of users to use as a base (optional)
     * - Returns: [ChatMessage] array of all private messages
     */
    func getPrivateMessages(_ collection: [ChatMessage]?=nil, users: [ChatUser]?=nil) -> [ChatMessage] {
        var result = [ChatMessage]()
        var messages = collection
        if messages == nil {
            messages  = appStore.state.chat.messages
        }
        var users = users
        if users == nil {
            users = appStore.state.chat.users
        }
        if let me = ChatUser.getById(appStore.state.user.user_id, collection: users!) {
            if me.id == self.id {
                return result
            }
            result = messages!.filter {$0.to_user != nil &&
                ($0.from_user.id == self.id && $0.to_user!.id == me.id) || ($0.from_user.id == me.id && $0.to_user!.id == self.id)}
                .sorted { $0.timestamp < $1.timestamp }.map {
                    $0.copy()
            }
        }
        return result
    }

    /**
     * Method returns number of unread messages from this user
     *
     * - Parameter collection: Collection of messages to search in (optional)
     * - Parameter users: Collection of users, which use as a base (optional)
     * - Returns: Int number of unread messages
     */
    func getUnreadMessagesCount(_ collection: [ChatMessage]?=nil, users: [ChatUser]?=nil) -> Int {
        var result = 0
        var messages = collection
        if messages == nil {
            messages  = appStore.state.chat.messages
        }
        var users = users
        if users == nil {
            users = appStore.state.chat.users
        }
        if let me = ChatUser.getById(appStore.state.user.user_id, collection: users!) {
            if me.id == self.id {
                return 0
            }
            result = messages!.filter {$0.from_user.id == self.id && $0.to_user != nil && $0.to_user!.id == me.id && $0.unread}.count
        }
        return result
    }

    /**
     * Method returns copy of room object
     * - Returns: copy of current object
     */
    override func copy() -> ChatUser {
        let result = ChatUser(id: self.id)
        result.email = self.email
        result.login = self.login
        result.birthDate = self.birthDate
        result.first_name = self.first_name
        result.last_name = self.last_name
        result.gender = self.gender
        result.isLogin = self.isLogin
        result.lastActivityTime = self.lastActivityTime
        result.profileImage = self.profileImage
        result.profileImageChecksum = self.profileImageChecksum
        result.role = self.role
        result.room = self.room?.copy()
        return result
    }

    /**
     * Method compares current object with provided obj and returns
     * true if they are equal and false otherwise
     *
     * - Parameter obj: Object to compare
     * - Returns: true if they are equal and false otherwise
     */
    func equals(_ obj: ChatUser?) -> Bool {
        return super.equals(obj) && ChatRoom.compare(model1: self.room, model2: obj!.room)
    }

    /**
     * Method converts object to HashMap
     *
     * - Returns: Dictionary with object properties
     */
    override func toHashMap() -> [String: Any] {
        var result: [String: Any] =  [
            "id": self.id,
            "login": self.login,
            "email": self.email,
            "first_name": self.first_name,
            "last_name": self.last_name,
            "gender": self.gender,
            "birthDate": self.birthDate,
            "role": self.role,
            "lastActivityTime": self.lastActivityTime,
            "isLogin": self.isLogin,
            "profileImageChecsum": self.profileImageChecksum
        ]
        if let room = self.room {
            result["room"] = room
        }
        if let profileImage = self.profileImage {
            result["profileImage"] = profileImage
        }
        return result
    }
}
