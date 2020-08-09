//
//  Person.swift
//  
//
//  Created by Kevin Laminto on 7/8/20.
//

import Foundation

public struct People: Codable, Hashable {
    public let id, name: String
    public let gender: Gender
    public let age: String
    public let filmIDs: [String]
}

public enum Gender: String, Codable {
    case female = "Female"
    case male = "Male"
    case na = "NA"
}

extension People {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
