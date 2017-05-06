//
//  ContentSubview+CoreDataProperties.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 5. 5..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import Foundation
import CoreData


extension ContentSubview {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContentSubview> {
        return NSFetchRequest<ContentSubview>(entityName: "ContentSubview")
    }

    @NSManaged public var id: Int32
    @NSManaged public var imagePath: String?
    @NSManaged public var name: String?
    @NSManaged public var parentName: String?
    @NSManaged public var proportion: Double
    @NSManaged public var text: String?
    @NSManaged public var type: Int32
    @NSManaged public var fontSize: Double
    @NSManaged public var fontWeight: Double

}
