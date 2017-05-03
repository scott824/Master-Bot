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
        NSLog("Start getContentData")
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
        
        NSLog("id : " + String(describing: id))
        
        var subviews: [ContentSubview] = self.contentSubviews.filter() { subview in
            subview.id == id
        }
        
        NSLog("subviews : " + String(describing: subviews))
        
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
        
        func setSubviewsAndConstraints(content: inout ContentInfo) {
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
                    var subviewContentInfoForm = ContentInfo(name: name, type: type, text: subview.text, proportion: subview.proportion, image: image)
                    setSubviewsAndConstraints(content: &subviewContentInfoForm)
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
        NSLog("setting before add subviews and constraints")
        setSubviewsAndConstraints(content: &content)
        NSLog(String(describing: content))
        return content
    }
    
    func firstData() {
        save(id: 1, name: "날씨")
        
        save(id: 1, name: "rootview", parentName: "self", type: Int32(ViewType.UIView.rawValue))
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.centerX.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.centerX.rawValue), multiplier: 1.0, constant: 0.0)
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.centerY.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.centerY.rawValue), multiplier: 1.0, constant: 0.0)
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.height.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.height.rawValue), multiplier: 0.0, constant: 200.0)
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.width.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.width.rawValue), multiplier: 1.0, constant: -20.0)
        
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.top.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.top.rawValue), multiplier: 1.0, constant: 10.0)
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.bottomMargin.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.bottomMargin.rawValue), multiplier: 1.0, constant: 10.0)
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.leading.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.leading.rawValue), multiplier: 1.0, constant: 10.0)
        save(id: 1, item: "rootview", itemAttr: Int32(NSLayoutAttribute.trailing.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.trailing.rawValue), multiplier: 1.0, constant: 10.0)
        
        save(id: 1, name: "imageview", parentName: "rootview", type: Int32(ViewType.UIImageView.rawValue), imagePath: "weather")
        save(id: 1, item: "imageview", itemAttr: Int32(NSLayoutAttribute.leading.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.leading.rawValue), multiplier: 1.0, constant: 20.0)
        save(id: 1, item: "imageview", itemAttr: Int32(NSLayoutAttribute.top.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.top.rawValue), multiplier: 1.0, constant: 20.0)
        save(id: 1, item: "imageview", itemAttr: Int32(NSLayoutAttribute.height.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.height.rawValue), multiplier: 0.0, constant: 100.0)
        save(id: 1, item: "imageview", itemAttr: Int32(NSLayoutAttribute.width.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.width.rawValue), multiplier: 0.0, constant: 100.0)
        
        save(id: 1, name: "wordlabel", parentName: "rootview", type: Int32(ViewType.UILabel.rawValue), text: "weather")
        save(id: 1, item: "wordlabel", itemAttr: Int32(NSLayoutAttribute.top.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.top.rawValue), multiplier: 1.0, constant: 10.0)
        save(id: 1, item: "wordlabel", itemAttr: Int32(NSLayoutAttribute.trailing.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.trailing.rawValue), multiplier: 1.0, constant: -30.0)
        save(id: 1, item: "wordlabel", itemAttr: Int32(NSLayoutAttribute.width.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.width.rawValue), multiplier: 0.0, constant: 100.0)
        save(id: 1, item: "wordlabel", itemAttr: Int32(NSLayoutAttribute.height.rawValue), toItem: "rootview", toItemAttr: Int32(NSLayoutAttribute.height.rawValue), multiplier: 0.0, constant: 30.0)
        
        
//        save(id: 1, name: "imageView", parentName: "self", type: Int32(ViewType.UIImageView.rawValue), imagePath: "todayweather")
//        save(id: 1, item: "imageView", itemAttr: Int32(NSLayoutAttribute.centerY.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.centerY.rawValue), multiplier: 1.0, constant: 0.0)
//        save(id: 1, item: "imageView", itemAttr: Int32(NSLayoutAttribute.centerX.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.centerX.rawValue), multiplier: 1.0, constant: 0.0)
//        save(id: 1, item: "imageView", itemAttr: Int32(NSLayoutAttribute.width.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.width.rawValue), multiplier: 1.0, constant: 0.0)
//        save(id: 1, item: "imageView", itemAttr: Int32(NSLayoutAttribute.height.rawValue), toItem: "self", toItemAttr: Int32(NSLayoutAttribute.height.rawValue), multiplier: 1.0, constant: 0.0)
        
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
    
    // save content subview
    func save(id: Int, name: String, parentName: String, type: Int32, text: String? = nil, proportion: Double? = nil, imagePath: String? = nil) {
        guard let context = self.appdelegate?.persistentContainer.viewContext else {
            return
        }
        
        let contentsubview = ContentSubview(context: context)
        contentsubview.id = Int32(id)
        contentsubview.name = name
        contentsubview.parentName = parentName
        contentsubview.type = type
        contentsubview.text = text
        if let proportion = proportion {
            contentsubview.proportion = proportion
        }
        contentsubview.imagePath = imagePath
        
        self.contentSubviews += [contentsubview]
        appdelegate?.saveContext()
    }
   
    // save content constraint
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
