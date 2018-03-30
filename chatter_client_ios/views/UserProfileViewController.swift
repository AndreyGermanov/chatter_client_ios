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
    
    /// Type of Application store object for Redux
    typealias StoreSubscriberStateType = AppState

    /// Link to profile image
    @IBOutlet weak var profileImage: UIImageView!
    
    /// Link to Login text field
    @IBOutlet weak var loginTextField: UITextField!
    
    /// Link to Password field
    @IBOutlet weak var passwordTextField: UITextField!
    
    /// Link to Confirm Password field
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    
    /// Link to First name field
    @IBOutlet weak var firstNameTextField: UITextField!
    
    /// Link to Last name field
    @IBOutlet weak var lastNameTextField: UITextField!
    
    /// Link to Gender selector
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    /// Link to BirthDate field
    @IBOutlet weak var birthDateTextField: UITextField!
    
    /// Link to Default room field
    @IBOutlet weak var defaultRoomTextField: UITextField!
    
    /// Link to Default room picker component
    let defaultRoomPicker = UIPickerView()
    
    /// Error label for Login field
    @IBOutlet weak var loginErrorLabel: UILabel!
    /// Error label from Password field
    @IBOutlet weak var passwordErrorLabel: UILabel!
    /// Error label for First Name field
    @IBOutlet weak var firstNameErrorLabel: UILabel!
    /// Error label for Last Name field
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    /// Error label for Gender field
    @IBOutlet weak var genderErrorLabel: UILabel!
    /// Error label for birthDate field
    @IBOutlet weak var birthDateErrorLabel: UILabel!
    /// Error label for Default Room field
    @IBOutlet weak var defaultRoomErrorLabel: UILabel!
    
    /// Progress indicator widget
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    /**
     * Callback function, which runs once after this screen constructed
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        appStore.subscribe(self)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onScreenTap)))
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.onProfileImageClick)))
        let birthDatePicker = UIDatePicker()
        birthDatePicker.addTarget(self, action: #selector(self.setBirtrhDate(sender:)), for: UIControlEvents.valueChanged)
        birthDatePicker.datePickerMode = .date
        let birthDate = appStore.state.userProfile.birthDate
        birthDatePicker.date = Date(timeIntervalSince1970: Double(birthDate))
        birthDateTextField.inputView = birthDatePicker
        self.defaultRoomPicker.dataSource = self
        self.defaultRoomPicker.delegate = self
        self.defaultRoomTextField.inputView = defaultRoomPicker
        self.loginTextField.delegate = self
        self.passwordTextField.delegate = self
        self.confirmPasswordTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        self.birthDateTextField.delegate = self
        self.defaultRoomTextField.delegate = self
    }
    
    /**
     * Callback function, which runs every time when user displays this screen
     * - Parameter animated: Should animate when appear
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (appStore.state.userProfile.profileImage != nil) {
            let img = UIImage(data: appStore.state.userProfile.profileImage!)
            self.profileImage.image = img
        }
        DispatchQueue.main.async {
            self.loginTextField.text = appStore.state.userProfile.login
            self.passwordTextField.text = ""
            self.confirmPasswordTextField.text = ""
            self.firstNameTextField.text = appStore.state.userProfile.first_name
            self.lastNameTextField.text = appStore.state.userProfile.last_name
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
            if let data = appStore.state.userProfile.profileImage {
                self.profileImage.image = UIImage(data: data)
            } else {
                let bundle = Bundle.main
                let path = bundle.path(forResource: "profile", ofType: "png")!
                let data = try! Data.init(contentsOf: URL.init(fileURLWithPath: path, isDirectory: false))
                self.profileImage.image = UIImage(data:data)
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: Date(timeIntervalSince1970: Double(appStore.state.userProfile.birthDate)))
            self.birthDateTextField.text = dateString
            var filteredRooms = appStore.state.userProfile.rooms.filter { item in
                return item["_id"] == appStore.state.userProfile.default_room
            }
            if filteredRooms.count == 1 {
                self.defaultRoomTextField.text = filteredRooms[0]["name"]
            }
        
            let state = appStore.state.userProfile
            
            if state.errors["login"] != nil {
                self.loginErrorLabel.text = state.errors["login"]?.message
                self.loginErrorLabel.isHidden = false
            } else {
                self.loginErrorLabel.text = ""
                self.loginErrorLabel.isHidden = true
            }
            if state.errors["password"] != nil {
                self.passwordErrorLabel.text = state.errors["password"]?.message
                self.passwordErrorLabel.isHidden = false
            } else {
                self.passwordErrorLabel.text = ""
                self.passwordErrorLabel.isHidden = true
            }
            if state.errors["first_name"] != nil {
                self.firstNameErrorLabel.text = state.errors["first_name"]?.message
                self.firstNameErrorLabel.isHidden = false
            } else {
                self.firstNameErrorLabel.text = ""
                self.firstNameErrorLabel.isHidden = true
            }
            if state.errors["last_name"] != nil {
                self.lastNameErrorLabel.text = state.errors["last_name"]?.message
                self.lastNameErrorLabel.isHidden = false
            } else {
                self.lastNameErrorLabel.text = ""
                self.lastNameErrorLabel.isHidden = true
            }
            if state.errors["gender"] != nil {
                self.genderErrorLabel.text = state.errors["gender"]?.message
                self.genderErrorLabel.isHidden = false
            } else {
                self.genderErrorLabel.text = ""
                self.genderErrorLabel.isHidden = true
            }
            if state.errors["birthDate"] != nil {
                self.birthDateErrorLabel.text = state.errors["birthDate"]?.message
                self.birthDateErrorLabel.isHidden = false
            } else {
                self.genderErrorLabel.text = ""
                self.genderErrorLabel.isHidden = true
            }
            if state.errors["default_room"] != nil {
                self.defaultRoomErrorLabel.text = state.errors["default_room"]?.message
                self.defaultRoomErrorLabel.isHidden = false
            } else {
                self.defaultRoomErrorLabel.text = ""
                self.defaultRoomErrorLabel.isHidden = true
            }

            if state.show_progress_indicator {
                self.progressIndicator.isHidden = false
                self.progressIndicator.startAnimating()
            } else {
                self.progressIndicator.isHidden = true
            }
            
            if state.errors["general"] != nil {
                var errors = state.errors
                self.present(showAlert(state.errors["general"]!.message),animated:true)
                errors["general"] = nil
                appStore.dispatch(changeUserProfileErrorsAction(errors:errors))
            }
                
            self.view.isUserInteractionEnabled = !state.show_progress_indicator
            
            if appStore.state.current_activity == .CHAT {
                self.performSegue(withIdentifier: "profileChatSegue", sender: self.parent)
            }
        }
    }
    
    /**
     * Gender segmented control onChhange handler
     *
     * - Parameter sender: Source Segmented control
     */
    @IBAction func onGenderChange(_ sender: UISegmentedControl) {
        var gender:Gender = .M
        switch sender.selectedSegmentIndex {
        case 0: gender = .M
        case 1: gender = .F
        default: break
        }
        appStore.dispatch(changeUserProfileGenderAction(gender: gender))
    }
    
    /**
     * "Update" button click handler.
     *
     * - Parameter sender: Source button
     */
    @IBAction func onUpdateButtonClick(_ sender: UIButton) {
        _ = updateUserProfileAction().exec()
    }

    /**
     * "Cancel" button click handler
     *
     * - Parameter sender: Source button
     */
    @IBAction func onCancelButtonClick(_ sender: UIButton) {
        _ = cancelUserProfileUpdateAction().exec()
    }
    
    /**
     * Function fires when user clisk on profile image. Used to begin process
     * of image capture. Shows Image source selection dialog (Camera or Photo library)
     */
    @objc func onProfileImageClick() {
        let dialog = UIAlertController(title: "Select", message: "Image source", preferredStyle: .actionSheet)
        dialog.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            self.getPhoto(.camera)
        }))
        dialog.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { action in
            self.getPhoto(.photoLibrary)
            
        }))
        self.present(dialog, animated: true, completion: nil)
    }
    
    /**
     * Function used to open Image capture view
     *
     * - Parameter source: Image source, either Camera or Photo Library
     */
    func getPhoto(_ source: UIImagePickerControllerSourceType) {
        let dialog = UIImagePickerController()
        dialog.sourceType = source
        dialog.allowsEditing = false
        dialog.delegate = self
        self.present(dialog, animated: true, completion: nil)
    }
    
    /**
     * Handler which executes when user changes date using DatePicker control
     *
     * - Parameter sender: Source date picker
     */
    @objc func setBirtrhDate(sender:UIDatePicker) {
        let date = Double(sender.date.timeIntervalSince1970)
        print(date)
        if date > 0 {
            appStore.dispatch(changeUserProfileBirthDateAction(birthDate: Int(date)))
        }
    }
    
    /**
     * Callback fired when user taps on screen. Used to hide onscreen keyboard
     */
    @objc func onScreenTap() {
        view.endEditing(true)
    }
}

