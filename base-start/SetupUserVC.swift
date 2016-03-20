//
//  SetupUserVC.swift
//  base-start
//
//  Created by Francisco Claret on 15/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class SetupUserVC: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var chosenEmailLbl: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var imagePicker = UIImagePickerController()
    
    private var _user: AnyObject!
    private var _userEmail: String!
    private var _userPwd: String!
    
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
    
    @IBAction func saveBtnPressed(sender: UIButton) {
        
        if let username = userNameTextField.text where username != "" {
            
            var userToSave: Dictionary<String, AnyObject>!
            
            DataService.ds.REF_BASE.createUser(self.userEmail, password: self.userPwd, withValueCompletionBlock: { error, userData in
                
                if error != nil {
                    
                    print(error.debugDescription)
                    
                } else {
                    
                    DataService.ds.postImgToImageschack(self.userImageView.image!, completion:{ imageschackUrl in
                        
                        LoggedInVC.imageCache.setObject(self.userImageView.image!, forKey: imageschackUrl)
                        
                        userToSave = ["provider": "emailaccount", "username": username, "profileImgUrl": imageschackUrl]
                        
                        DataService.ds.REF_USERS.childByAppendingPath("\(userData["uid"]!)").setValue(userToSave)
                        
                        NSUserDefaults.standardUserDefaults().setValue(userData[KEY_UID], forKey: KEY_UID)
                        
                        self.performSegueWithIdentifier("setupToLoggedIn", sender: nil)
                    })
                }
            })
            
        } else {
            self.displayAlert("Username Fail!", msg: "Please enter an unsername!")
        }
    }
    
    func displayAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func pickUserImg(sender: UITapGestureRecognizer) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
}

extension SetupUserVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.userImageView.image = image
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
    }
}


