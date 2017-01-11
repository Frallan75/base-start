//
//  PostCell.swift
//  base-start
//
//  Created by Francisco Claret on 13/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit
import Alamofire
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FBSDKCoreKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var commentsBtn: UIButton!
    
    var post: Post!
    var request: Request?
    var likeRef: FIRDatabaseReference!
    var fetchedImg: UIImage!
    var numberOfComments: UInt!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(PostCell.likeTapped(_:)))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
    }
    
    override func draw(_ rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
        postImageView.clipsToBounds = true
    }
    
    // POST CONFIG
    
    func configureCell(_ post: Post) {
        
        self.post = post
        self.descLbl.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        //POST IMAGE
        
        if post.imageUrl != nil {
            
            self.postImageView.isHidden = false
            
            if let img = IMG_CACHE.object(forKey: post.imageUrl! as NSString) {
                self.postImageView.image = img
            } else {
                
                DataService.ds.getImgFromFBS(imageUrl: "\(post.postKey)/postImg.png") {(image) in
                    self.postImageView.image = image
                    IMG_CACHE.setObject(image, forKey: self.post.imageUrl! as NSString)
                }
            }
            
        } else {
            self.postImageView.isHidden = true
        }
        
        //PROFILEIMG & USERNAME
        
        let userIdRef = DataService.ds.REF_USERS.child("\(post.posterId)")
        
        userIdRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                
                if let username = dict["username"] as? String {
                    self.usernameLbl.text = username
                }
                
                if let profileImageUrl = dict["profileImgUrl"] as? String {
                    
                    if let profileImg = IMG_CACHE.object(forKey: profileImageUrl as NSString) {
                        
                        self.profileImage.image = profileImg
                        
                    } else {
                        
                        DataService.ds.getImgFromFBS(imageUrl: "\(post.posterId)/profileImg.png", completion: { image in
                            self.profileImage.image = image
                            IMG_CACHE.setObject(image, forKey: profileImageUrl as NSString)
                            
                            
                        })
                    }
                }
            }
        })
        
        //LIKESIMG CONTROL
        
        likeRef = DataService.ds.REF_USER_CURRENT.child("likes").child("\(post.postKey)")
        
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if let _ = snapshot.value as? NSNull {
                //This means we have note liked this specific post
                self.likeImg.image = UIImage(named: "heart-empty.png")
            } else {
                self.likeImg.image = UIImage(named: "heart-full.png")
            }
        })
        
        //NUMBER OF COMMENTS
        
        let postCommentsRef = DataService.ds.REF_POSTS.child("\(post.postKey)").child("comments")
        
        postCommentsRef.observeSingleEvent(of: .value, with: { snapshot in
            
            self.numberOfComments = snapshot.childrenCount
            
            self.commentsBtn.setTitle("Comments (\(self.numberOfComments!))", for: UIControlState())
        })
        
    }
    
    func likeTapped(_ sender: UITapGestureRecognizer) {
        print(likeRef)
        
        likeRef.observeSingleEvent(of: .value, with: { snapshot in
            
            if let _ = snapshot.value as? NSNull {
                
                //This means we have note liked this specific post
                
                self.likeImg.image = UIImage(named: "heart-full.png")
                self.post.adjustLikes(true)
                self.likeRef.setValue(true)
                
            } else {
                
                self.likeImg.image = UIImage(named: "heart-empty.png")
                self.post.adjustLikes(false)
                self.likeRef.removeValue()
                
            }
        })
    }
}
