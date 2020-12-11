//
//  DAORate.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import Foundation

struct DAORate: Codable {
    var success: Bool?
    var error: DAOError?
    var quotes: [String: Decimal]?
  
}
