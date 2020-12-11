//
//  MainViewModel.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import Foundation

protocol MainViewModelDelegate: class {
    func didUpdateExchangeRates()
    func didFailToConvertCurrency(reason: String)
    func didFetchExchangeRates()
    func didFailToFetchRates(reason: String)
}

class MainViewModel {
    private weak var delegate: MainViewModelDelegate?
    private let currencyRepository: ICurrencyRepository
    private (set) var exchangeRates = [DTOExchange]()
    
    public var selectedCurrency: DTOCurrency?
    public var selectedAmount: String?
    
    init(delegate: MainViewModelDelegate?, currencyRepository: ICurrencyRepository) {
        self.delegate = delegate
        self.currencyRepository = currencyRepository
    }
    
    public func getLiveRates() {
        currencyRepository.fetchAndSaveRates { (error) in
            if let error = error {
                self.delegate?.didFailToFetchRates(reason: error.localizedDescription)
            }
            else {
                self.delegate?.didFetchExchangeRates()
            }
        }
    }
    
    public func convertCurrency() {
        if selectedCurrency == nil || selectedAmount == nil || selectedAmount!.isEmpty {
            self.exchangeRates.removeAll()
            delegate?.didUpdateExchangeRates()
            return
        }
        
        if let amountDecimal = Decimal(string: selectedAmount!) {
            var exchangeRates = currencyRepository.getExchangeRates(forCurrency: selectedCurrency!, amount: amountDecimal)
            if exchangeRates.isEmpty {
                delegate?.didFailToConvertCurrency(reason: "No exchange rates found. Please check your internet connection and tap the refresh button to fetch latest rates.")
            }
            else {
                exchangeRates.sort { (first, second) -> Bool in
                    return first.destinationCurrencyCode < second.destinationCurrencyCode
                }
                self.exchangeRates.removeAll()
                self.exchangeRates.append(contentsOf: exchangeRates)
                delegate?.didUpdateExchangeRates()
            }
        }
    }
    
}
