//
//  Content.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 4. 30..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import UIKit

////////////////////////////////////////////////////////////////////////////////
//
//  Content structure
//
////////////////////////////////////////////////////////////////////////////////

struct ContentInfo {
    var name: String
    var type: ViewType
    
    var subviews: [ContentInfo]?
    var constraints: [Constraint]?
    
    // configure of view
    var text: String?
    var proportion: Double?
    var image: UIImage?
    
    init(name: String, type: ViewType) {
        self.name = name
        self.type = type
    }
    init(name: String, type: ViewType, text: String) {
        self.init(name: name, type: type)
        self.text = text
    }
    init(name: String, type: ViewType, image: UIImage) {
        self.init(name: name, type: type)
        self.image = image
    }
}

enum ViewType {
    case content
    case UIView
    case UIImageView
    case UILabel
    case UIButton
    case UIWebView
}

struct Constraint {
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


class Content: UITableViewCell {
    
    var _subviews: [String:Any] = [:]

    // Initialization code
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // border for debug
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.gray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setContent(contentInfo: ContentInfo, parent: UIView? = nil) {
        NSLog("Set content: " + contentInfo.name)
        
        // add views in _subviews
        if let parent = parent {
            _subviews[contentInfo.name] = getViewObject(contentInfo)
            let child: UIView = _subviews[contentInfo.name] as! UIView
            parent.addSubview(child)
            child.translatesAutoresizingMaskIntoConstraints = false
        } else {
            _subviews["self"] = self
        }
        
        // add subviews in _subviews
        if let subviews = contentInfo.subviews {
            for subview in subviews {
                setContent(contentInfo: subview, parent: (_subviews[contentInfo.name] as! UIView))
            }
        }
        
        // add constraints
        if let constraintsInfo = contentInfo.constraints {
            var constraints: [NSLayoutConstraint] = []
            for constraint in constraintsInfo {
                NSLog("\(constraint.item) \(constraint.itemAttr) \(constraint.toItem) \(constraint.toItemAttr)")
                if let item = _subviews[constraint.item], let toItem = _subviews[constraint.toItem] {
                    constraints.append(makeConstraint(item, constraint.itemAttr, toItem, constraint.toItemAttr, mutiplier: constraint.multiplier, constant: constraint.constant))
                }
            }
            (_subviews[contentInfo.name] as! UIView).addConstraints(constraints)
        }
    }
    
    func getViewObject(_ contentInfo: ContentInfo) -> Any {
        
        let view: Any!
        
        switch contentInfo.type {
        case .UIView:
            view = UIView()
        case .UILabel:
            view = UILabel()
            (view as! UILabel).text = contentInfo.text
        case .UIImageView:
            view = UIImageView()
            (view as! UIImageView).image = contentInfo.image
            (view as! UIImageView).contentMode = UIViewContentMode.scaleAspectFit
        default:
            return 0
        }
        return view
    }
    
    func AddImageView(image: UIImage) {
        let imageView = UIImageView(image: image)
        let ratio = image.size.height / image.size.width
        
        self.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        let positionXConstraint = makeConstraint(imageView, .centerX, self, .centerX)
        let positionYConstraint = makeConstraint(imageView, .centerY, self, .centerY)
        let widthConstraint = makeConstraint(imageView, .width, self, .width)
        let heightConstraint = makeConstraint(imageView, .height, constant: Double(self.frame.width * ratio))
        let marginConstraint = makeConstraint(imageView, .top, self, .top)
        
        //let height = makeConstraint(self, .height, constant: Double(image.size.height))
        self.addConstraints([positionXConstraint, positionYConstraint, widthConstraint, heightConstraint, marginConstraint])
        imageView.sizeToFit()
        
        imageView.contentMode = .scaleAspectFit
        
        imageView.layer.borderColor = UIColor.gray.cgColor
        imageView.layer.borderWidth = 1
    }
    
    // TODO: SuggestionBarView.swift 와 중복된 코드!! 정리 필요
    // make NSLayoutConstraint in short code
    func makeConstraint(_ item: Any, _ itemAttribute: NSLayoutAttribute, _ toItem: Any? = nil, _ toItemAttribute: NSLayoutAttribute = .notAnAttribute, mutiplier: Double = 1.0, constant: Double = 0.0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: itemAttribute, relatedBy: .equal, toItem: toItem, attribute: toItemAttribute, multiplier: CGFloat(mutiplier), constant: CGFloat(constant))
    }
}
