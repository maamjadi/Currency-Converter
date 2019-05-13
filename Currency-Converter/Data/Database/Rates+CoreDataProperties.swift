//
//  Rates+CoreDataProperties.swift
//  
//
//  Created by Amin Amjadi on 2019. 05. 10..
//
//

import Foundation
import CoreData


extension Rate {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rate> {
        return NSFetchRequest<Rate>(entityName: "Rate")
    }

    @NSManaged public var currency: String
    @NSManaged public var value: Double
    @NSManaged public var date: String
    @NSManaged public var refreshDate: NSDate?

}
