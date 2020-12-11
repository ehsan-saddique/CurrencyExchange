//
//  AppError.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import Foundation

struct AppError {
    let message: String

    init(message: String) {
        self.message = message
    }
}

extension AppError: LocalizedError {
    var errorDescription: String? { return message }
}
