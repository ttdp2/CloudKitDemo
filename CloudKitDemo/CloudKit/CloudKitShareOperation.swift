//
//  CloudKitShareOperation.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 7/16/20.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitShareOperation {
    
    let isOwner: Bool
    
    var cloudKitDatabase: CKDatabase {
        return isOwner ? CloudKitManager.privateDB : CloudKitManager.sharedDB
    }
    
    init(isOwner: Bool) {
        self.isOwner = isOwner
    }
    
    func save(record: CKRecord, parent: CKRecord?, completion: @escaping (Bool) -> Void) {
        record.setParent(parent)
        
        cloudKitDatabase.save(record) { _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error occurs when saving shared record: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }
    
    func batchSave(records: [CKRecord], parent: CKRecord, completion: @escaping (Bool) -> Void) {
        records.forEach { record in
            record.setParent(parent)
        }
        
        let modifyOperation = CKModifyRecordsOperation(recordsToSave: records)
        modifyOperation.savePolicy = .changedKeys
        
        modifyOperation.modifyRecordsCompletionBlock = { _, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error occurs when batch saving shared records: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
        
        cloudKitDatabase.add(modifyOperation)
    }
    
}
