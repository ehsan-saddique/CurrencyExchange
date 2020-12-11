//
//  DatabaseHandler.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import Foundation
import CoreData

protocol IDatabaseHandler {
    func saveCurrencyRates(dictionary: [String: Decimal])
    func saveCurrencies(dictionary: [String: String])
    
    func getCurrencies() -> [Currency]
    func getRates() -> [Rate]
}

class DatabaseHandler: IDatabaseHandler {
    
    let coreDataHandler: CoreDataHandler
    
    init(coreDataHandler: CoreDataHandler) {
        self.coreDataHandler = coreDataHandler
    }
    
    func saveCurrencyRates(dictionary: [String : Decimal]) {
        let context = self.coreDataHandler.persistentContainer.viewContext
        for (key, value) in dictionary {
            let rate = Rate(context: context)
            rate.currency = key
            rate.rate = value as NSDecimalNumber
        }
        self.coreDataHandler.saveContext()
    }
    
    func saveCurrencies(dictionary: [String : String]) {
        let context = self.coreDataHandler.persistentContainer.viewContext
        for (key, value) in dictionary {
            let currency = Currency(context: context)
            currency.code = key
            currency.name = value
        }
        self.coreDataHandler.saveContext()
    }
    
    func getCurrencies() -> [Currency] {
        let context = self.coreDataHandler.persistentContainer.viewContext
        
        do {
            return try context.fetch(Currency.fetchRequest())
        } catch {
            print("Error fetching currency from CoreData")
            return []
        }
    }
    
    func getRates() -> [Rate] {
        let context = self.coreDataHandler.persistentContainer.viewContext
        
        do {
            return try context.fetch(Rate.fetchRequest())
        } catch {
            print("Error fetching rates from CoreData")
            return []
        }
    }
    
}
