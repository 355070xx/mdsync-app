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
    @StateObject private var reactionViewModel = ReactionViewModel()
    @State private var showEmojiPicker = false
    @State private var showMoodHistory = false
    @State private var showPairing = false
    
    var body: some View {
        ZStack {
            // 背景色
            Color("Background")
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 頂部導航欄（修正 Safe Area 和佈局）
                VStack(spacing: 0) {
                    // 狀態欄高度佔位
                    Color.clear
                        .frame(height: 0)
                    
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
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
                }
                .background(Color("Background"))
                
                // 主要內容區域（使用 ScrollView 避免內容被截斷）
                ScrollView {
                    VStack(spacing: 32) {
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
                        .padding(.top, 20)
                        
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
                            
                            // 伴侶心情卡片（只在已配對時顯示）
                            if !moodViewModel.pairedWith.isEmpty {
                                VStack(spacing: 16) {
                                    Text("\(moodViewModel.partnerName.isEmpty ? "另一半" : moodViewModel.partnerName)的心情")
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color("TextColor"))
                                    
                                    HStack(spacing: 12) {
                                        Text(moodViewModel.partnerMood.isEmpty ? "❓" : moodViewModel.partnerMood)
                                            .font(.system(size: 32))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(moodViewModel.partnerMood.isEmpty ? "還沒設定心情" : "\(moodViewModel.partnerName.isEmpty ? "另一半" : moodViewModel.partnerName)的心情")
                                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                                .foregroundColor(Color("TextColor"))
                                            
                                            Text(moodViewModel.partnerMood.isEmpty ? "提醒對方更新心情吧" : "更新於 \(formatPartnerLastUpdated())")
                                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                                .foregroundColor(Color("SecondaryColor"))
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "heart.fill")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(Color("PrimaryColor"))
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(Color("PrimaryColor").opacity(0.05))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(Color("PrimaryColor").opacity(0.2), lineWidth: 1)
                                            )
                                    )
                                    
                                    // Emoji 回應區域
                                    VStack(spacing: 12) {
                                        Text("送個回應給 TA 吧 💕")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(Color("SecondaryColor"))
                                        
                                        HStack(spacing: 16) {
                                            let emojis = ["❤️", "🤗", "💨", "👍", "😘", "🥺"]
                                            
                                            ForEach(emojis, id: \.self) { emoji in
                                                Button(action: {
                                                    Task {
                                                        await reactionViewModel.sendReaction(
                                                            emoji: emoji,
                                                            toPartnerUID: moodViewModel.pairedWith,
                                                            partnerName: moodViewModel.partnerName.isEmpty ? "另一半" : moodViewModel.partnerName,
                                                            fromName: authViewModel.userName.isEmpty ? "用戶" : authViewModel.userName
                                                        )
                                                    }
                                                }) {
                                                    Text(emoji)
                                                        .font(.system(size: 24))
                                                        .frame(width: 44, height: 44)
                                                        .background(
                                                            Circle()
                                                                .fill(.white)
                                                                .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                                                        )
                                                        .scaleEffect(reactionViewModel.isLoading ? 0.95 : 1.0)
                                                        .opacity(reactionViewModel.isLoading ? 0.6 : 1.0)
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                                .disabled(reactionViewModel.isLoading)
                                            }
                                        }
                                    }
                                    .padding(.top, 8)
                                }
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
                                        showPairing = true
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
                        .padding(.horizontal, 28)
                        
                        // 底部間距
                        Color.clear
                            .frame(height: 40)
                    }
                }
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
        .sheet(isPresented: $showPairing, onDismiss: {
            // 配對頁面關閉後，重新檢查配對狀態
            moodViewModel.checkPairingStatus()
        }) {
            PairingView()
        }
        .alert("錯誤", isPresented: $moodViewModel.showAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(moodViewModel.errorMessage)
        }
        .alert("錯誤", isPresented: $reactionViewModel.showAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(reactionViewModel.errorMessage)
        }
        .overlay(
            // 成功回饋訊息
            VStack {
                Spacer()
                if reactionViewModel.showFeedback {
                    Text(reactionViewModel.feedbackMessage)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color("PrimaryColor"))
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                        )
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: reactionViewModel.showFeedback)
                }
            }
            .padding(.bottom, 50)
        )
        .overlay(
            // 回應通知 Banner
            VStack {
                if reactionViewModel.showReactionNotification {
                    HStack(spacing: 12) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("PrimaryColor"))
                        
                        Text(reactionViewModel.notificationMessage)
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(Color("TextColor"))
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                reactionViewModel.showReactionNotification = false
                            }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color("SecondaryColor"))
                                .frame(width: 20, height: 20)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color("PrimaryColor").opacity(0.3), lineWidth: 1.5)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 12, x: 0, y: 4)
                    )
                    .padding(.horizontal, 24)
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                Spacer()
            }
            .padding(.top, 60)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: reactionViewModel.showReactionNotification)
        )
        .onChange(of: authViewModel.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                moodViewModel.loadCurrentMood()
                // 開始監聽回應
                reactionViewModel.startListeningForReactions()
            } else {
                // 登出時停止監聽
                reactionViewModel.stopListeningForReactions()
            }
        }
        .onAppear {
            // 如果已經登入，開始監聽回應
            if authViewModel.isLoggedIn {
                reactionViewModel.startListeningForReactions()
            }
        }
        .onDisappear {
            // 離開頁面時停止監聽
            reactionViewModel.stopListeningForReactions()
        }
    }
    
    // MARK: - 格式化伴侶最後更新時間
    private func formatPartnerLastUpdated() -> String {
        guard let lastUpdated = moodViewModel.partnerLastUpdated else {
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