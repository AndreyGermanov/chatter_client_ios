//
//  LoginFormViewController.swift
//  chatter_client_ios
//
//  Created by Andrey Germanov on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit
import ReSwift
/**
 *  Controller class for Login and Register forms
 */
class LoginFormViewController: UIViewController, StoreSubscriber {

    typealias StoreSubscriberStateType = AppState

    /// link to Table, which displays Login and Register forms inside it cells
    @IBOutlet weak var loginFormTableView: UITableView!

    /// link to form mode switcher between LOGIN and REGISTER
    @IBOutlet weak var loginFormNavigation: UISegmentedControl!

    /**
     * Login Form mode segmented control click handler. Changes Login Form
     * mode from "LOGIN" to "REGISTER" or vice versa
     *
     * - Parameter sender: Link to UISegmetedControl instance clicked
     */
    @IBAction func onChangeMode(_ sender: UISegmentedControl) {
        if let mode = LoginFormMode(rawValue: sender.selectedSegmentIndex) {
            appStore.dispatch(LoginFormState.changeLoginFormModeAction(mode: mode))
        }
    }

    /**
     * Function determines is it required to redraw TableView cell after state update
     * It is required if any of conditions below meet
     *
     * - Parameter state: Changed state
     * - Returns: true if need to redraw table cell to meet changed state or false otherwise
     */
    func needReloadTableView(state: AppState) -> Bool {
        return (loginFormTableView.cellForRow(at: IndexPath(row: 0, section: 0)) is LoginFormCell && state.loginForm.mode == .REGISTER) ||
        (loginFormTableView.cellForRow(at: IndexPath(row: 0, section: 0)) is RegisterFormCell && state.loginForm.mode == .LOGIN)
    }

    /**
     * Redux state change callback. Executes when state changes. Used to update
     * UI based on new state
     *
     * - Parameter state: Link to new updated state
     */
    func newState(state: LoginFormViewController.StoreSubscriberStateType) {
         DispatchQueue.main.async {
            if (self.needReloadTableView(state: state)) {
                self.loginFormTableView.reloadData()
            }
            self.loginFormNavigation.selectedSegmentIndex = appStore.state.loginForm.mode.rawValue
        }
    }

    /**
     *  Callback function which executed after view constructed and before display
     *  it on the screen
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        loginFormTableView.dataSource = self
        loginFormTableView.delegate = self
        appStore.subscribe(self)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onScreenTap)))
    }

    /**
     * Callback fired when user taps on screen. Used to hide onscreen keyboard
     */
    @objc func onScreenTap() {
        view.endEditing(true)
    }
 }

/**
 *  Extension used to manage tableView, which includes cells for Login Form and for Register forms
 */
extension LoginFormViewController: UITableViewDataSource, UITableViewDelegate {

    /**
     * Callback Function calculates and returns number of cells in a section of table view.
     * For current tableView it always display single cell
     *
     * - Parameter tableView: tableView instance to manger
     * - Parameter: section: index of section for which setup number of cells
     * - Returns: New number of cells in section
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    /**
     * Callback function which executes every time when need to display cell content of table view.
     * Cell object which need to display calculated based on application state. It can be either
     * Login Form cell or Register form cell, depending on tab, which user selected
     *
     * - Parameter tableView: link to tableView
     * - Parameter indexPath: index of cell, for which calculate content object
     * - Returns: Cell object (one of predefined templates)
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if appStore.state.loginForm.mode == .REGISTER {
            let cellTemplateName = "registerCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellTemplateName, for: indexPath) as! RegisterFormCell
            cell.parent = self
            return cell
        } else if appStore.state.loginForm.mode == .LOGIN {
            let cellTemplateName = "loginCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: cellTemplateName, for: indexPath) as! LoginFormCell
            cell.parent = self
            return cell
        } else {
            return UITableViewCell()
        }
    }

    /**
     * Callback function whcih executes every time when need to calculate height of tableView cell
     * depending on which cell and in which index displayed.
     * Depending on application state it can be either height for Login form or for Register form
     *
     * - Parameter tableView: link to tableView
     * - Parameter indexPath: index of cell, for which need to calculate and return height
     * - Returns: Calculated cell height
     */
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch appStore.state.loginForm.mode {
        case .LOGIN: return 200.0
        case .REGISTER: return 400.0
        }

    }
}
