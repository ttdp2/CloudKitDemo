//
//  PhotosViewModel.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/17.
//  Copyright © 2020 TTDP. All rights reserved.
//

import UIKit
import CloudKit

protocol PhotosViewModelDelegate: class {
    func showSharingController(_ controller: UICloudSharingController)
}

class PhotosViewModel {
    
    // MARK: - Property
    
    weak var delegate: PhotosViewModelDelegate?
    
    var share: CKShare?
    var root: CKRecord?
    
    var photos: [Photo] = []
    
    var isOwner: Bool = true
    
    let privateDB = CloudKitManager.privateDB
    let privateZone = CloudKitManager.photosZone
    
    let sharedDB = CloudKitManager.sharedDB
    var sharedZone: CKRecordZone?
    
    /* Example
     Owner Zone: <CKRecordZoneID: 0x2816a0e60; ownerName=__defaultOwner__, zoneName=Photos Zone>
     
     Participant Zone: <CKRecordZoneID: 0x280b991c0; ownerName=_a9bdc43038d1f1d3fee0b5b9e5c6010e, zoneName=Photos Zone>
    */
    
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
                self.root = record
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
                    self.root = record
                }
            }
        }
    }
    
    func addPhoto(_ photo: Photo) {
        photos.append(photo)
        
        uploadToCloudKit(photo)
    }
    
    private func uploadToCloudKit(_ photo: Photo) {
        if isOwner {
            let record = photo.convertToCKRecord()
            record.setParent(root)
            
            privateDB.save(record) { savedRecord, error in
                if let error = error {
                    print("Owner upload photo error: \(error)")
                }
                
                if savedRecord != nil {
                    print("Owner upload photo successfully")
                }
            }
        } else {
            guard let zoneID = sharedZone?.zoneID else {
                print("Participant has no shared zones")
                return
            }
            let recordID = CKRecord.ID(recordName: photo.uuid, zoneID: zoneID)
            var record = CKRecord(recordType: CKConstant.RecordType.Photos, recordID: recordID)
            record = photo.mergeWithCKRecord(record)
            record.setParent(root)
            
            sharedDB.save(record) { savedRecord, error in
                if let error = error {
                    print("Participant upload photo error: \(error)")
                }
                
                if savedRecord != nil {
                    print("Participant upload photo successfully")
                }
            }
        }
    }
    
    func addShare() {
        let controller: UICloudSharingController
        
        if let shareRecord = share {
            controller = UICloudSharingController(share: shareRecord, container: CKContainer.default())
        } else {
            controller = UICloudSharingController { (UICloudSharingController, handler: @escaping (CKShare?, CKContainer?, Error?) -> Void) in
                
                let root = Album(name: "Shared Album").convertToCKRecord()
                let share = CKShare(rootRecord: root)
                let operation = CKModifyRecordsOperation(recordsToSave: [share, root], recordIDsToDelete: nil)
                
                operation.modifyRecordsCompletionBlock = { _, _, error in
                    if let error = error {
                        print("Owner upload root album error: \(error)")
                    } else {
                        self.root = root
                        self.share = share
                        print("Owner upload root album successfully")
                    }
                    handler(share, CKContainer.default(), error)
                }
    
                self.privateDB.add(operation)
            }
            controller.availablePermissions = [.allowPrivate, .allowReadWrite]
        }
        
        delegate?.showSharingController(controller)
    }
    
    func stopShare() {
        share = nil
        root = nil
    }
    
}
