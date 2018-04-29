//
//  ChatPublicCell.swift
//  chatter_client_ios
//
//  Created by user on 26.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit

/**
 *  ViewController for Chat cell inside Private chat cell UI
 */
class ChatPrivateChatCell: UITableViewCell, ChatViewControllerCell {
    /// Link to parent view controller
    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState = ChatState()
}

/**
 * Extension used to manage Users List Table View
 */
extension ChatPrivateChatCell: UITableViewDataSource, UITableViewDelegate {
    /**
     * Function used to determine, does it need to redraw tableView
     * according to the changes of 'newState' or not
     *
     * Parameter newState: new updated state, which used to compare with current state
     * Returns: true if need to redraw tableView or false otherwise
     */
    static func shouldUpdateTableView(newState: ChatState) -> Bool {
        return true
    }
    func shouldUpdateTableView(newState: ChatState) -> Bool {
        return ChatPrivateUsersListCell.shouldUpdateTableView(newState: newState)
    }

    /**
     *  Function, which chatTableView calls to determine number of
     *  rows in a section. Returns number of users from application state array
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state.users.count
    }

    /**
     * Function, which tablewView calls whenever it need to redraw cell
     *
     * - Parameter tableView: source tableView, which need to update
     * - Parameter indexPath: coordinates of cell which need to redraw
     * - Returns: new cell which will replace cell which need to update
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        return UITableViewCell()
    }
}
