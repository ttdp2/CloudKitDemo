//
//  Photo.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/7.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation
import CloudKit

struct Photo {
    
    let uuid: String
    let createdAt: Date
    let updatedAt: Date
    
    let data: Data
    var album: Album?
}

extension Photo: Record {
    
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
        
        guard
            let asset = record.object(forKey: CKConstant.Field.data) as? CKAsset,
            let imageURL = asset.fileURL,
            let imageDate = try? Data(contentsOf: imageURL) else {
                self.data = Data()
                return
        }
        
        self.data = imageDate
    }
    
    func getRecordID() -> CKRecord.ID {
        let zoneID = CloudKitManager.photosZone.zoneID
        let recordID = CKRecord.ID(recordName: uuid, zoneID: zoneID)
        return recordID
    }
    
    func convertToCKRecord() -> CKRecord {
        let record = CKRecord(recordType: CKConstant.RecordType.Photos, recordID: getRecordID())
        return mergeWithCKRecord(record)
    }
    
    func mergeWithCKRecord(_ record: CKRecord) -> CKRecord {
        let tempDirectory = FileManager.default.temporaryDirectory
        let imageURL = tempDirectory.appendingPathComponent(uuid)
        do {
            try data.write(to: imageURL)
        } catch {
            NSLog("Image can't write to \(imageURL), error: \(error)")
        }
        
        let asset = CKAsset(fileURL: imageURL)
        record.setValue(asset, forKey: CKConstant.Field.data)
        record.setParent(album?.convertToCKRecord())
        return record
    }
    
}
