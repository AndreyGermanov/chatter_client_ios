//
//  ChatScreenReducer.swift
//  chatter_client_ios
//
//  Created by user on 21.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import ReSwift

/**
 *  Reducer, used to process Redux actions of Chat Screen.
 *
 * - Parameter action: Action to handle
 * - Parateter state: Input state
 * - Returns State after applying action to it
 */
func chatScreenReducer(action: Action, state: ChatState) -> ChatState {
    var newState = state
    Logger.log(level: LogLevel.DEBUG_REDUX, message: "ChatScreenReducer: Received action \(action)",
        className: "chatScreenReducer", methodName: "chatScreenReducer")
    switch action {
    case let action as ChatState.changeRooms:
        newState.rooms = action.rooms
    case let action as ChatState.changeUsers:
        newState.users = action.users
    case let action as ChatState.changeMessages:
        newState.messages = action.messages
    case let action as ChatState.changeErrors:
        newState.errors = action.errors
    case let action as ChatState.changeCurrentRoom:
        newState.currentRoom = action.currentRoom
    case let action as ChatState.changeSelectedUser:
        newState.selectedUser = action.selectedUser   
    case let action as ChatState.changeChatAttachment:
        newState.chatAttachment = action.chatAttachment
    case let action as ChatState.changePrivateChatAttachment:
        newState.privateChatAttachment = action.privateChatAttachment
    case let action as ChatState.changePrivateChatMode:
        newState.privateChatMode = action.privateChatMode
    case let action as ChatState.changeChatMode:
        newState.chatMode = action.chatMode
    case let action as ChatState.changeShowProgressIndicator:
        newState.showProgressIndicator = action.showProgressIndicator
    default:
        break
    }
    Logger.log(level: LogLevel.DEBUG_REDUX, message: "ChatScreenReducer: ChatState after reducing - \(newState)",
        className: "chatScreenReducer", methodName: "chatScreenReducer")
    return newState
}
