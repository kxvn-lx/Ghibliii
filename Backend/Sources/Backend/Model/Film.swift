//
//  File.swift
//  
//
//  Created by Kevin Laminto on 26/7/20.
//

import Foundation

public struct Film: Codable, Hashable {
    public let id, title, filmDescription, director: String
    public let producer, releaseDate, rtScore: String
    public let people, species, locations, vehicles: [String]
    public let url: String

    enum CodingKeys: String, CodingKey {
        case id, title
        case filmDescription = "description"
        case director, producer
        case releaseDate = "release_date"
        case rtScore = "rt_score"
        case people, species, locations, vehicles, url
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    public static func == (lhs: Film, rhs: Film) -> Bool {
      lhs.id == rhs.id
    }
}
