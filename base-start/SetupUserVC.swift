//
//  SetupUserVC.swift
//  base-start
//
//  Created by Francisco Claret on 15/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FBSDKCoreKit
import Alamofire

class SetupUserVC: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var chosenEmailLbl: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    fileprivate var _user: AnyObject!
    fileprivate var _userEmail: String!
    fileprivate var _userPwd: String!
    
    var userEmail: String {
        return _userEmail
    }
    
    var userPwd: String {
        return _userPwd
    }
    
    var user: AnyObject {
        get {
            return _user
        }
        set(newValue) {
            
            self._user = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = userImageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickUserImg))
        imageView?.isUserInteractionEnabled = true
        imageView?.addGestureRecognizer(tapGestureRecognizer)
        
        imagePicker.delegate = self
        
        if let userEmail = user["email"] as? String {
        
            self._userEmail = userEmail
            chosenEmailLbl.text = self.userEmail
        
        } else {
            
            chosenEmailLbl.text = "No email chosen"
        }
        
        if let userPwd = user["pwd"] as? String {
            self._userPwd = userPwd
        }
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        
        if let username = userNameTextField.text, username != "" {
            
            var userToSave: Dictionary<String, AnyObject>!
            
            FIRAuth.auth()?.createUser(withEmail: self.userEmail, password: self.userPwd, completion: { authUser, error in
                
                if error != nil {
                    
                    self.displayAlert("Error", body: "The folloeing error occurred \(error.debugDescription)")
                    
                } else {
        
                    DataService.ds.uploadImage(uid: authUser!.uid, imageName: "profileImg.png" , image: self.userImageView.image!, completeUpload: { (imgUrl) in
                        
                        userToSave = ["provider": "emailaccount" as AnyObject, "username": username as AnyObject, "profileImgUrl": imgUrl as AnyObject]
                        
                        DataService.ds.REF_USERS.child("\(authUser!.uid)").setValue(userToSave)
                        
                        UserDefaults.standard.setValue(authUser!.uid, forKey: "uid")
                        
                        self.performSegue(withIdentifier: "setupToLoggedIn", sender: nil)
                    })
                }
            })
            
        } else {
            self.displayAlert("Username Fail!", body: "Please enter an unsername!")
        }
    }
    
    func selectImage() {
        
        let imageAlert = UIAlertController(title: "Pick image", message: nil, preferredStyle: .actionSheet)
        
        let cameraOption = UIAlertAction(title: "Camera", style: .default, handler: { (action) in
            if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
            } else {
                self.displayAlert("Warning!", body: "You don't have a camera!")
            }
        })
        
        let photoAlbumAction = UIAlertAction(title: "Album", style: .default, handler: { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        })
        
        let cancelImageAlertAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        imageAlert.addAction(cameraOption)
        imageAlert.addAction(photoAlbumAction)
        imageAlert.addAction(cancelImageAlertAction)
        
        present(imageAlert, animated: true, completion: nil)
    }
    
    func displayAlert(_ title: String, body: String) {
        
        let alert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func pickUserImg(_ sender: UITapGestureRecognizer) {
        selectImage()
    }
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        
        present(imagePicker, animated: true, completion: nil)
    }
}

extension SetupUserVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        self.userImageView.image = image
        dismiss(animated: true, completion: nil)
    }
}
