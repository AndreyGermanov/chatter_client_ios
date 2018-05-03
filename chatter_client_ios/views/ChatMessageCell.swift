//
//  ChatPublicCell.swift
//  chatter_client_ios
//
//  Created by user on 26.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit

/**
 *  ViewController for row in ChatUsersList table. Shows single user
 */
class ChatMessageCell: UITableViewCell, ChatViewControllerCell {
    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState = ChatState()
    /// Link to user login above profile image
    @IBOutlet weak var userLoginLabel: UILabel!
    /// Link to user profile image view
    @IBOutlet weak var userProfileImageView: UIImageView!
    /// Link to date label of message
    @IBOutlet weak var messageDateLabel: UILabel!
    /// Link to message text (if exists)
    @IBOutlet weak var messageTextLabel: UILabel!
    /// Link to message attachment (if exists)
    @IBOutlet weak var messageAttachmentImageView: UIImageView!
    /// Link to displayed chat message object
    var message:ChatMessage? = nil
}
