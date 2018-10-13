//
//  RatesModel.swift
//  Currency-Converter
//
//  Created by Amin Amjadi on 10/13/18.
//  Copyright © 2018 Amin Amjadi. All rights reserved.
//

import Foundation

private struct GenericCodingKeys: CodingKey {
    var intValue: Int?
    var stringValue: String
    
    init?(intValue: Int) { self.intValue = intValue; self.stringValue = "\(intValue)" }
    init?(stringValue: String) { self.stringValue = stringValue }
    
    static func makeKey(name: String) -> GenericCodingKeys {
        return GenericCodingKeys(stringValue: name)!
    }
}

struct RatesModel: Decodable {
    var success: Bool
    var timestamp: Int
    var base: String
    var date: String
    var rates: [String: Float]
    
//    private enum CodingKeys: String, CodingKey {
//        case success
//        case timestamp
//        case base
//        case date
//        case rates
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        success = try container.decode(Bool.self, forKey: .success)
//        timestamp = try container.decode(Int.self, forKey: .timestamp)
//        base = try container.decode(String.self, forKey: .base)
//        date = try container.decode(String.self, forKey: .date)
//
//        rates = [String: Float]()
//        let subContainer = try container.nestedContainer(keyedBy: GenericCodingKeys.self, forKey: .rates)
//        for key in subContainer.allKeys {
//            rates[key.stringValue] = try subContainer.decode(Float.self, forKey: key)
//        }
//    }
}
