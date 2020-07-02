//
//  Idea.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/29.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation
import CloudKit

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
    
    func getRecordID() -> CKRecord.ID {
        let recordID = CKRecord.ID(recordName: uuid)
        return recordID
    }
    
    func convertToCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKConstant.RecordType.Ideas, recordID: getRecordID())
        record.setValue(title, forKey: CKConstant.Field.title)
        return record
    }
    
    func mergeWithCKRecord(_ record: CKRecord) -> CKRecord {
        record.setValue(title, forKey: CKConstant.Field.title)
        return record
    }
    
}
