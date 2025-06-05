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
    
    // 新增回覆狀態欄位
    let replyStatus: ReplyStatus?
    let replyByUID: String?
    
    enum ReplyStatus: String, CaseIterable, Codable {
        case accepted = "accepted"
        case later = "later"
        
        var displayText: String {
            switch self {
            case .accepted:
                return "接受"
            case .later:
                return "稍後再回應"
            }
        }
        
        var emoji: String {
            switch self {
            case .accepted:
                return "✅"
            case .later:
                return "🕓"
            }
        }
    }
    
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
        
        // 新增：檢查是否可以被回覆
        var canBeReplied: Bool {
            switch self {
            case .apology, .hug, .reject:
                return true
            case .message, .neutral:
                return false
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
    
    // 新增：檢查是否已經被回覆
    var isReplied: Bool {
        return replyStatus != nil && replyByUID != nil
    }
    
    // 新增：獲取回覆狀態顯示文字
    func getReplyStatusText(currentUserUID: String) -> String? {
        guard let replyStatus = replyStatus, let replyByUID = replyByUID else { return nil }
        
        let isCurrentUserReply = replyByUID == currentUserUID
        let prefix = isCurrentUserReply ? "你" : "對方"
        
        switch replyStatus {
        case .accepted:
            return "\(prefix)接受了這個\(type.displayText)"
        case .later:
            return "\(prefix)選擇稍後再回應"
        }
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