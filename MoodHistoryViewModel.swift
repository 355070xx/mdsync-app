//
//  MoodHistoryViewModel.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - Mood History Data Model
struct MoodHistoryItem: Identifiable {
    let id: String
    let mood: String
    let timestamp: Date
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.mood = data["mood"] as? String ?? ""
        
        if let timestamp = data["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else {
            self.timestamp = Date()
        }
    }
}

@MainActor
class MoodHistoryViewModel: ObservableObject {
    @Published var moodHistory: [MoodHistoryItem] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showAlert = false
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        loadMoodHistory()
    }
    
    // MARK: - 載入心情歷史紀錄
    func loadMoodHistory() {
        guard let currentUser = auth.currentUser else { return }
        
        isLoading = true
        
        Task {
            do {
                let snapshot = try await db.collection("users")
                    .document(currentUser.uid)
                    .collection("moodHistory")
                    .order(by: "timestamp", descending: true) // 時間由新至舊排序
                    .getDocuments()
                
                var items: [MoodHistoryItem] = []
                
                for document in snapshot.documents {
                    let item = MoodHistoryItem(id: document.documentID, data: document.data())
                    items.append(item)
                }
                
                moodHistory = items
                
            } catch {
                handleError(error)
            }
            
            isLoading = false
        }
    }
    
    // MARK: - 重新載入資料
    func refreshMoodHistory() {
        loadMoodHistory()
    }
    
    // MARK: - 格式化時間顯示
    func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            formatter.dateFormat = "今天 HH:mm"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
            formatter.dateFormat = "昨天 HH:mm"
        } else if calendar.component(.year, from: date) == calendar.component(.year, from: now) {
            formatter.dateFormat = "MM/dd HH:mm"
        } else {
            formatter.dateFormat = "yyyy/MM/dd HH:mm"
        }
        
        return formatter.string(from: date)
    }
    
    // MARK: - 錯誤處理
    private func handleError(_ error: Error) {
        errorMessage = "載入心情歷史時發生錯誤：\(error.localizedDescription)"
        showAlert = true
        print("MoodHistoryViewModel Error: \(error)")
    }
} 