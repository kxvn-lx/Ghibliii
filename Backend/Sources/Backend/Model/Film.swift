//
//  File.swift
//  
//
//  Created by Kevin Laminto on 26/7/20.
//

import Foundation

public struct Film: Codable, Hashable {
    public let id, title, filmDescription: String
    public let image: String
    public let director, producer, releaseDate, rtScore: String
    public let imdbLink: String
    public let imdbScore: String

    enum CodingKeys: String, CodingKey {
        case id, title
        case filmDescription = "description"
        case image, director, producer
        case releaseDate = "release_date"
        case rtScore = "rt_score"
        case imdbLink = "imdb_link"
        case imdbScore = "imdb_score"
    }
    
    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    public static func == (lhs: Film, rhs: Film) -> Bool {
      lhs.id == rhs.id
    }
}
