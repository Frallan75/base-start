//
//  LoggedInVC.swift
//  base-start
//
//  Created by Francisco Claret on 12/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class LoggedInVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImageView: UIImageView!
    @IBOutlet weak var userImgView: UIImageView!
    
    var postArray: [Post] = []
    static var imageCache = NSCache()
    var imagePicker = UIImagePickerController()
    var imageSelected = false
    var userImg: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        imagePicker.delegate = self
        
        DataService.ds.REF_USER_CURRENT.childByAppendingPath("profileImgUrl").observeSingleEventOfType(.Value, withBlock: { snapshot in
            
            if let profileImgUrl = snapshot.value as? String {
                
                DataService.ds.fetchImageFromUrl(profileImgUrl, completion: { (image) -> () in
                    
                    self.userImg = image
                    self.userImgView.image = self.userImg
                    LoggedInVC.imageCache.setObject(image, forKey: profileImgUrl)
                    
                })
                
            } else {
                self.userImg = UIImage(named: "add_user_img.png")
            }
        })
    
        DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapshot in
            
            self.postArray = []
            
            if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                
                for snap in snapshots {

                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, dict: postDict)
                        self.postArray.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        
        userImgView.layer.cornerRadius = userImgView.frame.width / 2
        userImgView.clipsToBounds = true
        userImgView.clipsToBounds = true
    }
    
    @IBAction func logoutBtnPressed(sender: AnyObject) {
       
        print("in unauth")
        NSUserDefaults.standardUserDefaults().setValue(nil, forKey: KEY_UID)
        print("in log out btn pressed: \(NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID))")
        DataService.ds.REF_BASE.unauth()
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func makePost(sender: UIButton) {
        
        if let txt = postField.text where txt != "" {
            
            DataService.ds.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: { snapshot in
                
                let id = snapshot.key
                
                if let dict = snapshot.value as? Dictionary<String, AnyObject> {
                    
                    if let profileImgUrl = dict["profileImgUrl"] as? String {
                        
                        DataService.ds.fetchImageFromUrl(profileImgUrl, completion: { (image) -> () in
                            
                            self.userImg = image
                            self.userImgView.image = self.userImg
                            
                            LoggedInVC.imageCache.setObject(image, forKey: profileImgUrl)
                            
                            if let img = self.imageSelectorImageView.image where self.imageSelected == true {
                                
                                DataService.ds.postImgToImageschack(img, completion: { imageschackUrl in
                                    
                                    self.postToFirebase(imageschackUrl, profileId: id)
                                })
                                
                            } else {
                                
                                self.postToFirebase(nil, profileId: id)
                                
                            }
                        })
                    }
                }
            })
        }
    }
    
    func postToFirebase(imgUrl: String?, profileId: String?) {
        
        var post: Dictionary<String, AnyObject> = ["description": postField.text!, "likes": 0]
        
        if imgUrl != nil {
        
            post["imageUrl"] = imgUrl!
        }
        
        post["id"] = profileId
        
        DataService.ds.REF_POSTS.childByAutoId().setValue(post)
        
        postField.text = ""
        imageSelectorImageView.image = UIImage(named: "compact-camera-xxl.png")
        imageSelected = false
        postField.resignFirstResponder()
        tableView.reloadData()
    }
}

//TABLEVIEW
extension LoggedInVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return postArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            let post = postArray[indexPath.row]
            
            if let cell = tableView.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
                
                cell.request?.cancel()
                
                var img: UIImage?
                
                if let url = post.imageUrl {
                    img = LoggedInVC.imageCache.objectForKey(url) as? UIImage
                }
                
                cell.configureCell(post, img: img, userImg: self.userImg)
                
                return cell
            
            } else {

            return PostCell()
            }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let post = postArray[indexPath.row]
        
        if post.imageUrl == nil {
            return 150.0
        } else {
            return 463.0
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0
        } else if section == 1 {
            return 50
        } else {
            return 0
        }
    }
}

//IMAGEPICKER
extension LoggedInVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.imageSelectorImageView.image = image
        imageSelected = true
        
    }
    
    @IBAction func selectImage(sender: UITapGestureRecognizer) {
        
    presentViewController(imagePicker, animated: true, completion: nil)
    
    }
}
