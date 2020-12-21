//
//  UILabelExtension.swift
//  radiofree
//
//  Created by Severin Kämpfer on 02.01.20.
//  Copyright © 2020 Severin Kämpfer. All rights reserved.
//
import Foundation
import UIKit
class TitleLabel: UILabel {
    override var text: String? {
        didSet {
            super.text = text?.uppercased()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        super.text = text?.uppercased()
    }
}
