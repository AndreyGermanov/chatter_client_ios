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
class ChatPublicCell: UITableViewCell, ChatViewControllerCell, StoreSubscriber {

    /// Alias to type of Application State
    typealias StoreSubscriberStateType = AppState

    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState = ChatState()

    /// Current list of chat messages, displayed in this room
    var messages = [ChatMessage]()
    
    /// Link to current chat room
    var room:ChatRoom? = nil
    
    /// Link to array of users which are now in room
    var users:[ChatUser]? = nil

    /// Link to chat message input field
    @IBOutlet weak var messageInputField: UITextField!
    
    /// Link to table view with chat messages
    @IBOutlet weak var publicChatTableView: UITableView!
    
    /**
     * Callback called when cell initialized
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        publicChatTableView.dataSource = self
        publicChatTableView.delegate = self
        publicChatTableView.estimatedRowHeight = 107.0
        publicChatTableView.rowHeight = UITableViewAutomaticDimension
        appStore.subscribe(self)
    }
    
    /**
     * Function used to determine should content be updated
     * on application state changes or not
     *
     * - Parameter newState: new state which need to compare to current one
     *
     */
    func shouldUpdateContent(newState: ChatState) -> Bool {
        if newState.chatMode != .ROOM {
            return false
        }
        return !(room?.equals(newState.currentRoom))! || !ChatUser.compare(models1:users,models2:newState.currentRoom?.getUsers())
        || !ChatMessage.compare(models1: messages, models2: newState.currentRoom?.getMessages())
    }

    /**
     * Function, executed by Redux Store every time when application state
     * changed. Used to update UI according to changed state
     *
     * - Parameter newState: new changed state
     */
    func newState(state: AppState) {
        Logger.log(level:LogLevel.DEBUG_UI,message:"Received state update for \(String(describing:room?.name)) public chat window",
            className:"ChatPublicCell",methodName:"newState")
        let state = state.chat
        let shouldUpdate = shouldUpdateContent(newState: state)
        if shouldUpdate {
            room = state.currentRoom?.copy()
            users = room!.getUsers().copy()
            messages = room!.getMessages().copy()
            Logger.log(level:LogLevel.DEBUG_UI,message:"Reload chat tableView from \(String(describing:room?.name)) public chat window." +
                "Messages \(messages)",className:"ChatPublicCell",methodName:"newState")
            publicChatTableView.reloadData()
            if messages.count > 0 {
                let lastRow = IndexPath(row:(messages.count-1)*2,section:0)
                publicChatTableView.scrollToRow(at: lastRow, at: .bottom, animated: true)
            }
        }
    }
    
    /**
     * "Send" button click handler
     *
     * - Parameter sender: Link to clicked button
     */
    @IBAction func sendBtnClick(_ sender: UIButton) {
        guard let messageText = messageInputField.text else {
            return
        }
        if messageText.isEmpty {
            return
        }
        let message = ChatMessage(id: UUID().description,
                                  timestamp: Int(Date().timeIntervalSince1970/1000),
                                  from_user: ChatUser.getById(appStore.state.user.user_id)!,
                                  text: messageText,
                                  attachment: nil,
                                  room: room!,
                                  to_user: nil)
        if let image = state.chatAttachment {
            message.attachment = image
        }
        messages.append(message)
        appStore.dispatch(ChatState.changeMessages(messages:messages))
        messageInputField.text = ""
        appStore.dispatch(ChatState.changeChatAttachment(chatAttachment: nil))
    }
    
    /** "Add picture" button click handler
     *
     * - Parameter sender: Link to clicked button
     */
    @IBAction func addPictureBtnClick(_ sender: UIButton) {
        if state.chatAttachment == nil {
            let photoCtrl = GetPhoto(parent: self.parentViewController!, callback: { data in
                if let image = data {
                    appStore.dispatch(ChatState.changeChatAttachment(chatAttachment: image))
                }
            })
            photoCtrl.run()
        } else {
            let dialog = UIAlertController(title: "Confirm",
                                           message: "Do you want to remove picked image from cache?", preferredStyle: .alert)
            dialog.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
                appStore.dispatch(ChatState.changeChatAttachment(chatAttachment: nil))
            }))
            dialog.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        }
    }
}

/**
 * Extension used to communicate with privateChatTableView table
 */
extension ChatPublicCell: UITableViewDelegate,UITableViewDataSource {
    
    /**
     * Method which tableView executes to determine number of rows in TableView
     *
     * - Parameter tableView: Source tableView
     * - Parameter section: Number of section for which need to get number of rows
     * - Returns: Number of rows
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count*2
    }
    
    /**
     * Method which tableView executes to get and drow cell in table view
     *
     * - Parameter tableView: Source tableView
     * - Parameter indexPath: Coordinates of cell to draw
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let messageIndex = Int(floor(Double(indexPath.row/2)))
        if indexPath.row % 2 != 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "publicChatAttachmentCell") as! ChatAttachmentCell
            return setupChatMessageAttachmentCell(cell, index: messageIndex)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "publicChatMessageCell") as! ChatMessageCell
            return setupChatMessageCell(cell, index: messageIndex)
        }
    }
    
    /**
     * Method used to get height for tableView row, depending on row number
     *
     * - Parameter tableView: Source tableView
     * - Parameter indexPath: Coordinates of row
     * - Returns: calculated height of row
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let messageIndex = Int(floor(Double(indexPath.row/2)))
        if indexPath.row % 2 == 0 {
            return UITableViewAutomaticDimension
        }
        guard let imageData = messages[messageIndex].attachment else {
            return 0.0
        }
        guard let image = UIImage(data:imageData) else {
            return 0.0
        }
        return image.size.height
    }
    
    
    /**
     * Method used to setup Message text cell when draw or redraw
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
        if let profileImage = message.from_user.id == appStore.state.user.user_id ? appStore.state.user.profileImage : message.from_user.profileImage {
            cell.userProfileImageView.image = UIImage(data: profileImage)
        }
        return cell
    }
    
    /**
     * Method used to setup Message image attachment cell when draw or redraw
     *
     * - Parameter cell: Link to Cell object to setup
     * - Parameter index: Row Index of cell
     * - Returns: Cell after setup all options, ready to display
     */
    func setupChatMessageAttachmentCell(_ cell:ChatAttachmentCell,index:Int) -> ChatAttachmentCell {
        let message = messages[index]
        if let imageData = message.attachment {
            cell.chatAttachmentImageView.image = UIImage(data: imageData)
        }
        return cell
    }
}
