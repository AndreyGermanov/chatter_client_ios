//
//  UserProfileViewController.swift
//  chatter_client_ios
//
//  Created by user on 26.03.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit
import ReSwift

/**
 *  Controller class for User Profile form
 */
class UserProfileViewController: UIViewController,StoreSubscriber {
    
    typealias StoreSubscriberStateType = AppState

    /// Link to profile image
    @IBOutlet weak var profileImage: UIImageView!
    
    /// Link to Login text field
    @IBOutlet weak var loginTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var lastNameTextField: UITextField!
    
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var birthDateTextField: UITextField!
    
    @IBOutlet weak var defaultRoomTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appStore.subscribe(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (appStore.state.userProfile.profileImage != nil) {
            let img = UIImage(data: appStore.state.userProfile.profileImage!)
            self.profileImage.image = img
        }
    }
    
    func newState(state: AppState) {
        
    }
    
    @IBAction func onGenderChange(_ sender: Any) {
    }
    
    @IBAction func onUpdateButtonClick(_ sender: Any) {
    }

    @IBAction func onCancelButtonClick(_ sender: Any) {
        
    }
    
}
