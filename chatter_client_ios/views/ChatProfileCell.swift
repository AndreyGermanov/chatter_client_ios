//
//  ChatPublicCell.swift
//  chatter_client_ios
//
//  Created by user on 26.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit

/**
 *  ViewController for Profile in chat UI (cell in TableView of Chat screen,
 *  which handles Profile chat tab)
 */
class ChatProfileCell: UITableViewCell, ChatViewControllerCell {
    /// Link to parent view controller
    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState = ChatState()
}
