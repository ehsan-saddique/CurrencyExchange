//
//  CurrencyListViewModel.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import Foundation

protocol CurrencyListViewModelDelegate: class {
    func onCurrencyListUpdated()
    func didFailToFetchCurrencies(reason: String)
}

class CurrencyListViewModel {
    private weak var delegate: CurrencyListViewModelDelegate?
    private let currencyRepository: ICurrencyRepository
    
    private (set) var currencies = [DTOCurrency]()
    
    init(delegate: CurrencyListViewModelDelegate?, currencyRepository: ICurrencyRepository) {
        self.delegate = delegate
        self.currencyRepository = currencyRepository
    }
    
    public func getAllCurrencies() {
        let allCurrencies = self.currencyRepository.getCurrencies()
        if allCurrencies.isEmpty {
            currencyRepository.fetchAndSaveCurrencies { (error) in
                if let error = error {
                    self.delegate?.didFailToFetchCurrencies(reason: error.localizedDescription)
                }
                else {
                    self.getSortedCurrencies()
                }
            }
        }
        else {
            getSortedCurrencies()
        }
    }
    
    private func getSortedCurrencies() {
        var allCurrencies = self.currencyRepository.getCurrencies()
        allCurrencies.sort { (first, second) -> Bool in
            return first.shortCode < second.shortCode
        }
        self.currencies.removeAll()
        self.currencies.append(contentsOf: allCurrencies)
        
        self.delegate?.onCurrencyListUpdated()
    }
    
    public func searchCurrencies(searchText: String) {
        let searchText = searchText.lowercased()
        let allCurrencies = currencyRepository.getCurrencies()
        
        let filteredCurrencies = allCurrencies.filter { (currency) -> Bool in
            
            return currency.shortCode.lowercased().contains(searchText)
                || currency.name.lowercased().contains(searchText)
        }
        
        self.currencies.removeAll()
        self.currencies.append(contentsOf: filteredCurrencies)
        
        delegate?.onCurrencyListUpdated()
    }
    
}
