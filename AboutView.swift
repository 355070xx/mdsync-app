//
//  AboutView.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI

struct AboutView: View {
    private let appVersion = "1.0.0"
    private let buildNumber = "1"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 40) {
                        // App Logo 和標題
                        VStack(spacing: 24) {
                            // Logo 動畫
                            Image(systemName: "heart.fill")
                                .font(.system(size: 100))
                                .foregroundColor(Color("PrimaryColor"))
                                .shadow(color: Color("PrimaryColor").opacity(0.3), radius: 12, x: 0, y: 6)
                            
                            VStack(spacing: 12) {
                                Text("MoodSync")
                                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color("TextColor"))
                                
                                Text("💕")
                                    .font(.system(size: 40))
                                
                                Text("與你最愛的人，同步每個心情時刻")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("SecondaryColor"))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                            }
                        }
                        .padding(.top, 20)
                        
                        // App 介紹
                        AboutSection(title: "關於 MoodSync") {
                            VStack(alignment: .leading, spacing: 16) {
                                AboutTextRow(
                                    icon: "heart.circle",
                                    text: "MoodSync 是一個專為情侶設計的心情同步應用程式"
                                )
                                
                                AboutTextRow(
                                    icon: "person.2.circle",
                                    text: "透過簡單的 Emoji 表達，讓你和另一半隨時了解彼此的心情狀態"
                                )
                                
                                AboutTextRow(
                                    icon: "chart.line.uptrend.xyaxis.circle",
                                    text: "記錄每日心情變化，建立專屬於你們的情感檔案"
                                )
                                
                                AboutTextRow(
                                    icon: "bell.circle",
                                    text: "即時通知和回應功能，讓關懷無時無刻不在身邊"
                                )
                            }
                        }
                        
                        // 功能特色
                        AboutSection(title: "主要功能") {
                            VStack(spacing: 16) {
                                FeatureRow(
                                    icon: "face.smiling",
                                    title: "心情記錄",
                                    description: "用 Emoji 輕鬆記錄每日心情"
                                )
                                
                                FeatureRow(
                                    icon: "link",
                                    title: "情侶配對",
                                    description: "與另一半建立心情同步連結"
                                )
                                
                                FeatureRow(
                                    icon: "clock.arrow.circlepath",
                                    title: "歷史記錄",
                                    description: "回顧過往的美好心情時光"
                                )
                                
                                FeatureRow(
                                    icon: "heart.text.square",
                                    title: "互動回應",
                                    description: "送出愛心回應關懷對方"
                                )
                            }
                        }
                        
                        // 版本資訊
                        AboutSection(title: "版本資訊") {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("版本號")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color("TextColor"))
                                    
                                    Spacer()
                                    
                                    Text("v\(appVersion)")
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color("PrimaryColor"))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                
                                Divider()
                                    .padding(.horizontal, 20)
                                
                                HStack {
                                    Text("建置版本")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(Color("TextColor"))
                                    
                                    Spacer()
                                    
                                    Text(buildNumber)
                                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        .foregroundColor(Color("SecondaryColor"))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            }
                        }
                        
                        // 聯絡資訊
                        AboutSection(title: "聯絡我們") {
                            VStack(spacing: 16) {
                                AboutActionRow(
                                    icon: "envelope",
                                    title: "意見回饋",
                                    subtitle: "告訴我們您的想法"
                                ) {
                                    // TODO: 開啟郵件應用
                                }
                                
                                AboutActionRow(
                                    icon: "star",
                                    title: "評分評論",
                                    subtitle: "在 App Store 給我們評分"
                                ) {
                                    // TODO: 開啟 App Store 評分
                                }
                                
                                AboutActionRow(
                                    icon: "questionmark.circle",
                                    title: "使用說明",
                                    subtitle: "了解如何使用 MoodSync"
                                ) {
                                    // TODO: 開啟使用說明
                                }
                            }
                        }
                        
                        // 法律資訊
                        VStack(spacing: 12) {
                            Text("© 2025 MoodSync. All rights reserved.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color("SecondaryColor"))
                            
                            HStack(spacing: 20) {
                                Button("隱私政策") {
                                    // TODO: 開啟隱私政策
                                }
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color("PrimaryColor"))
                                
                                Button("服務條款") {
                                    // TODO: 開啟服務條款
                                }
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(Color("PrimaryColor"))
                            }
                        }
                        .padding(.top, 20)
                        
                        // 底部間距
                        Color.clear
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 28)
                }
            }
            .navigationTitle("關於")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - About 區塊
struct AboutSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
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

// MARK: - 文字說明列
struct AboutTextRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color("PrimaryColor"))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color("PrimaryColor").opacity(0.1))
                )
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color("TextColor"))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - 功能特色列
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color("PrimaryColor"))
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("PrimaryColor").opacity(0.1))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("TextColor"))
                
                Text(description)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SecondaryColor"))
                    .lineLimit(nil)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - 操作按鈕列
struct AboutActionRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
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
    AboutView()
} 