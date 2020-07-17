//
//  PhotosViewModel.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/17.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation
import CloudKit

class PhotosViewModel {
    
    // MARK: - Property
    
    var share: CKShare?
    var rootRecord: CKRecord?
    
    var photos: [Photo] = []
    
    var isOwner: Bool = true
    
    let privateDB = CloudKitManager.privateDB
    let privateZone = CloudKitManager.photosZone
    
    let sharedDB = CloudKitManager.sharedDB
    var sharedZone: CKRecordZone?
    
    let predicate = NSPredicate(value: true)
    
    func fetchPhotos(completion: @escaping () -> Void) {
        let query = CKQuery(recordType: CKConstant.RecordType.Photos, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: privateZone.zoneID) { records, error in
            if let photoRecords = records {
                self.photos = photoRecords.map { Photo(record: $0) }
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
        
        sharedDB.perform(<#T##query: CKQuery##CKQuery#>, inZoneWith: <#T##CKRecordZone.ID?#>, completionHandler: <#T##([CKRecord]?, Error?) -> Void#>)
    }
    
}
