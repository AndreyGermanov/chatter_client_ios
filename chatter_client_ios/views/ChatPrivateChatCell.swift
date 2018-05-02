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
    /// Array of chat messages which currently displayed in ScrollView
    var messages = [ChatMessage]()
    /// Array of message View objects, displayed inside scrollview in format [message_id:View]
    var messageViews = [String:UIView]()
    
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
        var messages_to_add = [ChatMessage]()
        if let new_user = state.chat.selectedUser {
            Logger.log(level:LogLevel.DEBUG_UI,message:"Received state update for \(new_user.login) private chat window",
                className:"ChatPrivateChatCell",methodName:"newState")
            let new_user_messages = new_user.getPrivateMessages()
            if (!new_user.equals(user)) {
                messages = [ChatMessage]()
                clearChatWindow()
                Logger.log(level:LogLevel.DEBUG_UI,message:"Cleared chat window of user: \(new_user.login)",
                    className:"ChatPrivateChatCell",methodName:"newState")
            }
            if (!ChatMessage.compare(models1:self.messages,models2:new_user_messages)) {
                messages_to_add = new_user_messages.copy()
                if messages.count>0 {
                    messages_to_add.removeSubrange(0...messages.count-1)
                }
                Logger.log(level:LogLevel.DEBUG_UI,message:"Adding messages to chat window of user: \(new_user.login)",
                    className:"ChatPrivateChatCell",methodName:"newState")
                addMessages(messages_to_add)
            }
            messages = new_user_messages.copy()
            user = new_user.copy()
        }
    }
    
    /**
     * Method used to add messages to chat scrollView
     *
     * - Parameter messages: Array of messages to add
     */
    func addMessages(_ messages:[ChatMessage]) {
        for message in messages {
            let messageView = message.getView()
            messageView.leftAnchor.constraint(equalTo: chatScrollView.leftAnchor, constant: 5.0)
            messageView.rightAnchor.constraint(equalTo: chatScrollView.rightAnchor, constant: 5.0)
            if messageViews.count > 0 {
                if let lastMessageView = messageViews[messages[messages.count-1].id] {
                    messageView.topAnchor.constraint(equalTo: lastMessageView.bottomAnchor, constant: 5.0)
                }
            } else {
                messageView.topAnchor.constraint(equalTo: chatScrollView.topAnchor, constant: 5.0)
            }
            messageView.widthAnchor.constraint(equalTo: chatScrollView.widthAnchor, multiplier: 1.0)
            messageViews[message.id] = messageView
            chatScrollView.contentMode = .bottom
            chatScrollView.contentSize = CGSize(width: 500, height: 5000)
            chatScrollView.addSubview(messageView)
        }
    }
    
    /**
     * Method removes all messages from ScrollView
     */
    func clearChatWindow() {
        for (_,messageView) in messageViews {
            messageView.removeFromSuperview()
        }
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

