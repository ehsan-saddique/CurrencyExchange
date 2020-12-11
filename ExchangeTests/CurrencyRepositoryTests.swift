//
//  ExchangeTests.swift
//  ExchangeTests
//
//  Created by Muhammad Ehsan on 10/12/2020.
//

import XCTest
@testable import Exchange

class CurrencyRepositoryTests: XCTestCase {
    
    var currencyRepository: ICurrencyRepository!
    
    override func setUpWithError() throws {
        let mockNetworkHandler = MockNetworkHandler()
        let mockDatabaseHandler = MockDatabaseHandler()
        currencyRepository = CurrencyRepository(networkHandler: mockNetworkHandler, databaseHandler: mockDatabaseHandler)
    }
    
    override func tearDownWithError() throws {
        
    }
    
    func testGetCurrencies() throws {
        let currencies = currencyRepository.getCurrencies()
        
        XCTAssert(currencies.count == 2, "Unable to convert all DAOs to DTOs.")
        
        XCTAssert(currencies[0].shortCode == "JPY")
        XCTAssert(currencies[0].name == "Japanese Yen")
        XCTAssert(currencies[1].shortCode == "PKR")
        XCTAssert(currencies[1].name == "Pakistani Rupee")
    }
    
    func testGetExchangeRates() throws {
        let dtoCurrency = DTOCurrency(name: "Japanese Yen", shortCode: "JPY")
        let exchangeRates = currencyRepository.getExchangeRates(forCurrency: dtoCurrency, amount: 1)
        
        XCTAssert(exchangeRates.count == 3, "Unable to convert all DAOs to DTOs.")
        
        XCTAssert(exchangeRates[0].exchangeRate.isEqual(to: 1), "Invalid JPY to JPY exchange rate conversion.")
        XCTAssert(exchangeRates[1].exchangeRate.isEqual(to: 2), "Invalid JPY to PKR exchange rate conversion.")
        XCTAssert(exchangeRates[2].exchangeRate.isEqual(to: 4), "Invalid JPY to GBP exchange rate conversion.")
        
        XCTAssert(exchangeRates[1].destinationCurrencyCode == "PKR", "Unable to get currency code by trimming first 3 chars of exchange rate name.")
        XCTAssert(exchangeRates[1].destinationCurrencyName == "Pakistani Rupee", "Unable to get currency name from all currencies list.")
    }

}


//MARK: Mocking


class MockDatabaseHandler: XCTestCase, IDatabaseHandler {
    func saveCurrencyRates(dictionary: [String : Decimal]) {
        //--
    }

    func saveCurrencies(dictionary: [String : String]) {
        //--
    }

    func getCurrencies() -> [Currency] {
        let currency1 = StubCurrency(code: "JPY", name: "Japanese Yen")
        let currency2 = StubCurrency(code: "PKR", name: "Pakistani Rupee")

        return [currency1, currency2]
    }

    func getRates() -> [Rate] {
        let rate1 = StubRate(currency: "USDJPY", rate: 2)
        let rate2 = StubRate(currency: "USDPKR", rate: 4)
        let rate3 = StubRate(currency: "USDGBP", rate: 8)

        return [rate1, rate2, rate3]
    }

}

class MockNetworkHandler: XCTestCase, INetworkHandler {
    func get<T>(fromUrl url: String, completion: @escaping (T?, Error?) -> Void) where T : Decodable {
        var dict = [String: Any]()
        dict["success"] = true

        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: [])
        let dao = try? JSONDecoder().decode(T.self, from: jsonData)
        completion(dao, nil)
    }
}

class StubCurrency: Currency {
    var stubbedName = ""
    var stubbedCode = ""
    convenience init(code: String, name: String) {
        self.init()
        stubbedName = name
        stubbedCode = code
    }
    
    override var code: String? {
        get {
            return stubbedCode
        }
        set {}
    }
    
    override var name: String? {
        get {
            return stubbedName
        }
        set {}
    }
}

class StubRate: Rate {
    var stubbedCurrency = ""
    var stubbedRate = NSDecimalNumber()
    convenience init(currency: String, rate: NSDecimalNumber) {
        self.init()
        stubbedCurrency = currency
        stubbedRate = rate
    }
    
    override var currency: String? {
        get {
            return stubbedCurrency
        }
        set {}
    }
    
    override var rate: NSDecimalNumber? {
        get {
            return stubbedRate
        }
        set {}
    }
}
