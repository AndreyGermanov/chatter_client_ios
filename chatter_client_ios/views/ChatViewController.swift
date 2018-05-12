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

    /// link to "Back" button
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    /// Local copy of Chat Screen state (the state which used now to draw this screen)
    var state: ChatState = ChatState()

    /// Link to "Private chat" tableView cell
    var chatPrivateCell: ChatPrivateCell?
    
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
     * Method fires each time when view appears on the screen
     *
     * - Parameter animated: Should animate when appear
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (state.rooms.count == 0) {
            tester.loadTestState()
        }
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
            let shouldUpdate = self.shouldUpdateTableView(newState: state.chat)
            self.state = state.chat.copy()
            if shouldUpdate {
                Logger.log(level: LogLevel.DEBUG_UI, message: "Reloaded data in chatTableView",
                           className: "ChatViewController", methodName: "newState")
                self.chatTableView.reloadData()
            }
            self.backButton.tintColor = state.chat.privateChatMode == .CHAT ? nil : UIColor.clear
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
    
    /**
     * "Back" button click handler
     *
     * - Parameter sender: Source button clicked
     */
    @IBAction func backBtnClick(_ sender: UIButton) {
        if state.chatMode == .PRIVATE && state.privateChatMode == .CHAT {
            appStore.dispatch(ChatState.changePrivateChatMode(privateChatMode: .USERS))
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
        return state.chatMode != newState.chatMode
    }

    /**
     *  Function, which chatTableView calls to determine number of
     *  rows in a section. (always 1)
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
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
        switch(state.chatMode) {
        case .ROOM:
            switch(indexPath.row) {
            case 0: return screenSize.height
            default: return 0
            }
        case .PRIVATE:
            switch(indexPath.row) {
            case 1: return screenSize.height
            default: return 0
            }
        case .PROFILE:
            switch(indexPath.row) {
            case 2: return screenSize.height
            default: return 0
            }
        }
    }

    /**
     * Function, which chatTableView calls whenever it need to redraw cell
     *
     * - Parameter tableView: source tableView, which need to update
     * - Parameter indexPath: coordinates of cell which need to redraw
     * - Returns: new cell which will replace cell which need to update
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.row) {
        case 0: return setupChatPublicCell(tableView.dequeueReusableCell(withIdentifier: "ChatPublicCell")!)
        case 1: return setupChatPrivateCell(tableView.dequeueReusableCell(withIdentifier: "ChatPrivateCell")!)
        case 2: return setupChatProfileCell(tableView.dequeueReusableCell(withIdentifier: "ChatProfileCell")!)
        default: return UITableViewCell()
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

extension ChatViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    /**
     * Function fired when user captures image either from Camera or form PhotoLibrary
     *
     * - Parameter picker: Link to Source Image Picker component dialog
     * - Parameter info: Array of captured information, including captured image and other metadata
     */
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let data = UIImagePNGRepresentation(image) {
                print(data.bytes.count)
                appStore.dispatch(ChatState.changePrivateChatAttachment(privateChatAttachment: data))
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
}
