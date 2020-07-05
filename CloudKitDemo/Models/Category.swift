//
//  Category.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/2.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation
import CloudKit

struct Category {
    let uuid: String
    let createdAt: Date
    let updatedAt: Date
    
    let name: String
}

extension Category: Record {
    
    init(name: String) {
        self.uuid = UUID().uuidString
        self.createdAt = Date()
        self.updatedAt = Date()
        
        self.name = name
    }
    
    init(record: CKRecord) {
        self.uuid = record.recordID.recordName
        self.createdAt = record.creationDate!
        self.updatedAt = record.modificationDate!
        self.name = record.object(forKey: CKConstant.Field.name) as! String
    }
    
    func getRecordID() -> CKRecord.ID {
        let zoneID = CloudKitManager.notesZone.zoneID
        let recordID = CKRecord.ID(recordName: uuid, zoneID: zoneID)
        return recordID
    }
    
    func convertToCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKConstant.RecordType.Categories, recordID: getRecordID())
        record.setValue(name, forKey: CKConstant.Field.name)
        return record
    }
    
    func mergeWithCKRecord(_ record: CKRecord) -> CKRecord {
        record.setValue(name, forKey: CKConstant.Field.name)
        return record
    }
    
}
