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
    
    /// Link to chat table view
    @IBOutlet weak var privateChatTableView: UITableView!
    /// Link to message input field
    @IBOutlet weak var messageInputField: UITextField!
   
    /**
     * Callback called when cell initialized
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        // subscribe to application state change events
        privateChatTableView.dataSource = self
        privateChatTableView.delegate = self
        privateChatTableView.estimatedRowHeight = 107.0
        privateChatTableView.rowHeight = UITableViewAutomaticDimension
        appStore.subscribe(self)
    }
    
    /**
     * Redux state change callback. Executes when state changes. Used to update
     * UI based on new state
     *
     * - Parameter state: Link to new updated state
     */
    func newState(state: AppState) {
        Logger.log(level:LogLevel.DEBUG_UI,message:"Received state update for \(String(describing:user?.login)) private chat window",
            className:"ChatPrivateChatCell",methodName:"newState")
        let shouldUpdate = shouldUpdateTable(state.chat)
        if let selectedUser = state.chat.selectedUser?.copy() {
            user = selectedUser
            messages = selectedUser.getPrivateMessages()
        }
        self.state = state.chat.copy()
        if shouldUpdate {
            Logger.log(level:LogLevel.DEBUG_UI,message:"Reload chat tableView from \(String(describing:user?.login)) private chat window." +
                "Messages \(messages)",className:"ChatPrivateChatCell",methodName:"newState")
            privateChatTableView.reloadData()
            if messages.count > 0 {
                let lastRow = IndexPath(row:messages.count-1,section:0)
                privateChatTableView.scrollToRow(at: lastRow, at: .bottom, animated: true)
            }
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

/**
 * Extension used to communicate with privateChatTableView table
 */
extension ChatPrivateChatCell: UITableViewDelegate,UITableViewDataSource {
    
    /**
     * Method which tableView executes to determine number of rows in TableView
     *
     * - Parameter tableView: Source tableView
     * - Parameter section: Number of section for which need to get number of rows
     * - Returns: Number of rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    /**
     * Method which tableView executes to get and drow cell in table view
     *
     * - Parameter tableView: Source tableView
     * - Parameter indexPath: Coordinates of cell to draw
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "privateChatMessageCell") as? ChatMessageCell {
            return setupChatMessageCell(cell,index:indexPath.row)
        } else {
            Logger.log(level: LogLevel.WARNING, message: "Could not get ChatMessageCell object",
                       className: "ChatPrivateChatCell", methodName: "cellForRowAt")
            return UITableViewCell()
        }
    }

    /**
     * Method used to determine if need to reload data in tableView to meet new application state
     *
     * - Parameter newState: New application state
     * - Returns: True if need to reload data and false otherwise
     */
    func shouldUpdateTable(_ newState:ChatState) -> Bool {
        return ChatMessage.compare(models1: messages, models2: newState.selectedUser?.getPrivateMessages()) ||
            ChatUser.compare(model1:user,model2:newState.selectedUser)
    }
    
    /**
     * Method used to setup cell inside tableView when draw or redraw
     *
     * - Parameter cell: Link to Cell object to setup
     * - Parameter index: Row Index of cell
     * - Returns: Cell after setup all options, ready to display
     */
    func setupChatMessageCell(_ cell:ChatMessageCell,index:Int) -> ChatMessageCell {
        let message = messages[index]
        cell.message = message.copy()
        cell.messageTextLabel.text = message.text
        cell.userLoginLabel.text = message.from_user.login
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: Date(timeIntervalSince1970: Double.init(message.timestamp*1000)))
        cell.messageDateLabel.text = dateString
        if let image = message.attachment {
            cell.messageAttachmentImageView.image = UIImage(data: image)
        }
        if let profileImage = message.from_user.profileImage {
            cell.userProfileImageView.image = UIImage(data: profileImage)
        }
        return cell
    }
}
