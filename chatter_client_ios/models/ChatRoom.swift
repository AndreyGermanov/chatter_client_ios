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
     * - Returns: [ChatUser] array of users
     */
    func getUsers() -> [ChatUser] {
        var result = [ChatUser]()
        if let me = ChatUser.getById(appStore.state.user.user_id) {
            result = appStore.state.chat.users.filter {$0.room != nil && $0.room!.id == self.id && $0.isLogin && $0.id != me.id}
                .sorted {$0.lastActivityTime > $1.lastActivityTime}
        }
        return result
    }
    
    /**
     * Method returns number of unread messages in this room
     *
     * - Returns: Int Number of messages
     */
    func getUnreadMessagesCount() -> Int {
        var result = 0
        if let me = ChatUser.getById(appStore.state.user.user_id) {
            result = appStore.state.chat.messages.filter {$0.room != nil && $0.room!.id == self.id && $0.from_user.id != me.id}.count
        }
        return result
    }
    
    /**
     * Method returns all messages in this room, sorted ascending by timestamp
     *
     * - Returns: [ChatMessage] array of messages
     */
    func getMessages() -> [ChatMessage] {
        var result = [ChatMessage]()
        if ChatUser.getById(appStore.state.user.user_id) != nil {
            result = appStore.state.chat.messages.filter {$0.room != nil && $0.room!.id == self.id }
                .sorted { $0.timestamp < $1.timestamp}
        }
        return result
    }
}
