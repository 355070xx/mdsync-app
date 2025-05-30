//
//  WelcomeView.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI

struct WelcomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                // 溫柔漸層背景
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color("Background"), location: 0.0),
                        .init(color: Color("Background").opacity(0.8), location: 0.3),
                        .init(color: Color("SecondaryColor").opacity(0.2), location: 1.0)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    // Logo 區域 - 更溫柔的設計
                    VStack(spacing: 20) {
                        // Logo Icon - 使用溫柔的陰影
                        Image(systemName: "heart.fill")
                            .font(.system(size: 65))
                            .foregroundColor(Color("PrimaryColor"))
                            .shadow(color: Color("PrimaryColor").opacity(0.3), radius: 8, x: 0, y: 4)
                        
                        // App 標題 - 更柔和的字體
                        Text("MoodSync")
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("TextColor"))
                            .shadow(color: Color("PrimaryColor").opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    
                    // 插圖區域 - 更療癒的雙心設計
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            // 第一個心 - 主色
                            Image(systemName: "heart.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Color("PrimaryColor"))
                                .opacity(0.9)
                            
                            // 連接元素
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(Color("PrimaryColor").opacity(0.4))
                                    .frame(width: 4, height: 4)
                                Circle()
                                    .fill(Color("AccentColor").opacity(0.5))
                                    .frame(width: 4, height: 4)
                                Circle()
                                    .fill(Color("PrimaryColor").opacity(0.4))
                                    .frame(width: 4, height: 4)
                            }
                            
                            // 第二個心 - 強調色
                            Image(systemName: "heart.fill")
                                .font(.system(size: 36))
                                .foregroundColor(Color("AccentColor"))
                                .opacity(0.9)
                        }
                        .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
                    }
                    
                    // 文字說明 - 更溫暖的設計
                    VStack(spacing: 12) {
                        Text("與你最愛的人，")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(Color("TextColor"))
                        
                        Text("同步每個心情時刻")
                            .font(.system(size: 22, weight: .medium, design: .rounded))
                            .foregroundColor(Color("TextColor"))
                        
                        // 添加小 emoji 裝飾
                        Text("💕")
                            .font(.system(size: 24))
                            .padding(.top, 8)
                    }
                    .multilineTextAlignment(.center)
                    .opacity(0.85)
                    
                    Spacer()
                    
                    // 按鈕組 - 更溫柔的設計
                    VStack(spacing: 18) {
                        // 主要按鈕 - 使用 NavigationLink
                        NavigationLink(destination: SignUpView()) {
                            HStack(spacing: 8) {
                                Text("開始使用")
                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.system(size: 16))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color("PrimaryColor"))
                                    .shadow(color: Color("PrimaryColor").opacity(0.3), radius: 8, x: 0, y: 4)
                            )
                        }
                        .buttonStyle(GentlePressStyle())
                        
                        // 次要按鈕 - 使用 NavigationLink
                        NavigationLink(destination: LoginView()) {
                            HStack(spacing: 6) {
                                Text("已有帳號？")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("SecondaryColor"))
                                Text("登入")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color("PrimaryColor"))
                            }
                        }
                        .buttonStyle(GentlePressStyle())
                    }
                    .padding(.horizontal, 28)
                    .padding(.bottom, 60)
                }
            }
        }
    }
}

// MARK: - Button Styles - 更溫柔的按鈕效果
struct GentlePressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
} 