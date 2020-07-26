//
//  Endpoint.swift
//  
//
//  Created by Kevin Laminto on 26/7/20.
//

import Foundation

public enum Endpoint {
    case film(id: String? = nil)
    case people(id: String? = nil)
    
    func path() -> String {
        switch self {
        case let .film(id): return id != nil ? "films\(id!)" : "films"
        case let .people(id): return id != nil ? "people\(id!)" : "people"
        }
    }
    
}
