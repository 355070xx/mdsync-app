//
//  PairingViewModel.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class PairingViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showAlert = false
    @Published var showSuccessAlert = false
    @Published var partnerUID = ""
    @Published var currentUserUID = ""
    @Published var pairedWith = ""
    @Published var partnerName = ""
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    
    init() {
        loadCurrentUserInfo()
        checkPairingStatus()
    }
    
    // MARK: - 載入目前用戶資訊
    func loadCurrentUserInfo() {
        guard let currentUser = auth.currentUser else { return }
        currentUserUID = currentUser.uid
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
                    // 載入伴侶名稱
                    await loadPartnerName()
                } else {
                    // 清除伴侶相關資料
                    pairedWith = ""
                    partnerName = ""
                }
            } catch {
                print("檢查配對狀態失敗: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - 載入伴侶名稱
    func loadPartnerName() async {
        guard !pairedWith.isEmpty else { return }
        
        do {
            let document = try await db.collection("users").document(pairedWith).getDocument()
            
            if let data = document.data() {
                partnerName = data["name"] as? String ?? "未知用戶"
            }
        } catch {
            print("載入伴侶名稱失敗: \(error.localizedDescription)")
            partnerName = "未知用戶"
        }
    }
    
    // MARK: - 執行配對
    func performPairing() async {
        guard !partnerUID.isEmpty else {
            showError("請輸入配對碼")
            return
        }
        
        guard let currentUser = auth.currentUser else {
            showError("用戶未登入")
            return
        }
        
        // 檢查是否試圖與自己配對
        if partnerUID == currentUser.uid {
            showError("不能與自己配對")
            return
        }
        
        isLoading = true
        
        do {
            // 1. 檢查對方用戶是否存在
            let partnerDocument = try await db.collection("users").document(partnerUID).getDocument()
            
            guard partnerDocument.exists else {
                showError("找不到此配對碼的用戶，請確認配對碼是否正確")
                isLoading = false
                return
            }
            
            // 2. 檢查對方是否已經與其他人配對
            if let partnerData = partnerDocument.data(),
               let partnerPairedWith = partnerData["pairedWith"] as? String,
               !partnerPairedWith.isEmpty && partnerPairedWith != currentUser.uid {
                showError("此用戶已與其他人配對")
                isLoading = false
                return
            }
            
            // 3. 執行雙向配對 - 使用批次寫入確保原子性
            let batch = db.batch()
            
            // 更新當前用戶的 pairedWith 欄位
            let currentUserRef = db.collection("users").document(currentUser.uid)
            batch.updateData(["pairedWith": partnerUID], forDocument: currentUserRef)
            
            // 更新對方用戶的 pairedWith 欄位
            let partnerUserRef = db.collection("users").document(partnerUID)
            batch.updateData(["pairedWith": currentUser.uid], forDocument: partnerUserRef)
            
            // 執行批次寫入
            try await batch.commit()
            
            // 更新本地狀態
            pairedWith = partnerUID
            
            // 載入伴侶名稱
            await loadPartnerName()
            
            // 顯示成功訊息
            showSuccessAlert = true
            
        } catch {
            showError("配對失敗：\(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - 解除配對
    func unpair() async {
        guard let currentUser = auth.currentUser else {
            showError("用戶未登入")
            return
        }
        
        guard !pairedWith.isEmpty else {
            showError("目前沒有配對")
            return
        }
        
        isLoading = true
        
        do {
            // 使用批次寫入確保原子性
            let batch = db.batch()
            
            // 清除當前用戶的 pairedWith 欄位
            let currentUserRef = db.collection("users").document(currentUser.uid)
            batch.updateData(["pairedWith": FieldValue.delete()], forDocument: currentUserRef)
            
            // 清除對方用戶的 pairedWith 欄位
            let partnerUserRef = db.collection("users").document(pairedWith)
            batch.updateData(["pairedWith": FieldValue.delete()], forDocument: partnerUserRef)
            
            // 執行批次寫入
            try await batch.commit()
            
            // 更新本地狀態
            pairedWith = ""
            partnerUID = ""
            partnerName = ""
            
            showSuccessAlert = true
            
        } catch {
            showError("解除配對失敗：\(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - 複製 UID 到剪貼簿
    func copyUIDToClipboard() {
        UIPasteboard.general.string = currentUserUID
    }
    
    // MARK: - 錯誤處理
    private func showError(_ message: String) {
        errorMessage = message
        showAlert = true
    }
    
    // MARK: - 驗證 UID 格式
    func isValidUID(_ uid: String) -> Bool {
        // Firebase UID 通常是 28 個字符的字母數字字符串
        return uid.count == 28 && uid.allSatisfy { $0.isLetter || $0.isNumber }
    }
} 