//
//  API.swift
//  
//
//  Created by Kevin Laminto on 26/7/20.
//

import Foundation

public class API {
    public static let shared = API()
    
    private init() { }
    
    /// Retrieve the data from the given endpoint
    /// - Parameters:
    ///   - type: The type of the data that will be retrieved
    ///   - endpoint: The endpoint
    ///   - completion: Completion block when the data is recevied
    /// Load specified data for use
    public func getData<T: Decodable>(type: T.Type, fromEndpoint endpoint: Endpoint, completion: @escaping ([T]?) -> Void) {
        if let path = Bundle.main.path(forResource: endpoint.rawValue, ofType: "json") {
            do {
                let rawData = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let decodedData = try JSONDecoder().decode([T].self, from: rawData)
                completion(decodedData)
                
            } catch let error {
                print("parse error: \(error.localizedDescription)")
            }
        } else {
            fatalError("Invalid filename/path")
        }
    }
}
