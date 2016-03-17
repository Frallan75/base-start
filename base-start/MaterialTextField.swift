//
//  MaterialTextField.swift
//  base-start
//
//  Created by Francisco Claret on 12/03/16.
//  Copyright © 2016 Francisco Claret. All rights reserved.
//

import UIKit

class MaterialTextField: UITextField {

    override func awakeFromNib() {
        layer.cornerRadius = 2.0
        layer.borderColor = BORDER_COLOR.CGColor
        layer.borderWidth = 1.0
    }
    //For placeholder text (rect in rect)
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectOffset(bounds, 10, 0)
    }
    //When editing (textrect in textrect)
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectOffset(bounds, 10, 0)
    }

}
