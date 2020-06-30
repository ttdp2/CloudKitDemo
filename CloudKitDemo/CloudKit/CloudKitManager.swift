//
//  CloudKitManager.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/18.
//  Copyright © 2020 TTDP. All rights reserved.
//

import CloudKit

class CloudKitManager {
    
    static let shared = CloudKitManager()
    
    static let privateDB = CKContainer.default().privateCloudDatabase
    
    var ideas: [CKRecord] = []
    
    func save(idea: Idea) {
        let record = CKRecord(recordType: CKConstant.Record.Ideas)
        record.setValue(idea.title, forKey: CKConstant.Field.Title)
        
        CloudKitManager.privateDB.save(record) { (newRecord, error) in
            if error != nil {
                print(error!)
            } else {
                print(newRecord!.recordID)
            }
        }
    }
    
    func query(completion: @escaping () -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: CKConstant.Record.Ideas, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: CKConstant.Sort.CreationDate, ascending: true)]
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordFetchedBlock = { record in
            self.ideas.append(record)
        }
        
        operation.queryCompletionBlock = { cursor, error in
            DispatchQueue.main.async {
                completion()
                print(self.ideas)
            }
        }
        
        CloudKitManager.privateDB.add(operation)
    }
    
    func update() {
        let recordID = ideas.first?.recordID ?? CKRecord.ID()
     
        CloudKitManager.privateDB.fetch(withRecordID: recordID) { record, error in
            if error != nil {
                print(error!)
            } else {
                record!.setValue("Welcome to WWDC", forKey: CKConstant.Field.Title)
                CloudKitManager.privateDB.save(record!) { updatedRecord, error in
                    if error != nil {
                        print("Updated Error: \(error!)")
                    } else {
                        print("Updated Successfully")
                    }
                }
            }
        }
    }
    
    func delete() {
        let recordID = ideas.first?.recordID ?? CKRecord.ID()
        
        CloudKitManager.privateDB.delete(withRecordID: recordID) { id, error in
            if error != nil {
                print("Delete Error: \(error!)")
            } else {
                print("Deleted Successfully")
            }
        }
    }
    
}