/**
 * Extension to work with Take picture function, to handle callbacks from Camera capture
 * or Photo Library selection dialogs
 */
extension UserProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /**
     * Function fired when user captures image either from Camera or form PhotoLibrary
     *
     * - Parameter picker: Link to Source Image Picker component dialog
     * - Parameter info: Array of captured information, including captured image and other metadata
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let data = UIImagePNGRepresentation(image) {
                appStore.dispatch(changeUserProfileProfileImageAction(profileImage: data))
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }
}

/**
 * Extension which handles callbacks of Default room picker component
 */
extension UserProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    /**
     * Callback which used to set number of components in a row of PickerView component
     *
     * - Parameter pickerView: Link to source Picker view
     * - Returns: number of components in a row
     */
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /**
     * Callback which used to set number of items in PickerView component.
     *
     * - Parameter pickerView: Link to source Picker view
     * - Parameter component: Component, for which number of items need to set
     * - Returns: number of items in provided component
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return appStore.state.userProfile.rooms.count
    }
    
    /**
     * Callback used to set titles of items in picker view
     *
     * - Parameter pickerView: Link to source picker view
     * - Parameter row: Index of target row
     * - Parameter component: Index of target column
     * - Returns: title to assign to provided item
     */
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row < appStore.state.userProfile.rooms.count {
            let room = appStore.state.userProfile.rooms[row]
            return room["name"]
        } else {
            return nil
        }
    }
    
    /**
     * Picker value change handler. Executes when users selects value in PickerView component
     *
     * - Parameter pickerView: Link to source PickerView
     * - Parameter row: Index of selected row
     * - Parameter component: Index of selected column
     */
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row < appStore.state.userProfile.rooms.count {
            let room = appStore.state.userProfile.rooms[row]
            appStore.dispatch(changeUserProfileDefaultRoomAction(defaultRoom: room["_id"]!))
        }
    }
}

/**
 * Extension to handle input to text fields
 */
extension UserProfileViewController: UITextFieldDelegate {
    
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
        case textFields.LOGIN.rawValue: appStore.dispatch(changeUserProfileLoginAction(login: text))
        case textFields.CONFIRM_PASSWORD.rawValue: appStore.dispatch(changeUserProfileConfirmPasswordAction(confirmPassword: text))
        case textFields.PASSWORD.rawValue: appStore.dispatch(changeUserProfilePasswordAction(password: text))
        case textFields.FIRST_NAME.rawValue: appStore.dispatch(changeUserProfileFirstNameAction(firstName: text))
        case textFields.LAST_NAME.rawValue: appStore.dispatch(changeUserProfileLastNameAction(lastName: text))
        case textFields.BIRTHDATE.rawValue: return false
        case textFields.DEFAULT_ROOM.rawValue: return false
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
        case LOGIN = 1, PASSWORD = 2, CONFIRM_PASSWORD = 3, FIRST_NAME=4, LAST_NAME=5, BIRTHDATE=6, DEFAULT_ROOM=7
    }
}
