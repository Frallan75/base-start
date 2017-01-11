//
//  CommentsVc.swift
//  base-start
//
//  Created by Francisco Claret on 17/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import Alamofire

class CommentsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postCommentTxtField: MaterialTextField!
    
    var commentsArray: [Comment] = []
    var postKey: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        
        
        //LOADING EVENTUAL EXISTING COMMENTS
        let postRef = DataService.ds.REF_POSTS.child(postKey).child("comments")
        let commentRef = DataService.ds.REF_COMMENTS
        
        postRef.observe(.value, with: { snapshot in
            
            self.commentsArray = []
            
            if let _ = snapshot.value as? NSNull {
                print("no comments yet")
                
            } else {
                
                if let snapshots = snapshot.children.allObjects as? [FIRDataSnapshot] {
                    
                    for snap in snapshots {
                        
                        let commentId = snap.key
                        
                        let ref = commentRef.child("\(commentId)")
                        
                        ref.observeSingleEvent(of: .value, with: { snapshot in
                            
                            if var comment = snapshot.value as? Dictionary<String, AnyObject> {
                                
                                if let uid = comment["commenterId"] as? String {
                                    
                                    DataService.ds.REF_USERS.child("\(uid)").observeSingleEvent(of: .value, with: { snapshot in
                                        
                                        if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                                            
                                            if let username = userDict["username"] as? String, let imgUrl = userDict["profileImgUrl"] as? String {
                                                
                                                comment["username"] = username as AnyObject?
                                                comment["profileImgUrl"] = imgUrl as AnyObject?
                                                
                                                let commentToAppend = Comment(commentKey: commentId, dict: comment)
                                                
                                                self.commentsArray.append(commentToAppend)
                                                self.tableView.reloadData()
                                                
                                            }
                                        }
                                    })
                                }
                            }
                        })
                    }
                }
            }
        })
        
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.reloadData()
    }
    
    @IBAction func makeComment() {
        
        if let commentText = postCommentTxtField.text, commentText != "" {
            
            DataService.ds.REF_USER_CURRENT.observeSingleEvent(of: .value, with: { snapshot in
                
                let uid = snapshot.key
                
                self.commentToFirebase(commentText, commenterId: uid)
            })
        }
    }
    
    func commentToFirebase(_ commentText: String, commenterId: String) {
        
        let comment: Dictionary<String, AnyObject> = ["commentText": commentText as AnyObject, "commenterId": commenterId as AnyObject, "timestamp": "N/A" as AnyObject]
        
        DataService.ds.REF_COMMENTS.childByAutoId().setValue(comment) { error, snapshot in
            
            if error != nil {
                print("Error making comment to firebase")
                
            } else {
                
                let commentKey = snapshot.key
                
                DataService.ds.REF_COMMENTS.child("\(commentKey)").updateChildValues(["timestamp": FIRServerValue.timestamp()])
                DataService.ds.REF_USERS.child("\(commenterId)").child("comments").child("\(commentKey)").setValue(true)
                DataService.ds.REF_POSTS.child("\(self.postKey!)").child("comments").child("\(commentKey)").setValue(true)
                self.tableView.reloadData()
            }
        }
        
        postCommentTxtField.text = ""
        postCommentTxtField.resignFirstResponder()
    }
}

//TABLEVIEW EXTENSION
extension CommentsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell") as? CommentsViewCell {
            
            let currentComment = commentsArray[indexPath.row]
            let text = currentComment.commentText
            let commenterId = currentComment.uId
            let url = currentComment.commenterProfileImgUrl
            let username = currentComment.commenterUsername
            let time = Double(currentComment.timestamp / 1000)
            let newTime = Date(timeIntervalSince1970: time)
            let timestamp = DataService.ds.convertTimeStamp(currentComment.timestamp)
            
            cell.configureCommentsViewCell(text, commenterId: commenterId, commenterProfileImgUrl: url, username: username, timestamp: timestamp)
            
            return cell
        }
        return UITableViewCell()
    }
}

