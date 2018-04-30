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
 *  ViewController for Users List cell inside Private chat cell UI
 */
class ChatPrivateUsersListCell: UITableViewCell, ChatViewControllerCell, StoreSubscriber {
    
    /// Link to parent view controller
    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState = ChatState()
    /// TableView which displays list of users
    @IBOutlet weak var usersTableView: UITableView!
    /// Link to object, using for testing purposes
    let tester = (UIApplication.shared.delegate as! AppDelegate).tester
    
    /**
     * Callback called when cell initialized
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        usersTableView.delegate = self
        usersTableView.dataSource = self
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
        let shouldUpdateTableView = self.shouldUpdateTableView(newState: state.chat)
        self.state = state.chat.copy()
        if shouldUpdateTableView {
            Logger.log(level: LogLevel.DEBUG_UI, message: "Reloaded usersTableView data \(self.state.users)",
                       className: "ChatPrivateCell", methodName: "newState")
            usersTableView.reloadData()
        }
        Logger.log(level: LogLevel.DEBUG_UI,message: "Updated local state from application state. State content: " +
            "\(String(describing: self.state))",className: "ChatPrivateUsersListCell",methodName:"newState")
    }
}
/**
 * Extension used to manage Users List Table View
 */
extension ChatPrivateUsersListCell: UITableViewDataSource, UITableViewDelegate {
    /**
     * Function used to determine, does it need to redraw tableView
     * according to the changes of 'newState' or not
     *
     * Parameter newState: new updated state, which used to compare with current state
     * Returns: true if need to redraw tableView or false otherwise
     */
    static func shouldUpdateTableView(newState: ChatState) -> Bool {
        var result = false
        let state = appStore.state.chat
        result = ChatUser.compare(models1:state.users,models2:newState.users)
        if !result {
            for user in newState.users {
                let new_messages_count = user.getPrivateMessages(newState.messages, users: newState.users)
                let old_messages_count = ChatUser.getById(user.id,collection:state.users)!.getPrivateMessages(state.messages, users: state.users)
                if new_messages_count != old_messages_count {
                    result = true
                    break
                }
            }
        }
        return result
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
        let row = indexPath.row
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUserCell", for: indexPath) as? ChatUserCell else {
            return UITableViewCell()
        }
        let user = state.users[row]
        var name = ""
        if !user.first_name.isEmpty {
            name = user.first_name
        }
        if !user.last_name.isEmpty {
            name += " \(user.last_name)"
        }
        let messages_count = user.getUnreadMessagesCount(state.messages, users: state.users)
        name += " \(user.login) - \(messages_count)"
        cell.userNameLabel.text = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let profileImage = user.profileImage {
            cell.userProfileImageView.image = UIImage(data: profileImage)
        }
        return cell
    }
}
