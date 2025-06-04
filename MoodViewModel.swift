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
    @Published var partnerMood: String = ""
    @Published var partnerLastUpdated: Date?
    @Published var pairedWith: String = ""
    @Published var partnerName: String = ""
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        loadCurrentMood()
        checkPairingStatus()
    }
    
    // MARK: - 載入目前心情
    func loadCurrentMood() {
        guard let currentUser = auth.currentUser else { 
            // 清理狀態如果用戶未登入
            currentMood = ""
            lastUpdated = nil
            pairedWith = ""
            partnerMood = ""
            partnerLastUpdated = nil
            partnerName = ""
            return 
        }
        
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
            
            // 同時將心情儲存到 moodHistory 子集合
            await saveMoodToHistory(mood: emoji)
            
            // 如果有配對伴侶，重新載入伴侶心情
            if !pairedWith.isEmpty {
                await loadPartnerMood()
            }
            
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
                
                // 同時將心情儲存到 moodHistory 子集合
                await saveMoodToHistory(mood: emoji)
                
                // 如果有配對伴侶，重新載入伴侶心情
                if !pairedWith.isEmpty {
                    await loadPartnerMood()
                }
                
            } catch {
                handleError(error)
            }
        }
        
        isLoading = false
    }
    
    // MARK: - 儲存心情到歷史紀錄
    func saveMoodToHistory(mood: String) async {
        guard let currentUser = auth.currentUser else { return }
        
        do {
            let moodHistoryData: [String: Any] = [
                "mood": mood,
                "timestamp": Timestamp()
            ]
            
            // 使用自動 ID 新增文檔到 moodHistory 子集合
            try await db.collection("users")
                .document(currentUser.uid)
                .collection("moodHistory")
                .addDocument(data: moodHistoryData)
            
            print("成功儲存心情到歷史紀錄: \(mood)")
            
        } catch {
            print("儲存心情歷史紀錄時發生錯誤: \(error.localizedDescription)")
            // 這裡不顯示錯誤alert，因為主要功能（更新current mood）已經成功
            // 只在console中記錄錯誤即可
        }
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
    
    // MARK: - 檢查配對狀態
    func checkPairingStatus() {
        guard let currentUser = auth.currentUser else { return }
        
        Task {
            do {
                let document = try await db.collection("users").document(currentUser.uid).getDocument()
                
                if let data = document.data(),
                   let pairedWithUID = data["pairedWith"] as? String,
                   !pairedWithUID.isEmpty {
                    pairedWith = pairedWithUID
                    // 載入伴侶心情和名稱
                    await loadPartnerMood()
                } else {
                    // 清除伴侶相關資料
                    pairedWith = ""
                    partnerMood = ""
                    partnerLastUpdated = nil
                    partnerName = ""
                }
            } catch {
                print("檢查配對狀態失敗: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 載入伴侶心情
    func loadPartnerMood() async {
        guard !pairedWith.isEmpty else { return }
        
        do {
            let document = try await db.collection("users").document(pairedWith).getDocument()
            
            if let data = document.data() {
                partnerMood = data["mood"] as? String ?? ""
                partnerName = data["name"] as? String ?? "未知用戶"
                
                if let timestamp = data["lastUpdated"] as? Timestamp {
                    partnerLastUpdated = timestamp.dateValue()
                }
            }
        } catch {
            print("載入伴侶心情失敗: \(error.localizedDescription)")
        }
    }
} 