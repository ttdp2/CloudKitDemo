//
//  CKConstant.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/29.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation

struct CKConstant {
    
    static let isNotesZoneReady = "isNotesZoneReady"
    static let isPhotosZoneReady = "isPhotosZoneReady"
    
    struct Zone {
        static let Notes = "Notes Zone"
        static let Photos = "Photos Zone"
        static let Default = "_defaultZone"
    }
    
    struct RecordType {
        static let Ideas = "Ideas"
        static let Notes = "Notes"
        static let Categories = "Categories"
        static let Photos = "Photos"
    }
    
    struct Field {
        static let title = "title"
        static let text = "text"
        static let name = "name"
        static let data = "data"
        static let category = "category"
        static let image = "image"
    }
    
    struct Sort {
        static let creationDate = "creationDate"
        static let modificationDate = "modificationDate"
    }
    
}
