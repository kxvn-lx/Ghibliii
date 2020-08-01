//
//  people.swift
//  
//
//  Created by Kevin Laminto on 26/7/20.
//

import Foundation

public struct People: Codable, Hashable {
    public let id, name: String
    public let gender: Gender
    public let age, eyeColor, hairColor: String
    public let films: [String]
    public let species, url: String

    enum CodingKeys: String, CodingKey {
        case id, name, gender, age
        case eyeColor = "eye_color"
        case hairColor = "hair_color"
        case films, species, url
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    public static func == (lhs: People, rhs: People) -> Bool {
      lhs.id == rhs.id
    }
}

public enum Gender: String, Codable {
    case female = "Female"
    case male = "Male"
    case na = "NA"
}
