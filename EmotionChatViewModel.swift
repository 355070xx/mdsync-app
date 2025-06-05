//
//  EmotionChatViewModel.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class EmotionChatViewModel: ObservableObject {
    @Published var messages: [EmotionChatMessage] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showAlert = false
    @Published var isEmotionChatEnabled = false
    @Published var pairedWith = ""
    @Published var partnerName = ""
    @Published var showSuccessFeedback = false
    @Published var successMessage = ""
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var messagesListener: ListenerRegistration?
    private var metadataListener: ListenerRegistration?
    
    init() {
        loadPairingInfo()
    }
    
    deinit {
        messagesListener?.remove()
        metadataListener?.remove()
    }
    
    // MARK: - 載入配對資訊
    func loadPairingInfo() {
        guard let currentUser = auth.currentUser else { return }
        
        Task {
            do {
                let document = try await db.collection("users").document(currentUser.uid).getDocument()
                
                if let data = document.data(),
                   let pairedWithUID = data["pairedWith"] as? String,
                   !pairedWithUID.isEmpty {
                    
                    pairedWith = pairedWithUID
                    
                    // 載入伴侶名稱
                    let partnerDoc = try await db.collection("users").document(pairedWithUID).getDocument()
                    if let partnerData = partnerDoc.data() {
                        partnerName = partnerData["name"] as? String ?? "伴侶"
                    }
                    
                    // 開始監聽聊天狀態和訊息
                    startListening()
                } else {
                    // 清除狀態
                    pairedWith = ""
                    partnerName = ""
                    isEmotionChatEnabled = false
                    messages = []
                }
            } catch {
                handleError(error)
            }
        }
    }
    
    // MARK: - 開始監聽聊天狀態和訊息
    private func startListening() {
        guard !pairedWith.isEmpty else { return }
        
        let pairID = createPairID(currentUserUID: auth.currentUser?.uid ?? "", partnerUID: pairedWith)
        
        // 監聽聊天狀態
        metadataListener = db.collection("emotionChats")
            .document(pairID)
            .collection("metadata")
            .document("status")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("監聽聊天狀態失敗: \(error)")
                    return
                }
                
                if let data = snapshot?.data() {
                    self.isEmotionChatEnabled = data["isEmotionChatEnabled"] as? Bool ?? false
                    
                    // 如果聊天已啟用，開始監聽訊息
                    if self.isEmotionChatEnabled {
                        self.startListeningMessages()
                    } else {
                        self.messages = []
                        self.messagesListener?.remove()
                    }
                }
            }
    }
    
    // MARK: - 監聽訊息
    private func startListeningMessages() {
        guard !pairedWith.isEmpty else { return }
        
        let pairID = createPairID(currentUserUID: auth.currentUser?.uid ?? "", partnerUID: pairedWith)
        
        messagesListener = db.collection("emotionChats")
            .document(pairID)
            .collection("messages")
            .order(by: "createdAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("監聽訊息失敗: \(error)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // 過濾未過期的訊息
                self.messages = documents.compactMap { document in
                    do {
                        let message = try document.data(as: EmotionChatMessage.self)
                        return message.isExpired ? nil : message
                    } catch {
                        print("解析訊息失敗: \(error)")
                        return nil
                    }
                }
            }
    }
    
    // MARK: - 啟用情緒聊天
    func enableEmotionChat() async {
        guard let currentUser = auth.currentUser, !pairedWith.isEmpty else { return }
        
        isLoading = true
        
        do {
            let pairID = createPairID(currentUserUID: currentUser.uid, partnerUID: pairedWith)
            let metadata = EmotionChatMetadata(isEnabled: true)
            
            try await db.collection("emotionChats")
                .document(pairID)
                .collection("metadata")
                .document("status")
                .setData(from: metadata)
            
            isEmotionChatEnabled = true
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 發送訊息
    func sendMessage(text: String?, emoji: String?, type: EmotionChatMessage.MessageType) async {
        guard let currentUser = auth.currentUser,
              !pairedWith.isEmpty,
              isEmotionChatEnabled else { return }
        
        // 至少要有文字或 emoji
        let hasValidText = text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        let hasValidEmoji = emoji?.isEmpty == false
        
        guard hasValidText || hasValidEmoji else { return }
        
        isLoading = true
        
        do {
            let pairID = createPairID(currentUserUID: currentUser.uid, partnerUID: pairedWith)
            
            // 計算過期時間（7天後）
            let expiresAt = Timestamp(date: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date())
            
            let messageData: [String: Any] = [
                "fromUID": currentUser.uid,
                "fromName": getUserName(),
                "emoji": emoji as Any,
                "text": text as Any,
                "type": type.rawValue,
                "createdAt": Timestamp(),
                "expiresAt": expiresAt,
                "replyStatus": NSNull(),
                "replyByUID": NSNull()
            ]
            
            try await db.collection("emotionChats")
                .document(pairID)
                .collection("messages")
                .addDocument(data: messageData)
            
            // 顯示成功回饋
            successMessage = "已發送 \(type.displayText)"
            showSuccessFeedback = true
            
            // 2秒後隱藏回饋
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showSuccessFeedback = false
            }
            
            // 更新通知狀態
            try await updateNotificationStatus(pairID: pairID, currentUser: currentUser)
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 更新通知狀態
    private func updateNotificationStatus(pairID: String, currentUser: User) async throws {
        let notificationData: [String: Any] = [
            "hasUnread": true,
            "lastSenderUID": currentUser.uid,
            "lastSenderName": getUserName(),
            "lastUpdated": Timestamp()
        ]
        
        try await db.collection("emotionChats")
            .document(pairID)
            .collection("metadata")
            .document("notification")
            .setData(notificationData, merge: true)
    }
    
    // MARK: - 標記為已讀
    func markAsRead() async {
        guard let currentUser = auth.currentUser, !pairedWith.isEmpty else { return }
        
        let pairID = createPairID(currentUserUID: currentUser.uid, partnerUID: pairedWith)
        
        do {
            try await db.collection("emotionChats")
                .document(pairID)
                .collection("metadata")
                .document("notification")
                .updateData([
                    "hasUnread": false
                ])
        } catch {
            print("標記為已讀失敗: \(error)")
        }
    }
    
    // MARK: - 發送快速回應
    func sendQuickResponse(type: EmotionChatMessage.MessageType) async {
        // 確保聊天已啟用
        guard isEmotionChatEnabled else { return }
        
        await sendMessage(
            text: nil,
            emoji: type.defaultEmoji,
            type: type
        )
    }
    
    // MARK: - 回覆訊息
    func replyToMessage(messageID: String, replyStatus: EmotionChatMessage.ReplyStatus) async {
        guard let currentUser = auth.currentUser, !pairedWith.isEmpty, isEmotionChatEnabled else { return }
        
        isLoading = true
        
        do {
            let pairID = createPairID(currentUserUID: currentUser.uid, partnerUID: pairedWith)
            
            // 更新訊息的回覆狀態
            try await db.collection("emotionChats")
                .document(pairID)
                .collection("messages")
                .document(messageID)
                .updateData([
                    "replyStatus": replyStatus.rawValue,
                    "replyByUID": currentUser.uid
                ])
            
            // 如果選擇「稍後再回應」，發送一則訊息
            if replyStatus == .later {
                await sendMessage(
                    text: "等一下",
                    emoji: "🤔",
                    type: .neutral
                )
            }
            
            // 顯示成功回饋
            successMessage = "已回覆：\(replyStatus.displayText)"
            showSuccessFeedback = true
            
            // 2秒後隱藏回饋
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showSuccessFeedback = false
            }
            
            // 更新通知狀態
            try await updateNotificationStatus(pairID: pairID, currentUser: currentUser)
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 停用情緒聊天
    func disableEmotionChat() async {
        guard let currentUser = auth.currentUser, !pairedWith.isEmpty else { return }
        
        isLoading = true
        
        do {
            let pairID = createPairID(currentUserUID: currentUser.uid, partnerUID: pairedWith)
            
            try await db.collection("emotionChats")
                .document(pairID)
                .collection("metadata")
                .document("status")
                .updateData([
                    "isEmotionChatEnabled": false
                ])
            
            isEmotionChatEnabled = false
            messages = []
            messagesListener?.remove()
            
        } catch {
            handleError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 輔助函數
    private func createPairID(currentUserUID: String, partnerUID: String) -> String {
        let sortedUIDs = [currentUserUID, partnerUID].sorted()
        return "\(sortedUIDs[0])_\(sortedUIDs[1])"
    }
    
    private func getUserName() -> String {
        // 首先嘗試從 UserDefaults 獲取
        if let storedName = UserDefaults.standard.string(forKey: "userName"), !storedName.isEmpty {
            return storedName
        }
        
        // 如果 UserDefaults 中沒有，嘗試從當前用戶的 displayName 獲取
        if let displayName = auth.currentUser?.displayName, !displayName.isEmpty {
            return displayName
        }
        
        // 最後返回預設值
        return "使用者"
    }
    
    private func handleError(_ error: Error) {
        errorMessage = "操作失敗：\(error.localizedDescription)"
        showAlert = true
        print("EmotionChatViewModel Error: \(error)")
    }
    
    // MARK: - 檢查是否為當前用戶的訊息
    func isCurrentUserMessage(_ message: EmotionChatMessage) -> Bool {
        return message.fromUID == auth.currentUser?.uid
    }
    
    // MARK: - 自動清除過期訊息
    func cleanupExpiredMessages() async {
        guard let currentUser = auth.currentUser, !pairedWith.isEmpty else { 
            await showSuccess("無法清理：用戶未登入或未配對")
            return 
        }
        
        let pairID = createPairID(currentUserUID: currentUser.uid, partnerUID: pairedWith)
        
        do {
            let snapshot = try await db.collection("emotionChats")
                .document(pairID)
                .collection("messages")
                .whereField("expiresAt", isLessThan: Timestamp())
                .getDocuments()
            
            let batch = db.batch()
            
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            try await batch.commit()
            
            let count = snapshot.documents.count
            if count > 0 {
                await showSuccess("已清除 \(count) 則過期訊息")
            } else {
                await showSuccess("沒有找到過期訊息")
            }
            print("已清除 \(count) 則過期訊息")
            
        } catch {
            await showSuccess("清除失敗：\(error.localizedDescription)")
            print("清除過期訊息失敗: \(error)")
        }
    }
    
    // MARK: - 添加測試假資料
    func addTestMessages() async {
        guard let currentUser = auth.currentUser, !pairedWith.isEmpty else { return }
        
        let pairID = createPairID(currentUserUID: currentUser.uid, partnerUID: pairedWith)
        let now = Date()
        
        // 假資料訊息
        let testMessages: [(text: String?, emoji: String?, type: EmotionChatMessage.MessageType, fromCurrentUser: Bool, minutesAgo: Int)] = [
            ("對不起，我剛才說話太重了...", "🙏", .apology, true, 30),
            ("我也有錯，我們都冷靜一下吧", "😔", .message, false, 25),
            (nil, "🫂", .hug, true, 20),
            ("謝謝你的擁抱", "💕", .message, false, 18),
            ("我需要一些時間思考", nil, .neutral, false, 15),
            ("好的，我會給你空間", "✅", .message, true, 12),
            ("其實我也很在意你的感受", "❤️", .hug, false, 8),
            ("我們一起努力解決這個問題吧", "🤝", .message, true, 5)
        ]
        
        for testMessage in testMessages {
            let messageData: [String: Any] = [
                "fromUID": testMessage.fromCurrentUser ? currentUser.uid : pairedWith,
                "fromName": testMessage.fromCurrentUser ? getUserName() : partnerName,
                "emoji": testMessage.emoji as Any,
                "text": testMessage.text as Any,
                "type": testMessage.type.rawValue,
                "createdAt": Timestamp(date: Calendar.current.date(byAdding: .minute, value: -testMessage.minutesAgo, to: now) ?? now),
                "expiresAt": Timestamp(date: Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now),
                "replyStatus": NSNull(),
                "replyByUID": NSNull()
            ]
            
            do {
                try await db.collection("emotionChats")
                    .document(pairID)
                    .collection("messages")
                    .addDocument(data: messageData)
            } catch {
                print("添加測試訊息失敗: \(error)")
            }
        }
        
        await showSuccess("已添加 \(testMessages.count) 則測試訊息")
        print("已添加 \(testMessages.count) 則測試訊息")
    }
    
    // MARK: - 添加已過期的測試訊息（用於測試清理功能）
    func addExpiredTestMessages() async {
        guard let currentUser = auth.currentUser, !pairedWith.isEmpty else { return }
        
        let pairID = createPairID(currentUserUID: currentUser.uid, partnerUID: pairedWith)
        let now = Date()
        
        // 已過期的假資料訊息
        let expiredMessages: [(text: String?, emoji: String?, type: EmotionChatMessage.MessageType, fromCurrentUser: Bool, daysAgo: Int)] = [
            ("這是一週前的道歉訊息", "🙏", .apology, true, 8),
            ("這是過期的擁抱", "🫂", .hug, false, 9),
            ("這則訊息應該被清理", nil, .neutral, true, 10)
        ]
        
        for expiredMessage in expiredMessages {
            let messageData: [String: Any] = [
                "fromUID": expiredMessage.fromCurrentUser ? currentUser.uid : pairedWith,
                "fromName": expiredMessage.fromCurrentUser ? getUserName() : partnerName,
                "emoji": expiredMessage.emoji as Any,
                "text": expiredMessage.text as Any,
                "type": expiredMessage.type.rawValue,
                "createdAt": Timestamp(date: Calendar.current.date(byAdding: .day, value: -expiredMessage.daysAgo, to: now) ?? now),
                "expiresAt": Timestamp(date: Calendar.current.date(byAdding: .day, value: -(expiredMessage.daysAgo - 7), to: now) ?? now), // 已過期
                "replyStatus": NSNull(),
                "replyByUID": NSNull()
            ]
            
            do {
                try await db.collection("emotionChats")
                    .document(pairID)
                    .collection("messages")
                    .addDocument(data: messageData)
            } catch {
                print("添加已過期測試訊息失敗: \(error)")
            }
        }
        
        await showSuccess("已添加 \(expiredMessages.count) 則過期測試訊息")
        print("已添加 \(expiredMessages.count) 則過期測試訊息")
    }
    
    // MARK: - 定期清理過期訊息（背景任務）
    func startPeriodicCleanup() {
        // 每小時檢查一次過期訊息
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.cleanupExpiredMessages()
            }
        }
    }
} 