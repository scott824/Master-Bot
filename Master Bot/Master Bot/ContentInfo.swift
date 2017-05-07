//
//  ContentInfo.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 5. 8..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import Foundation
import UIKit


/// *Content Information*
///
/// All the information for content are saved in `ContentInfo` instance

class ContentInfo {
    // general information
    var name: String
    var type: ViewType
    var removed: Bool = false
    
    var subviews: [ContentInfo]?
    var constraints: [Constraint]?
    var actions: [(() -> ())]?
    
    // configure of view
    var cornerRadius: CGFloat?
    var borderWidth: CGFloat?
    var borderColor: CGColor?
    
    var text: String?
    var font: UIFont?
    var proportion: Double?
    var image: UIImage?
    
    
    init(name: String, type: ViewType, text: String? = nil, font: UIFont? = nil, proportion: Double? = nil, image: UIImage? = nil) {
        self.name = name
        self.type = type
        self.text = text
        self.font = font
        self.proportion = proportion
        self.image = image
    }
}

/// UIView types
enum ViewType: Int32 {
    case content = 0    // cell
    case UIView = 1
    case UIImageView = 2
    case UILabel = 3
    case UIButton = 4
    case UIWebView = 5
    case UIScrollView = 6
    
}

/// information to make `NSConstraint`
class Constraint {
    var item: String
    var itemAttr: NSLayoutAttribute
    var toItem: String
    var toItemAttr: NSLayoutAttribute
    var multiplier: Double
    var constant: Double
    
    init(_ item: String, _ itemAttr: NSLayoutAttribute, _ toItem: String, _ toItemAttr:NSLayoutAttribute, multiplier: Double, constant: Double) {
        self.item = item
        self.itemAttr = itemAttr
        self.toItem = toItem
        self.toItemAttr = toItemAttr
        self.multiplier = multiplier
        self.constant = constant
    }
}
