//
//  Post.swift
//  base-start
//
//  Created by Francisco Claret on 13/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FBSDKCoreKit

class Post {
    
    fileprivate var _postDescription: String!
    fileprivate var _imageUrl: NSString?
    fileprivate var _likes: Int!
    fileprivate var _postKey: String!
    fileprivate var _postRef: FIRDatabaseReference!
    fileprivate var _posterId: String!
    fileprivate var _commentCount: Int!

    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: NSString? {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var postKey: String {
        return _postKey
    }
    
    var posterId: String {
        return _posterId
    }
    
    var commentCount: Int {
        return _commentCount
    }
    
    init(postKey: String, dict: Dictionary<String, AnyObject>) {
        
        self._postKey = postKey
        
        if let likes = dict["likes"] as? Int {
            self._likes = likes
        }
        
        if let imageUrl = dict["postImgUrl"] as? NSString {
            self._imageUrl = imageUrl
        }
        
        if let desc = dict["description"] as? String {
            self._postDescription = desc
        }
        
        if let posterId = dict["posterId"] as? String {
            self._posterId = posterId
        }
        
        self._postRef = DataService.ds.REF_POSTS.child("\(postKey)")
//        self._postRef = DataService.ds.REF_POSTS.child("\(self._postKey)")
    }
    
    func adjustLikes(_ addlike: Bool) {
        
        if addlike {
            _likes = _likes + 1
            
        } else {
            _likes = _likes - 1
        }
    
        _postRef.child("likes").setValue(_likes)
    }
    
}

