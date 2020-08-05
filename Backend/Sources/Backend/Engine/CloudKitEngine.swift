//
//  CloudKitEngine.swift
//  
//
//  Created by Kevin Laminto on 3/8/20.
//

import Foundation
import CloudKit

public class CloudKitEngine {
    
    public enum CloudKitEngineError: String, Error {
        case cloudKitNotAuthenticated = "Could not authenticate iCloud. Please make sure you have an iCloud account signed in."
        case networkFailure = "Your internet seems to not be working properly right now. Perhaps try again?"
        case generalError = "Something's not right. Please try again."
    }
    private let database = CKContainer.default().privateCloudDatabase
    public static let shared = CloudKitEngine()
    private init() { }
    
    // MARK: - Class methods
    /// Save the film to CloudKit
    public func save(film: Film, completion: @escaping (Result<CKRecord, CloudKitEngineError>) -> Swift.Void) {
        let filmRecord = film.toRecord()
        
        database.save(filmRecord) { (record, error) in
            DispatchQueue.main.async {
                if let error = error as? CKError {
                    switch error.code {
                    case .notAuthenticated: completion(.failure(CloudKitEngineError.cloudKitNotAuthenticated))
                    case .networkFailure, .networkUnavailable: completion(.failure(CloudKitEngineError.networkFailure))
                    default: completion(.failure(CloudKitEngineError.generalError))
                    }
                    return
                }
                
                guard let record = record else {
                    completion(.failure(CloudKitEngineError.generalError))
                    return
                }
                
                completion(.success(record))
                return
            }
        }
    }
    
    /// Remove the film from CloudKit
    public func remove(filmWithRecord record: CKRecord?, completion: @escaping (Result<Bool, CloudKitEngineError>) -> Swift.Void) {
        if let recordID = record?.recordID {
            database.delete(withRecordID: recordID) { (_, error) in
                if let error = error as? CKError {
                    switch error.code {
                    case .notAuthenticated: completion(.failure(CloudKitEngineError.cloudKitNotAuthenticated))
                    case .networkFailure, .networkUnavailable: completion(.failure(CloudKitEngineError.networkFailure))
                    default: completion(.failure(CloudKitEngineError.generalError))
                    }
                    return
                }
                
                if record != nil {
                    completion(.success(true))
                } else {
                    completion(.failure(CloudKitEngineError.generalError))
                }
                
                return
            }
        }
        
    }
    
    /// Fetch watched films from CloudKit
    ///
    /// Use this method to fetch data from CloudKit. If you expect a new record to be fetched along,
    /// Specify the record in its parameter.
    public func fetch(withNewRecord recordToCheck: CKRecord? = nil, completion: @escaping (Result<[Film], CloudKitEngineError>) -> Swift.Void) {
        let query = CKQuery(recordType: Film.RecordType, predicate: NSPredicate(value: true))
        database.perform(query, inZoneWith: nil) { (fetchedRecords, error) in
            DispatchQueue.main.async {
                if let error = error as? CKError {
                    switch error.code {
                    case .notAuthenticated: completion(.failure(CloudKitEngineError.cloudKitNotAuthenticated))
                    case .networkFailure, .networkUnavailable: completion(.failure(CloudKitEngineError.networkFailure))
                    default: completion(.failure(CloudKitEngineError.generalError))
                    }
                    return
                }
                
                // Check for the record that might  be missing
                if let recordToCheck = recordToCheck {
                    if let fetchedRecords = fetchedRecords {
                        let newResults = fetchedRecords.filter({  $0.recordID == recordToCheck.recordID })
                        
                        // Only execute if there is a new record that is missing from the query
                        if newResults.count == 0 {
                            let additionalOperation = CKFetchRecordsOperation(recordIDs: [recordToCheck.recordID])
                            
                            additionalOperation.fetchRecordsCompletionBlock = { recordsDict, error in
                                if let error = error as? CKError {
                                    switch error.code {
                                    case .notAuthenticated: completion(.failure(CloudKitEngineError.cloudKitNotAuthenticated))
                                    case .networkFailure, .networkUnavailable: completion(.failure(CloudKitEngineError.networkFailure))
                                    default: completion(.failure(CloudKitEngineError.generalError))
                                    }
                                    return
                                }
                                
                                if let recordsDict = recordsDict {
                                    let additionalRecords = recordsDict.map({ $0.1 })
                                    
                                    let stichedRecords = Array(Set(additionalRecords + fetchedRecords))
                                    let fetchedFilms = stichedRecords.map { Film(withRecord: $0) }
                                    completion(.success(fetchedFilms))
                                    return
                                }
                            }
                            self.database.add(additionalOperation)
                        }
                    }
                }
                
                // If everything fails, that means no new record is found.
                // Proceed to fetching normally.
                if let fetchedRecords = fetchedRecords {
                    let fetchedFilms = fetchedRecords.map({ Film(withRecord: $0) })
                    completion(.success(fetchedFilms))
                    return
                }
            }
        }
    }
}
