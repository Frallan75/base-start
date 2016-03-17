//
//  MaterialButton.swift
//  base-start
//
//  Created by Francisco Claret on 12/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit

class MaterialButton: UIButton {

    override func awakeFromNib() {
        
        layer.cornerRadius = 2.0
        layer.shadowColor = SHADOW_COLOR.CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        
    }

}
