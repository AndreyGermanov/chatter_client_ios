//
//  LoginFormViewController.swift
//  chatter_client_ios
//
//  Created by Andrey Germanov on 19.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit

/**
 *  Controller class for Login and Register forms
 */
class LoginFormViewController: UIViewController {

    /// link to Table, which displays Login and Register forms inside it cells
    @IBOutlet weak var loginFormTableView: UITableView!
    
    /**
     *  Callback function which executed after view constructed and before display
     *  it on the screen
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        loginFormTableView.dataSource = self
        loginFormTableView.delegate = self
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
        var cellTemplateName = "loginCell"
        if appStore.state.loginForm.mode == .REGISTER {
            cellTemplateName = "registerCell"
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellTemplateName, for: indexPath)
        return cell
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
        var height: CGFloat = 95.0
        if appStore.state.loginForm.mode == .REGISTER {
            height = 180.0
        }
        return height
    }
}
