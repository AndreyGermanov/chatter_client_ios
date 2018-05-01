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
 *  ViewController for Private chat UI (cell in TableView of Chat screen,
 *  which handles Private chat tab)
 */
class ChatPrivateCell: UITableViewCell, ChatViewControllerCell, StoreSubscriber {

    /// Alias to type of Application state
    typealias StoreSubscriberStateType = AppState

    /// TableView which displays one of two cells, depending on Application state:
    /// etiher "User list" or "Private chat" with selected user
    @IBOutlet weak var chatPrivateTableView: UITableView!
    /// Link to parent ViewController
    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState = ChatState()
    /// Link to object, using for testing purposes
    let tester = (UIApplication.shared.delegate as! AppDelegate).tester

    /**
     * Callback called when cell initialized
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        chatPrivateTableView.delegate = self
        chatPrivateTableView.dataSource = self
        tester.loadUsers()
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
        if shouldUpdateTableView {
            Logger.log(level: LogLevel.DEBUG_UI, message: "Reloaded chatPrivateTableView data",
                       className: "ChatPrivateCell", methodName: "newState")
            chatPrivateTableView.reloadData()
        }
        self.state = state.chat.copy()
        Logger.log(level: LogLevel.DEBUG_UI,message: "Updated local state from application state. State content: \(String(describing: self.state))",
            className: "ChatPrivateCell",methodName:"newState")
    }
}

/**
 *  Extension to process tableView related events
 */
extension ChatPrivateCell: UITableViewDelegate, UITableViewDataSource {

    /**
     * Function used to determine, does it need to redraw tableView
     * according to the changes of 'newState' or not
     *
     * Parameter newState: new updated state, which used to compare with current state
     * Returns: true if need to redraw tableView or false otherwise
     */
    func shouldUpdateTableView(newState: ChatState) -> Bool {
        return ChatPrivateCell.shouldUpdateTableView(newState:newState)
    }
    static func shouldUpdateTableView(newState: ChatState) -> Bool {
        let state = appStore.state.chat
        var result = false
        if state.privateChatMode != newState.privateChatMode {
            result = true
        }
        return result ||
            ChatPrivateUsersListCell.shouldUpdateTableView(newState: newState)
    }

    /**
     *  Function, which chatTableView calls to determine number of
     *  rows in a section. (always 1)
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    /**
     * Function, which tableView calls whenever it need to redraw cell
     *
     * - Parameter tableView: source tableView, which need to update
     * - Parameter indexPath: coordinates of cell which need to redraw
     * - Returns: new cell which will replace cell which need to update
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.row) {
        case 0: return setupPrivateChatCell(tableView.dequeueReusableCell(withIdentifier: "ChatPrivateChatCell")!)
        case 1: return setupUsersListCell(tableView.dequeueReusableCell(withIdentifier: "ChatPrivateUsersListCell")!)
        default: return UITableViewCell()
        }
    }
    

    /**
     * Function used to setup tableView cell as Users List cell depending on current Chat state
     *
     * - Parameter cell: Source tableView cell to setup
     * - Returns: Reconstructed cell
     */
    func setupUsersListCell(_ cell: UITableViewCell) -> ChatPrivateUsersListCell {
        let cell = cell as! ChatPrivateUsersListCell
        cell.parentViewController = parentViewController
        Logger.log(level: LogLevel.DEBUG_UI, message: "Constructed ChatPrivateUsersListCell",
                   className: "ChatPrivateCell", methodName: "setupUsersListCell")
        return cell
    }

    /**
     * Function used to setup tableView cell as Private Chat cell depending on current Chat state
     *
     * - Parameter cell: Source tableView cell to setup
     * - Returns: Reconstructed cell
     */
    func setupPrivateChatCell(_ cell: UITableViewCell) -> ChatPrivateChatCell {
        let cell = cell as! ChatPrivateChatCell
        cell.parentViewController = parentViewController
        Logger.log(level: LogLevel.DEBUG_UI, message: "Constructed ChatPrivateChatCell",
                   className: "ChatPrivateCell", methodName: "setupPrivateChatCell")
        return cell
    }
    
    /**
     * Function fires when tableView needs to calculate height of cell
     *
     * - Parameter tableView: Source tableView
     * - Parameter indexPath: Coordinates of cell, which height need to calculated
     * - Returns: calculated height
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        switch(state.privateChatMode) {
        case .CHAT:
            switch(indexPath.row) {
            case 0: return screenSize.height
            default: return 0
            }
        case .USERS:
            switch(indexPath.row) {
            case 1: return screenSize.height
            default: return 0
            }
        }
    }
}
