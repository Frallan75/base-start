//
//  Constants.swift
//  base-start
//
//  Created by Francisco Claret on 12/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import Foundation
import UIKit


let SHADOW_COLOR = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 0.5)
let BORDER_COLOR = UIColor(red: 157/255, green: 157/255, blue: 157/255, alpha: 0.1)

let KEY_UID = "uid"


//SEGUES

let SEGUE_LOGGED_IN = "loggedIn"
let SEGUE_SETUP_USER = "setupUser"
let SEGUE_TO_LOGGED_IN = "setupToLoggedIn"

//STATUS CODES

let STATUS_ACCOUNT_NONEXIST = -8

//IMG HANDLING
let MAX_IMG_SIZE: CGFloat = 100000
let IMG_CACHE: NSCache<NSString, UIImage> = NSCache()

