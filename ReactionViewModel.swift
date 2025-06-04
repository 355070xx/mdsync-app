//
//  ReactionViewModel.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class ReactionViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showAlert = false
    @Published var feedbackMessage = ""
    @Published var showFeedback = false
    
    // 新增：最新回應相關屬性
    @Published var latestReaction: Reaction?
    @Published var showReactionNotification = false
    @Published var notificationMessage = ""
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var reactionListener: ListenerRegistration?
    
    // 用於追蹤已顯示過的回應，避免重複提示
    private var lastNotifiedReactionId: String?
    
    // MARK: - 發送 emoji 回應
    func sendReaction(emoji: String, toPartnerUID: String, partnerName: String, fromName: String) async {
        guard let currentUser = auth.currentUser else {
            handleError(message: "請先登入")
            return
        }
        
        // 防止重複點擊
        guard !isLoading else { return }
        
        isLoading = true
        
        do {
            let reactionData: [String: Any] = [
                "fromUID": currentUser.uid,
                "fromName": fromName,
                "emoji": emoji,
                "timestamp": Timestamp()
            ]
            
            // 寫入到伴侶的 reactions 子集合
            try await db.collection("users")
                .document(toPartnerUID)
                .collection("reactions")
                .addDocument(data: reactionData)
            
            // 顯示成功回饋訊息
            feedbackMessage = "已送出 \(emoji) 給 \(partnerName)"
            showFeedback = true
            
            // 3秒後自動隱藏回饋訊息
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.showFeedback = false
            }
            
            print("成功發送 emoji 回應: \(emoji) 給 \(partnerName)")
            
        } catch {
            handleError(message: "發送回應失敗：\(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - 開始監聽回應
    func startListeningForReactions() {
        guard let currentUser = auth.currentUser else { return }
        
        // 停止之前的監聽器
        stopListeningForReactions()
        
        reactionListener = db.collection("users")
            .document(currentUser.uid)
            .collection("reactions")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("監聽回應錯誤: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("沒有回應記錄")
                    return
                }
                
                do {
                    let reaction = try documents[0].data(as: Reaction.self)
                    self.latestReaction = reaction
                    
                    // 檢查是否需要顯示通知（避免重複提示）
                    if let reactionId = reaction.id,
                       reactionId != self.lastNotifiedReactionId {
                        self.showReactionNotificationBanner(for: reaction)
                        self.lastNotifiedReactionId = reactionId
                    }
                    
                } catch {
                    print("解析回應資料錯誤: \(error.localizedDescription)")
                }
            }
    }
    
    // MARK: - 停止監聽回應
    func stopListeningForReactions() {
        reactionListener?.remove()
        reactionListener = nil
    }
    
    // MARK: - 顯示回應通知
    private func showReactionNotificationBanner(for reaction: Reaction) {
        notificationMessage = "\(reaction.fromName) 給了你一個 \(reaction.emoji) 回應 💬"
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            showReactionNotification = true
        }
        
        // 3秒後自動隱藏通知
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                self.showReactionNotification = false
            }
        }
    }
    
    // MARK: - 錯誤處理
    private func handleError(message: String) {
        errorMessage = message
        showAlert = true
        print("ReactionViewModel Error: \(message)")
    }
} 