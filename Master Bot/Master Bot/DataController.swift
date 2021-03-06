//
//  DataController.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 5. 2..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DataController {
    
    var appdelegate: AppDelegate! = nil
    var context: NSManagedObjectContext! = nil
    
    var contentIds: [ContentId] = []
    var contentConstraints: [ContentConstraint] = []
    var contentSubviews: [ContentSubview] = []
    
    init() {
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        self.appdelegate = appdelegate
        self.context = appdelegate.persistentContainer.viewContext
        
        // get initial data from core data
        do {
            try self.contentIds = self.context.fetch(ContentId.fetchRequest())
            try self.contentConstraints = self.context.fetch(ContentConstraint.fetchRequest())
            try self.contentSubviews = self.context.fetch(ContentSubview.fetchRequest())
            deleteAll()
            firstData()
        } catch {
            NSLog("fetch fail")
        }
    }
    
    // get ContentInfo Object by input string
    func getContentData(input: String) -> ContentInfo? {
        
        var id: Int32? = nil
        
        for contentId in self.contentIds {
            if let name = contentId.name {
                NSLog(name + " " + input)
                if name == input {
                    id = contentId.id
                }
            }
        }
        
        if id == nil {
            NSLog("there is no id")
            return nil
        }
        
        
        var subviews: [ContentSubview] = self.contentSubviews.filter() { subview in
            subview.id == id
        }
        
        
        var constraints: [Constraint?] = self.contentConstraints.filter({ constraint in
            constraint.id == id
        }).map({ constraint -> Constraint? in
            guard let item = constraint.item,
                  let toItem = constraint.toItem,
                  let itemAttr = NSLayoutAttribute(rawValue: Int(constraint.itemAttr)),
                  let toItemAttr = NSLayoutAttribute(rawValue: Int(constraint.toItemAttr)) else {
                return nil
            }
            let multiplier = constraint.multiplier
            let constant = constraint.constant
            
            return Constraint(item, itemAttr, toItem, toItemAttr, multiplier: multiplier, constant: constant)
        }).filter({ constraint in constraint != nil})
        
        
        var content = ContentInfo(name: "self", type: .content)
        
        func setSubviewsAndConstraints(content: ContentInfo) {
            for subview in subviews {
                guard let parentName = subview.parentName else {
                    continue
                }
                NSLog(parentName + " " + content.name)
                if parentName == content.name {
                    NSLog("have same name")
                    guard let name = subview.name,
                          let type = ViewType(rawValue: subview.type) else {
                        NSLog("Error")
                        continue
                    }
                    var image: UIImage?
                    if let imagePath = subview.imagePath {
                        image = UIImage(named: imagePath)
                    } else {
                        image = nil
                    }
                    let font = UIFont.systemFont(ofSize: CGFloat(subview.fontSize), weight: CGFloat(subview.fontWeight))
                    let subviewContentInfoForm = ContentInfo(name: name, type: type, text: subview.text, font: font, proportion: subview.proportion, image: image)
                    setSubviewsAndConstraints(content: subviewContentInfoForm)
                    if content.subviews != nil {
                        content.subviews? += [subviewContentInfoForm]
                    } else {
                        content.subviews = [subviewContentInfoForm]
                    }
                    NSLog("set subviews" + String(describing: content))
                }
            }
            for constraint in constraints {
                if let constraint = constraint {
                    if constraint.toItem == content.name {
                        if content.constraints != nil {
                            content.constraints? += [constraint]
                        } else {
                            content.constraints = [constraint]
                        }
                    }
                }
            }
        }
        
        setSubviewsAndConstraints(content: content)
        
        return content
    }
    
    func firstData() {
        
        // weather form
        save(id: 1, name: "날씨")
        
        save(id: 1, name: "rootview", parentName: "self", type: Int32(ViewType.UIView.rawValue))
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.centerX.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.centerX.rawValue), multiplier: 1.0, constant: 0.0)
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.centerY.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.centerY.rawValue), multiplier: 1.0, constant: 0.0)
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.height.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.height.rawValue), multiplier: 0.0, constant: 200.0)
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.width.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.width.rawValue), multiplier: 0.8, constant: 0.0)
        
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.top.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.top.rawValue), multiplier: 1.0, constant: 10.0)
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.bottom.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.bottom.rawValue), multiplier: 1.0, constant: -10.0)
        
        save(id: 1, name: "imageview", parentName: "rootview", type: Int32(ViewType.UIImageView.rawValue), imagePath: "weather")
        save(id: 1, item: "imageview", itemAttr: Int32(NSLayoutAttribute.right.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.centerX.rawValue), multiplier: 1.0, constant: -20.0)
        save(id: 1, item: "imageview", itemAttr: Int32(NSLayoutAttribute.top.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.top.rawValue), multiplier: 1.0, constant: 20.0)
        save(id: 1, item: "imageview", itemAttr: Int32(NSLayoutAttribute.height.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.height.rawValue), multiplier: 0.0, constant: 100.0)
        save(id: 1, item: "imageview", itemAttr: Int32(NSLayoutAttribute.width.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.width.rawValue), multiplier: 0.0, constant: 100.0)
        
        save(id: 1, name: "currenttemperaturelabel", parentName: "rootview", type: Int32(ViewType.UILabel.rawValue), text: "weather", fontSize: 50, fontWeight: Double(UIFontWeightUltraLight))
        save(id: 1, item: "currenttemperaturelabel", itemAttr: Int32(NSLayoutAttribute.top.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.top.rawValue), multiplier: 1.0, constant: 20.0)
        save(id: 1, item: "currenttemperaturelabel", itemAttr: Int32(NSLayoutAttribute.left.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.centerX.rawValue), multiplier: 1.0, constant: 20.0)
        
        save(id: 1, name: "weathernamelabel", parentName: "rootview", type: Int32(ViewType.UILabel.rawValue), text: "weather",  fontSize: 40, fontWeight: Double(UIFontWeightUltraLight))
        save(id: 1, item: "weathernamelabel", itemAttr: Int32(NSLayoutAttribute.top.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.top.rawValue), multiplier: 1.0, constant: 75.0)
        save(id: 1, item: "weathernamelabel", itemAttr: Int32(NSLayoutAttribute.left.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.centerX.rawValue), multiplier: 1.0, constant: 20.0)
        
        save(id: 1, name: "horizontalline", parentName: "rootview", type: Int32(ViewType.UIView.rawValue))
        save(id: 1, item: "horizontalline", itemAttr: Int32(NSLayoutAttribute.height.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.height.rawValue), multiplier: 0.0, constant: 1.0)
        save(id: 1, item: "horizontalline", itemAttr: Int32(NSLayoutAttribute.width.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.width.rawValue), multiplier: 0.8, constant: 0.0)
        save(id: 1, item: "horizontalline", itemAttr: Int32(NSLayoutAttribute.centerX.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.centerX.rawValue), multiplier: 1.0, constant: 0.0)
        save(id: 1, item: "horizontalline", itemAttr: Int32(NSLayoutAttribute.centerY.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.top.rawValue), multiplier: 1.0, constant: 150.0)
        
        save(id: 1, name: "detailbutton", parentName: "rootview", type: Int32(ViewType.UIButton.rawValue), text: "자세히", fontSize: 25, fontWeight: Double(UIFontWeightThin))
        save(id: 1, item: "detailbutton", itemAttr: Int32(NSLayoutAttribute.centerX.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.centerX.rawValue), multiplier: 1.0, constant: 0.0)
        save(id: 1, item: "detailbutton", itemAttr: Int32(NSLayoutAttribute.top.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.top.rawValue), multiplier: 1.0, constant: 155.0)
        
        
        
        // send message form
        save(id: 0, name: "sendMessage")
        
        save(id: 0, name: "rootview", parentName: "self", type: Int32(ViewType.UIView.rawValue))
        save(id: 0, item: "rootview", itemAttr: Int32(NSLayoutAttribute.right.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.right.rawValue), multiplier: 1.0, constant: -10.0)
        save(id: 0, item: "rootview", itemAttr: Int32(NSLayoutAttribute.centerY.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.centerY.rawValue), multiplier: 1.0, constant: 0.0)
        
        save(id: 0, name: "talklabel", parentName: "rootview", type: Int32(ViewType.UILabel.rawValue), text: "talk", fontSize: 25, fontWeight: Double(UIFontWeightThin))
        save(id: 0, item: "talklabel", itemAttr: Int32(NSLayoutAttribute.right.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.right.rawValue), multiplier: 1.0, constant: -5.0)
        save(id: 0, item: "talklabel", itemAttr: Int32(NSLayoutAttribute.left.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.left.rawValue), multiplier: 1.0, constant: 0.0)
        save(id: 0, item: "talklabel", itemAttr: Int32(NSLayoutAttribute.top.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.top.rawValue), multiplier: 1.0, constant: 0.0)
        save(id: 0, item: "talklabel", itemAttr: Int32(NSLayoutAttribute.bottom.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.bottom.rawValue), multiplier: 1.0, constant: 0.0)
        save(id: 0, item: "talklabel", itemAttr: Int32(NSLayoutAttribute.centerY.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.centerY.rawValue), multiplier: 1.0, constant: 0.0)
        
    }
    
    // save content id
    func save(id: Int, name: String) {
        NSLog("save " + String(id) + name)
        
        guard let context = self.appdelegate?.persistentContainer.viewContext else {
            return
        }
        
        let contentid = ContentId(context: context)
        contentid.name = name
        contentid.id = Int32(id)
        
        self.contentIds += [contentid]
        appdelegate?.saveContext()
    }
    
    
    /**
     save content subview
     
     - parameters:
        - id: id of content form
        - name: view name
        - parentName: parent view name
        - type: UI's type
        - text: for lebel, button
        - fontSize: for label
        - fontWeight: for label
        - proportion: for progress, slider
        - imagePath: for image view
     
    */
    func save(id: Int, name: String, parentName: String, type: Int32, text: String? = nil, fontSize: Double? = nil, fontWeight: Double? = nil, proportion: Double? = nil, imagePath: String? = nil) {
        guard let context = self.appdelegate?.persistentContainer.viewContext else {
            return
        }
        
        let contentsubview = ContentSubview(context: context)
        contentsubview.id = Int32(id)
        contentsubview.name = name
        contentsubview.parentName = parentName
        contentsubview.type = type
        contentsubview.text = text
        if let fontSize = fontSize, let fontWeight = fontWeight {
            contentsubview.fontSize = fontSize
            contentsubview.fontWeight = fontWeight
        }
        if let proportion = proportion {
            contentsubview.proportion = proportion
        }
        contentsubview.imagePath = imagePath
        
        self.contentSubviews += [contentsubview]
        appdelegate?.saveContext()
    }
    
   
    /**
     save content constraint
     
     - parameters:
        - id: id of content form
        - item
        - itemAttr
        - toItem
        - toItemAttr
        - multiplier
        - constant
    */
    func save(id: Int, item: String, itemAttr: Int32, toItem: String, toItemAttr: Int32, multiplier: Double, constant: Double) {
        guard let context = self.appdelegate?.persistentContainer.viewContext else {
            return
        }
        
        let contentconstraint = ContentConstraint(context: context)
        contentconstraint.id = Int32(id)
        contentconstraint.item = item
        contentconstraint.itemAttr = itemAttr
        contentconstraint.toItem = toItem
        contentconstraint.toItemAttr = toItemAttr
        contentconstraint.multiplier = multiplier
        contentconstraint.constant = constant
        
        self.contentConstraints += [contentconstraint]
        appdelegate?.saveContext()
    }
    
    
    // delete all the data from core data
    func deleteAll() {
        
        guard let context = self.appdelegate?.persistentContainer.viewContext else {
            return
        }
        
        for id in self.contentIds {
            context.delete(id)
        }
        for subview in self.contentSubviews {
            context.delete(subview)
        }
        for constraint in self.contentConstraints {
            context.delete(constraint)
        }
        
        appdelegate?.saveContext()
    }
}
