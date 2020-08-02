//
//  DataPersistEngine.swift
//  
//
//  Created by Kevin Laminto on 27/7/20.
//

import Foundation

public struct DataPersistEngine {
    
    public var films = [Film]()
    
    private var filePath: URL?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private struct SavedData: Codable {
        let films: [Film]
    }
    
    public init() {
        do {
            filePath = try? FileManager.default.url(for: .documentDirectory,
                                                   in: .userDomainMask,
                                                   appropriateFor: nil,
                                                   
                                                   create: false).appendingPathComponent("SavedDatas")

            if let data = try? Data(contentsOf: filePath!) {
                decoder.dataDecodingStrategy = .base64
                let savedData = try? decoder.decode(SavedData.self, from: data)
                self.films = savedData?.films ?? []
            }
        }
    }
    
    /// Save the films locally
    public mutating func saveFilms(_ films: [Film]) {
        self.films = films
        save()
    }
    
    /// Do the saving
    private func save() {
        if let filePath = self.filePath {
            do {
                let savedData = SavedData(films: films)
                let data = try encoder.encode(savedData)
                try data.write(to: filePath, options: .atomicWrite)
            } catch let error {
                print("Error while saving datas: \(error.localizedDescription)")
            }
            encoder.dataEncodingStrategy = .base64
        }
    }
}
