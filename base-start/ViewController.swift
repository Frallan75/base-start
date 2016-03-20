//
//  ViewController.swift
//  base-start
//
//  Created by Francisco Claret on 12/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController {

    @IBOutlet weak var passwordField: MaterialTextField!
    @IBOutlet weak var emailField: MaterialTextField!

    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.titleLabel!.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
            
            let userKey = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID)
            self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: userKey)
        }
    }
    
    @IBAction func attemptLoginBtn(sender: UIButton) {
        
        if let email = emailField.text where email != "", let pwd = passwordField.text where pwd != "" {
            
            clearForm()
            
            DataService.ds.REF_BASE.authUser(email, password: pwd, withCompletionBlock: { error , authData in
                
                if error != nil {
                    
                    if let errorDesc = FAuthenticationError(rawValue: error.code) {
                        
                        switch errorDesc {
                            
                        case .UserDoesNotExist:
                            
                            let user = ["email" : email, "pwd": pwd]
                            
                            self.performSegueWithIdentifier(SEGUE_SETUP_USER, sender: user)
                        
                        case .EmailTaken:
                            self.displayAlert("User already exists!", msg: "Please choose another user!")
                            
                        case .InvalidEmail:
                            self.displayAlert("Invalid Email", msg: "Please insert a vaild e-mail adress!")
                            
                        case .InvalidPassword:
                            self.displayAlert("Invalid Password", msg: "Please try again!")
                        default:
                            self.displayAlert("Server alert", msg: "The server found a problem, please try again later!")
                        }
                    }
                    
                } else {
                    
                    NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                    self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    
                }
            })
        } else {
            displayAlert("Email and password required!", msg: "Please fill in both email and password fields")
        }
    }
    
    @IBAction func fbBtnPressed(sender: UIButton) {
        
        clearForm()
        
        let facebookLogin = FBSDKLoginManager()
        var user = Dictionary<String, String>()
        
        facebookLogin.logInWithReadPermissions(["email", "public_profile"], fromViewController: self) { result, error in
        
            if error != nil {
                print("Facebook login failed. Error \(error)")
            
            } else {
                
                let fbRequest = FBSDKGraphRequest(graphPath:"me", parameters: ["fields": "email, name"])
                
                fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
                    
                    if error != nil {
                        
                        print("Error Getting Info \(error)")
                        
                    } else {
                    
                        let dict = result as! Dictionary<String, String>
                        user["username"] = dict["name"]
                        
                    }
                }

                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
    
                DataService.ds.REF_BASE.authWithOAuthProvider("facebook", token: accessToken, withCompletionBlock: { error, authData in
                    
                    if error != nil {
                        
                        print("Login Failed. \(error)")
                    
                    } else {
                        
                        if NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) != nil {
                            
                        } else {
                        
                        let userId = authData.uid!.stringByReplacingOccurrencesOfString("facebook:", withString: "")
                            
                        user["profileImgUrl"] = "https://graph.facebook.com/\(userId)/picture?type=large"
                        user["provider"] = authData.provider!
                        user["id"] = authData.uid!
                        
                        DataService.ds.createFirebaseUser(authData.uid, user: user)
                
                        }
                        NSUserDefaults.standardUserDefaults().setValue(authData.uid, forKey: KEY_UID)
                        self.performSegueWithIdentifier(SEGUE_LOGGED_IN, sender: nil)
                    }
                })
            }
        }
    }
    
    func displayAlert(title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == SEGUE_SETUP_USER {
            
            if let vc = segue.destinationViewController as? SetupUserVC {
                vc.user = sender!
                
            } else {
                
                print("unable to perform segue")
            }
            
        }
    }
    
    func clearForm() {
        
        self.emailField.text = ""
        self.passwordField.text = ""
    }
}

