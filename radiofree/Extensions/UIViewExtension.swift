//
//  UIViewExtension.swift
//  radiofree
//
//  Created by Severin Kämpfer on 01.01.20.
//  Copyright © 2020 Severin Kämpfer. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func fadeIn(duration: TimeInterval = 1.00 , to: CGRect) {
        let before = self.isHidden
        UIView.animate(withDuration: duration, animations: {
            //Fades the view in.
            self.frame  = to
            if(before == true){
                self.isHidden = false
            }else{
                self.isHidden = true
            }
        })
        
        
    }
}
