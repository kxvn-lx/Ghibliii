//
//  File.swift
//  
//
//  Created by Kevin Laminto on 26/7/20.
//

import Foundation
import CloudKit

public struct Film: Codable, Hashable {
    private enum RecordKeys: String {
        case id, title, filmDescription, image, director, producer, releaseDate, rtScore, imdbLink, imdbScore
    }
    public static let RecordType = "Film"
    
    public let id, filmDescription: String
    public var title: String
    public let image: String
    public let director, producer, releaseDate, rtScore: String
    public let imdbLink: String
    public let imdbScore: String
    
    public var record: CKRecord?
    public var hasWatched = false
    
    enum CodingKeys: String, CodingKey {
        case id, title
        case filmDescription = "description"
        case image, director, producer
        case releaseDate = "release_date"
        case rtScore = "rt_score"
        case imdbLink = "imdb_link"
        case imdbScore = "imdb_score"
    }
    
    public init(withRecord record: CKRecord) {
        self.id = record[RecordKeys.id.rawValue] as? String ?? ""
        self.title = record[RecordKeys.title.rawValue] as? String ?? ""
        self.filmDescription = record[RecordKeys.filmDescription.rawValue] as? String ?? ""
        self.image = record[RecordKeys.image.rawValue] as? String ?? ""
        self.director = record[RecordKeys.director.rawValue] as? String ?? ""
        self.producer = record[RecordKeys.producer.rawValue] as? String ?? ""
        self.releaseDate = record[RecordKeys.releaseDate.rawValue] as? String ?? ""
        self.rtScore = record[RecordKeys.rtScore.rawValue] as? String ?? ""
        self.imdbLink = record[RecordKeys.imdbLink.rawValue] as? String ?? ""
        self.imdbScore = record[RecordKeys.imdbScore.rawValue] as? String ?? ""
        self.record = record
    }
    
    public func toRecord() -> CKRecord {
        let record = self.record ?? CKRecord(recordType: Self.RecordType)
        record[RecordKeys.id.rawValue] = id
        record[RecordKeys.title.rawValue] = title
        record[RecordKeys.filmDescription.rawValue] = filmDescription
        record[RecordKeys.image.rawValue] = image
        record[RecordKeys.director.rawValue] = director
        record[RecordKeys.producer.rawValue] = producer
        record[RecordKeys.releaseDate.rawValue] = releaseDate
        record[RecordKeys.rtScore.rawValue] = rtScore
        record[RecordKeys.imdbLink.rawValue] = imdbLink
        record[RecordKeys.imdbScore.rawValue] = imdbScore
        
        return record
    }
}

extension Film {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
