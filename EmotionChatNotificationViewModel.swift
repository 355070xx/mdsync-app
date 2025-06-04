//
//  EmotionChatNotificationViewModel.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

@MainActor
class EmotionChatNotificationViewModel: ObservableObject {
    @Published var hasUnreadEmotionChat = false
    @Published var lastSenderName = ""
    @Published var showNotification = false
    @Published var pairedWith = ""
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var metadataListener: ListenerRegistration?
    private var pairingListener: ListenerRegistration?
    
    init() {
        startListeningForPairing()
    }
    
    deinit {
        metadataListener?.remove()
        pairingListener?.remove()
    }
    
    // MARK: - 開始監聽配對狀態
    func startListeningForPairing() {
        guard let currentUser = auth.currentUser else { return }
        
        pairingListener = db.collection("users")
            .document(currentUser.uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("監聽配對狀態失敗: \(error)")
                    return
                }
                
                if let data = snapshot?.data(),
                   let pairedWithUID = data["pairedWith"] as? String,
                   !pairedWithUID.isEmpty {
                    
                    if self.pairedWith != pairedWithUID {
                        self.pairedWith = pairedWithUID
                        self.startListeningForEmotionChatNotifications()
                    }
                } else {
                    // 清除狀態
                    self.pairedWith = ""
                    self.hasUnreadEmotionChat = false
                    self.showNotification = false
                    self.metadataListener?.remove()
                }
            }
    }
    
    // MARK: - 監聽冷靜通道通知
    private func startListeningForEmotionChatNotifications() {
        guard let currentUser = auth.currentUser, !pairedWith.isEmpty else { return }
        
        let pairID = createPairID(currentUserUID: currentUser.uid, partnerUID: pairedWith)
        
        metadataListener = db.collection("emotionChats")
            .document(pairID)
            .collection("metadata")
            .document("notification")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("監聽冷靜通道通知失敗: \(error)")
                    return
                }
                
                if let data = snapshot?.data() {
                    let hasUnread = data["hasUnread"] as? Bool ?? false
                    let lastSenderUID = data["lastSenderUID"] as? String ?? ""
                    let lastSenderName = data["lastSenderName"] as? String ?? ""
                    
                    // 只有當自己不是最後發送者時才顯示通知
                    if hasUnread && lastSenderUID != currentUser.uid {
                        self.hasUnreadEmotionChat = true
                        self.lastSenderName = lastSenderName
                        self.showNotification = true
                    } else {
                        self.hasUnreadEmotionChat = false
                        self.showNotification = false
                    }
                }
            }
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
            
            hasUnreadEmotionChat = false
            showNotification = false
        } catch {
            print("標記為已讀失敗: \(error)")
        }
    }
    
    // MARK: - 手動隱藏通知
    func hideNotification() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            showNotification = false
        }
    }
    
    // MARK: - 輔助函數
    private func createPairID(currentUserUID: String, partnerUID: String) -> String {
        let sortedUIDs = [currentUserUID, partnerUID].sorted()
        return "\(sortedUIDs[0])_\(sortedUIDs[1])"
    }
    
    // MARK: - 停止監聽
    func stopListening() {
        metadataListener?.remove()
        pairingListener?.remove()
    }
} 