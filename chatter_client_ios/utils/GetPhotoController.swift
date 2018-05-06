//
//  GetPhotoController.swift
//  chatter_client_ios
//
//  Created by Andrey Germanov on 06.05.2018.
//  Copyright © 2018 Andrey Germanov. All rights reserved.
//

import UIKit
import Foundation

/**
 *
 *  Utility class which used as a helper to select image source and pick image
 *  either from Camera, or from Gallery. It shows dialog to delect image source
 *  and then depending on selected source runs appropriate software
 */
class GetPhoto: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    /// Callback, which is used to transfer selected image to function, initiated image picking process
    var callback: ((_ image:Data)->())? = nil
    /// Parent view controller
    var parent: UIViewController
    
    /**
     * Class constructor
     *
     * - Parameter parent: Parent view controller which starts image picking process
     * - Parameter callback: Callback, function which is called when image captured or canceled with "image" parameter
     */
    init(parent:UIViewController,callback:((_ image:Data?)->())? = nil) {
        self.parent = parent
        self.callback = callback
    }

    /**
     *  Function shows image source selection dialog and starts image picker process when
     *  user selects image source
     */
    func run() {
        let dialog = UIAlertController(title: "Select", message: "Image source", preferredStyle: .actionSheet)
        dialog.addAction(UIAlertAction(title: "Camera", style: .default, handler: { v in
            self.getPhoto(.camera)
        }))
        dialog.addAction(UIAlertAction(title: "Photo library", style: .default, handler: { v in
            self.getPhoto(.photoLibrary)
            
        }))
        self.parent.present(dialog, animated: true, completion: nil)
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
        self.parent.present(dialog, animated: true, completion: nil)
    }
    
    /**
     * Function fired when user captures image either from Camera or form PhotoLibrary
     *
     * - Parameter picker: Link to Source Image Picker component dialog
     * - Parameter info: Array of captured information, including captured image and other metadata
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        print("HERE1")
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let data = UIImagePNGRepresentation(image) {
                print("ONE")
                if let callback = self.callback {
                    print("TWO")
                    callback(data)
                }
                picker.dismiss(animated: true, completion: nil)
            }
        }
    }

}
