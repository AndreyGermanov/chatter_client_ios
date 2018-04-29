//
//  ChatViewController.swift
//  chatter_client_ios
//
//  Created by user on 20.04.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit
import ReSwift

class ChatViewController: UIViewController, StoreSubscriber {

    /// Type of Application store object for Redux
    typealias StoreSubscriberStateType = AppState

    /// Top segmented control used to switch between
    /// chat screen modes (Public, Private, Profile)
    @IBOutlet weak var chatModesSegmentedControl: UISegmentedControl!

    /// Main Chat tableView, used to display different
    /// subscreens of chat (Public,Private or Profile) as
    /// cells
    @IBOutlet weak var chatTableView: UITableView!

    /// Local copy of Chat Screen state (the state which used now to draw this screen)
    var state: ChatState = ChatState()

    /// Link to object, using for testing purposes
    let tester = (UIApplication.shared.delegate as! AppDelegate).tester
    
    /**
     *  Callback function which executed after view constructed and before display
     *  it on the screen
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        chatModesSegmentedControl.selectedSegmentIndex = appStore.state.chat.chatMode.rawValue-1
        chatTableView.dataSource = self
        chatTableView.delegate = self
        self.state = appStore.state.chat
        appStore.subscribe(self)
    }

    /**
     * Redux state change callback. Executes when state changes. Used to update
     * UI based on new state
     *
     * - Parameter state: Link to new updated state
     */
    func newState(state: AppState) {
        DispatchQueue.main.async {
            if state.current_activity != .CHAT {
                switch state.current_activity {
                case .LOGIN_FORM:
                    self.performSegue(withIdentifier: "chatLoginSegue", sender: self)
                default: break
                }
            }
            if state.chat.errors["general"] != nil {
                var errors = state.chat.errors
                self.present(showAlert(state.chat.errors["general"]!.message), animated: true)
                errors["general"] = nil
                appStore.dispatch(ChatState.changeErrors(errors: errors))
            }
            if self.shouldUpdateTableView(newState: state.chat) {
                Logger.log(level: LogLevel.DEBUG_UI, message: "Reloaded data in chatTableView",
                           className: "ChatViewController", methodName: "newState")
                self.chatTableView.reloadData()
            }
            self.state = state.chat.copy()
            Logger.log(level: LogLevel.DEBUG_UI,message: "Updated local state from application state. State content: \(self.state)",
                className: "ChatViewController",methodName:"newState")
        }
    }

    /**
     * "Logout" button click handler
     *
     * - Parameter sender: Link to clicked button
     */
    @IBAction func logoutBtnClick(_ sender: UIBarButtonItem) {
        let dialog = UIAlertController(title: "Logout", message: "Do you want to logout?", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            ChatState.logout().exec()
            dialog.dismiss(animated: true, completion: nil)
        }))
        dialog.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(dialog, animated: true, completion: nil)
    }

    /**
     *  Chat modes segmented control onClick handler. Used
     *  to switch between different chat screen modes
     *
     * - Parameter sender: Source UISegmentedControl which clicked
     */
    @IBAction func chatModesClick(_ sender: UISegmentedControl) {
        if let currentMode = ChatScreenMode(rawValue: sender.selectedSegmentIndex+1) {
            appStore.dispatch(ChatState.changeChatMode(chatMode: currentMode))
        }
    }
}

/**
 *  Extension to controller, used to process chatTable view event
 *  handlers
 */
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {

    /**
     * Function used to determine, does it need to redraw chatTableView
     * according to the changes of 'newState' or not
     *
     * Parameter newState: new updated state, which used to compare with current state
     * Returns: true if need to redraw tableView or false otherwise
     */
    func shouldUpdateTableView(newState: ChatState) -> Bool {
        let result = state.chatMode != newState.chatMode
        return result
    }

    /**
     *  Function, which chatTableView calls to determine number of
     *  rows in a section. (always 1)
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    /**
     * Function, which chatTableView calls whenever it need to redraw cell
     *
     * - Parameter tableView: source tableView, which need to update
     * - Parameter indexPath: coordinates of cell which need to redraw
     * - Returns: new cell which will replace cell which need to update
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: state.chatMode.cellID, for: indexPath)
        switch (appStore.state.chat.chatMode) {
        case .ROOM: return setupChatPublicCell(cell)
        case .PRIVATE: return setupChatPrivateCell(cell)
        case .PROFILE: return setupChatProfileCell(cell)
        }
    }

    /**
     * Function used to setup tableView cell as Private Chat cell depending on current Chat state
     *
     * - Parameter cell: Source tableView cell to setup
     * - Returns: Reconstructed cell
     */
    func setupChatPrivateCell(_ cell: UITableViewCell) -> ChatPrivateCell {
        let cell = cell as! ChatPrivateCell
        cell.parentViewController = self
        Logger.log(level: LogLevel.DEBUG_UI, message: "Constructed ChatPrivateCell",
                   className: "ChatViewController", methodName: "setupChatPrivateCell")
        return cell
    }

    /**
     * Function used to setup tableView cell as Public Chat cell depending on current Chat state
     *
     * - Parameter cell: Source tableView cell to setup
     * - Returns: Reconstructed cell
     */
    func setupChatPublicCell(_ cell: UITableViewCell) -> ChatPublicCell {
        let cell = cell as! ChatPublicCell
        cell.parentViewController = self
        Logger.log(level: LogLevel.DEBUG_UI, message: "Constructed ChatPublicCell",
                   className: "ChatViewController", methodName: "setupChatPublicCell")
        return cell
    }

    /**
     * Function used to setup tableView cell as Profile Chat cell depending on current Chat state
     *
     * - Parameter cell: Source tableView cell to setup
     * - Returns: reconstructed cell
     */
    func setupChatProfileCell(_ cell: UITableViewCell) -> ChatProfileCell {
        let cell = cell as! ChatProfileCell
        cell.parentViewController = self
        Logger.log(level: LogLevel.DEBUG_UI, message: "Constructed ChatProfileCell",
                   className: "ChatViewController", methodName: "setupChatProfileCell")
        return cell
    }
}

/**
 * Protocol which each cell inside chatTableView must implmenent
 */
protocol ChatViewControllerCell {
    /// Link to view controller, which manages tableView of this cell
    var parentViewController: ChatViewController? {get set}
    var state: ChatState {get set}
}
