//
//  File.swift
//  
//
//  Created by Kevin Laminto on 3/8/20.
//

import Foundation
import CloudKit

public protocol CloudModel {
    static var RecordType: String { get }
    init(withRecord record: CKRecord)
    func toRecord() -> CKRecord
}
