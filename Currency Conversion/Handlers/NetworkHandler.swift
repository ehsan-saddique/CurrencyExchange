//
//  NetworkHandler.swift
//  Currency Conversion
//
//  Created by Muhammad Ehsan on 09/12/2020.
//

import Foundation

protocol INetworkHandler: class {
    func get<T: Decodable>(fromUrl url: String, completion: @escaping (T?, Error?)->Void)
}

class NetworkHandler: INetworkHandler {
    private var configs: URLSessionConfiguration
    private var session: URLSession
    
    init() {
        configs = URLSessionConfiguration.default
        session = URLSession(configuration: configs)
    }
    
    public func get<T: Decodable>(fromUrl url: String, completion: @escaping (T?, Error?)->Void) {
        let request = URLRequest(url: URL(string: url)!)
        let task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(nil, error)
                }
                else if let data = data {
                    let dao = try? JSONDecoder().decode(T.self, from: data)
                    completion(dao, nil)
                }
                else {
                    completion(nil, nil)
                }
            }
        }
        
        task.resume()
    }
    
}
