//
//  Currency_ConverterTests.swift
//  Currency-ConverterTests
//
//  Created by Amin Amjadi on 10/11/18.
//  Copyright © 2018 Amin Amjadi. All rights reserved.
//

import XCTest
@testable import Currency_Converter

class Currency_ConverterTests: XCTestCase {
    
    func testGetCurrencies() {
        let exp = expectation(description: "getting the list of all the available currencies")
        var curr = [String]()
        RateHandler.shared.getCurrencies { (_, data) in
            curr = data
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        XCTAssertFalse(curr.isEmpty)
    }
    
    func testConvertForADate() {
        let exp = expectation(description: "getting the converted value based on the random date's rates")
        var value: Double = 0
        RateHandler.shared.convert(for: "2012-11-08", amount: 1, firstCurrency: "EUR", secondCurrency: "USD") { (_, _, data) in
            value = data
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        XCTAssertGreaterThan(value, 0)
    }
    
    func testConvertToday() {
        let exp = expectation(description: "getting the converted value based on the today's rates")
        var value: Double = 0
        RateHandler.shared.convert(amount: 1, firstCurrency: "EUR", secondCurrency: "USD") { (_, _, data) in
            value = data
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 5)
        
        XCTAssertGreaterThan(value, 0)
    }
    
    //test case for whether we are getting the data for each last seven days or not
    func testConvertionForLastSevenDays() {
        let exp = expectation(description: "getting convertion rates for last seven days completes")
        var data = [(key: String, value: Double)]()
        RateHandler.shared.convertionForLastSevenDays { (_, _, retrievedData) in
            data = retrievedData
            exp.fulfill()
        }
        
        waitForExpectations(timeout: 10)
        
        XCTAssertEqual(data.count, 7)
    }
    
    
}
