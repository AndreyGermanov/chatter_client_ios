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
class ChatUserCell: UITableViewCell, ChatViewControllerCell {
    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState = ChatState()
    /// Link to User image view
    @IBOutlet weak var userProfileImageView: UIImageView!
    /// Link to User label
    @IBOutlet weak var userNameLabel: UILabel!
    /// Link to Unread messages label
    @IBOutlet weak var unreadMessagesLabel: UILabel!
}
