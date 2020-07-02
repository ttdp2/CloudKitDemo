//
//  Note.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/2.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation
import CloudKit

struct Note: Record {
    let uuid: String
    let createdAt: Date
    let updatedAt: Date
    
    let text: String
}

extension Note {
    
    init(text: String) {
        self.uuid = UUID().uuidString
        self.createdAt = Date()
        self.updatedAt = Date()
        
        self.text = text
    }
    
    init(record: CKRecord) {
        self.uuid = record.recordID.recordName
        self.createdAt = record.creationDate!
        self.updatedAt = record.modificationDate!
        self.text = record.object(forKey: CKConstant.Field.text) as! String
    }
    
    func convertToCKRecord() -> CKRecord {
        let zoneID = CloudKitManager.notesZone.zoneID
        let recordID = CKRecord.ID(recordName: uuid, zoneID: zoneID)
        let record = CKRecord(recordType: CKConstant.RecordType.Notes, recordID: recordID)
        record.setValue(text, forKey: CKConstant.Field.text)
        return record
    }
    
    func mergeWithCKRecord(_ record: CKRecord) -> CKRecord {
        record.setValue(text, forKey: CKConstant.Field.text)
        return record
    }
    
}
