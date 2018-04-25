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
    class loadUsers: ChatAction, MessageCenterResponseListener {
        
        /// Link to message center instance, used to process request
        var messageCenter: MessageCenter = (UIApplication.shared.delegate as! AppDelegate).msgCenter
        
        /// Callback function, which executes after successfull response received
        var callback: (()->())?
        
        /**
         * Action executor. Used to create request to WebSocket server and place it to pendingRequests queue
         *
         * - Parameter callback: Lambda function which executed after successfull response to this action received
         */
        func exec(callback: (()->())?=nil) {
            Logger.log(level:LogLevel.DEBUG,message:"Started 'load users' action.",className:"ChatState",methodName:"loadUsers.exec")
            if (appStore.state.chat.showProgressIndicator) {
                Logger.log(level:LogLevel.WARNING,message:"Request already going. Could not send until finish",className:"ChatState",methodName:"loadUsers.exec")
                return
            }
            if (!messageCenter.isConnected()) {
                Logger.log(level:LogLevel.WARNING,message:"No connection to server.",className:"ChatState",methodName:"loadUsers.exec")
                appStore.dispatch(ChatState.changeErrors(errors:["general":ChatScreenError.RESULT_ERROR_CONNECTION_ERROR]))
                return
            }
            Logger.log(level:LogLevel.DEBUG,message:"Prepare request to MessageCenter",className:"ChatState",methodName:"loadUsers.exec")
            let message:[String:Any] = ["action":"get_users_list","sender":self]
            guard let request = messageCenter.addToPendingRequests(message) else {
                Logger.log(level:LogLevel.WARNING,message:"Could not prepare request to MessageCenter",className:"ChatState",methodName:"loadUsers.exec")
                return
            }
            self.callback = callback
            appStore.dispatch(ChatState.changeShowProgressIndicator(showProgressIndicator: true))
            Logger.log(level:LogLevel.DEBUG,message:"Sent request to MessageCenter. Request body: \(request)",className:"ChatState",methodName:"loadUsers.exec")
        }
        
        /**
         * Method which MessageCenter invokes when receives response for loadUsers action.
         *
         * - Parameter request_id: ID of request from requestsWaitingResponses queue
         * - Parameter response: Body of response
         */
        func handleWebSocketResponse(request_id: String, response: [String : Any]) {
            Logger.log(level:LogLevel.DEBUG,message:"Received 'loadUsers' response for request_id:\(request_id). Response body: \(response)",
                className:"ChatState",methodName:"loadUsers.handleWebSocketResponse")
            appStore.dispatch(ChatState.changeShowProgressIndicator(showProgressIndicator: false))
            if (!ChatState.validateResponse(request_id: request_id, response: response)) {
                _ = messageCenter.removeFromRequestsWaitingResponses(request_id)
                return
            }
            let users = self.getUsersList(response)
            if users.count == 0 {
                Logger.log(level:LogLevel.DEBUG,message:"Users list in this response is empty. Response: \(response)",
                    className:"ChatState",methodName:"loadusers.handleWebSocketResponse")
                _ = messageCenter.removeFromRequestsWaitingResponses(request_id)
                return
            }
            Logger.log(level:LogLevel.DEBUG,message:"Begin update users data from list: \(users)",
                className:"ChatState",methodName:"loadUsers.handleWebSocketResponse")
            var changed = false
            for user in users {
                if (ChatState.updateUser(data:user,response:response)) {
                    changed = true
                }
            }
            if changed {
                Logger.log(level:LogLevel.DEBUG,message:"Updating chat screen state with changed information about users",
                           className:"ChatState",methodName:"loadUsers.handleWebSocketResponse")
                appStore.dispatch(ChatState.changeUsers(users: appStore.state.chat.users))
            } else {
                Logger.log(level:LogLevel.DEBUG,message:"No changes in users list after loading data. No need to update chat screen state",
                            className:"ChatState",methodName:"loadUsers.handleWebSocketResponse")
            }
            _ = messageCenter.removeFromRequestsWaitingResponses(request_id)
            if callback != nil {
                callback!()
            }
            self.callback = nil
        }
        
        /**
         * Utility function which used to get 'list' of users from response
         * and convert it to [[String:Any]] array
         *
         * - Parameter response: Response body to parse
         * - Returns Array of users data. Each user item is Hashmap [String:Any
         */
        func getUsersList(_ response:[String : Any]) -> [[String:Any]] {
            Logger.log(level:LogLevel.DEBUG,message:"Begin extracting 'list' of users from response: \(response)",
                className:"ChatState",methodName:"loadUsers.getUsersList")
            var result = [[String:Any]]()
            guard let listObj = response["list"] else {
                Logger.log(level:LogLevel.WARNING,message:"Response does not contain 'list' field with results. Response body: \(response).",
                    className:"ChatState",methodName:"loadUsers.getUsersList")
                return result
            }
            if !(listObj is String) && !(listObj is NSArray) {
                Logger.log(level:LogLevel.WARNING,message:"'list' is not in correct format: \(listObj)",
                    className:"ChatState",methodName:"loadUsers.getUsersList")
                return result
            }
            Logger.log(level:LogLevel.DEBUG,message:"Extracted 'list' item from response: \(listObj)",
                className:"ChatState",methodName:"loadUsers.getUsersList")
            var list = NSArray()
            if listObj is String {
                do {
                    let listStr = listObj as! String
                    list = try JSONSerialization.jsonObject(with: listStr.data(using: String.Encoding.utf8)!) as! NSArray
                } catch {
                    Logger.log(level:LogLevel.WARNING,message:"Could not parse list of users as JSON string \(listObj)",
                        className:"ChatState",methodName:"loadUsers.getUsersList")
                    return result
                }
            } else if (listObj is NSArray) {
                list = listObj as! NSArray
            }
            if (list.count==0) {
                Logger.log(level:LogLevel.WARNING,message:"Empty list returned after parsing \(listObj)",
                    className:"ChatState",methodName:"loadUsers.getUsersList")
                return result
            }
            Logger.log(level:LogLevel.DEBUG,message:"Beginning to parse users list: \(list)",
                className:"ChatState",methodName:"loadUsers.getUsersList")
            for item in list {
                guard let user = item as? [String:Any] else {
                    Logger.log(level:LogLevel.WARNING,message:"Could not parse user \(item)",
                        className:"ChatState",methodName:"loadUsers.getUsersList")
                    continue
                }
                result.append(user)
                
            }
            Logger.log(level:LogLevel.DEBUG,message:"Returning resulting users list: \(result)",
                className:"ChatState",methodName:"loadUsers.getUsersList")
            return result
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
                    Logger.log(level:LogLevel.DEBUG,message:"Found Error: \(status_code.rawValue)",
                        className:"ChatState",methodName:"validateResponse")
                } else {
                    appStore.dispatch(ChatState.changeErrors(errors:["general":.RESULT_ERROR_UNKNOWN_ERROR]))
                    Logger.log(level:LogLevel.DEBUG,message:"Unknown error: \(ChatScreenError.RESULT_ERROR_UNKNOWN_ERROR.rawValue)",
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
    
    /**
     * Utility function used to create or update ChatUser instance which is in 'users' list from provided HashMap
     *
     * - Parameter data: Dictionary with values to update
     * - Parameter response: Full body of response from MessageCenter, if need to request profile Images (optional)
     * - Returns: true if user updated or false otherwise
     */
    static func updateUser(data:[String:Any],response:[String:Any]?=nil) -> Bool {
        let messageCenter: MessageCenter = (UIApplication.shared.delegate as! AppDelegate).msgCenter
        var result = false
        guard let user_id = data["_id"] as? String else {
            Logger.log(level:LogLevel.WARNING,message:"User record \(data) does not contain '_id' fields. Could not process",
                className:"ChatState",methodName:"updateUser")
            return result
        }
        var users = appStore.state.chat.users
        var user = ChatUser(id:user_id)
        if ChatUser.getById(user_id) != nil {
            user = ChatUser.getById(user_id)!
        } else {
            users.append(user)
            result = true
        }
        appStore.state.chat.users = users
        if let login = data["login"] as? String {
            if user.login != login && !login.isEmpty {
                user.login = login
                result = true
            }
        }
        if let email = data["email"] as? String {
            if user.email != email && !email.isEmpty {
                user.email = email
                result = true
            }
        }
        if let room_id = data["room"] as? String {
            if let room = ChatRoom.getById(room_id) {
                if user.room == nil {
                    user.room = room
                    result = true
                } else if user.room!.id != room.id {
                    user.room = room
                    result = true
                }
            } else {
                Logger.log(level:LogLevel.WARNING,message:"Could not find room for \(room_id). Data: \(data)",
                    className:"ChatState",methodName:"updateUser")
            }
        } else {
            Logger.log(level:LogLevel.WARNING,message:"User data does not contain 'room' field. Data: \(data)",
                className:"ChatState",methodName:"updateUser")
        }
        if let role = parseAnyToInt(data["role"]) {
            if role>0 && user.role != role {
                user.role = role
                result = true
            }
        }
        if let first_name = data["first_name"] as? String {
            if user.first_name != first_name && !first_name.isEmpty {
                user.first_name = first_name
                result = true
            }
        }
        if let last_name = data["last_name"] as? String {
            if user.last_name != last_name && !last_name.isEmpty {
                user.last_name = last_name
                result = true
            }
        }
        if let gender = data["gender"] as? String {
            if user.gender != gender && ["M","F"].contains(gender) {
                user.gender = gender
                result = true
            }
        }
        if let birthDate = parseAnyToInt(data["birthDate"]) {
            if birthDate>0 && user.birthDate != birthDate {
                user.birthDate = birthDate
                result = true
            }
        }
        if let isLogin = data["isLogin"] as? Bool {
            if user.isLogin != isLogin {
                user.isLogin = isLogin
                result = true
            }
        } else if let isLoginString = data["isLogin"] as? String {
            let isLogin = isLoginString.boolValue
            if user.isLogin != isLogin {
                user.isLogin = isLogin
            }
        }
        if let lastActivityTime = parseAnyToInt(data["lastActivityTime"]) {
            if user.lastActivityTime != lastActivityTime && lastActivityTime>0 {
                user.lastActivityTime = lastActivityTime
                result = true
            }
        }
        if let profileImageChecksum = parseAnyToInt(data["profileImageChecksum"]) {
            if user.profileImageChecksum != profileImageChecksum && profileImageChecksum>0 {
                user.profileImageChecksum = profileImageChecksum
            }
        }
        if (user.profileImageChecksum == 0 || response == nil ||
            (user.profileImage != nil && Int(user.profileImage!.bytes.crc32()) == user.profileImageChecksum)) {
            return result
        }
        guard let profileImageRecord = messageCenter.receivedFiles[user.profileImageChecksum] as? [String:Any]  else {
            let request = messageCenter.addToResponsesWaitingFile(checksum: user.profileImageChecksum, response: response!)
            Logger.log(level:LogLevel.DEBUG,message:"Added response to 'responsesWaitingFileQueue' to wait profile image for \(user.login). " +
                "Response body: \(request)",className:"ChatState",methodName:"updateUser")
            return result
        }
        guard let profileImage =  profileImageRecord["data"] as? Data else {
            Logger.log(level:LogLevel.DEBUG,message:"Could not parse profileImage for checksum \(user.profileImageChecksum)",
                className:"ChatState",methodName:"updateUser")
            _ = messageCenter.removeFromReceivedFiles(user.profileImageChecksum)
            return result
        }
        Logger.log(level:LogLevel.DEBUG,message:"Set received file with checksum \(user.profileImageChecksum) as profile image for \(user.login)",
            className:"ChatState",methodName:"updateUser")
        user.profileImage = profileImage
        result = true
        if messageCenter.responsesWaitingFile[user.profileImageChecksum] != nil {
            _ = messageCenter.removeFromResponsesWaitingFile(user.profileImageChecksum)
        }
        _ = messageCenter.removeFromReceivedFiles(user.profileImageChecksum)
        return result
    }
}

/// Chat state screen error definitions
enum ChatScreenError: String {
    case RESULT_OK = "RESULT_OK"
    case RESULT_ERROR_CONNECTION_ERROR = "RESULT_ERROR_CONNECTION_ERROR"
    case INTERNAL_ERROR = "INTERNAL_ERROR"
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
