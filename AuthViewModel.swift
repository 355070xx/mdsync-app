//
//  AuthViewModel.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var showAlert = false
    @AppStorage("isLoggedIn") var isLoggedIn = false
    @AppStorage("userEmail") var userEmail = ""
    @AppStorage("userName") var userName = ""
    
    private let auth = Auth.auth()
    private let db = Firestore.firestore()
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        setupAuthStateListener()
        checkAuthState()
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
    
    // MARK: - 設置認證狀態監聽器
    private func setupAuthStateListener() {
        authStateListener = auth.addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                if let user = user {
                    // 用戶已登入
                    self?.isLoggedIn = true
                    self?.userEmail = user.email ?? ""
                    Task {
                        await self?.loadUserProfile()
                    }
                } else {
                    // 用戶已登出
                    self?.clearAuthState()
                }
            }
        }
    }
    
    // MARK: - 檢查登入狀態
    func checkAuthState() {
        // 清理過期的本地狀態
        if let currentUser = auth.currentUser {
            // 重新驗證當前用戶的認證狀態
            currentUser.reload { [weak self] error in
                DispatchQueue.main.async {
                    if let error = error {
                        // 認證已過期，清理狀態
                        print("認證已過期: \(error.localizedDescription)")
                        self?.clearAuthState()
                    } else {
                        // 認證有效，更新狀態
                        self?.isLoggedIn = true
                        self?.userEmail = currentUser.email ?? ""
                        Task {
                            await self?.loadUserProfile()
                        }
                    }
                }
            }
        } else {
            clearAuthState()
        }
    }
    
    // MARK: - 註冊功能
    func signUp(name: String, email: String, password: String) async {
        isLoading = true
        
        do {
            // 建立 Firebase Authentication 帳號
            let result = try await auth.createUser(withEmail: email, password: password)
            let uid = result.user.uid
            
            // 更新使用者顯示名稱
            let changeRequest = result.user.createProfileChangeRequest()
            changeRequest.displayName = name
            try await changeRequest.commitChanges()
            
            // 將使用者資料存到 Firestore
            try await saveUserProfile(uid: uid, name: name, email: email)
            
            // 更新本地狀態
            userName = name
            userEmail = email
            isLoggedIn = true
            
        } catch {
            handleAuthError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 登入功能
    func signIn(email: String, password: String) async {
        isLoading = true
        
        do {
            // 確保先清理之前的認證狀態
            if auth.currentUser != nil {
                try auth.signOut()
            }
            
            // 執行登入
            let result = try await auth.signIn(withEmail: email, password: password)
            
            // 確認用戶認證成功
            guard let user = result.user.email else {
                throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "認證失敗"])
            }
            
            // 載入使用者資料
            await loadUserProfile()
            
            userEmail = email
            isLoggedIn = true
            
        } catch {
            clearAuthState()
            handleAuthError(error)
        }
        
        isLoading = false
    }
    
    // MARK: - 登出功能
    func signOut() {
        do {
            try auth.signOut()
            clearAuthState()
        } catch {
            handleAuthError(error)
            // 即使登出失敗，也要清理本地狀態
            clearAuthState()
        }
    }
    
    // MARK: - 清理認證狀態
    private func clearAuthState() {
        isLoggedIn = false
        userEmail = ""
        userName = ""
        errorMessage = ""
        showAlert = false
    }
    
    // MARK: - 儲存使用者資料到 Firestore
    private func saveUserProfile(uid: String, name: String, email: String) async throws {
        let userData: [String: Any] = [
            "name": name,
            "email": email,
            "createdAt": Timestamp(),
            "lastLoginAt": Timestamp()
        ]
        
        try await db.collection("users").document(uid).setData(userData)
    }
    
    // MARK: - 從 Firestore 載入使用者資料
    private func loadUserProfile() async {
        guard let currentUser = auth.currentUser else { return }
        
        do {
            let document = try await db.collection("users").document(currentUser.uid).getDocument()
            
            if let data = document.data() {
                userName = data["name"] as? String ?? currentUser.displayName ?? ""
            }
        } catch {
            print("載入使用者資料失敗: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 錯誤處理
    private func handleAuthError(_ error: Error) {
        if let authError = error as NSError? {
            switch authError.code {
            case AuthErrorCode.emailAlreadyInUse.rawValue:
                errorMessage = "此帳號已註冊，請嘗試登入或使用其他電子郵件"
            case AuthErrorCode.weakPassword.rawValue:
                errorMessage = "密碼強度不足，請選擇更安全的密碼"
            case AuthErrorCode.invalidEmail.rawValue:
                errorMessage = "電子郵件格式不正確"
            case AuthErrorCode.userNotFound.rawValue:
                errorMessage = "找不到此帳號，請檢查電子郵件或註冊新帳號"
            case AuthErrorCode.wrongPassword.rawValue:
                errorMessage = "密碼錯誤，請重新輸入"
            case AuthErrorCode.userDisabled.rawValue:
                errorMessage = "此帳號已被停用，請聯繫客服"
            case AuthErrorCode.tooManyRequests.rawValue:
                errorMessage = "嘗試次數過多，請稍後再試"
            case AuthErrorCode.networkError.rawValue:
                errorMessage = "網絡連接異常，請檢查網絡設置"
            case AuthErrorCode.invalidCredential.rawValue:
                errorMessage = "認證憑證無效，請重新登入"
            case AuthErrorCode.credentialAlreadyInUse.rawValue:
                errorMessage = "此認證憑證已被其他帳號使用"
            case AuthErrorCode.sessionExpired.rawValue:
                errorMessage = "登入會話已過期，請重新登入"
            default:
                // 檢查是否為認證憑證格式錯誤
                if error.localizedDescription.contains("malformed") || error.localizedDescription.contains("expired") {
                    errorMessage = "認證憑證已過期，請重新登入"
                } else {
                    errorMessage = "登入發生錯誤：\(error.localizedDescription)"
                }
            }
        } else {
            errorMessage = "未知錯誤：\(error.localizedDescription)"
        }
        
        showAlert = true
    }
    
    // MARK: - 驗證函數
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
} 