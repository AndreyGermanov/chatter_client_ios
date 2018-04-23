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
    
    /**
     * Logout action
     */
    struct logout: UserAction,MessageCenterResponseListener {
        
        var messageCenter: MessageCenter = (UIApplication.shared.delegate as! AppDelegate).msgCenter
        /**
         * Action starter. Creates logout request to server and waits
         * for response
         */
        func exec() {
            let user = appStore.state.user
            Logger.log(level:LogLevel.DEBUG,message:"Started logout action for user: \(user)",
                className:"ChatState",methodName:"logout.exec")
            if user.user_id.isEmpty {
                Logger.log(level:LogLevel.WARNING,message:"Could not start this action because did not login",
                           className:"ChatState",methodName:"logout.exec")
                appStore.dispatch(ChatState.changeErrors(errors:["general":.INTERNAL_ERROR]))
                return
            }
            if !messageCenter.isConnected() {
                Logger.log(level:LogLevel.WARNING,message:"Server connection error",
                           className:"ChatState",methodName:"logout.exec")
                appStore.dispatch(ChatState.changeErrors(errors:["general":.RESULT_ERROR_CONNECTION_ERROR]))
                return
            }
            let request:[String:Any] = ["action":"logout_user","sender":self]
            Logger.log(level:LogLevel.DEBUG,message:"Prepared request for MessageCenter: \(request)",
                className:"ChatState",methodName:"logout.exec")
            guard let response = messageCenter.addToPendingRequests(request) else {
                Logger.log(level:LogLevel.DEBUG,message:"Could not put request to pendingRequests queue",
                           className:"ChatState",methodName:"logout.exec")
                appStore.dispatch(ChatState.changeErrors(errors:["general":.INTERNAL_ERROR]))
                return
            }
            Logger.log(level:LogLevel.DEBUG,message:"Pushed request to pendingRequests queue. Request content: \(response)",
                className:"ChatState",methodName:"logout.exec")
            appStore.dispatch(ChatState.changeShowProgressIndicator(showProgressIndicator: true))
        }
        
        /**
         * Method, which MessageCenter calls when receive response for request, generated by this action.
         *
         * - Parameter request_id: ID of request
         * - Parameter response: Response body
         */
        func handleWebSocketResponse(request_id: String, response: [String : Any]) {
            Logger.log(level:LogLevel.DEBUG,message:"Received logout response for request \(request_id). " +
                "Response body: \(response)", className:"ChatState",methodName:"logout.handleWebSocketResponse")
            _ = self.messageCenter.removeFromRequestsWaitingResponses(request_id)
            if !ChatState.validateResponse(request_id: request_id, response: response) {
                return
            }
            Logger.log(level:LogLevel.DEBUG,message:"Successfull response received. Clearing current user data",
                       className:"chatState",methodName:"logout.handleWebSocketResponse")
            UserState.logoutUser()
        }
    }
    
    /**
     * Action used to load users list from server, with session information
     * and profile images
     */
    struct loadUsers: ChatAction, MessageCenterResponseListener {
        
        /// Link to message center instance, used to process request
        var messageCenter: MessageCenter = (UIApplication.shared.delegate as! AppDelegate).msgCenter
        
        /**
         * Method which MessageCenter invokes when receives response for loadUsers action.
         *
         * - Parameter request_id: ID of request from requestsWaitingResponses queue
         * - Parameter response: Body of response
         */
        func handleWebSocketResponse(request_id: String, response: [String : Any]) {
            

        }
    }
    
    /**
     * Utility function which used to validate response and make needed state
     * updates if response contains errors
     *
     * - Parameter request_id: ID of request, to which response received
     * - Parameter response: Body of response to validate
     * - Returns: true if no errors or false otherwise
     */
    static func validateResponse(request_id:String,response:[String:Any]) -> Bool {
        let status = response["status"] as? String
        appStore.dispatch(ChatState.changeShowProgressIndicator(showProgressIndicator: false))
        if status == nil {
            Logger.log(level:LogLevel.DEBUG,message:"Response for request \(request_id) does not contain 'status' field",
                className:"ChatState",methodName:"validateResponse")
            appStore.dispatch(ChatState.changeErrors(errors:["general":.RESULT_ERROR_UNKNOWN_ERROR]))
            return true
        }
        if status != "ok" && status != "error" {
            appStore.dispatch(ChatState.changeErrors(errors:["general":.RESULT_ERROR_UNKNOWN_ERROR]))
            Logger.log(level:LogLevel.WARNING,message:"Server did not return correct status to user login request \(request_id)",
                className:"ChatState",methodName:"validateResponse")
            return true
        }
        if status == "error" {
            if let status_code_string = response["status_code"] as? String {
                if let status_code = ChatScreenError(rawValue: status_code_string) {
                    appStore.dispatch(ChatState.changeErrors(errors:["general":status_code]))
                    Logger.log(level:LogLevel.DEBUG,message:"User login error: \(status_code.rawValue)",
                        className:"ChatState",methodName:"validateResponse")
                } else {
                    appStore.dispatch(ChatState.changeErrors(errors:["general":.RESULT_ERROR_UNKNOWN_ERROR]))
                    Logger.log(level:LogLevel.DEBUG,message:"User login error: \(ChatScreenError.RESULT_ERROR_UNKNOWN_ERROR.rawValue)",
                        className:"ChatState",methodName:"validateResponse")
                }
            } else {
                appStore.dispatch(ChatState.changeErrors(errors:["general":.RESULT_ERROR_UNKNOWN_ERROR]))
                Logger.log(level:LogLevel.WARNING,message:"Server did not return correct status_code for request \(request_id)",
                    className:"ChatState",methodName:"validateResponse")
            }
            return false
        }
        return true
    }
}

/// Chat state screen error definitions
enum ChatScreenError: String {
    case RESULT_OK = "RESULT_OK"
    case RESULT_ERROR_CONNECTION_ERROR = "RESULT_ERROR_CONNECTION_ERROR"
    case INTERNAL_ERROR = "INTERNAL ERROR"
    case AUTHENTICATION_ERROR = "AUTHENTICATION_ERROR"
    case RESULT_ERROR_UNKNOWN_ERROR = "RESULT_ERROR_UNKNOWN_ERROR"
}

extension ChatScreenError: RawRepresentable {
    typealias  RawValue = String
    /// Extension calculated variable used to get text representation of each error
    var message: String {
        switch self {
        case .RESULT_ERROR_CONNECTION_ERROR: return "Connection error."
        case .RESULT_ERROR_UNKNOWN_ERROR: return "Unknown error. Please, call support"
        case .INTERNAL_ERROR: return "System error. Please, call support"
        case .AUTHENTICATION_ERROR: return "Authentication error. Please, login again"
        case .RESULT_OK: return ""
        }
    }
}
