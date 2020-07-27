//
//  API.swift
//  
//
//  Created by Kevin Laminto on 26/7/20.
//

import Foundation

public class API {
    public static let shared = API()
    private let BASE_URL = "https://ghibliapi.herokuapp.com"
    
    private let session = URLSession.shared
    
    private init() { }
    
    /// Retrieve the data from the given endpoint
    public func getData<T>(type: T.Type, fromEndpoint endpoint: Endpoint, completion: @escaping ([T]?) -> Void) {
        let url = makeURL(endpoint: endpoint)
        var datas: [T]?
        
        session.dataTask(with: url) { (data, _, error) in
            guard let data = data else { fatalError() }
            if error != nil { fatalError(error!.localizedDescription) }
            
            do {
                datas = try JSONDecoder().decode([Film].self, from: data) as? [T]
                completion(datas)
            } catch {
                print(error)
            }
        }.resume()
    }
    
    /// Convert the given endpoint into a valid URL
    private func makeURL(endpoint: Endpoint) -> URL {
        let url = URL(string: BASE_URL)!.appendingPathComponent(endpoint.path())
        let component = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        return component.url!
    }
    
}
