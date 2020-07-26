//
//  people.swift
//  
//
//  Created by Kevin Laminto on 26/7/20.
//

import Foundation

public struct People: Codable {
    let id, name: String
    let gender: Gender
    let age, eyeColor, hairColor: String
    let films: [String]
    let species, url: String

    enum CodingKeys: String, CodingKey {
        case id, name, gender, age
        case eyeColor = "eye_color"
        case hairColor = "hair_color"
        case films, species, url
    }
}

enum Gender: String, Codable {
    case female = "Female"
    case male = "Male"
    case na = "NA"
}
