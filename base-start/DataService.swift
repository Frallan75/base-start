//
//  DataService.swift
//  base-start
//
//  Created by Francisco Claret on 12/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import Foundation
import Firebase
import Alamofire

let BASE_URL = "https://base-start.firebaseio.com"

class DataService {
    
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "\(BASE_URL)")
    private var _REF_POSTS = Firebase(url: "\(BASE_URL)/posts")
    private var _REF_USERS = Firebase(url: "\(BASE_URL)/users")
    private var _REF_COMMENTS = Firebase(url: "\(BASE_URL)/comments")
    
    var storedImgUrl: String!
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_COMMENTS: Firebase {
        return _REF_COMMENTS
    }
    
    var REF_USER_CURRENT: Firebase {
        
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
        let user = Firebase(url: "\(BASE_URL)").childByAppendingPath("users").childByAppendingPath(uid)
        return user
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
    
    func fetchImageFromUrl(url: String, completion: (image: UIImage) -> ()) {
        
        Alamofire.request(.GET, url).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, error -> Void in
            
            let fetchedImage: UIImage!
            
            if error == nil {
                
                fetchedImage = UIImage(data: data!)!
                
            } else {
                
                fetchedImage = UIImage(named: "compact-camera-xxl.png")
                
            }
            completion(image: fetchedImage)
        })
    }
    
    func postImgToImageschack(img: UIImage, completion: (imageschackUrl: String) -> ()) {

    let urlStr = "https://post.imageshack.us/upload_api.php"
    let url = NSURL(string: urlStr)!
    let imgData = UIImageJPEGRepresentation(img, 0.2)!
    let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
    let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!

        Alamofire.upload(.POST, url, multipartFormData: { splitData in
                
                splitData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jpg")
                splitData.appendBodyPart(data: keyData, name: "key")
                splitData.appendBodyPart(data: keyJSON, name: "format")
                
            }, encodingCompletion: { encodingResult in
                
                switch encodingResult {
                    
                case .Success(let successRequest, _, _):
                    successRequest.responseJSON(completionHandler: { endResponse in
                        
                        if let info = endResponse.result.value as? Dictionary<String, AnyObject> {
                            
                            if let links = info["links"] as? Dictionary<String, AnyObject> {
                                
                                if let url = links["image_link"] as? String {
                                    
                                    LoggedInVC.imageCache.setObject(img, forKey: url)
                                    completion(imageschackUrl: url)
                                }
                            }
                        }
                    })
                case .Failure(let errorType):
                    print("\(errorType)")
                }
        })
    }
    
    func convertTimeStamp(timestamp: Int) -> String {
        
        let timeInMilliseconds = Double(timestamp)
        let timeInSeconds = timeInMilliseconds / 1000.0
        
        let shortDateFormatter = NSDateFormatter()
        shortDateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        let date = NSDate(timeIntervalSince1970: timeInSeconds)
        
        print("Printing current Date")
        print(date)
        
        let currentDateNS = NSDate()
    
        let todayDateFormatter = NSDateFormatter()
        todayDateFormatter.dateFormat = "HH:mm"
        
        let dateStringFormatter = NSDateFormatter()
        dateStringFormatter.dateFormat = "EEE, dd MMMM yyyy @ HH:mm"
        
        
        let newdate = shortDateFormatter.stringFromDate(date)
        
        let currentDateInUnix = currentDateNS.timeIntervalSinceReferenceDate
        let latestdayInUnix = date.timeIntervalSinceReferenceDate
        
        let diff = currentDateInUnix - latestdayInUnix
        
        let diffinhours = diff/3600
        
     
        
        var dateToPrint = "N/A"
        
        if diffinhours < 24.0 {
        
            dateToPrint = "today @ \(todayDateFormatter.stringFromDate(date))"
        
        } else if diffinhours > 24.0 && diffinhours < 48.0 {
            
            dateToPrint = "yesterday @ \(todayDateFormatter.stringFromDate(date))"
        
        } else {
            
            dateToPrint = "\(dateStringFormatter.stringFromDate(date))"
        }
        
        return dateToPrint
        
    }
}