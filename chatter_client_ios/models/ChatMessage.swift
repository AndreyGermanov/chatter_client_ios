//
//  ChatMessage.swift
//  chatter_client_ios
//
//  Model for Chat Message
//
//  Created by user on 22.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation

/**
 * Class describes chat message, which sent "from_user" either to specified "to_room"
 * or to private chat if no room specified
 */
class ChatMessage: Model {    
    /// Time of message
    var timestamp: Int
    /// Link to user sender of message
    var from_user: ChatUser
    /// Link to user receiver of message
    var to_user: ChatUser? = nil
    /// Link to room, to which message sent (optional)
    var room: ChatRoom? = nil
    /// Message text (optional)
    var text: String = ""
    /// Attached image (optional)
    var attachment: Data? = nil
    /// True if message is unread by current user
    var unread: Bool = true
    
    /**
     * Constructor of message
     *
     * - Parameter id: Unique id of message
     * - Parameter timestamp: Time of message
     * - Parameter from_user: User, which created this message
     * - Parameter to_user: User, to which message sent
     * - Parameter room: Room, to which message sent
     * - Parameter message: Text of message
     * - Parameter attachment: Attached image if exists
     */
    init(id:String="", timestamp:Int=0, from_user:ChatUser,
         text:String="", attachment:Data?=nil, room:ChatRoom?=nil,
         to_user:ChatUser?=nil) {
        print(Date().timeIntervalSince1970)
        print(Int(Date().timeIntervalSince1970))
        self.timestamp = timestamp == 0 ? Int(Date().timeIntervalSince1970) : timestamp
        self.from_user = from_user
        self.to_user = to_user
        self.room = room == nil ? (
            ChatRoom.getById(appStore.state.user.default_room) != nil ?
                ChatRoom.getById(appStore.state.user.default_room)! : nil)
            : room
        self.attachment = attachment
        print(text)
        self.text = text
        print(self.text)
        super.init(id:id)
    }
    
    /**
     * Method returns instance of this class by ID
     *
     * - Parameter id: ID of item to return
     * - Returns: ChatMessage instance or nothing if not found
     */
    static func getById(_ id:String) -> ChatMessage? {
        return getModelById(id: id, collection: appStore.state.chat.messages)
    }
    
    /**
     * Method returns total number of unread messages, sent to active user or to
     * room of current user
     *
     * Returns: Int, number of unread messages
     */
    static func getUnreadCount() -> Int {
        var result = 0
        if let user = ChatUser.getById(appStore.state.user.user_id) {
            result = appStore.state.chat.messages.filter {$0.unread == true &&
                ($0.to_user != nil && $0.to_user!.id == user.id) || ($0.room != nil && $0.room!.id == user.room!.id)}.count
        }
        return result
    }

}
