//
//  EmotionChatView.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI

struct EmotionChatView: View {
    @StateObject private var viewModel = EmotionChatViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var selectedMessageType: EmotionChatMessage.MessageType = .message
    @State private var showingTypePicker = false
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 冷靜背景色
                LinearGradient(
                    colors: [Color.gray.opacity(0.1), Color.gray.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 頂部提醒
                    warningHeader
                    
                    if viewModel.pairedWith.isEmpty {
                        // 未配對狀態
                        unpairingStateView
                    } else if !viewModel.isEmotionChatEnabled {
                        // 聊天未啟用狀態
                        disabledStateView
                    } else {
                        // 聊天已啟用狀態
                        VStack(spacing: 0) {
                            // 訊息列表
                            messagesList
                            
                            // 輸入區域
                            inputSection
                        }
                    }
                }
            }
            .navigationTitle("🌧️ 冷靜通道")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 16, weight: .medium))
                            Text("返回")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(Color("TextColor"))
                    }
                }
                
                if viewModel.isEmotionChatEnabled {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("關閉通道") {
                            Task {
                                await viewModel.disableEmotionChat()
                            }
                        }
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .onTapGesture {
            // 點擊背景時收起鍵盤
            isTextFieldFocused = false
        }
        .alert("錯誤", isPresented: $viewModel.showAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
    }
    
    // MARK: - 頂部提醒
    private var warningHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                    .font(.system(size: 16))
                
                Text("你即將進入冷靜空間")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color("TextColor"))
            }
            
            Text("這裡的對話不會儲存於歷史紀錄，7天後自動消失")
                .font(.system(size: 13, weight: .regular, design: .rounded))
                .foregroundColor(Color("SecondaryColor"))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
    
    // MARK: - 未配對狀態
    private var unpairingStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 16) {
                Image(systemName: "person.2.slash")
                    .font(.system(size: 60))
                    .foregroundColor(Color("SecondaryColor"))
                
                Text("尚未配對")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("TextColor"))
                
                Text("冷靜通道需要與伴侶配對後才能使用")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SecondaryColor"))
                    .multilineTextAlignment(.center)
            }
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
    
    // MARK: - 聊天未啟用狀態
    private var disabledStateView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "bubble.left.and.bubble.right")
                    .font(.system(size: 60))
                    .foregroundColor(Color("SecondaryColor"))
                
                VStack(spacing: 12) {
                    Text("開啟冷靜通道？")
                        .font(.system(size: 24, weight: .semibold, design: .rounded))
                        .foregroundColor(Color("TextColor"))
                    
                    Text("與 \(viewModel.partnerName.isEmpty ? "伴侶" : viewModel.partnerName) 開始一段情緒對話")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryColor"))
                        .multilineTextAlignment(.center)
                }
            }
            
            Button(action: {
                Task {
                    await viewModel.enableEmotionChat()
                }
            }) {
                HStack(spacing: 8) {
                    if viewModel.isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .tint(.white)
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 18))
                    }
                    
                    Text("開始對話")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("PrimaryColor"))
                )
            }
            .disabled(viewModel.isLoading)
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - 訊息列表
    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageBubbleView(
                            message: message,
                            isCurrentUser: viewModel.isCurrentUserMessage(message),
                            onQuickResponse: { type in
                                Task {
                                    await viewModel.sendQuickResponse(type: type)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation(.easeOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    // MARK: - 輸入區域
    private var inputSection: some View {
        VStack(spacing: 0) {
            Divider()
                .background(Color.gray.opacity(0.3))
            
            VStack(spacing: 12) {
                // 訊息類型選擇
                HStack(spacing: 8) {
                    Text("類型:")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryColor"))
                    
                    Button(action: {
                        showingTypePicker = true
                    }) {
                        HStack(spacing: 4) {
                            Text(selectedMessageType.defaultEmoji)
                            Text(selectedMessageType.displayText)
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                        }
                        .foregroundColor(Color("TextColor"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.1))
                        )
                    }
                    
                    Spacer()
                }
                
                // 輸入框和發送按鈕
                HStack(spacing: 12) {
                    TextField("輸入訊息...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .focused($isTextFieldFocused)
                        .keyboardType(.default)
                        .textInputAutocapitalization(.sentences)
                        .submitLabel(.send)
                        .onTapGesture {
                            isTextFieldFocused = true
                        }
                        .onSubmit {
                            sendMessage()
                        }
                        .background(Color.clear)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
                                          Color.gray.opacity(0.5) : Color("PrimaryColor"))
                            )
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                }
                
                // 快速回應按鈕
                HStack(spacing: 12) {
                    // 測試鍵盤按鈕
                    Button(action: {
                        isTextFieldFocused = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "keyboard")
                                .font(.system(size: 12))
                            Text("鍵盤")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                        }
                        .foregroundColor(Color("PrimaryColor"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("PrimaryColor").opacity(0.1))
                        )
                    }
                    
                    ForEach([EmotionChatMessage.MessageType.apology, .hug, .neutral], id: \.self) { type in
                        Button(action: {
                            Task {
                                await viewModel.sendQuickResponse(type: type)
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text(type.defaultEmoji)
                                    .font(.system(size: 14))
                                Text(type.displayText)
                                    .font(.system(size: 12, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(Color("TextColor"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
                        .disabled(viewModel.isLoading)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
        .confirmationDialog("選擇訊息類型", isPresented: $showingTypePicker, titleVisibility: .visible) {
            ForEach(EmotionChatMessage.MessageType.allCases, id: \.self) { type in
                Button("\(type.defaultEmoji) \(type.displayText)") {
                    selectedMessageType = type
                }
            }
            Button("取消", role: .cancel) { }
        }
    }
    
    // MARK: - 發送訊息
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        Task {
            await viewModel.sendMessage(
                text: text,
                emoji: selectedMessageType.defaultEmoji,
                type: selectedMessageType
            )
            
            // 清空輸入框但保持焦點
            messageText = ""
        }
    }
}

// MARK: - 訊息氣泡視圖
struct MessageBubbleView: View {
    let message: EmotionChatMessage
    let isCurrentUser: Bool
    let onQuickResponse: ((EmotionChatMessage.MessageType) -> Void)?
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                // 訊息內容
                HStack(spacing: 8) {
                    if let emoji = message.emoji, !emoji.isEmpty {
                        Text(emoji)
                            .font(.system(size: 18))
                    }
                    
                    if let text = message.text, !text.isEmpty {
                        Text(text)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundColor(isCurrentUser ? .white : Color("TextColor"))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isCurrentUser ? Color("PrimaryColor") : Color.gray.opacity(0.1))
                )
                
                // 快速回應按鈕（只對非當前用戶的道歉訊息顯示）
                if !isCurrentUser && message.type == .apology {
                    HStack(spacing: 8) {
                        Button(action: {
                            onQuickResponse?(.hug)
                        }) {
                            HStack(spacing: 4) {
                                Text("🫂")
                                    .font(.system(size: 12))
                                Text("和好吧")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(Color("PrimaryColor"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("PrimaryColor").opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("PrimaryColor").opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        Button(action: {
                            onQuickResponse?(.neutral)
                        }) {
                            HStack(spacing: 4) {
                                Text("🤔")
                                    .font(.system(size: 12))
                                Text("等一下")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(Color("SecondaryColor"))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.gray.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.top, 4)
                }
                
                // 時間和類型
                HStack(spacing: 4) {
                    Text(message.formatCreatedTime())
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryColor"))
                    
                    Text("•")
                        .font(.system(size: 11))
                        .foregroundColor(Color("SecondaryColor"))
                    
                    Text(message.type.displayText)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryColor"))
                }
            }
            
            if !isCurrentUser {
                Spacer(minLength: 50)
            }
        }
    }
}

#Preview {
    EmotionChatView()
} 