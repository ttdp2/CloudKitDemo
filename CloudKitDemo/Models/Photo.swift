//
//  Photo.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/1.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation
import CloudKit

struct Photo: Record {
    
    let uuid: String
    let createdAt: Date
    let updatedAt: Date
    
    let data: Data
}

extension Photo {
    
    init(data: Data) {
        self.uuid = UUID().uuidString
        self.createdAt = Date()
        self.updatedAt = Date()
        
        self.data = data
    }
    
    init(record: CKRecord) {
        self.uuid = record.recordID.recordName
        self.createdAt = record.creationDate!
        self.updatedAt = record.modificationDate!
        
        self.data = record.value(forKey: CKConstant.Field.data) as! Data
    }
    
    func getRecordID() -> CKRecord.ID {
        let recordID = CKRecord.ID(recordName: uuid)
        return recordID
    }
    
    func convertToCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKConstant.RecordType.Photos, recordID: getRecordID())
        record.setValue(data, forKey: CKConstant.Field.data)
        return record
    }
    
    func mergeWithCKRecord(_ record: CKRecord) -> CKRecord {
        record.setValue(data, forKey: CKConstant.Field.data)
        return record
    }
    
}
