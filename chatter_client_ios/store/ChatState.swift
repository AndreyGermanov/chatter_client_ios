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
 * Holds Redux application state for Chat screen
 */
struct ChatState {
    
    /*******************
     * State variables *
     *******************/
    
    var rooms = [ChatRoom]()
    var users = [ChatUser]()
    var messages = [ChatMessage]()
    
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
