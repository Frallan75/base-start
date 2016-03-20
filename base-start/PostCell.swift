//
//  PostCell.swift
//  base-start
//
//  Created by Francisco Claret on 13/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit
import Alamofire
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var showcaseImage: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var descLbl: UITextView!
    @IBOutlet weak var imageUrlLbl: UIImageView!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var showHideCommentsBtn: UIButton!
    
    var post: Post!
    var request: Request?
    var likeRef: Firebase!
    var fetchedImg: UIImage!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: "likeTapped:")
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.userInteractionEnabled = true
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImage.layer.cornerRadius = profileImage.frame.width / 2
        profileImage.clipsToBounds = true
        showcaseImage.clipsToBounds = true
    }
    
    // POST CONFIG
    
    func configureCell(post: Post, img: UIImage?, userImg: UIImage?) {
        
        self.post = post
        self.descLbl.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        //POST IMAGE
        
        if post.imageUrl != nil {
            
            self.imageUrlLbl.hidden = false
            
            if img != nil {
                
                self.imageUrlLbl.image = img
            
            } else {
            
                DataService.ds.fetchImageFromUrl(post.imageUrl!, completion: { (image) -> () in
                    
                    self.imageUrlLbl.image = image
                    
                })
            }
            
        } else {
            self.imageUrlLbl.hidden = true
        }
        
        //PROFILEIMG & USERNAME
        
        let userIdRef = DataService.ds.REF_USERS.childByAppendingPath("\(post.posterId)")
        
        userIdRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                
                if let username = dict["username"] as? String {
                    self.usernameLbl.text = username
                }
                                
                if let profileImageUrl = dict["profileImgUrl"] as? String {
                    
                    if let profileImg = LoggedInVC.imageCache.objectForKey(profileImageUrl) as? UIImage {
                        
                        self.profileImage.image = profileImg
                        
                    } else {
                        
                        DataService.ds.fetchImageFromUrl(profileImageUrl, completion: { image in
                            
                            self.profileImage.image = image
                        })
                        
                    }
                }
            }
        })

        //LIKESIMG CONTROL
        
        likeRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("likes").childByAppendingPath(post.postKey)

        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let _ = snapshot.value as? NSNull {
                //This means we have note liked this specific post
                self.likeImg.image = UIImage(named: "heart-empty.png")
            } else {
                self.likeImg.image = UIImage(named: "heart-full.png")
            }
        })
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
          print(likeRef)
        likeRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            
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
