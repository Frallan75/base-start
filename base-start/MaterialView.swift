//
//  MaterialView.swift
//  base-start
//
//  Created by Francisco Claret on 12/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit

class MaterialView: UIView {

    override func awakeFromNib() {
        
        layer.cornerRadius = 2.0
        layer.shadowColor = SHADOW_COLOR.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowRadius = 4.0
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)

    }
}
