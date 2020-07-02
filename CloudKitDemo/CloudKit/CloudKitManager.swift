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
    static let notesZone = CKRecordZone(zoneName: CKConstant.Zone.Notes)
    static let defaultZone = CKRecordZone(zoneName: CKConstant.Zone.Default)
    
    static var isNotesZoneReady: Bool {
        return UserDefaults.standard.bool(forKey: CKConstant.isNotesZoneReady)
    }
    
    class func setUpNotesZone() {
        let zoneOperation = CKModifyRecordZonesOperation(recordZonesToSave: [notesZone], recordZoneIDsToDelete: nil)
        zoneOperation.modifyRecordZonesCompletionBlock = { _, _, error in
            if let error = error {
                NSLog("CloudKit ModifyRecordZones Error: \(error.localizedDescription) #CloudKitOperation")
            } else {
                UserDefaults.standard.set(true, forKey: CKConstant.isNotesZoneReady)
            }
        }
        CloudKitManager.privateDB.add(zoneOperation)
    }
    
}
