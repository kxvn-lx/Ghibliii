//
//  CloudKitEngine.swift
//  
//
//  Created by Kevin Laminto on 3/8/20.
//

import Foundation
import CloudKit

public class CloudKitEngine {
    
    public enum CloudKitEngineError: Error {
        case recordFailure
        case recordIDFailure
    }
    private let database = CKContainer.default().privateCloudDatabase
    public static let shared = CloudKitEngine()
    private init() { }
    
    // MARK: - Class methods
    /// Save the film to CloudKit
    public func save(film: Film, completion: @escaping (Result<CKRecord, Error>) -> Swift.Void) {
        let filmRecord = film.toRecord()
        
        database.save(filmRecord) { (record, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let record = record else {
                    completion(.failure(CloudKitEngineError.recordFailure))
                    return
                }
                
                completion(.success(record))
                return
            }
        }
    }
    
    /// Remove the film from CloudKit
    /// - Parameters:
    ///   - id: The ID of the film
    public func remove(filmWithRecord record: CKRecord?, completion: @escaping (Result<Bool, Error>) -> Swift.Void) {
        if let recordID = record?.recordID {
            database.delete(withRecordID: recordID) { (recordID, error) in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if record != nil {
                    completion(.success(true))
                } else {
                    completion(.failure(CloudKitEngineError.recordFailure))
                }
                
                return
            }
        }

    }
    
    /// Fetch watched films from CloudKit
    public func fetch(completion: @escaping (Result<[Film], Error>) -> Swift.Void) {
        let query = CKQuery(recordType: Film.RecordType, predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { (records, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                if let records = records {
                    let fetchedFilms = records.map({ Film(withRecord: $0) })
                    completion(.success(fetchedFilms))
                }
            }

        }
    }
}
