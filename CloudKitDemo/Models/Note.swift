//
//  Note.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/2.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation
import CloudKit

struct Note {
    let uuid: String
    let createdAt: Date
    let updatedAt: Date
    
    let text: String
    var categoryId: String?
    var image: Data?
}

extension Note: Record {
    
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
        
        if let asset = record.object(forKey: CKConstant.Field.image) as? CKAsset {
            if let imageURL = asset.fileURL {
                self.image = try? Data(contentsOf: imageURL)
            }
        }
    }
    
    func getRecordID() -> CKRecord.ID {
        let zoneID = CloudKitManager.notesZone.zoneID
        let recordID = CKRecord.ID(recordName: uuid, zoneID: zoneID)
        return recordID
    }
    
    func convertToCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKConstant.RecordType.Notes, recordID: getRecordID())
        return mergeWithCKRecord(record)
    }
    
    func mergeWithCKRecord(_ record: CKRecord) -> CKRecord {
        record.setValue(text, forKey: CKConstant.Field.text)
        
        if let categoryId = categoryId {
            let reference = getCategoryReference(categoryId: categoryId)
            record.setValue(reference, forKey: CKConstant.Field.category)
        } else {
            record.setValue(nil, forKey: CKConstant.Field.category)
        }
        
        if let imageData = image {
            let tempDirectory = FileManager.default.temporaryDirectory
            let imageURL = tempDirectory.appendingPathComponent(uuid)
            do {
                try imageData.write(to: imageURL)
            } catch {
                NSLog("Image can't write to \(imageURL), error: \(error)")
            }
            
            let asset = CKAsset(fileURL: imageURL)
            record.setValue(asset, forKey: CKConstant.Field.image)
        } else {
            record.setValue(nil, forKey: CKConstant.Field.image)
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
