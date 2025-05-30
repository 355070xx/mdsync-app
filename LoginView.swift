//
//  LoginView.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            // 療癒背景色 #FFF9F3
            Color("Background")
                .ignoresSafeArea()
            
            // 當使用者已登入時，自動跳轉到主畫面
            if authViewModel.isLoggedIn {
                MainView()
                    .transition(.opacity)
            } else {
                VStack(spacing: 32) {
                    // 頂部導航
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(Color("PrimaryColor"))
                                .frame(width: 44, height: 44)
                                .background(
                                    Circle()
                                        .fill(.white)
                                        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                                )
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // 主要內容區域
                    VStack(spacing: 40) {
                        // Logo 與標題
                        VStack(spacing: 20) {
                            // Logo
                            Image(systemName: "heart.fill")
                                .font(.system(size: 50))
                                .foregroundColor(Color("PrimaryColor"))
                                .shadow(color: Color("PrimaryColor").opacity(0.3), radius: 6, x: 0, y: 3)
                            
                            // 歡迎標題
                            VStack(spacing: 8) {
                                Text("歡迎回來")
                                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color("TextColor"))
                                
                                Text("💕")
                                    .font(.system(size: 24))
                            }
                        }
                        
                        // 輸入欄位區域
                        VStack(spacing: 20) {
                            // Email 輸入框
                            LoginCustomTextField(
                                placeholder: "電子郵件",
                                text: $email,
                                icon: "envelope"
                            )
                            
                            // 密碼輸入框
                            LoginCustomSecureField(
                                placeholder: "密碼",
                                text: $password,
                                icon: "lock"
                            )
                        }
                        
                        // 登入按鈕
                        Button(action: {
                            Task {
                                await handleLogin()
                            }
                        }) {
                            HStack(spacing: 8) {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Text("登入")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 16))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(authViewModel.isLoading ? Color("PrimaryColor").opacity(0.7) : Color("PrimaryColor"))
                                    .shadow(color: Color("PrimaryColor").opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .disabled(authViewModel.isLoading)
                        .buttonStyle(GentlePressStyle())
                        
                        // 註冊提示 - 改為 NavigationLink
                        NavigationLink(destination: SignUpView()) {
                            HStack(spacing: 6) {
                                Text("未有帳號？")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("SecondaryColor"))
                                Text("註冊")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color("PrimaryColor"))
                            }
                        }
                        .buttonStyle(GentlePressStyle())
                    }
                    .padding(.horizontal, 28)
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .alert("提示", isPresented: $authViewModel.showAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(authViewModel.errorMessage)
        }
        .animation(.easeInOut(duration: 0.3), value: authViewModel.isLoggedIn)
    }
    
    // MARK: - 登入處理函數
    private func handleLogin() async {
        // 驗證輸入
        guard !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            authViewModel.errorMessage = "請輸入電子郵件"
            authViewModel.showAlert = true
            return
        }
        
        guard authViewModel.isValidEmail(email) else {
            authViewModel.errorMessage = "請輸入有效的電子郵件地址"
            authViewModel.showAlert = true
            return
        }
        
        guard !password.isEmpty else {
            authViewModel.errorMessage = "請輸入密碼"
            authViewModel.showAlert = true
            return
        }
        
        // 使用 AuthViewModel 進行登入
        await authViewModel.signIn(email: email, password: password)
        
        // 如果登入成功，清空表單
        if authViewModel.isLoggedIn {
            email = ""
            password = ""
        }
    }
}

// MARK: - Custom TextField Components
struct LoginCustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("SecondaryColor"))
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color("TextColor"))
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

struct LoginCustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    @State private var isSecure = true
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("SecondaryColor"))
                .frame(width: 20)
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color("TextColor"))
            } else {
                TextField(placeholder, text: $text)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color("TextColor"))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            Button(action: {
                isSecure.toggle()
            }) {
                Image(systemName: isSecure ? "eye" : "eye.slash")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color("SecondaryColor"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Preview
#Preview("LoginView") {
    NavigationStack {
        LoginView()
            .environmentObject(AuthViewModel())
    }
} 