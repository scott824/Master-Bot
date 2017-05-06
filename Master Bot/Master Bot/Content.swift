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

class ContentInfo {
    var name: String
    var type: ViewType
    
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

enum ViewType: Int32 {
    case content = 0
    case UIView = 1
    case UIImageView = 2
    case UILabel = 3
    case UIButton = 4
    case UIWebView = 5
    
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
        //self.layer.borderWidth = 1
        //self.layer.borderColor = UIColor.gray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        //super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func resetCell() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
        _subviews = [:]
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
            resetCell()
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
            (view as! UIView).backgroundColor = UIColor.white
            (view as! UIView).layer.cornerRadius = 10
            (view as! UIView).layer.borderColor = UIColor.gray.cgColor
            (view as! UIView).layer.borderWidth = 1
        case .UILabel:
            NSLog("make label")
            view = UILabel()
            (view as! UILabel).text = contentInfo.text
            //(view as! UILabel).font = UIFont.systemFont(ofSize: 50, weight: UIFontWeightUltraLight)
            (view as! UILabel).font = contentInfo.font
            (view as! UILabel).sizeToFit()
            //(view as! UILabel).adjustsFontSizeToFitWidth = true
        case .UIImageView:
            NSLog("make image view")
            view = UIImageView()
            (view as! UIImageView).sizeToFit()
            (view as! UIImageView).image = contentInfo.image
            (view as! UIImageView).contentMode = UIViewContentMode.scaleAspectFit
        default:
            view = 0
            break
        }
        
        //(view as! UIView).layer.borderColor = UIColor.gray.cgColor
        //(view as! UIView).layer.borderWidth = 1
        
        return view
    }
    
    // TODO: SuggestionBarView.swift 와 중복된 코드!! 정리 필요
    // make NSLayoutConstraint in short code
    func makeConstraint(_ item: Any, _ itemAttribute: NSLayoutAttribute, _ toItem: Any? = nil, _ toItemAttribute: NSLayoutAttribute = .notAnAttribute, mutiplier: Double = 1.0, constant: Double = 0.0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: itemAttribute, relatedBy: .equal, toItem: toItem, attribute: toItemAttribute, multiplier: CGFloat(mutiplier), constant: CGFloat(constant))
    }
}
