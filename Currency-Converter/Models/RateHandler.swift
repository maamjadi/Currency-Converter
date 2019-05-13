//
//  RateHandler.swift
//  Currency-Converter
//
//  Created by Amin Amjadi on 10/12/18.
//  Copyright © 2018 Amin Amjadi. All rights reserved.
//

import UIKit
import CoreData

class RateHandler: NSObject {
    
    static let shared = RateHandler()
    
    //fixer.io api key for using the service
    private let apiKey = "6554d9e9aa28145210f3e85cfa0a5cdf"
    private var currentAmount: Double?
    private var currentFirstCurr: String?
    private var currentSecCurr: String?
    private static var mainContext: NSManagedObjectContext!

    override init() {
        let container = NSPersistentContainer.create(for: "Model")
        container.viewContext.automaticallyMergesChangesFromParent = true
        RateHandler.mainContext = container.viewContext
        super.init()
    }
    
    private func fetchRates(for date: String? = nil, completionHandler: @escaping (_ success:Bool, _ error: String?, _ data: [Rate]?) -> Void) {

        let date = date ?? getFormattedString(for: Date())

        //checking if we have fetch the todaysRates before, to just return it
        if let rates = Rate.getItems(for: date, context: RateHandler.mainContext), !rates.isEmpty {
            completionHandler(true, nil, rates)
        } else {
            let urlString = "http://data.fixer.io/api/\(date)?access_key=\(apiKey)&base=EUR"
            guard let url = URL(string: urlString) else {
                completionHandler(false, "couldn't convert String to URL", nil)
                return
            }
            
            URLSession.shared.dataTask(with: url) { (data, _, err) in
                //start the asynchronous task on main thread
                DispatchQueue.main.async {
                    if let err = err {
                        completionHandler(false, "Fail to get data from url:\(err)", nil)
                        return
                    }
                    
                    guard let data = data else {
                        completionHandler(false, nil, nil)
                        return
                    }
                    
                    do {
                        //decoding the json data
                        let decoder = JSONDecoder()
                        let rateObject = try decoder.decode(RateObjectDTO.self, from: data)
                        let rates = Rate.addOrUpdateRates(from: rateObject, context: RateHandler.mainContext)
                        RateHandler.mainContext.cd_saveToPersistentStore()
                        completionHandler(true, nil, rates)
                    } catch let jsonErr {
                        completionHandler(false, "Fail to decode:\(jsonErr)", nil)
                    }
                }
            }.resume()
        }
    }
    
    func convertionForLastSevenDays(completionHandler: @escaping (_ success:Bool, _ error: String?, _ data: [(key: String, value: Double)]) -> Void) {
        guard let amount = currentAmount, let firstCurr = currentFirstCurr, let secCurr = currentSecCurr else {
            completionHandler(false, "selected values couldn't be found", [])
            return
        }
        var dataDictionary = [String : Double]()
        let dates: [String] = getLastSevenDaysDates()
        let myGroup = DispatchGroup()
        //loop through the date strings to get their corresponding conversion rates
        dates.forEach { date in
            myGroup.enter()
            var dateValue: String? = date
            //check and if date is today, it won't send any date to get the latest which is more accurate
            if date == getFormattedString(for: Date()) {
                dateValue = nil
            }
            convert(for: dateValue, amount: amount, firstCurrency: firstCurr, secondCurrency: secCurr) { (_, _, convertedVal) in
                dataDictionary[date] = convertedVal
                myGroup.leave()
            }
        }
        
        //after the loop has been executed continue
        myGroup.notify(queue: .main) {
            if dataDictionary.count == 7 {
                //sort function returns an array of tuple values instead of the dictionary
                let dataTupleArray = dataDictionary.sorted(by: { $0.0 < $1.0 })
                completionHandler(true, nil, dataTupleArray)
            } else {
                completionHandler(false, "Couldn't convert for all the 7 days", [])
            }
        }
    }
    
    //convert the dates to the wanted string
    private func getFormattedString(for date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: date)
    }
    
    //getting the dates for last seven days
    private func getLastSevenDaysDates() -> [String] {
        var dates = [String]()
        let calendar = Calendar.current
        let today = Date()
        dates.append(getFormattedString(for: today))
        for ctr in 1...6 {
            if let date = calendar.date(byAdding: .day, value: -ctr, to: today) {
                dates.append(getFormattedString(for: date))
            }
        }
        return dates
    }
    
    func convert(for date: String? = nil,
                 amount: Double,
                 firstCurrency firstCurr: String,
                 secondCurrency secCurr: String,
                 completionHandler: @escaping (_ success: Bool, _ error: String?, _ data: Double) -> Void) {
        currentAmount = amount
        currentFirstCurr = firstCurr
        currentSecCurr = secCurr
        fetchRates(for: date) { (success, err, rates) in
            if let rates = rates, success {
                var firstRate: Double?
                var secondRate: Double?
                
                //looping through the rates to find the wanted ones
                rates.forEach { rate in
                    if rate.currency == firstCurr {
                        firstRate = rate.value
                    }
                    if rate.currency == secCurr {
                        secondRate = rate.value
                    }
                }
                guard let first = firstRate, let second = secondRate else {
                    completionHandler(false, "Choosen currency couldn't be found in data set", 0)
                    return
                }
                let rate = second / first
                let val = amount * rate
                completionHandler(true, nil, val)
            } else {
                //returns 0 as the converted value if it cannot get the rates
                completionHandler(false, err, 0)
            }
        }
    }
    
    //fetch the available currencies
    func getCurrencies(completionHandler: @escaping (_ success: Bool, _ data: [String]) -> Void) {
        fetchRates { (success, err, rates) in
            if let rates = rates, success {
                var data = [String]()
                rates.forEach { rate in
                    data.append(rate.currency)
                }
                //sorting the array in alphabetical order
                data = data.sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                completionHandler(true, data)
            } else {
                completionHandler(false, [])
            }
        }
    }
}
