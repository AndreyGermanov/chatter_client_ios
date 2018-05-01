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
 *  ViewController for Chat cell inside Private chat cell UI
 */
class ChatPrivateChatCell: UITableViewCell, ChatViewControllerCell,StoreSubscriber {
    
    /// Link to application state type
    typealias StoreSubscriberStateType = AppState
    /// Link to parent view controller
    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState = ChatState()
    /// Link to participant of chat
    var user:ChatUser? = nil
    
    /// Link to chat window
    @IBOutlet weak var chatScrollView: UIScrollView!
    /// Link to message input field
    @IBOutlet weak var messageInputField: UITextField!
   
    /**
     * Callback called when cell initialized
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        // subscribe to application state change events
        appStore.subscribe(self)
    }
    
    /**
     * Redux state change callback. Executes when state changes. Used to update
     * UI based on new state
     *
     * - Parameter state: Link to new updated state
     */
    func newState(state: AppState) {
        
    }
    
    /** "Add picture" button click handler
     *
     * - Parameter sender: Link to clicked button
     */
    @IBAction func addPictureBtnClick(_ sender: UIButton) {
    }
    
    /**
     * "Send" button click handler
     *
     * - Parameter sender: Link to clicked button
     */
    @IBAction func sendMessageBtnClick(_ sender: UIButton) {
    }
    
    
    
   }

