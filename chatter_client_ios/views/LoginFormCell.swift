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
        appStore.dispatch(LoginFormState.changeLoginAction(login:loginTextField.text!))
        appStore.dispatch(LoginFormState.changePasswordAction(password:passwordTextField.text!))
        LoginFormState.loginUserAction(messageCenter:appDelegate.msgCenter).exec()
    }
    
    /**
     * Function determines is it required to redraw TableView cell after state update
     * It is required if any of conditions below meet
     *
     * - Parameter state: Changed state
     * - Returns: true if need to redraw table cell to meet changed state or false otherwise
     */
    func needReloadTableView(state:AppState) -> Bool {
        return (state.loginForm.errors["login"] != nil && self.loginErrorLabel.isHidden) ||
                (state.loginForm.errors["login"] == nil && !self.loginErrorLabel.isHidden) ||
                (state.loginForm.errors["password"] != nil && self.passwordErrorLabel.isHidden) ||
                (state.loginForm.errors["password"] == nil && !self.passwordErrorLabel.isHidden) ||
                (!state.loginForm.show_progress_indicator && !self.progressIndicator.isHidden) ||
                (state.loginForm.show_progress_indicator && self.progressIndicator.isHidden)
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
            self.loginErrorLabel.text = ""
            self.loginErrorLabel.isHidden = true
        }
        if state.loginForm.errors["password"] != nil {
            self.passwordErrorLabel.text = state.loginForm.errors["password"]?.message
            self.passwordErrorLabel.isHidden = false
        } else {
            self.passwordErrorLabel.text = ""
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
                appStore.dispatch(LoginFormState.changeLoginFormPopupMessageAction(popupMessage: ""))
            }
            if state.loginForm.errors["general"] != nil {
                var errors = state.loginForm.errors
                parent.present(showAlert(state.loginForm.errors["general"]!.message),animated:true)
                errors["general"] = nil
                appStore.dispatch(LoginFormState.changeLoginFormErrorsAction(errors:errors))
            }
            if state.current_activity != .LOGIN_FORM {
                switch state.current_activity {
                case .CHAT: parent.performSegue(withIdentifier: "loginChatSegue", sender: self.parent)
                case .USER_PROFILE: parent.performSegue(withIdentifier: "loginProfileSegue", sender: self.parent)
                default: break
                }
            }
            parent.view.isUserInteractionEnabled = !state.loginForm.show_progress_indicator
            if (self.needReloadTableView(state: state)) {
                parent.loginFormTableView.reloadData()
            }
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
     * Callback called when user edit text in text field
     *
     * - Parameter textField: link to target text field
     * - Parameter range: range of text which was edited
     * - Parameter string: new text which replaced in a range
     * - Returns: true if allowed to edit this text and false otherwise
     */
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var text = textField.text!
        text.replaceSubrange(Range<String.Index>.init(range, in: text)!, with: string)
        switch textField.tag {
        case textFields.LOGIN.rawValue: appStore.dispatch(LoginFormState.changeLoginAction(login: text))
        case textFields.PASSWORD.rawValue: appStore.dispatch(LoginFormState.changePasswordAction(password: text))
        default: break
        }
        return true
    }
    
    /**
     * Function fires when user finishes edit text in text field and presses "Return" button
     *
     * - Parameter textField: Source text field component
     * - Returns: true if allow to implement return action or false otherwise
     */
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     * Enumeration to map "tag" codes of text fields to human readable IDs
     */
    enum textFields: Int {
        case LOGIN = 1, PASSWORD = 2
    }
}

