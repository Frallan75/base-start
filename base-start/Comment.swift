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
import Firebase

class Comment {
    
    private var _commentText: String!
    private var _uId: String!
    private var _commentKey: String!
    private var _commenterUsername: String!
    private var _commenterProfileImgUrl: String!
    private var _commenterProfileImg: UIImage!
    
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
    
 
    
    init(commentKey: String, dict: Dictionary<String, AnyObject>) {
        
        self._commentKey = commentKey
        
        self._commentText = dict["commentText"] as? String
        self._uId = dict["commenterId"] as? String
        self._commenterUsername = dict["username"] as? String
        self._commenterProfileImgUrl = dict["profileImgUrl"] as? String 
        
        
        
        }
}

