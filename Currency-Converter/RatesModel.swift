//
//  RatesModel.swift
//  Currency-Converter
//
//  Created by Amin Amjadi on 10/13/18.
//  Copyright © 2018 Amin Amjadi. All rights reserved.
//

import Foundation

struct RatesModel: Decodable {
    var success: Bool
    var timestamp: Int
    var base: String
    var date: String
    var rates: [String: Double]
}
