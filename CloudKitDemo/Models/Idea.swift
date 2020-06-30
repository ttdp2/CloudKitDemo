//
//  Idea.swift
//  CloudKitDemo
//
//  Created by Tian Tong on 2020/6/29.
//  Copyright © 2020 TTDP. All rights reserved.
//

import Foundation

protocol Record {
    var uuid: String { get }
    var createdAt: Date { get }
    var updatedAt: Date { get set }
}

struct Idea: Record {
    let uuid: String
    let createdAt: Date
    var updatedAt: Date
    
    let title: String
}

extension Idea {
    init(title: String) {
        self.uuid = UUID().uuidString
        self.createdAt = Date()
        self.updatedAt = Date()
        
        self.title = title
    }
}
