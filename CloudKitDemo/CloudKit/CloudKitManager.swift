//
//  CloudKitManager.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/18.
//  Copyright © 2020 TTDP. All rights reserved.
//

import CloudKit

class CloudKitManager {

    static let privateDB = CKContainer.default().privateCloudDatabase
    static let sharedDB = CKContainer.default().sharedCloudDatabase
    
    static let notesZone = CKRecordZone(zoneName: CKConstant.Zone.Notes)
    static let photosZone = CKRecordZone(zoneName: CKConstant.Zone.Photos)
    static let defaultZone = CKRecordZone(zoneName: CKConstant.Zone.Default)
    
    static var isNotesZoneReady: Bool {
        return UserDefaults.standard.bool(forKey: CKConstant.isNotesZoneReady)
    }
    
    static var isPhotosZoneReady: Bool {
        return UserDefaults.standard.bool(forKey: CKConstant.isPhotosZoneReady)
    }
    
    static var isNotesSubcriptionReady: Bool {
        return UserDefaults.standard.bool(forKey: CKConstant.isNotesSubscriptionReady)
    }
    
    class func setUpNotesZone() {
        let zoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [notesZone], recordZoneIDsToDelete: nil)
        
        zoneOperation.modifyRecordZonesCompletionBlock = { _, _, error in
            if let error = error {
                NSLog("CloudKit ModifyRecordZones Error: \(error.localizedDescription)")
            } else {
                UserDefaults.standard.set(true, forKey: CKConstant.isNotesZoneReady)
            }
        }
        
        CloudKitManager.privateDB.add(zoneOperation)
    }
    
    class func setupPhotosZone() {
        let zoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [photosZone], recordZoneIDsToDelete: nil)
        
        zoneOperation.modifyRecordZonesCompletionBlock = { _, _, error in
            if let error = error {
                NSLog("CloudKit ModifyRecordZones Error: \(error.localizedDescription)")
            } else {
                UserDefaults.standard.set(true, forKey: CKConstant.isPhotosZoneReady)
            }
        }
        
        CloudKitManager.privateDB.add(zoneOperation)
    }

    class func setupNotesSubcription() {
        let predicate = NSPredicate(value: true)
        let options: CKQuerySubscription.Options = [.firesOnRecordCreation, .firesOnRecordDeletion, .firesOnRecordUpdate]
        
        let subscription = CKQuerySubscription(recordType: CKConstant.RecordType.Notes, predicate: predicate, subscriptionID: CKConstant.Subscription.Notes, options: options)
        
        let into = CKSubscription.NotificationInfo()
        into.alertBody = "A new notification has been posted!"
        into.soundName = "default"
        
        subscription.notificationInfo = into
        
        CloudKitManager.privateDB.save(subscription) { sub, error in
            guard sub != nil, error == nil else {
                NSLog("Subscription failed: \(error!)")
                return
            }
            
            UserDefaults.standard.set(true, forKey: CKConstant.isNotesSubscriptionReady)
        }
    }
    
}
