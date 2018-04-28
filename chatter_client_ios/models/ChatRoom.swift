//
//  ChatRoom.swift
//  chatter_client_ios
//
//  Model for Chat room
//
//  Created by user on 22.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation

/**
 * Class describes Chat room
 */
class ChatRoom: Model {
    /// Name of room
    var name: String
    
    /**
     * Class constructor
     *
     * - Parameter id: UUID of room
     * - Parameter name: String name of room
     */
    init(id:String,name:String) {
        self.name = name
        super.init(id:id)
    }
    
    /**
     * Method returns instance of this class by ID
     *
     * - Parameter id: ID of item to return
     * - Returns: ChatRoom instance or nothing if not found
     */
    static func getById(_ id:String) -> ChatRoom? {
        return getModelById(id: id, collection: appStore.state.chat.rooms)
    }
    
    /**
     * Method returns array of users which are currently in this room
     *
     * - Parameter: Collection of users to search in (optional)
     * - Returns: [ChatUser] array of users
     */
    func getUsers(_ collection:[ChatUser]?=nil) -> [ChatUser] {
        var result = [ChatUser]()
        var users = collection
        if users == nil {
            users = appStore.state.chat.users
        }
        if let me = ChatUser.getById(appStore.state.user.user_id,collection:users!) {
            result = users!.filter {$0.room != nil && $0.room!.id == self.id && $0.isLogin && $0.id != me.id}
                .sorted {$0.lastActivityTime > $1.lastActivityTime}.map { $0.copy() }
        }
        return result
    }
    
    /**
     * Method returns number of unread messages in this room
     *
     * - Parameter collection: Collection of messages to search in (optional)
     * - Parameter users: Collection of users to use as a base
     * - Returns: Int Number of messages
     */
    func getUnreadMessagesCount(_ collection:[ChatMessage]?=nil,users:[ChatUser]?=nil) -> Int {
        var result = 0
        var messages = collection
        if messages == nil {
            messages = appStore.state.chat.messages
        }
        var users = users
        if users == nil {
            users = appStore.state.chat.users
        }
        if let me = ChatUser.getById(appStore.state.user.user_id,collection:users!) {
            result = messages!.filter {$0.room != nil && $0.room!.id == self.id && $0.from_user.id != me.id}.count
        }
        return result
    }
    
    /**
     * Method returns all messages in this room, sorted ascending by timestamp
     *
     * - Parameter collection: Collection of messages to search in (optional)
     * - Parameter users: Collection of users to use as a base
     * - Returns: [ChatMessage] array of messages
     */
    func getMessages(_ collection:[ChatMessage]?=nil,users:[ChatUser]?=nil) -> [ChatMessage] {
        var result = [ChatMessage]()
        var messages = collection
        if messages == nil {
            messages = appStore.state.chat.messages
        }
        var users = users
        if users == nil {
            users = appStore.state.chat.users
        }
        if ChatUser.getById(appStore.state.user.user_id,collection:users) != nil {
            result = messages!.filter {$0.room != nil && $0.room!.id == self.id }
                .sorted { $0.timestamp < $1.timestamp}.map { $0.copy() }
        }
        return result
    }
    
    /**
     * Method returns copy of room object
     * - Returns: ChatRoom object copy of current one
     */
    override func copy() -> ChatRoom {
        return ChatRoom(id:self.id,name:self.name)
    }
    
    /**
     * Method converts object to HashMap
     *
     * - Returns: Dictionary with object properties
     */
    override func toHashMap() -> [String:Any] {
        return ["id":self.id,"name":self.name]
    }
}
