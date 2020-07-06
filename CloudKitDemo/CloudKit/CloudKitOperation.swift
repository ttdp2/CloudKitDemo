//
//  CloudKitOperation.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/30.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation
import CloudKit

class CloudKitOperation<T: Record> {
    
    static func save(model: T, completion: @escaping (T) -> Void) {
        let record = model.convertToCKRecord()
        
        CloudKitManager.privateDB.save(record) { savedRecord, error in
            if let error = error {
                print("Save Error: \(error)")
            }
            
            if let record = savedRecord {
                DispatchQueue.main.async {
                    completion(T(record: record))
                }
            }
        }
    }
    
    static func query(type: String, completion: @escaping ([T]) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: type, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: CKConstant.Sort.creationDate, ascending: true)]
        
        let operation = CKQueryOperation(query: query)
        
        var records: [T] = []
        operation.recordFetchedBlock = { record in
            records.append(T(record: record))
        }
        
        operation.queryCompletionBlock = { cursor, error in
            if let error = error {
                print("Query Error: \(error)")
            }
            
            DispatchQueue.main.async {
                completion(records)
            }
        }
        
        CloudKitManager.privateDB.add(operation)
    }
    
    static func update(model: T, completion: @escaping (T) -> Void) {
        let recordID = model.getRecordID()
        
        CloudKitManager.privateDB.fetch(withRecordID: recordID) { fetchedRecord, error in
            guard let cloudRecord = fetchedRecord else { return }
            
            // The update operation need use `recordChangeTag` from iCloud,
            // this is a get property, so we have to use the cloud one and merge with our value
            let record = model.mergeWithCKRecord(cloudRecord)
            
            CloudKitManager.privateDB.save(record) { updatedRecord, error in
                if let error = error {
                    print("Update Error: \(error)")
                }
                
                if let record = updatedRecord {
                    DispatchQueue.main.async {
                        completion(T(record: record))
                    }
                }
            }
        }
    }
    
    static func delete(model: T, completion: @escaping (Bool) -> Void) {
        let recordID = model.getRecordID()
        
        CloudKitManager.privateDB.delete(withRecordID: recordID) { id, error in
            if error != nil {
                print("Delete Error: \(error!)")
            }
            
            if id != nil {
                DispatchQueue.main.async {
                    completion(true)
                }
            }
        }
    }
    
    static func batch(modelsToSave: [T], modelsToDelete: [T], completion: @escaping ([T], [String]) -> Void) {
        let recordsToSave = modelsToSave.map { $0.convertToCKRecord() }
        let recordIDsToDelete = modelsToDelete.map { $0.getRecordID() }
        
        let operation = CKModifyRecordsOperation(recordsToSave: recordsToSave, recordIDsToDelete: recordIDsToDelete)
        operation.savePolicy = .changedKeys
        operation.perRecordCompletionBlock = { record, error in }
        operation.modifyRecordsCompletionBlock = { records, ids, error in
            if error != nil {
                print("Batch Error: \(error!)")
            }
            
            let savedRecords = records?.map { T(record: $0) } ?? []
            let deletedRecordIDs = ids?.map { $0.recordName } ?? []
            
            DispatchQueue.main.async {
                completion(savedRecords, deletedRecordIDs)
            }
        }
        
        CloudKitManager.privateDB.add(operation)
    }
    
}
