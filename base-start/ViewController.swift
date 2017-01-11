//
//  ViewController.swift
//  base-start
//
//  Created by Francisco Claret on 12/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var passwordField: MaterialTextField!
    @IBOutlet weak var emailField: MaterialTextField!
    @IBOutlet weak var fbLoginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fbLoginButton.titleLabel!.adjustsFontSizeToFitWidth = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if UserDefaults.standard.value(forKey: KEY_UID) != nil {
            
            let userKey = UserDefaults.standard.value(forKey: KEY_UID)
            self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: userKey)
        }
    }
    
    @IBAction func attemptLoginBtn(_ sender: UIButton) {
        
        if let email = emailField.text, email != "", let pwd = passwordField.text, pwd != "" {
            
            clearForm()
            
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { authData, error in
                
                if let error = error as? NSError {
                    
                    if let errorDesc = FIRAuthErrorCode(rawValue: error.code) {
                        
                        switch errorDesc {
                            
                        case .errorCodeUserNotFound:

                            let user = ["email" : email, "pwd": pwd]
                            
                            self.performSegue(withIdentifier: SEGUE_SETUP_USER, sender: user)
                        
                        case .errorCodeEmailAlreadyInUse:
                            self.displayAlert("User already exists!", msg: "Please choose another user!")
                            
                        case .errorCodeInvalidEmail:
                            self.displayAlert("Invalid Email", msg: "Please insert a vaild e-mail adress!")
                            
                        case .errorCodeWrongPassword, .errorCodeWeakPassword :
                            self.displayAlert("Invalid Password", msg: "Please try again!")
                        default:
                            self.displayAlert("Server alert", msg: "The server found a problem, please try again later!")
                        }
                    }
                    
                } else {
                    
                    UserDefaults.standard.setValue(authData?.uid, forKey: KEY_UID)
                    self.performSegue(withIdentifier: SEGUE_LOGGED_IN, sender: nil)
                    
                }
            })
        } else {
            displayAlert("Email and password required!", msg: "Please fill in both email and password fields")
        }
    }
    
    @IBAction func fbLoginBtnPressed(_ sender: UIButton) {
        
        displayAlert("Error!", msg: "FB Login not available yet, coming soon!")
    }
    
    func displayAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == SEGUE_SETUP_USER {
            if let vc = segue.destination as? SetupUserVC {
                vc.user = sender! as AnyObject
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

