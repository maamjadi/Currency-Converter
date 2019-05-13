//
//  Rates+CoreDataClass.swift
//  
//
//  Created by Amin Amjadi on 2019. 05. 10..
//
//

import Foundation
import CoreData

@objc(Rate)
public class Rate: NSManagedObject {

    class func fetchRates(for date: String, context: NSManagedObjectContext) -> NSFetchedResultsController<Rate>? {
        return Rate.cd_fetchAll(withPredicate: NSPredicate(format: "date == %@", date),
                                sortedBy: [("date", .desc)],
                                delegate: nil,
                                faulting: false,
                                context: context)
    }

    class func getItem(by date: String, currency: String, context: NSManagedObjectContext) -> Rate? {
        let results: [Rate]? = Rate.cd_findAll(inContext: context,
                                               predicate: NSPredicate(format: "date == %@ && currency == %@", date, currency))
        return results?.first
    }

    class func getItems(for date: String, context: NSManagedObjectContext) -> [Rate]? {
        let results: [Rate]? = Rate.cd_findAll(inContext: context,
                                               predicate: NSPredicate(format: "date == %@", date))
        return results
    }

    class func addOrUpdateRates(from content: RateObjectDTO, context: NSManagedObjectContext) -> [Rate] {
        var rates = [Rate]()
        let contentDate = content.date
        content.rates.forEach { (key, value) in
            if let rate = Rate.getItem(by: contentDate,
                                       currency: key,
                                       context: context) ?? Rate.cd_new(inContext: context) {
                rate.currency = key
                rate.value = value
                rate.date = contentDate
                rate.refreshDate = Date() as NSDate
                rates.append(rate)
            }
        }
        return rates
    }
}
