//
//  DataService.swift
//  base-start
//
//  Created by Francisco Claret on 12/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import FirebaseStorage
import FirebaseDatabase
import Alamofire

let BASE_URL = FIRDatabase.database().reference()

class DataService {
    
    static let ds = DataService()
    
    fileprivate var _REF_BASE = BASE_URL
    fileprivate var _REF_POSTS = BASE_URL.child("posts")
    fileprivate var _REF_USERS = BASE_URL.child("users")
    fileprivate var _REF_COMMENTS = BASE_URL.child("comments")
    fileprivate var _REF_IMGSTORAGE = FIRStorage.storage().reference(forURL: "gs://base-start.appspot.com/")
    
    var storedImgUrl: String!
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_COMMENTS: FIRDatabaseReference {
        return _REF_COMMENTS
    }
    
    var REF_IMGSTORAGE: FIRStorageReference {
        return _REF_IMGSTORAGE
    }
    
    var REF_USER_CURRENT: FIRDatabaseReference {
        
        let uid = UserDefaults.standard.value(forKey: KEY_UID) as! String
        let user = BASE_URL.child("users").child("\(uid)")
        return user
    }
    
    func createFirebaseUser(_ uid: String, user: Dictionary<String, String>) {
        REF_USERS.child("\(uid)").setValue(user)
    }
    
    func uploadImage(uid: String, imageName: String, image: UIImage, completeUpload: @escaping (_ imageUrl: NSString) -> Void) {
        
        let nsdataImg =  UIImagePNGRepresentation(image)
        let imgSize = CGFloat(nsdataImg!.count)
        let imageResizeFactor = MAX_IMG_SIZE/imgSize
        let imageToStore = UIImageJPEGRepresentation(image, imageResizeFactor)
        
        REF_IMGSTORAGE.child("\(uid)/\(imageName)").put(imageToStore!, metadata: nil, completion: { (metadata, error) in
            if let error = error as? NSError {
                print("There was an error saving your asset image, \(error.localizedDescription)")
            } else {
                let imgUrl = metadata!.downloadURL()!.absoluteString as NSString
                print("IMGAGAEGEGAE")
                print(imgUrl)
                completeUpload(imgUrl)
            }
        })
    }
    
    func getImgFromFBS(imageUrl: String, completion: @escaping (_ image: UIImage) -> Void) {
        
        let ref = REF_IMGSTORAGE.child(imageUrl)
        print(ref)
        ref.data(withMaxSize: 1000000) { (data, error) in
            
            if data != nil {
                
                let image = UIImage(data: data!)!
                completion(image)
                
            } else {
                print("ERRRRRRORORORORORORO GETTING IMAGE \(error?.localizedDescription)")
            }
        }
    }

//
//    
//    
//    
//    
//    
//    func fetchImageFromUrl(_ url: String, completion: @escaping (_ image: UIImage) -> ()) {
//        
//        Alamofire.request(url).validate(contentType: ["image/*"]).response(completionHandler: { (defaultDataResponse) in
//            let fetchedImage: UIImage!
//            if defaultDataResponse.error == nil {
//                fetchedImage = UIImage(data: defaultDataResponse.data!)!
//            } else {
//                fetchedImage = UIImage(named: "compact-camera-xxl.png")
//            }
//            completion(fetchedImage)
//        })
//    }
//    
//    func postImgToImageschack(_ img: UIImage, completion: @escaping (_ imageschackUrl: String) -> ()) {
//
//    let urlStr = "https:post.imageshack.us/upload_api.php"
//    let url = URL(string: urlStr)!
//    let imgData = UIImageJPEGRepresentation(img, 0.2)!
//    let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".data(using: String.Encoding.utf8)!
//    let keyJSON = "json".data(using: String.Encoding.utf8)!
//
//    Alamofire.upload(multipartFormData: { (splitData) in
//            
//            splitData.append(imgData, withName: "fileUpload", fileName: "image", mimeType: "image/jpg")
//            splitData.append(keyData, withName: "key")
//            splitData.append(keyJSON, withName: "format")
//            
//    }, to: url) { (encodingResult) in
//            
//            switch encodingResult {
//                
//            case .success(let successRequest, _, _):
//                successRequest.responseJSON(completionHandler: { endResponse in
//                    
//                    if let info = endResponse.result.value as? Dictionary<String, AnyObject> {
//                        
//                        if let links = info["links"] as? Dictionary<String, AnyObject> {
//                            
//                            if let url = links["image_link"] as? String {
//                                
//                                LoggedInVC.imageCache.setObject(img, forKey: url as AnyObject)
//                                completion(url)
//                            }
//                        }
//                    }
//                })
//            case .failure(let errorType):
//                print("\(errorType)")
//            }
//        }
//    }
    
    func convertTimeStamp(_ timestamp: Int) -> String {
        
        let timeInMilliseconds = Double(timestamp)
        let timeInSeconds = timeInMilliseconds / 1000.0
        
        let shortDateFormatter = DateFormatter()
        shortDateFormatter.dateStyle = DateFormatter.Style.short
        
        let date = Date(timeIntervalSince1970: timeInSeconds)
        
        print("Printing current Date")
        print(date)
        
        let currentDateNS = Date()
    
        let todayDateFormatter = DateFormatter()
        todayDateFormatter.dateFormat = "HH:mm"
        
        let dateStringFormatter = DateFormatter()
        dateStringFormatter.dateFormat = "EEE, dd MMMM yyyy @ HH:mm"
        
        
        _ = shortDateFormatter.string(from: date)
        
        let currentDateInUnix = currentDateNS.timeIntervalSinceReferenceDate
        let latestdayInUnix = date.timeIntervalSinceReferenceDate
        
        let diff = currentDateInUnix - latestdayInUnix
        
        let diffinhours = diff/3600
        
        var dateToPrint = "N/A"
        
        if diffinhours < 24.0 {
        
            dateToPrint = "today @ \(todayDateFormatter.string(from: date))"
        
        } else if diffinhours > 24.0 && diffinhours < 48.0 {
            
            dateToPrint = "yesterday @ \(todayDateFormatter.string(from: date))"
        
        } else {
            
            dateToPrint = "\(dateStringFormatter.string(from: date))"
        }
        
        return dateToPrint
        
    }
}
