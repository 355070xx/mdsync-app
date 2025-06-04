//
//  Reaction.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import Foundation
import FirebaseFirestore

struct Reaction: Identifiable, Codable {
    @DocumentID var id: String?
    let fromUID: String
    let fromName: String
    let emoji: String
    let timestamp: Timestamp
    
    // 便利屬性：獲取可讀的日期
    var date: Date {
        return timestamp.dateValue()
    }
} 