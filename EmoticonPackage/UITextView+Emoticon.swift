//
//  UITextView+Emoticon.swift
//  EmoticonPackageDemo
//
//  Created by Kevin on 11/3/16.
//  Copyright © 2016 SeeLee. All rights reserved.
//

import UIKit

extension UITextView : EmoticonDelegate {

    func insertEmoticon(_ emoticon: Emoticon) {
                
        if emoticon.removeEmoticon {
            self.deleteBackward()
            return
        }
        
        if let emoji = emoticon.chs {
            
            if !emoji.isEmpty {
                
                self.replace(self.selectedTextRange!, withText: emoji)
                
            }
        }
        
    }
    
}
