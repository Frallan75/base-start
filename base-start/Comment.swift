//
//  Comment.swift
//  base-start
//
//  Created by Francisco Claret on 17/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FBSDKCoreKit

class Comment {
    
    fileprivate var _commentText: String!
    fileprivate var _uId: String!
    fileprivate var _commentKey: String!
    fileprivate var _commenterUsername: String!
    fileprivate var _commenterProfileImgUrl: String!
    fileprivate var _commenterProfileImg: UIImage!
    fileprivate var _timestamp: Int!
    
    var commentText: String {
        return _commentText
    }
    
    var uId: String {
        return _uId
    }
    
    var commentKey: String {
        return _commentKey
    }
    
    var commenterUsername: String {
        return _commenterUsername
    }
    
    var commenterProfileImgUrl: String {
        return _commenterProfileImgUrl
    }
    
    var commenterProfileImg: UIImage {
        return _commenterProfileImg
    }
    
    var timestamp: Int {
        return _timestamp
    }
    
    init(commentKey: String, dict: Dictionary<String, AnyObject>) {
        
        self._commentKey = commentKey
        self._commentText = dict["commentText"] as? String
        self._uId = dict["commenterId"] as? String
        self._commenterUsername = dict["username"] as? String
        self._commenterProfileImgUrl = dict["profileImgUrl"] as? String
        self._timestamp = dict["timestamp"] as? Int
    }
}

