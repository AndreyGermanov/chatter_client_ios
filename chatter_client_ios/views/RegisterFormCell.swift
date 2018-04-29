//
//  RegisterFormCell.swift
//  chatter_client_ios
//
//  Created by user on 25.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit
import ReSwift

/**
 * User interface for Register Form as a cell of TableView
 */
class RegisterFormCell: UITableViewCell, StoreSubscriber, UITextFieldDelegate {

    /// Alias to Application state for Redux
    typealias StoreSubscriberStateType = AppState

    /// Link to parent ViewController
    var parent: LoginFormViewController?

    /// Login text field
    @IBOutlet weak var loginTextField: UITextField!

    /// Email text field
    @IBOutlet weak var emailTextField: UITextField!

    /// Password text field
    @IBOutlet weak var passwordTextField: UITextField!

    /// Confirm password text field
    @IBOutlet weak var confirmPasswordTextField: UITextField!

    /// Error message for Login field
    @IBOutlet weak var loginErrorLabel: UILabel!

    /// Error message for Email field
    @IBOutlet weak var emailErrorLabel: UILabel!

    /// Error message for Password field
    @IBOutlet weak var passwordErrorLabel: UILabel!

    /// Indicator of progress of Register operation
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!

    /**
     * "Register" button click handler
     *
     * - Parameter sender: Link to "Register" button
     */
    @IBAction func registerButtonClick(_ sender: UIButton) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        LoginFormState.registerUserAction(messageCenter: appDelegate.msgCenter).exec()
    }

    /**
     * Function determines is it required to redraw TableView cell after state update
     * It is required if any of conditions below meet
     *
     * - Parameter state: Changed state
     * - Returns: true if need to redraw table cell to meet changed state or false otherwise
     */
    func needReloadTableView(state: AppState) -> Bool {
        return (state.loginForm.errors["login"] != nil && self.loginErrorLabel.isHidden) ||
            (state.loginForm.errors["login"] == nil && !self.loginErrorLabel.isHidden) ||
            (state.loginForm.errors["password"] != nil && self.passwordErrorLabel.isHidden) ||
            (state.loginForm.errors["password"] == nil && !self.passwordErrorLabel.isHidden) ||
            (state.loginForm.errors["email"] != nil && self.emailErrorLabel.isHidden) ||
            (state.loginForm.errors["email"] == nil && !self.emailErrorLabel.isHidden) ||
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
        if state.loginForm.errors["email"] != nil {
            self.emailErrorLabel.text = state.loginForm.errors["email"]?.message
            self.emailErrorLabel.isHidden = false
        } else {
            self.emailErrorLabel.text = ""
            self.emailErrorLabel.isHidden = true
        }
        if state.loginForm.show_progress_indicator {
            self.progressIndicator.isHidden = false
            self.progressIndicator.startAnimating()
        } else {
            self.progressIndicator.isHidden = true
        }

        if let parent = self.parent {
            if state.loginForm.popup_message.count>0 {
                parent.present(showAlert(state.loginForm.popup_message), animated: true)
                appStore.dispatch(LoginFormState.changeLoginFormPopupMessageAction(popupMessage: ""))
            }
            if state.loginForm.errors["general"] != nil {
                var errors = state.loginForm.errors
                parent.present(showAlert(state.loginForm.errors["general"]!.message), animated: true)
                errors["general"] = nil
                appStore.dispatch(LoginFormState.changeLoginFormErrorsAction(errors: errors))
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
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
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
        case textFields.EMAIL.rawValue: appStore.dispatch(LoginFormState.changeEmailAction(email: text))
        case textFields.PASSWORD.rawValue: appStore.dispatch(LoginFormState.changePasswordAction(password: text))
            case textFields.CONFIRM_PASSWORD.rawValue: appStore.dispatch(LoginFormState.changeLoginFormConfirmPasswordAction(confirmPassword: text))
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
        case LOGIN = 3, EMAIL = 4, PASSWORD = 5, CONFIRM_PASSWORD = 6
    }
}
