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
class ChatPrivateUsersListCell: UITableViewCell,ChatViewControllerCell,StoreSubscriber {
    /// Link to parent view controller
    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState?
    /// TableView which displays list of users
    @IBOutlet weak var usersTableView: UITableView!
    
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
        let shouldUpdateTableView = self.shouldUpdateTableView(newState:state.chat)
        if shouldUpdateTableView {
            Logger.log(level:LogLevel.DEBUG_UI,message:"Reloaded chatPrivateTableView data",
                       className:"ChatPrivateCell",methodName:"newState")
            usersTableView.reloadData()
        }
        self.state = state.chat
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
    static func shouldUpdateTableView(newState:ChatState) -> Bool {
        return true
    }
    func shouldUpdateTableView(newState:ChatState) -> Bool {
        return ChatPrivateUsersListCell.shouldUpdateTableView(newState:newState)
    }
    
    /**
     *  Function, which chatTableView calls to determine number of
     *  rows in a section. Returns number of users from application state array
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return state!.users.count
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
        guard let state = state else {
            return UITableViewCell()
        }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChatUserCell", for: indexPath) as? ChatUserCell else {
            return UITableViewCell()
        }
        let user = state.users[row]
        var name = "";
        if !user.first_name.isEmpty {
            name = user.first_name
        }
        if !user.last_name.isEmpty {
            name += " \(user.last_name)"
        }
        name += " \(user.login)"
        cell.userNameLabel.text = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let profileImage = user.profileImage {
            cell.userProfileImageView.image = UIImage(data: profileImage)
        }
        return cell
    }
}

