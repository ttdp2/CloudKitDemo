//
//  Idea.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/29.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation
import CloudKit

protocol Record {
    var uuid: String { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
    
    init(record: CKRecord)
    func convertToCKRecord() -> CKRecord
    func mergeWithCKRecord(_ record: CKRecord) -> CKRecord
}

struct Idea: Record {
    let uuid: String
    let createdAt: Date
    let updatedAt: Date
    
    let title: String
}

extension Idea {
    
    init(title: String) {
        self.uuid = UUID().uuidString
        self.createdAt = Date()
        self.updatedAt = Date()
        
        self.title = title
    }
    
    init(record: CKRecord) {
        self.uuid = record.recordID.recordName
        self.createdAt = record.creationDate!
        self.updatedAt = record.modificationDate!
        self.title = record.object(forKey: CKConstant.Field.title) as! String
    }
    
    func convertToCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: uuid)
        let record = CKRecord(recordType: CKConstant.RecordType.Ideas, recordID: recordID)
        record.setValue(title, forKey: CKConstant.Field.title)
        return record
    }
    
    func mergeWithCKRecord(_ record: CKRecord) -> CKRecord {
        record.setValue(title, forKey: CKConstant.Field.title)
        return record
    }
    
}
