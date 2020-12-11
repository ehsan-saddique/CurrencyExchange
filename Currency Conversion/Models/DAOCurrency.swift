//
//  DAOCurrency.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import Foundation

struct DAOCurrency: Codable {
    var success: Bool?
    var error: DAOError?
    var currencies: [String: String]?
  
}
