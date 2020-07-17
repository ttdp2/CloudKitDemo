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
    
    
    func fetchPhotos(completion: @escaping () -> Void) {
        let predicate = NSPredicate(value: true)
        let photoQuery = CKQuery(recordType: CKConstant.RecordType.Photos, predicate: predicate)
        let albumQuery = CKQuery(recordType: CKConstant.RecordType.Albums, predicate: predicate)
        let shareQuery = CKQuery(recordType: CKConstant.RecordType.CloudKitShare, predicate: predicate)
        
        // Fetch owner's photos in his private database
        privateDB.perform(photoQuery, inZoneWith: privateZone.zoneID) { records, error in
            if let photoRecords = records {
                self.photos = photoRecords.map { Photo(record: $0) }
                
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
        
        // Fetch owner's root album in his private database
        privateDB.perform(albumQuery, inZoneWith: privateZone.zoneID) { records, error in
            if let record = records?.first {
                self.rootRecord = record
            }
        }
        
        // Fetch owner's `share` type record in his private database
        privateDB.perform(shareQuery, inZoneWith: privateZone.zoneID) { records, error in
            if let record = records?.first as? CKShare {
                self.share = record
            }
        }
        
        
        // Fetch shared zones in participant's shared database
        sharedDB.fetchAllRecordZones { zones, error in
            guard let zone = zones?.first else { return }
                
            // If shared zone exists, the current user is a participant
            self.sharedZone = zone
            self.isOwner = false
            
            // Fetch owner's photos in participant's shared database
            self.sharedDB.perform(photoQuery, inZoneWith: zone.zoneID) { records, error in
                if let photoRecords = records {
                    self.photos = photoRecords.map { Photo(record: $0) }
                    
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
            
            // Fetch owner's root album in participant's shared database
            self.sharedDB.perform(albumQuery, inZoneWith: zone.zoneID) { records, error in
                if let record = records?.first {
                    self.rootRecord = record
                }
            }
        }
    }
    
}
