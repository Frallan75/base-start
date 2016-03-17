//
//  Post.swift
//  base-start
//
//  Created by Francisco Claret on 13/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _postDescription: String!
    private var _imageUrl: String?
    private var _likes: Int!
    private var _postKey: String!
    private var _postRef: Firebase!
    private var _posterId: String!

    var postDescription: String {
        return _postDescription
    }
    
    var imageUrl: String? {
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
    
    init(postKey: String, dict: Dictionary<String, AnyObject>) {
        
        self._postKey = postKey
        
        if let likes = dict["likes"] as? Int {
            self._likes = likes
        }
        
        if let imageUrl = dict["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let desc = dict["description"] as? String {
            self._postDescription = desc
        }
        
        if let posterId = dict["id"] as? String {
            self._posterId = posterId
        }
        
        self._postRef = DataService.ds.REF_POSTS.childByAppendingPath(self._postKey)
    }
    
    func adjustLikes(addlike: Bool) {
        
        if addlike {
            _likes = _likes + 1
            
        } else {
            _likes = _likes - 1
        }
        
        _postRef.childByAppendingPath("likes").setValue(_likes)
    }
    
}

