//
//  CloudKitHelper.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/18.
//  Copyright © 2020 TTDP. All rights reserved.
//

import CloudKit

class CloudKitManager {
    
    static let shared = CloudKitManager()
    
    static let privateDB = CKContainer.default().privateCloudDatabase
    
    func save(idea: Idea) {
        let record = CKRecord(recordType: "Ideas")
        record.setValue(idea.title, forKey: "title")
        record.setValue(idea.description, forKey: "description")
        
        CloudKitManager.privateDB.save(record) { (newRecord, error) in
            if error != nil {
                print(error!)
            } else {
                print(newRecord!.recordID)
            }
        }
    }
    
}
