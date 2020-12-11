//
//  MainViewModelTest.swift
//  ExchangeTests
//
//  Created by Muhammad Ehsan on 10/12/2020.
//

import XCTest
@testable import Exchange

class MainViewModelTest: XCTestCase, MainViewModelDelegate {

    var mainViewModel: MainViewModel!
    var mockCurrencyRepository: MockCurrencyRepository!
    var getLiveRatesExpectation: XCTestExpectation!
    var getLiveRatesErrorExpectation: XCTestExpectation!
    
    var convertCurrencyExpectation: XCTestExpectation!
    var convertCurrencyErrorExpectation: XCTestExpectation!
    
    override func setUpWithError() throws {
        mockCurrencyRepository = MockCurrencyRepository()
        mainViewModel = MainViewModel(delegate: self, currencyRepository: mockCurrencyRepository)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    //MARK: getLiveRates()
    
    func testGetLiveRates() {
        getLiveRatesExpectation = expectation(description: "getLiveRatesExpectation")
        mainViewModel.getLiveRates()
        wait(for: [getLiveRatesExpectation], timeout: 5)
    }
    
    func testGetLiveRatesError() {
        getLiveRatesErrorExpectation = expectation(description: "getLiveRatesErrorExpectation")
        let viewModel = MainViewModel(delegate: self, currencyRepository: MockErrorCurrencyRepository())
        viewModel.getLiveRates()
        wait(for: [getLiveRatesErrorExpectation], timeout: 5)
    }
    
    //MARK: convertCurrency()
    
    func testConvertCurrency() {
        convertCurrencyExpectation = expectation(description: "convertCurrencyExpectation")
        
        mainViewModel.selectedCurrency = DTOCurrency(name: "Japanese Yen", shortCode: "JPY")
        mainViewModel.selectedAmount = "1"
        mainViewModel.convertCurrency()
        
        wait(for: [convertCurrencyExpectation], timeout: 5)
    }
    
    func testConvertCurrencyWithNilSelectedCurrency() {
        mainViewModel.selectedCurrency = nil
        mainViewModel.convertCurrency()
        XCTAssert(mainViewModel.exchangeRates.isEmpty, "Exchange rate list should be empty if selected currency is nil.")
    }
    
    func testConvertCurrencyWithNilSelectedAmount() {
        mainViewModel.selectedCurrency = DTOCurrency(name: "Japanese Yen", shortCode: "JPY")
        mainViewModel.selectedAmount = nil
        mainViewModel.convertCurrency()
        XCTAssert(mainViewModel.exchangeRates.isEmpty, "Exchange rate list should be empty if selected amount is nil.")
    }
    
    func testConvertCurrencySorting() {
        let unsortedRates = mockCurrencyRepository.getExchangeRates(forCurrency: DTOCurrency(name: "", shortCode: ""), amount: 1)
        mainViewModel.selectedCurrency = DTOCurrency(name: "Japanese Yen", shortCode: "JPY")
        mainViewModel.selectedAmount = "1"
        mainViewModel.convertCurrency()
        
        let isSorted = mainViewModel.exchangeRates.elementsEqual(unsortedRates, by: { $0.destinationCurrencyCode == $1.destinationCurrencyCode })
        
        XCTAssert(!mainViewModel.exchangeRates.isEmpty, "Exchange rate list should not be empty.")
        XCTAssert(!isSorted, "Exchange rates array is not sorted based on currency code.")
        XCTAssert(mainViewModel.exchangeRates[0].exchangeRate.isEqual(to: 6))
        XCTAssert(mainViewModel.exchangeRates[2].exchangeRate.isEqual(to: 4))
    }
    
    func testConvertCurrencyError() {
        convertCurrencyErrorExpectation = expectation(description: "convertCurrencyErrorExpectation")
        
        let viewModel = MainViewModel(delegate: self, currencyRepository: MockErrorCurrencyRepository())
        viewModel.selectedCurrency = DTOCurrency(name: "Japanese Yen", shortCode: "JPY")
        viewModel.selectedAmount = "1"
        viewModel.convertCurrency()
        
        wait(for: [convertCurrencyErrorExpectation], timeout: 5)
    }
    
    //MARK: MainViewModelDelegate
    
    func didUpdateExchangeRates() {
        self.convertCurrencyExpectation?.fulfill()
    }
    
    func didFailToConvertCurrency(reason: String) {
        XCTAssert(reason == "No exchange rates found. Please check your internet connection and tap the refresh button to fetch latest rates.")
        self.convertCurrencyErrorExpectation.fulfill()
    }
    
    func didFetchExchangeRates() {
        self.getLiveRatesExpectation.fulfill()
    }
    
    func didFailToFetchRates(reason: String) {
        XCTAssert(reason == "Mock Error")
        self.getLiveRatesErrorExpectation.fulfill()
    }

}


//MARK: Mocking

class MockCurrencyRepository: ICurrencyRepository {
    func fetchAndSaveRates(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
    func fetchAndSaveCurrencies(completion: @escaping (Error?) -> Void) {
        completion(nil)
    }
    
    func getCurrencies() -> [DTOCurrency] {
        let currency1 = DTOCurrency(name: "Japanese Yen", shortCode: "JPY")
        let currency2 = DTOCurrency(name: "Pakistani Rupee", shortCode: "PKR")
        
        return [currency1, currency2]
    }
    
    func getExchangeRates(forCurrency sourceCurrency: DTOCurrency, amount: Decimal) -> [DTOExchange] {
        let exchange1 = DTOExchange()
        exchange1.destinationCurrencyCode = "JPY"
        exchange1.destinationCurrencyName = "Japanese Yen"
        exchange1.exchangeRate = 1
        
        let exchange2 = DTOExchange()
        exchange2.destinationCurrencyCode = "PKR"
        exchange2.destinationCurrencyName = "Pakistani Rupee"
        exchange2.exchangeRate = 4
        
        let exchange3 = DTOExchange()
        exchange3.destinationCurrencyCode = "GBP"
        exchange3.destinationCurrencyName = "British Pound Sterling"
        exchange3.exchangeRate = 6
        
        return [exchange1, exchange2, exchange3]
    }
    
}

class MockErrorCurrencyRepository: ICurrencyRepository {
    func fetchAndSaveRates(completion: @escaping (Error?) -> Void) {
        completion(AppError(message: "Mock Error"))
    }
    
    func fetchAndSaveCurrencies(completion: @escaping (Error?) -> Void) {
        completion(AppError(message: "Mock Error"))
    }
    
    func getCurrencies() -> [DTOCurrency] {
        return []
    }
    
    func getExchangeRates(forCurrency sourceCurrency: DTOCurrency, amount: Decimal) -> [DTOExchange] {
        return []
    }
    
    
}
