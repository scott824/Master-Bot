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

enum ViewType: Int32 {
    case content = 0
    case UIView = 1
    case UIImageView = 2
    case UILabel = 3
    case UIButton = 4
    case UIWebView = 5
    case UIScrollView = 6
    
}

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

protocol ContentInContents {
    func reload(cell: Content)
    func index(cell: Content) -> Int
}

class Content: UITableViewCell {
    
    var _subviews: [String:Any] = [:]
    var contentInfos: [ContentInfo] = []
    var constraintInfos: [Constraint] = []
    var tableviewcontroller: ContentsController?

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
        contentInfos = []
        constraintInfos = []
    }
    
    func setContent(contentInfo: ContentInfo, parent: UIView? = nil) {
        NSLog("Set content: " + contentInfo.name)
        
        if contentInfo.removed {
            return
        }
        contentInfos += [contentInfo]
        
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
            self.constraintInfos += constraintsInfo
            var constraints: [NSLayoutConstraint] = []
            for constraint in constraintsInfo {
                if let item = _subviews[constraint.item], let toItem = _subviews[constraint.toItem] {
                    constraints.append(makeConstraint(item, constraint.itemAttr, toItem, constraint.toItemAttr, mutiplier: constraint.multiplier, constant: constraint.constant))
                }
            }
            (_subviews[contentInfo.name] as! UIView).addConstraints(constraints)
        }
        
        if parent == nil && contentInfo.name == "self" {
            setAction()
        }
    }
    
    func getViewObject(_ contentInfo: ContentInfo) -> Any {
        
        let view: Any!
        
        switch contentInfo.type {
        case .UIView:
            view = UIView()
            (view as! UIView).backgroundColor = UIColor.white
            if contentInfo.name == "rootview" || contentInfo.name == "horizontalline" {
                (view as! UIView).layer.cornerRadius = 10
                (view as! UIView).layer.borderColor = UIColor.gray.cgColor
                (view as! UIView).layer.borderWidth = 1
            }
        case .UIScrollView:
            view = UIScrollView()
            (view as! UIScrollView).backgroundColor = UIColor.white
            (view as! UIScrollView).contentSize = CGSize(width: (contentInfo.subviews?.count)!*70, height: 100)
        case .UILabel:
            NSLog("make label")
            view = UILabel()
            (view as! UILabel).text = contentInfo.text
            (view as! UILabel).font = contentInfo.font
            (view as! UILabel).textAlignment = NSTextAlignment.center
            (view as! UILabel).sizeToFit()
        case .UIImageView:
            NSLog("make image view")
            view = UIImageView()
            (view as! UIImageView).sizeToFit()
            (view as! UIImageView).image = contentInfo.image
            (view as! UIImageView).contentMode = UIViewContentMode.scaleAspectFit
        case .UIButton:
            view = UIButton()
            //(view as! UIButton).titleLabel?.text = contentInfo.text
            (view as! UIButton).titleLabel?.font = contentInfo.font
            (view as! UIButton).setTitle(contentInfo.text, for: .normal)
            (view as! UIButton).setTitleColor(UIColor(red: 0, green: 128.0/255, blue: 255.0/255, alpha: 1), for: .normal)
            (view as! UIButton).setTitleColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1), for: .focused)
            (view as! UIButton).sizeToFit()
        default:
            view = 0
            break
        }
        
        //(view as! UIView).layer.borderColor = UIColor.gray.cgColor
        //(view as! UIView).layer.borderWidth = 1
        
        return view
    }
    
    func setAction() {
        NSLog("set action")
        if let button = _subviews["detailbutton"] {
            (button as! UIButton).addTarget(self, action: #selector(buttonAction), for: UIControlEvents.touchUpInside)
        }
    }
    
    func buttonAction() {
        NSLog("button action")
        let index = tableviewcontroller?.index(cell: self)
        
        modify(constraint: Constraint("rootview", .height, "self", .height, multiplier: 0.0, constant: 300.0))
        
        remove(subviewName: "detailbutton")
        
        add(name: "3hoursweatherview", parentName: "rootview", type: .UIScrollView)
        add(constraint: Constraint("3hoursweatherview", NSLayoutAttribute.centerX, "rootview", NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
        add(constraint: Constraint("3hoursweatherview", NSLayoutAttribute.bottom, "rootview", NSLayoutAttribute.bottom, multiplier: 1.0, constant: -10.0))
        add(constraint: Constraint("3hoursweatherview", NSLayoutAttribute.width, "rootview", NSLayoutAttribute.width, multiplier: 0.9, constant: 0.0))
        add(constraint: Constraint("3hoursweatherview", NSLayoutAttribute.height, "rootview", NSLayoutAttribute.height, multiplier: 0.0, constant: 100.0))
        
        let requestcontroller = RequestController()
        requestcontroller.request(url: "http://lionbot.net/weather", callback: { (jsonDic: [String:String]) -> Void in
            NSLog("add 3 hour per weather")
            var hour: Int = 4
            for i in 0..<10 {
                hour += 3
                let code = "code" + String(hour) + "hour"
                NSLog(code)
                self.add(name: code + "view", parentName: "3hoursweatherview", type: .UIView)
                let width: Double = 70
                self.add(constraint: Constraint(code + "view", NSLayoutAttribute.left, "3hoursweatherview", NSLayoutAttribute.left, multiplier: 1.0, constant: width*Double(i)))
                self.add(constraint: Constraint(code + "view", NSLayoutAttribute.centerY, "3hoursweatherview", NSLayoutAttribute.centerY, multiplier: 1.0, constant: 0.0))
                self.add(constraint: Constraint(code + "view", NSLayoutAttribute.width, "3hoursweatherview", NSLayoutAttribute.width, multiplier: 0.0, constant: width))
                self.add(constraint: Constraint(code + "view", NSLayoutAttribute.height, "3hoursweatherview", NSLayoutAttribute.height, multiplier: 1.0, constant: 0.0))
                
                self.add(name: code + "label", parentName: code + "view", type: .UILabel, text: String(hour) + "h 후", fontSize: 15, fontWeight: UIFontWeightThin)
                self.add(constraint: Constraint(code + "label", NSLayoutAttribute.top, code + "view", NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0))
                self.add(constraint: Constraint(code + "label", NSLayoutAttribute.centerX, code + "view", NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
                self.add(constraint: Constraint(code + "label", NSLayoutAttribute.width, code + "view", NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0))
                
                self.add(name: code + "image", parentName: code + "view", type: .UIImageView, imagePath: jsonDic[code]!)
                self.add(constraint: Constraint(code + "image", NSLayoutAttribute.top, code + "view", NSLayoutAttribute.top, multiplier: 1.0, constant: 20.0))
                self.add(constraint: Constraint(code + "image", NSLayoutAttribute.centerX, code + "view", NSLayoutAttribute.centerX, multiplier: 1.0, constant: 0.0))
                self.add(constraint: Constraint(code + "image", NSLayoutAttribute.width, code + "view", NSLayoutAttribute.width, multiplier: 0.6, constant: 0.0))
                self.add(constraint: Constraint(code + "image", NSLayoutAttribute.height, code + "view", NSLayoutAttribute.width, multiplier: 0.6, constant: 0.0))
                
                let temp = "temp" + String(hour) + "hour"
                self.add(name: temp + "label", parentName: code + "view", type: .UILabel, text: jsonDic[temp]!.components(separatedBy: ".")[0] + "˚", fontSize: 15, fontWeight: UIFontWeightThin)
                self.add(constraint: Constraint(temp + "label", NSLayoutAttribute.bottom, code + "view", NSLayoutAttribute.bottom, multiplier: 1.0, constant: -10.0))
                self.add(constraint: Constraint(temp + "label", NSLayoutAttribute.centerX, code + "view", NSLayoutAttribute.centerX, multiplier: 1.0, constant: 4.0))
                self.add(constraint: Constraint(temp + "label", NSLayoutAttribute.width, code + "view", NSLayoutAttribute.width, multiplier: 1.0, constant: 0.0))
            }
            DispatchQueue.main.async {
                self.tableviewcontroller?.reload(cell: self)
            }
        })
    }
    
    func modify(constraint: Constraint) {
        for i in self.constraintInfos {
            if i.item == constraint.item && i.itemAttr == constraint.itemAttr && i.toItem == constraint.toItem && i.toItemAttr == constraint.toItemAttr {
                NSLog("modify constraint")
                i.multiplier = constraint.multiplier
                i.constant = constraint.constant
                break
            }
        }
    }
    
    func add(constraint: Constraint) {
        for i in self.contentInfos {
            if i.name == constraint.toItem {
                if i.constraints != nil {
                    i.constraints! += [constraint]
                } else {
                    i.constraints = [constraint]
                }
                break
            }
        }
    }
    
    func add(name: String, parentName: String, type: ViewType, text: String? = nil, fontSize: Double? = nil, fontWeight: CGFloat? = nil, proportion: Double? = nil, imagePath: String? = nil) {
        var font: UIFont?
        var image: UIImage?
        
        if let fontSize = fontSize, let fontWeight = fontWeight {
            font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: fontWeight)
        }
        if let imagePath = imagePath {
            image = UIImage(named: imagePath)
        }
        
        for i in self.contentInfos {
            if i.name == parentName {
                let contentInfo = ContentInfo(name: name, type: type, text: text, font: font, proportion: proportion, image: image)
                self.contentInfos += [contentInfo]
                if i.subviews != nil {
                    i.subviews! += [contentInfo]
                } else {
                    i.subviews = [contentInfo]
                }
                break
            }
        }
    }
    
    func remove(subviewName: String) {
        for i in self.contentInfos {
            if i.name == subviewName {
                i.removed = true
                break
            }
        }
    }
    
    
    // TODO: SuggestionBarView.swift 와 중복된 코드!! 정리 필요
    // make NSLayoutConstraint in short code
    func makeConstraint(_ item: Any, _ itemAttribute: NSLayoutAttribute, _ toItem: Any? = nil, _ toItemAttribute: NSLayoutAttribute = .notAnAttribute, mutiplier: Double = 1.0, constant: Double = 0.0) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: item, attribute: itemAttribute, relatedBy: .equal, toItem: toItem, attribute: toItemAttribute, multiplier: CGFloat(mutiplier), constant: CGFloat(constant))
    }
}
