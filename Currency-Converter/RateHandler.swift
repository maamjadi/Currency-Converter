//
//  RateHandler.swift
//  Currency-Converter
//
//  Created by Amin Amjadi on 10/12/18.
//  Copyright © 2018 Amin Amjadi. All rights reserved.
//

import Foundation

class RateHandler {
    
    static let shared = RateHandler()
    
    //fixer.io api key for using the service
    private let apiKey = "6554d9e9aa28145210f3e85cfa0a5cdf"
    //string to get latest currency rates for today
    private let todayStr: String = "latest"
    private var todaysRates: RatesModel?
    private var currentAmount: Float?
    private var currentFirstCurr: String?
    private var currentSecCurr: String?
    
    private func fetchRates(for theDate: String, completionHandler: @escaping (_ success:Bool, _ error: String?, _ data: RatesModel?) -> Void) {
        //checking if we have fetch the todaysRates before, to just return it
        if let rates = todaysRates, theDate == todayStr {
            completionHandler(true, nil, rates)
        } else {
            let urlString = "http://data.fixer.io/api/\(theDate)?access_key=\(apiKey)&base=EUR"
            guard let theURL = URL(string: urlString) else {
                completionHandler(false, "couldn't convert String to URL", nil)
                return
            }
            
            URLSession.shared.dataTask(with: theURL) { (data, _, err) in
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
                        let theRates = try decoder.decode(RatesModel.self, from: data)
                        //assigning the rates to todayRates if the date is today
                        if theDate == self.todayStr {
                            self.todaysRates = theRates
                        }
                        completionHandler(true, nil, theRates)
                    } catch let jsonErr {
                        completionHandler(false, "Fail to decode:\(jsonErr)", nil)
                    }
                }
            }.resume()
        }
    }
    
    func convertionForLastSevenDays(completionHandler: @escaping (_ success:Bool, _ error: String?, _ data: [(key: String, value: Float)]) -> Void) {
        guard let amount = currentAmount, let firstCurr = currentFirstCurr, let secCurr = currentSecCurr else {
            completionHandler(false, "selected values couldn't be found", [])
            return
        }
        var dataDictionary = [String : Float]()
        let dates: [String] = getLastSevenDaysDates()
        let myGroup = DispatchGroup()
        //loop through the date strings to get their corresponding conversion rates
        for theDate in dates {
            myGroup.enter()
            var date: String? = theDate
            //check and if theDate is today, it won't send any date to get the latest which is more accurate
            if theDate == getFormattedString(for: Date()) {
                date = nil
            }
            convert(for: date, amount: amount, firstCurrency: firstCurr, secondCurrency: secCurr) { (_, _, convertedVal) in
                dataDictionary[theDate] = convertedVal
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
        for i in 1...6 {
            if let theDate = calendar.date(byAdding: .day, value: -i, to: today) {
                dates.append(getFormattedString(for: theDate))
            }
        }
        return dates
    }
    
    func convert(for theDate: String? = nil, amount: Float, firstCurrency firstCurr: String, secondCurrency secCurr: String, completionHandler: @escaping (_ success: Bool, _ error: String?, _ data: Float) -> Void) {
        currentAmount = amount
        currentFirstCurr = firstCurr
        currentSecCurr = secCurr
        fetchRates(for: theDate ?? todayStr) { (success, err, rates) in
            if let rates = rates, success {
                var firstRate: Float?
                var secondRate: Float?
                
                //looping through the rates to find the wanted ones
                for (key, value) in rates.rates {
                    if key == firstCurr {
                        firstRate = value
                    }
                    if key == secCurr {
                        secondRate = value
                    }
                }
                guard let theFirst = firstRate, let theSecond = secondRate else {
                    completionHandler(false, "Choosen currency couldn't be found in data set", 0)
                    return
                }
                let theRate = theSecond / theFirst
                let val = self.roundToFiveDecimalPlaces(for: amount * theRate)
                completionHandler(true, nil, val)
            } else {
                //returns 0 as the converted value if it cannot get the rates
                completionHandler(false, err, 0)
            }
        }
    }
    
    private func roundToFiveDecimalPlaces(for theFLoat: Float) -> Float {
        let val = Float(round(100000*theFLoat)/100000)
        return val
    }
    
    //fetch the available currencies
    func getTheCurrencies(completionHandler: @escaping (_ success: Bool, _ data: [String]) -> Void) {
        fetchRates(for: todayStr) { (success, err, rates) in
            if let rates = rates, success {
                var theData = [String]()
                for theKey in rates.rates.keys {
                    theData.append(theKey)
                }
                //sorting the array in alphabetical order
                theData = theData.sorted {$0.localizedStandardCompare($1) == .orderedAscending}
                completionHandler(true, theData)
            } else {
                completionHandler(false, [])
            }
        }
    }
}
