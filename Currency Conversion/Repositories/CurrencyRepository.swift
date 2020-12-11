//
//  RatesRepositry.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//
import Foundation

protocol ICurrencyRepository {
    func fetchAndSaveRates(completion: @escaping (Error?)->Void)
    func fetchAndSaveCurrencies(completion: @escaping (Error?)->Void)
    
    func getCurrencies() -> [DTOCurrency]
    func getExchangeRates(forCurrency sourceCurrency: DTOCurrency, amount: Decimal) -> [DTOExchange]
}

class CurrencyRepository: ICurrencyRepository {
    
    let networkHandler: INetworkHandler
    let databaseHandler: IDatabaseHandler
    
    init(networkHandler: INetworkHandler, databaseHandler: IDatabaseHandler) {
        self.networkHandler = networkHandler
        self.databaseHandler = databaseHandler
    }
    
    func fetchAndSaveRates(completion: @escaping (Error?)->Void) {
        networkHandler.get(fromUrl: "http://api.currencylayer.com/live?access_key=8ebf2c76df33eab5ad3186141d38dd16") { (daoRate: DAORate?, error: Error?) in
            if let error = error {
                completion(error)
            }
            else if let daoRate = daoRate {
                if daoRate.success ?? false {
                    
                    self.databaseHandler.saveCurrencyRates(dictionary: daoRate.quotes ?? [:])
                    completion(nil)
                }
                else {
                    completion(AppError(message: error?.localizedDescription ?? ""))
                }
            }
            else {
                
                completion(AppError(message: "An unknown error occured. Please try again."))
            }
        }
    }
    
    func fetchAndSaveCurrencies(completion: @escaping (Error?)->Void) {
        networkHandler.get(fromUrl: "http://api.currencylayer.com/list?access_key=8ebf2c76df33eab5ad3186141d38dd16") { (daoRate: DAOCurrency?, error: Error?) in
            if let error = error {
                completion(error)
            }
            else if let daoCurrency = daoRate {
                if daoCurrency.success ?? false {
                    
                    self.databaseHandler.saveCurrencies(dictionary: daoCurrency.currencies ?? [:])
                    completion(nil)
                }
                else {
                    completion(AppError(message: error?.localizedDescription ?? ""))
                }
            }
            else {
                
                completion(AppError(message: "An unknown error occured. Please try again."))
            }
        }
    }
    
    func getCurrencies() -> [DTOCurrency] {
        let daoCurrencyList = self.databaseHandler.getCurrencies()
        
        var dtoCurrencyList = [DTOCurrency]()
        for daoCurrency in daoCurrencyList {
            let dto = DTOCurrency(name: daoCurrency.name ?? "", shortCode: daoCurrency.code ?? "")
            dtoCurrencyList.append(dto)
        }
        
        return dtoCurrencyList
    }
    
    func getExchangeRates(forCurrency sourceCurrency: DTOCurrency, amount: Decimal) -> [DTOExchange] {
        let usdExchangeRates = self.databaseHandler.getRates()
        let allCurrencyList = self.getCurrencies()
        
        var exchangeRateList = [DTOExchange]()
        let key = "USD" + "\(sourceCurrency.shortCode)"
        if let usdToCurrencyRate = usdExchangeRates.first(where: { $0.currency == key }) {
            let usdConversionRate = usdToCurrencyRate.rate!
            
            for usdExchangeRate in usdExchangeRates {
                let exchange = DTOExchange()
                let currencyCode = usdExchangeRate.currency?.substring(from: 3) ?? ""
                let usdRate = usdExchangeRate.rate!
                var exchangeRate = usdRate.dividing(by: usdConversionRate)
                exchangeRate = exchangeRate.multiplying(by: amount as NSDecimalNumber)
                
                exchange.sourceCurrencyName = sourceCurrency.name
                exchange.sourceCurrencyCode = sourceCurrency.shortCode
                exchange.destinationCurrencyName = allCurrencyList.first(where: { $0.shortCode == currencyCode })?.name ?? ""
                exchange.destinationCurrencyCode = currencyCode
                exchange.exchangeRate = exchangeRate as Decimal
                exchangeRateList.append(exchange)
            }
        }
        
        return exchangeRateList
    }
    
}
