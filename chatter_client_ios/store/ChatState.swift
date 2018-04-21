//
//  ChatState.swift
//  chatter_client_ios
//  Represents state and actions for Chat screen
//  Created by user on 21.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import Foundation
import ReSwift

/**
 * Base protocol for all Redux actions, related to Chat screen
 */
protocol ChatAction: Action {}

/// Possible modes of chat screen (one of subscreens, which displayed in any moment of time)
enum ChatScreenMode:Int {
    case ROOM = 1, PRIVATE = 2, PROFILE = 3
}

/**
 * Possible models of "private chat" screen. It either shows list of users to chat with (USERS),
 * or chat screen with with selected User
 */
enum PrivateChatScreenMode:Int {
    case USERS = 1, CHAT = 2
}

/**
 * Structure represents Chat room
 */
class ChatRoom: Codable {
    /// Unique ID of room
    let id: String
    /// Name of room
    var name: String
}

/**
 * Structure represents chat message, which sent "from_user" either to specified "to_room"
 * or to private chat if no room specified
 */
class ChatMessage: Codable {
    /// Unique ID of message
    let id: String
    /// Time of message
    let timestamp: Int
    /// Link to user sender of message
    let from_user: ChatUser
    /// Link to user receiver of message
    let to_user: ChatUser? 
    /// Link to room, to which message sent (optional)
    let room: ChatRoom?
    /// Message text (optional)
    let message: String?
    /// Attached image (optional)
    var attachment: Data?
    /// True if message is unread by current user
    var unread: Bool = true
}

/***
 * Definitions of user roles
 */
enum UserRole:Int {
    case USER = 1, ADMIN = 2
}

/**
 * Structure represents user in chat
 */
class ChatUser: Codable {
    /// Unique ID of user
    let id: String
    /// User login name
    var login: String
    /// User email
    var email: String
    /// User First Name
    var first_name: String
    /// User Last Name
    var last_name: String
    /// User Gender
    var gender: String
    /// Date of Birth of user
    var birthDate: Int
    /// Last activity time of user (when he send last message), or login or logout
    var lastActivityTime: Int
    /// Room, in which user currently presents
    var room: ChatRoom?
    /// Is user login and active right now
    var isLogin: Bool = false
    /// Role of user
    var role: Int
    /// Profile image
    var profileImage: Data?
}

/**
 * Holds Redux application state for Chat screen
 */
struct ChatState {
    
    /*******************
     * State variables *
     *******************/
    
    var rooms: [ChatRoom]? = nil
    var users: [ChatUser]? = nil
    var messages: [ChatMessage]? = nil
    
    var currentRoom: ChatRoom? = nil
    var selectedUser: ChatUser? = nil
    
    var chatMode: ChatScreenMode = .ROOM
    var chatMessage: String = ""
    var chatAttachment: Data? = nil
    
    var privateChatMode: PrivateChatScreenMode = .USERS
    var privateChatMessage: String = ""
    var privateChatAttachment: Data? = nil
    
    var showProgressIndicator = false
    var errors = [String:ChatScreenError]()
    
    /*************************************************
     * Actions which directly mutate state variables *
     *************************************************/
    
    struct changeRooms: ChatAction {
        let rooms: [ChatRoom]
    }
    
    struct changeUsers: ChatAction {
        let users: [ChatUser]
    }
    
    struct changeMessages: ChatAction {
        let messages: [ChatMessage]
    }
    
    struct changeCurrentRoom: ChatAction {
        let currentRoom: ChatRoom
    }
    
    struct changeSelectedUser: ChatAction {
        let selectedUser: ChatUser
    }
    
    struct changeChatMode: ChatAction {
        let chatMode: ChatScreenMode
    }
    
    struct changePrivateChatMode: ChatAction {
        let privateChatMode: PrivateChatScreenMode
    }
    
    struct changeChatMessage: ChatAction {
        let chatMessage: String
    }
    
    struct changePrivateChatMessage: ChatAction {
        let privateChatMessage: String
    }
    
    struct changeChatAttachment: ChatAction {
        let chatAttachment: Data
    }
    
    struct changePrivateChatAttachment: ChatAction {
        let privateChatAttachment: Data
    }
    
    struct changeShowProgressIndicator: ChatAction {
        let showProgressIndicator: Bool
    }
    
    struct changeErrors: ChatAction {
        let errors: [String:ChatScreenError]
    }
    
    /******************
     * Helper methods *
     ******************/
    
    /**
     * Method returns room by id
     *
     * - Parameter id: ID of room to find
     * - Returns 'ChatRoom' object with specified ID or nil if not found
     */
    func getRoomById(id:String) -> ChatRoom? {
        if let rooms = self.rooms {
            let selectedRooms = rooms.filter { it in
                it.id == id
            }
            if selectedRooms.count == 1 {
                return selectedRooms[0]
            }
        }
        return nil
    }
}

/// Chat state screen error definitions
enum ChatScreenError: String {
    case RESULT_OK = "RESULT_OK"
    case RESULT_ERROR_CONNECTION_ERROR = "RESULT_ERROR_CONNECTION_ERROR"
    case RESULT_ERROR_UNKNOWN_ERROR = "RESULT_ERROR_UNKNOWN_ERROR"
}

extension ChatScreenError: RawRepresentable {
    typealias  RawValue = String
    /// Extension calculated variable used to get text representation of each error
    var message: String {
        switch self {
        case .RESULT_ERROR_CONNECTION_ERROR: return "Connection error."
        case .RESULT_ERROR_UNKNOWN_ERROR: return "Unknown error. Please, call support"
        case .RESULT_OK: return ""
        }
    }
}
