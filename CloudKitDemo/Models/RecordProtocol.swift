//
//  RecordProtocol.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/7/3.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation
import CloudKit

protocol Record {
    var uuid: String { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
    
    init(record: CKRecord)
    
    func getRecordID() -> CKRecord.ID
    func convertToCKRecord() -> CKRecord
    func mergeWithCKRecord(_ record: CKRecord) -> CKRecord
}
