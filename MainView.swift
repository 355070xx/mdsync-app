//
//  MainView.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var moodViewModel = MoodViewModel()
    @State private var showEmojiPicker = false
    @State private var showMoodHistory = false
    
    var body: some View {
        ZStack {
            // 背景色
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // 頂部導航欄
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("歡迎回來")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color("SecondaryColor"))
                        
                        Text(authViewModel.userName.isEmpty ? "使用者" : authViewModel.userName)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("TextColor"))
                    }
                    
                    Spacer()
                    
                    // 設定按鈕
                    Button(action: {
                        authViewModel.signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color("PrimaryColor"))
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                
                Spacer()
                
                // 主要內容區域
                VStack(spacing: 40) {
                    // Logo 與歡迎信息
                    VStack(spacing: 20) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("PrimaryColor"))
                            .shadow(color: Color("PrimaryColor").opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        VStack(spacing: 8) {
                            Text("MoodSync")
                                .font(.system(size: 28, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("TextColor"))
                            
                            Text("💕")
                                .font(.system(size: 32))
                        }
                    }
                    
                    // 狀態卡片
                    VStack(spacing: 24) {
                        // 今日心情卡片
                        VStack(spacing: 16) {
                            Text("今日心情")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                                .foregroundColor(Color("TextColor"))
                            
                            Button(action: {
                                showEmojiPicker = true
                            }) {
                                HStack(spacing: 12) {
                                    Text(moodViewModel.currentMood.isEmpty ? "😊" : moodViewModel.currentMood)
                                        .font(.system(size: 32))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(moodViewModel.currentMood.isEmpty ? "選擇今日心情" : "目前心情")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundColor(Color("TextColor"))
                                        
                                        Text(moodViewModel.currentMood.isEmpty ? "點擊設定你的心情" : "更新於 \(moodViewModel.formatLastUpdated())")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color("SecondaryColor"))
                                    }
                                    
                                    Spacer()
                                    
                                    if moodViewModel.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(Color("SecondaryColor"))
                                    } else {
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(Color("SecondaryColor"))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.white)
                                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                                )
                            }
                            .buttonStyle(GentlePressStyle())
                            .disabled(moodViewModel.isLoading)
                        }
                        
                        // 功能按鈕組
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                // 心情歷史
                                MainFeatureButton(
                                    icon: "clock",
                                    title: "歷史",
                                    subtitle: "查看心情記錄"
                                ) {
                                    showMoodHistory = true
                                }
                                
                                // 配對設定
                                MainFeatureButton(
                                    icon: "person.2",
                                    title: "配對",
                                    subtitle: "同步心情"
                                ) {
                                    // TODO: 開啟配對設定
                                }
                            }
                            
                            HStack(spacing: 16) {
                                // 設定
                                MainFeatureButton(
                                    icon: "gearshape",
                                    title: "設定",
                                    subtitle: "個人化設置"
                                ) {
                                    // TODO: 開啟設定頁面
                                }
                                
                                // 關於
                                MainFeatureButton(
                                    icon: "heart.text.square",
                                    title: "關於",
                                    subtitle: "了解 MoodSync"
                                ) {
                                    // TODO: 開啟關於頁面
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 28)
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showEmojiPicker) {
            EmojiPickerView()
                .environmentObject(moodViewModel)
        }
        .sheet(isPresented: $showMoodHistory) {
            MoodHistoryView()
        }
        .alert("錯誤", isPresented: $moodViewModel.showAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(moodViewModel.errorMessage)
        }
        .onChange(of: authViewModel.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                moodViewModel.loadCurrentMood()
            }
        }
    }
}

// MARK: - 功能按鈕組件
struct MainFeatureButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color("PrimaryColor"))
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color("PrimaryColor").opacity(0.1))
                    )
                
                VStack(spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("TextColor"))
                    
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryColor"))
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            )
        }
        .buttonStyle(GentlePressStyle())
    }
}

// MARK: - Preview
#Preview("MainView") {
    MainView()
        .environmentObject(AuthViewModel())
} 