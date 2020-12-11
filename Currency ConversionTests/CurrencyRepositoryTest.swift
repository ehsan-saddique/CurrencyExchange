//
//  CurrencyRepositoryTest.swift
//  Currency ConversionTests
//
//  Created by Muhammad Ehsan on 10/12/2020.
//

import XCTest
@testable import Exchange

class CurrencyRepositoryTest: XCTestCase {

//    var currencyRepository: ICurrencyRepository!
    
    override func setUpWithError() throws {
//        let mockNetworkHandler = MockNetworkHandler()
//        let mockDatabaseHandler = MockDatabaseHandler()
//        currencyRepository = CurrencyRepository(networkHandler: mockNetworkHandler, databaseHandler: mockDatabaseHandler)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCurrenciesCount() throws {
//        let currencies = currencyRepository.getCurrencies()
//
//        XCTAssert(currencies.count == 1, "Currency count should have been 2.")
    }

}

class MockDatabaseHandler: XCTestCase, IDatabaseHandler {
    func saveCurrencyRates(dictionary: [String : Decimal]) {
        //--
    }

    func saveCurrencies(dictionary: [String : String]) {
        //--
    }

    func getCurrencies() -> [Currency] {
        let currency1 = Currency()
        currency1.code = "JPY"
        currency1.name = "Japanese Yen"

        let currency2 = Currency()
        currency2.code = "PKR"
        currency2.name = "Pakistani Rupee"

        return [currency1, currency2]
    }

    func getRates() -> [Rate] {
        let rate1 = Rate()
        rate1.currency = "USDJPY"
        rate1.rate = 2

        let rate2 = Rate()
        rate2.currency = "USDPKR"
        rate2.rate = 4

        return [rate1, rate2]
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
