//
//  ContentId+CoreDataProperties.swift
//  Master Bot
//
//  Created by Sang Chul Lee on 2017. 5. 3..
//  Copyright © 2017년 SC_production. All rights reserved.
//

import Foundation
import CoreData


extension ContentId {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContentId> {
        return NSFetchRequest<ContentId>(entityName: "ContentId")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?

}
