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

    /**
     *  Callback function which executed after view constructed and before display
     *  it on the screen
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        appStore.subscribe(self)
    }
    
    /**
     * Redux state change callback. Executes when state changes. Used to update
     * UI based on new state
     *
     * - Parameter state: Link to new updated state
     */
    func newState(state: AppState) {
        if state.current_activity != .CHAT {
            switch state.current_activity {
            case .LOGIN_FORM: self.performSegue(withIdentifier: "chatLoginSegue", sender: self)
            default: break
            }
        }
        let state = state.chat
        DispatchQueue.main.async {
            if state.errors["general"] != nil {
                var errors = state.errors
                self.present(showAlert(state.errors["general"]!.message),animated:true)
                errors["general"] = nil
                appStore.dispatch(ChatState.changeErrors(errors:errors))
            }
            
        }
    }
    
    /**
     * "Logout" button click handler
     *
     * - Parameter sender: Link to clicked button
     */
    @IBAction func logoutBtnClick(_ sender: UIBarButtonItem) {
        let dialog = UIAlertController(title: "Logout", message: "Do you want to logout?", preferredStyle: .alert)
        dialog.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            ChatState.logout().exec()
            dialog.dismiss(animated: true, completion: nil)
        }))
        dialog.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(dialog, animated: true, completion: nil)
    }
}
