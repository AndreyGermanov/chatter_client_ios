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
class ChatPrivateCell: UITableViewCell,ChatViewControllerCell, StoreSubscriber {
    
    /// Alias to type of Application state
    typealias StoreSubscriberStateType = AppState
    
    /// TableView which displays one of two cells, depending on Application state:
    /// etiher "User list" or "Private chat" with selected user
    @IBOutlet weak var chatPrivateTableView: UITableView!
    /// Link to parent ViewController
    var parentViewController: ChatViewController?
    /// Link to application state related to chat screen
    var state: ChatState?
    
    /**
     * Callback called when cell initialized
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        chatPrivateTableView.delegate = self
        chatPrivateTableView.dataSource = self
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
            chatPrivateTableView.reloadData()
        }
        self.state = state.chat
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
    func shouldUpdateTableView(newState:ChatState) -> Bool {
        if state?.privateChatMode != newState.privateChatMode {
            return true
        }
        return false
    }
    
    /**
     *  Function, which chatTableView calls to determine number of
     *  rows in a section. (always 1)
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    /**
     * Function, which chatPrivateTableView calls whenever it need to redraw cell
     *
     * - Parameter tableView: source tableView, which need to update
     * - Parameter indexPath: coordinates of cell which need to redraw
     * - Returns: new cell which will replace cell which need to update
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let screenMode = state?.privateChatMode else {
            Logger.log(level:LogLevel.DEBUG_UI,message:"Could not determine current screen mode form Private Chat Screen",
                       className:"ChatPrivateCell",methodName:"cellForRowAt")
            return UITableViewCell()
        }
        let cellID = screenMode.cellID
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        switch (screenMode) {
        case .CHAT: return setupPrivateChatCell(cell)
        case .USERS: return setupUsersListCell(cell)
        }
    }

    /**
     * Function used to setup tableView cell as Users List cell depending on current Chat state
     *
     * - Parameter cell: Source tableView cell to setup
     * - Returns: Reconstructed cell
     */
    func setupUsersListCell(_ cell:UITableViewCell) -> ChatPrivateUsersListCell {
        let cell = cell as! ChatPrivateUsersListCell
        cell.parentViewController = parentViewController
        Logger.log(level:LogLevel.DEBUG_UI,message:"Constructed ChatPrivateUsersListCell",
                   className:"ChatPrivateCell",methodName:"setupUsersListCell")
        return cell
    }
    
    /**
     * Function used to setup tableView cell as Private Chat cell depending on current Chat state
     *
     * - Parameter cell: Source tableView cell to setup
     * - Returns: Reconstructed cell
     */
    func setupPrivateChatCell(_ cell:UITableViewCell) -> ChatPrivateChatCell {
        let cell = cell as! ChatPrivateChatCell
        cell.parentViewController = parentViewController
        Logger.log(level:LogLevel.DEBUG_UI,message:"Constructed ChatPrivateChatCell",
                   className:"ChatPrivateCell",methodName:"setupPrivateChatCell")
        return cell
    }
}
