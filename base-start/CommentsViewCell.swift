//
//  ComentsCellView.swift
//  base-start
//
//  Created by Francisco Claret on 17/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit

class CommentsViewCell: UITableViewCell {

    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var timestamp: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }
    
    override func draw(_ rect: CGRect) {
        
        profileImg.layer.cornerRadius = profileImg.frame.height / 2
        profileImg.clipsToBounds = true
        
    }

    func configureCommentsViewCell(_ comment: String, commenterId: String, commenterProfileImgUrl: String, username: String, timestamp: String) {
        
        self.usernameLbl.text = username
        self.commentLbl.text = comment
        self.timestamp.text = timestamp
        
        if let cachedProfileImg = IMG_CACHE.object(forKey: commenterProfileImgUrl as NSString) {
            
            self.profileImg.image = cachedProfileImg
            
        } else {
        
            DataService.ds.getImgFromFBS(imageUrl: commenterProfileImgUrl, completion: { (image) in
                
                self.profileImg.image = image
            })
        }
    }
}

