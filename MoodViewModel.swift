//
//  MoodViewModel.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class MoodViewModel: ObservableObject {
    @Published var currentMood: String = ""
    @Published var lastUpdated: Date?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showAlert = false
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        loadCurrentMood()
    }
    
    // MARK: - 載入目前心情
    func loadCurrentMood() {
        guard let currentUser = auth.currentUser else { return }
        
        isLoading = true
        
        Task {
            do {
                let document = try await db.collection("users").document(currentUser.uid).getDocument()
                
                if let data = document.data() {
                    currentMood = data["mood"] as? String ?? ""
                    
                    if let timestamp = data["lastUpdated"] as? Timestamp {
                        lastUpdated = timestamp.dateValue()
                    }
                }
            } catch {
                handleError(error)
            }
            
            isLoading = false
        }
    }
    
    // MARK: - 更新心情
    func updateMood(_ emoji: String) async {
        guard let currentUser = auth.currentUser else { return }
        
        isLoading = true
        
        do {
            let updateData: [String: Any] = [
                "mood": emoji,
                "lastUpdated": Timestamp()
            ]
            
            try await db.collection("users").document(currentUser.uid).updateData(updateData)
            
            // 更新本地狀態
            currentMood = emoji
            lastUpdated = Date()
            
        } catch {
            // 如果文檔不存在，嘗試建立
            do {
                let userData: [String: Any] = [
                    "mood": emoji,
                    "lastUpdated": Timestamp()
                ]
                
                try await db.collection("users").document(currentUser.uid).setData(userData, merge: true)
                
                currentMood = emoji
                lastUpdated = Date()
                
            } catch {
                handleError(error)
            }
        }
        
        isLoading = false
    }
    
    // MARK: - 錯誤處理
    private func handleError(_ error: Error) {
        errorMessage = "更新心情時發生錯誤：\(error.localizedDescription)"
        showAlert = true
        print("MoodViewModel Error: \(error)")
    }
    
    // MARK: - 格式化時間
    func formatLastUpdated() -> String {
        guard let lastUpdated = lastUpdated else {
            return "尚未設定"
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(lastUpdated, inSameDayAs: now) {
            formatter.dateFormat = "今天 HH:mm"
        } else if calendar.isDate(lastUpdated, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
            formatter.dateFormat = "昨天 HH:mm"
        } else {
            formatter.dateFormat = "MM/dd HH:mm"
        }
        
        return formatter.string(from: lastUpdated)
    }
} 