//
//  LoggedInVC.swift
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

class LoggedInVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postField: MaterialTextField!
    @IBOutlet weak var imageSelectorImageView: UIImageView!
    @IBOutlet weak var userImgView: UIImageView!
    
    var postArray: [Post] = []
    var postKey: String!
    var imagePicker = UIImagePickerController()
    var imageSelected = false
    var userImg: UIImage!
    var user: FIRUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IMG_CACHE.removeAllObjects()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        user = FIRAuth.auth()?.currentUser
        
        tableView.delegate = self
        tableView.dataSource = self
        imagePicker.delegate = self
        
        DataService.ds.getImgFromFBS(imageUrl: ("\(self.user.uid)/profileImg.png"), completion: { (image) -> () in
            
            self.userImg = image
            self.userImgView.image = self.userImg
        })
        
        DataService.ds.REF_POSTS.observe(.value, with: { snapshot in
            
            self.postArray = []
            
            if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                
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
    
    override func viewDidAppear(_ animated: Bool) {
        
        userImgView.layer.cornerRadius = userImgView.frame.width / 2
        userImgView.clipsToBounds = true
        userImgView.clipsToBounds = true
    }
    
    @IBAction func logoutBtnPressed(_ sender: AnyObject) {
        
        UserDefaults.standard.setValue(nil, forKey: KEY_UID)
        
        do {
            try FIRAuth.auth()?.signOut()
            if let domainName = Bundle.main.bundleIdentifier { UserDefaults.standard.removePersistentDomain(forName: domainName)}
        } catch {
            print("error logging out")
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func makePost(_ sender: UIButton) {
        
        if let txt = postField.text, txt != "" {
            
            var postDict: Dictionary<String, AnyObject> = ["description": postField.text! as AnyObject,
                                                           "likes": 0 as AnyObject,
                                                           "posterId": self.user.uid as AnyObject]
            
            let newPostRef = FIRDatabase.database().reference().child("posts").childByAutoId()
            
            self.postKey = newPostRef.key
            
            postDict["postKey"] = newPostRef.key as AnyObject?
            
            if let img = self.imageSelectorImageView.image, self.imageSelected == true {
                
                DataService.ds.uploadImage(uid: newPostRef.key, imageName: "postImg.png", image: img, completeUpload: { postImgUrl in
                    postDict["postImgUrl"] = postImgUrl as AnyObject?
                    IMG_CACHE.setObject(img, forKey: postImgUrl)
                    newPostRef.setValue(postDict)
                    self.tableView.reloadData()
                })
            } else {
                newPostRef.setValue(postDict)
                self.tableView.reloadData()
            }
        }
        self.postField.text = ""
        self.imageSelectorImageView.image = UIImage(named: "compact-camera-xxl.png")
        self.imageSelected = false
        self.postField.resignFirstResponder()
    }
    
    @IBAction func commentsButtonPressed(_ sender: UIButton) {
        
        var post: Post!
        
        let point = tableView.convert(CGPoint.zero, from: sender)
        if let indexPath = tableView.indexPathForRow(at: point) {
            post = postArray[indexPath.row]
            postKey = post.postKey
            performSegue(withIdentifier: "commentViewSegue", sender: postKey)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "commentViewSegue" {
            if let vc = segue.destination as? CommentsVC {
                vc.postKey = self.postKey
            } else {
                print("Error presenting Comments View")
            }
        }
    }
}

//IMAGEPICKER EXTENSION
extension LoggedInVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        imagePicker.dismiss(animated: true, completion: nil)
        self.imageSelectorImageView.image = image
        imageSelected = true
    }
    
    @IBAction func selectImage(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }
}

//TABLEVIEW EXTENSION
extension LoggedInVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = postArray[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            cell.request?.cancel()
            cell.configureCell(post)
            return cell
            
        } else {
            return PostCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
