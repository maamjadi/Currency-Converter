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
    
    private func getTodaysRates() {
        var theURL = "http://data.fixer.io/api/latest?access_key=\(apiKey)&base=EUR"
    }
    
    private func getlastSevenDaysRates() {
    
    }
    
    func convert(amount: Float, firstCurrency firstCurr: String, secondCurrency secCurr: String) -> Float {
        return (5*amount)
    }
}
