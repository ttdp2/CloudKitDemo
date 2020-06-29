//
//  CloudKitHelper.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/18.
//  Copyright © 2020 TTDP. All rights reserved.
//

import CloudKit

class CloudKitHelper {
    
    static let shared = CloudKitHelper()
    
    static let privateDB = CKContainer.default().privateCloudDatabase
    
    func save(idea: Idea) {
        let record = CKRecord(recordType: "Idea")
        record.setValue(idea.title, forKey: "title")
        record.setValue(idea.date, forKey: "date")
        
        CloudKitHelper.privateDB.save(record) { (newRecord, error) in
            if error != nil {
                print(error!)
            } else {
                print(newRecord!)
            }
        }
    }
    
}
