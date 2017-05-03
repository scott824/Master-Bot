//
//  ContentConstraint+CoreDataProperties.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 5. 3..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import Foundation
import CoreData


extension ContentConstraint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContentConstraint> {
        return NSFetchRequest<ContentConstraint>(entityName: "ContentConstraint")
    }

    @NSManaged public var constant: Double
    @NSManaged public var id: Int32
    @NSManaged public var item: String?
    @NSManaged public var itemAttr: Int32
    @NSManaged public var multiplier: Double
    @NSManaged public var toItem: String?
    @NSManaged public var toItemAttr: Int32

}
