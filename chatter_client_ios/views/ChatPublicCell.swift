//
//  ChatPublicCell.swift
//  chatter_client_ios
//
//  Created by user on 26.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit
import ReSwift

/**
 *  ViewController for Chat room (cell in TableView of Chat screen,
 &  which handles Public Chat Room tab)
 */
class ChatPublicCell: UITableViewCell,ChatViewControllerCell,StoreSubscriber {
    
    /// Alias to type of Application State
    typealias StoreSubscriberStateType = AppState
    
    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState?
    
    /// Current list of chat messages, displayed in this room
    var messages = [ChatMessage]()
    
    /**
     * Function used to determine should content be updated
     * on application state changes or not
     *
     * - Parameter newState: new state which need to compare to current one
     *
     */
    func shouldUpdateContent(newState:ChatState) -> Bool {
        return true
    }
    
    /**
     * Function, executed by Redux Store every time when application state
     * changed. Used to update UI according to changed state
     *
     * - Parameter newState: new changed state
     */
    func newState(state: AppState) {
        let state = state.chat
        if shouldUpdateContent(newState: state) {
            messages = state.currentRoom!.getMessages()
        }
    }
}

