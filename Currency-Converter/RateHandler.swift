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
    
    private let apiKey = "6554d9e9aa28145210f3e85cfa0a5cdf"
    private var todaysRates: RatesModel?
    
    private func fetchTodaysRates(completionHandler: @escaping (_ success:Bool, _ error: String?, _ data: RatesModel?) -> Void) {
        if let rates = todaysRates {
            completionHandler(true, nil, rates)
        }
        let urlString = "http://data.fixer.io/api/latest?access_key=\(apiKey)&base=EUR"
        guard let theURL = URL(string: urlString) else {
            completionHandler(false, "couldn't convert String to URL", nil)
            return
        }
        
        URLSession.shared.dataTask(with: theURL) { (data, _, err) in
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
                    self.todaysRates = try decoder.decode(RatesModel.self, from: data)
                    completionHandler(true, nil, self.todaysRates!)
                } catch let jsonErr {
                    completionHandler(false, "Fail to decode:\(jsonErr)", nil)
                }
            }
            }.resume()
        
    }
    
    private func getlastSevenDaysRates() {
        
    }
    
    func convert(amount: Float, firstCurrency firstCurr: String, secondCurrency secCurr: String, completionHandler: @escaping (_ success: Bool, _ error: String?, _ data: Float) -> Void) {
        fetchTodaysRates { (success, err, rates) in
            if let rates = rates, success {
                completionHandler(true, nil, amount * 5)
            } else {
                //returns 0 as the converted value if it cannot get the rates
                completionHandler(false, err, 0)
            }
        }
    }
    
    func getTheCurrencies(completionHandler: @escaping (_ success: Bool, _ data: [String]) -> Void) {
        fetchTodaysRates { (success, err, rates) in
            if let rates = rates, success {
                var theData = [String]()
                for theKey in rates.rates.keys {
                    theData.append(theKey)
                }
                completionHandler(true, theData)
            } else {
                completionHandler(false, [])
            }
        }
    }
}
