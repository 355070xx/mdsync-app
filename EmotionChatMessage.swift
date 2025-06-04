//
//  EmotionChatMessage.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import Foundation
import FirebaseFirestore

struct EmotionChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let fromUID: String
    let fromName: String
    let emoji: String?
    let text: String?
    let type: MessageType
    let createdAt: Timestamp
    let expiresAt: Timestamp
    
    enum MessageType: String, CaseIterable, Codable {
        case message = "message"
        case apology = "apology"
        case hug = "hug"
        case reject = "reject"
        case neutral = "neutral"
        
        var displayText: String {
            switch self {
            case .message:
                return "一般訊息"
            case .apology:
                return "道歉"
            case .hug:
                return "擁抱"
            case .reject:
                return "拒絕"
            case .neutral:
                return "中性"
            }
        }
        
        var defaultEmoji: String {
            switch self {
            case .message:
                return "💬"
            case .apology:
                return "🙏"
            case .hug:
                return "🫂"
            case .reject:
                return "❌"
            case .neutral:
                return "😐"
            }
        }
    }
    
    // 檢查訊息是否已過期
    var isExpired: Bool {
        return expiresAt.dateValue() < Date()
    }
    
    // 計算剩餘時間
    var timeRemaining: TimeInterval {
        return expiresAt.dateValue().timeIntervalSince(Date())
    }
    
    // 格式化時間顯示
    func formatCreatedTime() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        
        let calendar = Calendar.current
        let now = Date()
        let messageDate = createdAt.dateValue()
        
        if calendar.isDate(messageDate, inSameDayAs: now) {
            formatter.dateFormat = "HH:mm"
        } else if calendar.isDate(messageDate, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
            formatter.dateFormat = "昨天 HH:mm"
        } else {
            formatter.dateFormat = "MM/dd HH:mm"
        }
        
        return formatter.string(from: messageDate)
    }
}

// 聊天室狀態模型
struct EmotionChatMetadata: Codable {
    let isEmotionChatEnabled: Bool
    let lastOpened: Timestamp
    
    init(isEnabled: Bool = true) {
        self.isEmotionChatEnabled = isEnabled
        self.lastOpened = Timestamp()
    }
} 