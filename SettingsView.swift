//
//  SettingsView.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var showDeleteAccountAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // 用戶資訊區域
                        VStack(spacing: 20) {
                            // 頭像區域
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(Color("PrimaryColor"))
                                .shadow(color: Color("PrimaryColor").opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            VStack(spacing: 8) {
                                Text(authViewModel.userName.isEmpty ? "使用者" : authViewModel.userName)
                                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color("TextColor"))
                                
                                Text(authViewModel.userEmail ?? "未設定信箱")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("SecondaryColor"))
                            }
                        }
                        .padding(.top, 20)
                        
                        // 設定選項
                        VStack(spacing: 24) {
                            // 通知設定
                            SettingsSection(title: "通知設定") {
                                VStack(spacing: 16) {
                                    SettingsToggleRow(
                                        icon: "bell",
                                        title: "推送通知",
                                        subtitle: "接收心情更新提醒",
                                        isOn: $notificationsEnabled
                                    )
                                    
                                    SettingsToggleRow(
                                        icon: "speaker.wave.2",
                                        title: "音效",
                                        subtitle: "播放通知音效",
                                        isOn: $soundEnabled
                                    )
                                }
                            }
                            
                            // 帳號設定
                            SettingsSection(title: "帳號設定") {
                                VStack(spacing: 16) {
                                    SettingsActionRow(
                                        icon: "person.crop.circle",
                                        title: "編輯個人資料",
                                        subtitle: "修改暱稱和個人資訊"
                                    ) {
                                        // TODO: 開啟編輯個人資料
                                    }
                                    
                                    SettingsActionRow(
                                        icon: "key",
                                        title: "變更密碼",
                                        subtitle: "更新您的登入密碼"
                                    ) {
                                        // TODO: 開啟變更密碼
                                    }
                                }
                            }
                            
                            // 資料管理
                            SettingsSection(title: "資料管理") {
                                VStack(spacing: 16) {
                                    SettingsActionRow(
                                        icon: "icloud.and.arrow.down",
                                        title: "匯出資料",
                                        subtitle: "下載您的心情記錄"
                                    ) {
                                        // TODO: 實現資料匯出
                                    }
                                    
                                    SettingsActionRow(
                                        icon: "trash",
                                        title: "刪除帳號",
                                        subtitle: "永久刪除您的帳號和資料",
                                        isDestructive: true
                                    ) {
                                        showDeleteAccountAlert = true
                                    }
                                }
                            }
                            
                            // 登出按鈕
                            Button(action: {
                                authViewModel.signOut()
                            }) {
                                HStack(spacing: 12) {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                        .font(.system(size: 18, weight: .medium))
                                    
                                    Text("登出")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 54)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(Color("AccentColor"))
                                        .shadow(color: Color("AccentColor").opacity(0.3), radius: 8, x: 0, y: 4)
                                )
                            }
                            .buttonStyle(GentlePressStyle())
                        }
                        .padding(.horizontal, 28)
                        
                        // 底部間距
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
        }
        .alert("刪除帳號", isPresented: $showDeleteAccountAlert) {
            Button("取消", role: .cancel) { }
            Button("刪除", role: .destructive) {
                // TODO: 實現刪除帳號功能
            }
        } message: {
            Text("此操作無法復原，您的所有資料將被永久刪除。")
        }
    }
}

// MARK: - 設定區塊
struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color("TextColor"))
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
        }
    }
}

// MARK: - 切換開關列
struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("PrimaryColor"))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color("PrimaryColor").opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("TextColor"))
                
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SecondaryColor"))
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(Color("PrimaryColor"))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - 操作按鈕列
struct SettingsActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isDestructive ? .red : Color("PrimaryColor"))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill((isDestructive ? Color.red : Color("PrimaryColor")).opacity(0.1))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(isDestructive ? .red : Color("TextColor"))
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryColor"))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("SecondaryColor"))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview
#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
} 