//
//  CommentsVc.swift
//  base-start
//
//  Created by Francisco Claret on 17/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit
import Firebase
import Alamofire

class CommentsVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postCommentTxtField: MaterialTextField!
    
    var commentsArray: [Comment] = []
    var postKey: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //LOADING EVENTUAL EXISTING COMMENTS
        
        
        
        
        let postRef = DataService.ds.REF_POSTS.childByAppendingPath(postKey).childByAppendingPath("comments")
        let commentRef = DataService.ds.REF_COMMENTS
        
        postRef.observeEventType(.Value, withBlock: { snapshot in
        
        self.commentsArray = []
            
            if let _ = snapshot.value as? NSNull {
                print("no comments yet")
                
            } else {
                
                if let snapshots = snapshot.children.allObjects as? [FDataSnapshot] {
                    
                    for snap in snapshots {
                        
                        let commentId = snap.key
                        print("the ket for the child \(commentId)")
                        
                        let ref = commentRef.childByAppendingPath(commentId)
                        
                            print("printing ref")
                            print(ref)
                                
                            ref.observeSingleEventOfType(.Value, withBlock: { snapshot in
                            
                                print("inside the snap of the comment")
                                
                                print(snapshot.value)
                                if var comment = snapshot.value as? Dictionary<String, AnyObject> {
                                
                                    if let uid = comment["commenterId"] as? String {
                                        
                                        DataService.ds.REF_USERS.childByAppendingPath(uid).observeSingleEventOfType(.Value, withBlock: { snapshot in
                                            
                                            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                                                
                                                if let username = userDict["username"] as? String, imgUrl = userDict["profileImgUrl"] as? String {
                                                    
                                                    print("inside adding to array")
                                                    
                                                    comment["username"] = username
                                                    comment["profileImgUrl"] = imgUrl
                                                    
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
        
        if let commentText = postCommentTxtField.text where commentText != "" {
            
                DataService.ds.REF_USER_CURRENT.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    
                    let uid = snapshot.key
                    
                    self.commentToFirebase(commentText, commenterId: uid)
                })
            }
    }
                
    func commentToFirebase(commentText: String, commenterId: String) {
        
        let comment: Dictionary<String, AnyObject> = ["commentText": commentText, "commenterId": commenterId]
        
        print("comment \(comment)")
        
        
        DataService.ds.REF_COMMENTS.childByAutoId().setValue(comment) { error, snapshot in
            
            
            if error != nil {
                print("Error making comment to firebase")

            } else {
                
                
                let commmentKey = snapshot.key
                
                DataService.ds.REF_USERS.childByAppendingPath(commenterId).childByAppendingPath("comments").childByAppendingPath(commmentKey).setValue(true)
                DataService.ds.REF_POSTS.childByAppendingPath(self.postKey).childByAppendingPath("comments").childByAppendingPath(commmentKey).setValue(true)
            }
        }
        
        
        
        postCommentTxtField.text = ""
        postCommentTxtField.resignFirstResponder()
        tableView.reloadData()
        
    }
}

//TABLEVIEW

extension CommentsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(commentsArray.count)
        return commentsArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("CommentsCell") as? CommentsViewCell {
            print("inside cellforrow")
            print(commentsArray)
            
            let currentComment = commentsArray[indexPath.row]
            
            print(currentComment)
            
            let text = currentComment.commentText
            let commenterId = currentComment.uId
            let url = currentComment.commenterProfileImgUrl
            let username = currentComment.commenterUsername
            
            cell.configureCommentsViewCell(text, commenterId: commenterId, commenterProfileImgUrl: url, username: username)
            
            
            
            return cell
        }
        return UITableViewCell()
    }
    
    
}

