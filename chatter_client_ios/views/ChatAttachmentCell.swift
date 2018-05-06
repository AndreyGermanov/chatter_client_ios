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
class ChatAttachmentCell: UITableViewCell, ChatViewControllerCell {
    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState = ChatState()
    /// Link to attached image
    @IBOutlet weak var chatAttachmentImageView: UIImageView!
    /**
     * Callback called when cell initialized
     */
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
