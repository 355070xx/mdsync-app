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
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
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
    
    // MARK: - 錯誤處理
    private func handleError(message: String) {
        errorMessage = message
        showAlert = true
        print("ReactionViewModel Error: \(message)")
    }
} 