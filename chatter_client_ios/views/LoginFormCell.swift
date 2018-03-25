//
//  LoginFormCell.swift
//  chatter_client_ios
//
//  Created by user on 25.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit
import ReSwift

/**
 * User interface for Login Form as a cell of TableView
 */
class LoginFormCell: UITableViewCell,StoreSubscriber,UITextFieldDelegate {
    
    /// Alias to Application state for Redux
    typealias StoreSubscriberStateType = AppState

    /// "Login" text field
    @IBOutlet weak var loginTextField: UITextField!

    /// "Password" text field
    @IBOutlet weak var passwordTextField: UITextField!

    /// "Login" button
    @IBOutlet weak var loginButton: UIButton!
    
    /// Indicator of login progress
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    /// Label which appears in case of error in "Login" field
   
    @IBOutlet weak var loginErrorLabel: UILabel!
    
    /// Label which appears in case of error in "Password" field
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    /// Link to parent ViewController
    var parent:LoginFormViewController?
    
    /** Fired when user clicks "Login" button
     *
     * - Parameter sender: Link to clicked button
     */
    @IBAction func onLoginButtonClick(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appStore.dispatch(changeLoginAction(login:loginTextField.text!))
        appStore.dispatch(changePasswordAction(password:passwordTextField.text!))
        loginUserAction(messageCenter:appDelegate.msgCenter).exec()
    }
    
    /**
     * Redux state change callback. Executes when state changes. Used to update
     * UI based on new state
     *
     * - Parameter state: Link to new updated state
     */
    func newState(state: AppState) {
        if state.loginForm.errors["login"] != nil {
            self.loginErrorLabel.text = state.loginForm.errors["login"]?.message
            self.loginErrorLabel.isHidden = false
        } else {
            self.loginErrorLabel.isHidden = true
        }
        if state.loginForm.errors["password"] != nil {
            self.passwordErrorLabel.text = state.loginForm.errors["password"]?.message
            self.passwordErrorLabel.isHidden = false
        } else {
            self.passwordErrorLabel.isHidden = true
        }
        if state.loginForm.show_progress_indicator {
            self.progressIndicator.isHidden = false
            self.progressIndicator.startAnimating()
        } else {
            self.progressIndicator.isHidden = true
        }
        
        if let parent = self.parent {
            if state.loginForm.popup_message.count>0 {
                parent.present(showAlert(state.loginForm.popup_message),animated: true)
                appStore.dispatch(changeLoginFormPopupMessageAction(popupMessage: ""))
            }
            if state.loginForm.errors["general"] != nil {
                var errors = state.loginForm.errors
                parent.present(showAlert(state.loginForm.errors["general"]!.message),animated:true)
                errors["general"] = nil
                appStore.dispatch(changeLoginFormErrorsAction(errors:errors))
            }
            if state.current_activity != .LOGIN_FORM {
                switch state.current_activity {
                case .CHAT: parent.performSegue(withIdentifier: "loginChatSegue", sender: self.parent)
                case .USER_PROFILE: parent.performSegue(withIdentifier: "loginProfileSegue", sender: self.parent)
                default: break
                }
            }
            parent.view.isUserInteractionEnabled = !state.loginForm.show_progress_indicator
            parent.loginFormTableView.reloadData()
        }
    }
    
    /**
     * Callback called when cell initialized
     */
    override func awakeFromNib() {
        super.awakeFromNib()
        loginTextField.delegate = self
        passwordTextField.delegate = self
        // subscribe to application state change events
        appStore.subscribe(self)
    }
    
    /**
     * Callback called when user finished editing text in text field
     *
     * - Parameter textField: link to target text field
     */
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print(textField.tag)
        switch textField.tag {
        case textFields.LOGIN.rawValue: appStore.dispatch(changeLoginAction(login:textField.text!))
        case textFields.PASSWORD.rawValue: appStore.dispatch(changePasswordAction(password:textField.text!))
        default: break
        }
        return true
    }
    
    /**
     * Enumeration to map "tag" codes of text fields to human readable IDs
     */
    enum textFields: Int {
        case LOGIN = 1, PASSWORD = 2
    }
}

