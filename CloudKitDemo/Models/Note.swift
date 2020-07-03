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
    var categoryId: String?
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
        if let reference = record.object(forKey: CKConstant.Field.category) as? CKRecord.Reference {
            self.categoryId = reference.recordID.recordName
        }
    }
    
    func getRecordID() -> CKRecord.ID {
        let zoneID = CloudKitManager.notesZone.zoneID
        let recordID = CKRecord.ID(recordName: uuid, zoneID: zoneID)
        return recordID
    }
    
    func convertToCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKConstant.RecordType.Notes, recordID: getRecordID())
        record.setValue(text, forKey: CKConstant.Field.text)
        
        if let categoryId = categoryId {
            let reference = getCategoryReference(categoryId: categoryId)
            record.setValue(reference, forKey: CKConstant.Field.category)
        }
        
        return record
    }
    
    func mergeWithCKRecord(_ record: CKRecord) -> CKRecord {
        record.setValue(text, forKey: CKConstant.Field.text)
        if let categoryId = categoryId {
            let reference = getCategoryReference(categoryId: categoryId)
            record.setValue(reference, forKey: CKConstant.Field.category)
        }
        return record
    }
    
    private func getCategoryReference(categoryId: String) -> CKRecord.Reference {
        let zoneID = CloudKitManager.notesZone.zoneID
        let categoryRecordID = CKRecord.ID(recordName: categoryId, zoneID: zoneID)
        let categoryReference = CKRecord.Reference(recordID: categoryRecordID, action: .deleteSelf)
        return categoryReference
    }
    
}