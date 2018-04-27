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
enum UserRole:Int {
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
    var room: ChatRoom? = nil
    /// Is user login and active right now
    var isLogin: Bool = false
    /// Role of user
    var role: Int = 1
    /// Profile image
    var profileImage: Data? = nil
    /// Profile image checksum
    var profileImageChecksum: Int = 0
    
    /**
     * Method returns instance of this class by ID
     *
     * - Parameter id: ID of item to return
     * - Returns: ChatUser instance or nothing if not found
     */
    static func getById(_ id:String) -> ChatUser? {
        return getModelById(id: id, collection: appStore.state.chat.users)
    }
    
    /**
     * Method returns array of private messages, sent by this user
     * to active user.
     *
     * - Returns: [ChatMessage] array of all private messages
     */
    func getPrivateMessages() -> [ChatMessage] {
        var result = [ChatMessage]()
        if let me = ChatUser.getById(appStore.state.user.user_id) {
            if me.id == self.id {
                return result
            }
            result = appStore.state.chat.messages.filter {$0.to_user != nil && $0.to_user!.id == me.id}
                .sorted { $0.timestamp < $1.timestamp }
        }
        return result
    }
    
    /**
     * Method returns number of unread messages from this user
     *
     * - Returns: Int number of unread messages
     */
    func getUnreadMessagesCount() -> Int {
        var result = 0
        if let me = ChatUser.getById(appStore.state.user.user_id) {
            if me.id == self.id {
                return 0
            }
            result = appStore.state.chat.messages.filter {$0.to_user != nil && $0.to_user!.id == me.id && $0.unread}.count
        }
        return result
    }
    
    /**
     * Function returns copy of room object
     * - Returns: ChatRoom object copy of current one
     */
    func copy() -> ChatUser {
        var result = ChatUser(id: self.id)
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
        result.room = self.room
        return result
    }
    
    /**
     * Compares current object with provided and returns
     * true if they are equal and false otherwise
     *
     * - Parameter obj: Object to compare
     * - Returns: true if they are equal and false otherwise
     */
    func equals(obj:Any?) -> Bool {
        guard let user = obj as? ChatUser else {
            return false
        }
        return self.toHashMap().isEqual(user.toHashMap())
    }
    
    /**
     * Function converts object to HashMap
     *
     * - Returns: Dictionary with object properties
     */
    func toHashMap() -> [String:Any] {
        var result:[String:Any] =  ["id":self.id,
                                    "login":self.login,
                                    "email":self.email,
                                    "first_name":self.first_name,
                                    "last_name":self.last_name,
                                    "gender":self.gender,
                                    "birthDate":self.birthDate,
                                    "role":self.role,
                                    "lastActivityTime":self.lastActivityTime,
                                    "isLogin": self.isLogin,
                                    "profileImageChecsum": self.profileImageChecksum
        ]
        if self.room != nil {
            result["room"] = self.room
        }
        if self.profileImage != nil {
            result["profileImage"] = self.profileImage
        }
        return result
    }

}
