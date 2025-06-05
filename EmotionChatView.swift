//
//  EmotionChatView.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct EmotionChatView: View {
    @StateObject private var viewModel = EmotionChatViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var selectedTag: String = "neutral"
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 冷靜背景色 - 使用治癒系的淺色調
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.98, blue: 1.0),  // 極淺藍
                        Color(red: 0.97, green: 1.0, blue: 0.98)   // 極淺綠
                    ],
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
                        .foregroundColor(Color(red: 0.1, green: 0.1, blue: 0.1))  // 改為明顯的深色
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                if viewModel.isEmotionChatEnabled {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("🧪 添加測試資料") {
                                Task {
                                    await viewModel.addTestMessages()
                                }
                            }
                            
                            Button("⏰ 添加過期測試訊息") {
                                Task {
                                    await viewModel.addExpiredTestMessages()
                                }
                            }
                            
                            Button("🗑️ 清理過期訊息") {
                                Task {
                                    await viewModel.cleanupExpiredMessages()
                                }
                            }
                            
                            Divider()
                            
                            Button("關閉通道", role: .destructive) {
                                Task {
                                    await viewModel.disableEmotionChat()
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color("TextColor"))
                        }
                        .buttonStyle(PlainButtonStyle())
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
        .overlay(
            // 成功回饋訊息
            VStack {
                Spacer()
                if viewModel.showSuccessFeedback {
                    Text(viewModel.successMessage)
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
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.showSuccessFeedback)
                }
            }
            .padding(.bottom, 100)
        )
        .onAppear {
            // 重新載入配對信息
            viewModel.loadPairingInfo()
            
            // 標記為已讀
            Task {
                await viewModel.markAsRead()
            }
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
                            },
                            onReply: { messageID, replyStatus in
                                Task {
                                    await viewModel.replyToMessage(messageID: messageID, replyStatus: replyStatus)
                                }
                            },
                            onToggleStar: { messageID, currentIsStarred in
                                Task {
                                    await viewModel.toggleMessageStar(messageID: messageID, currentIsStarred: currentIsStarred)
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
                // 訊息類型選擇 - 改為 Emoji 按鈕
                HStack(spacing: 12) {
                    // 道歉按鈕
                    Button(action: {
                        selectedTag = "apology"
                        messageText = "對唔住，唔係想傷害你"
                        
                        // 添加觸覺回饋
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        Text("🙏")
                            .font(.system(size: 20))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(selectedTag == "apology" ? Color("PrimaryColor").opacity(0.2) : Color.white)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedTag == "apology" ? Color("PrimaryColor") : Color.gray.opacity(0.3), lineWidth: 1.5)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 擁抱按鈕
                    Button(action: {
                        selectedTag = "hug"
                        messageText = "我哋可以唔講野先，淨係抱下"
                        
                        // 添加觸覺回饋
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        Text("🫂")
                            .font(.system(size: 20))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(selectedTag == "hug" ? Color("PrimaryColor").opacity(0.2) : Color.white)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedTag == "hug" ? Color("PrimaryColor") : Color.gray.opacity(0.3), lineWidth: 1.5)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 中性按鈕
                    Button(action: {
                        selectedTag = "neutral"
                        messageText = "我而家未 ready 講，但我會聽你講"
                        
                        // 添加觸覺回饋
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                    }) {
                        Text("😐")
                            .font(.system(size: 20))
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(selectedTag == "neutral" ? Color("PrimaryColor").opacity(0.2) : Color.white)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedTag == "neutral" ? Color("PrimaryColor") : Color.gray.opacity(0.3), lineWidth: 1.5)
                                    )
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Spacer()
                }
                
                // 輸入框和發送按鈕
                HStack(spacing: 12) {
                    TextField("輸入訊息...", text: $messageText)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))  // 深灰文字
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)  // 純白背景
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.85, green: 0.85, blue: 0.85), lineWidth: 1)  // 淺灰邊框
                                )
                        )
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
                    
                    Button(action: {
                        // 添加觸覺回饋
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                        
                        sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
                                          Color.gray.opacity(0.5) : Color.blue)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
                    .contentShape(Circle())
                }
                
                // 快速回應按鈕
                HStack(spacing: 12) {
                    // 鍵盤按鈕
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
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("PrimaryColor").opacity(0.1))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    ForEach([EmotionChatMessage.MessageType.apology, .hug, .neutral], id: \.self) { type in
                        Button(action: {
                            // 添加觸覺回饋
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            Task {
                                await viewModel.sendQuickResponse(type: type)
                            }
                        }) {
                            HStack(spacing: 4) {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .scaleEffect(0.7)
                                        .frame(width: 14, height: 14)
                                } else {
                                    Text(type.defaultEmoji)
                                        .font(.system(size: 16))
                                }
                                
                                Text(type.displayText)
                                    .font(.system(size: 13, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(viewModel.isLoading ? Color("SecondaryColor") : Color("TextColor"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(minWidth: 60, minHeight: 32)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 1.0, green: 1.0, blue: 0.98))  // 溫暖的白色
                            )
                            .scaleEffect(viewModel.isLoading ? 0.95 : 1.0)
                            .opacity(viewModel.isLoading ? 0.6 : 1.0)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .disabled(viewModel.isLoading)
                        .contentShape(Rectangle())
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(red: 1.0, green: 1.0, blue: 0.98))  // 溫暖的白色
        }
    }
    
    // MARK: - 發送訊息
    private func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        
        // 根據 selectedTag 決定訊息類型和 emoji
        let messageType: EmotionChatMessage.MessageType
        let emoji: String
        
        switch selectedTag {
        case "apology":
            messageType = .apology
            emoji = "🙏"
        case "hug":
            messageType = .hug
            emoji = "🫂"
        case "neutral":
            messageType = .neutral
            emoji = "😐"
        default:
            messageType = .neutral
            emoji = "😐"
        }
        
        Task {
            await viewModel.sendMessage(
                text: text,
                emoji: emoji,
                type: messageType
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
    let onReply: ((String, EmotionChatMessage.ReplyStatus) -> Void)?
    let onToggleStar: ((String, Bool) -> Void)?
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer(minLength: 50)
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                // 訊息內容與星星按鈕
                ZStack(alignment: .topTrailing) {
                    HStack(spacing: 8) {
                        if let emoji = message.emoji, !emoji.isEmpty {
                            Text(emoji)
                                .font(.system(size: 18))
                        }
                        
                        if let text = message.text, !text.isEmpty {
                            Text(text)
                                .font(.system(size: 16, weight: .regular, design: .rounded))
                                .foregroundColor(isCurrentUser ? 
                                               Color(red: 0.1, green: 0.2, blue: 0.4) :  // 深藍灰
                                               Color(red: 0.2, green: 0.2, blue: 0.2))   // 深灰
                        }
                        
                        // 為星星按鈕預留空間
                        Spacer(minLength: 20)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(isCurrentUser ? 
                                  Color(red: 0.7, green: 0.85, blue: 1.0) :    // 淺藍色（用戶訊息）
                                  Color(red: 0.94, green: 0.94, blue: 0.92))   // 改為米白色（對方訊息）
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(isCurrentUser ? 
                                           Color.clear : 
                                           Color(red: 0.8, green: 0.8, blue: 0.78), lineWidth: 1)  // 對方訊息添加邊框
                            )
                    )
                    
                    // 星星按鈕（右上角）
                    Button(action: {
                        guard let messageID = message.id else { return }
                        let currentIsStarred = message.isStarred ?? false
                        
                        // 添加觸覺回饋
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        onToggleStar?(messageID, currentIsStarred)
                    }) {
                        Image(systemName: (message.isStarred ?? false) ? "star.fill" : "star")
                            .font(.system(size: 14))
                            .foregroundColor((message.isStarred ?? false) ? Color.yellow : Color.gray.opacity(0.6))
                            .frame(width: 20, height: 20)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(0.8))
                                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .offset(x: -4, y: -4)
                }
                
                // 回覆狀態顯示
                if let currentUserUID = Auth.auth().currentUser?.uid,
                   let replyStatusText = message.getReplyStatusText(currentUserUID: currentUserUID) {
                    HStack(spacing: 4) {
                        if let replyStatus = message.replyStatus {
                            Text(replyStatus.emoji)
                                .font(.system(size: 12))
                        }
                        Text(replyStatusText)
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))  // 改為更明顯的深灰色
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(red: 0.95, green: 0.97, blue: 1.0))  // 極淺藍色
                    )
                }
                
                // 回覆按鈕（只對非當前用戶且可回覆的訊息顯示，且未被回覆過）
                if !isCurrentUser && message.type.canBeReplied && !message.isReplied,
                   let messageID = message.id {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("回覆這段訊息？")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))  // 改為更明顯的深灰色
                        
                        HStack(spacing: 8) {
                            Button(action: {
                                onReply?(messageID, .accepted)
                            }) {
                                HStack(spacing: 4) {
                                    Text("✅")
                                        .font(.system(size: 12))
                                    Text("接受")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                }
                                .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.8))  // 柔和藍色
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.9, green: 0.95, blue: 1.0))  // 極淺藍背景
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color(red: 0.7, green: 0.85, blue: 0.95), lineWidth: 1)
                                        )
                                )
                            }
                            
                            Button(action: {
                                onReply?(messageID, .later)
                            }) {
                                HStack(spacing: 4) {
                                    Text("🕓")
                                        .font(.system(size: 12))
                                    Text("稍後再回應")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                }
                                .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.4))  // 溫暖中性色
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(red: 0.96, green: 0.96, blue: 0.94))  // 溫暖淺灰
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color(red: 0.85, green: 0.85, blue: 0.82), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                
                // 快速回應按鈕（只對非當前用戶的道歉訊息顯示，且保留舊功能）
                if !isCurrentUser && message.type == .apology && message.isReplied {
                    HStack(spacing: 8) {
                        Button(action: {
                            // 添加觸覺回饋
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            print("和好吧按鈕被點擊")
                            onQuickResponse?(.hug)
                        }) {
                            HStack(spacing: 4) {
                                Text("🫂")
                                    .font(.system(size: 12))
                                Text("和好吧")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(Color(red: 0.3, green: 0.6, blue: 0.8))  // 柔和藍色
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.9, green: 0.95, blue: 1.0))  // 極淺藍背景
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 0.7, green: 0.85, blue: 0.95), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                        
                        Button(action: {
                            // 添加觸覺回饋
                            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                            impactFeedback.impactOccurred()
                            
                            print("等一下按鈕被點擊")
                            onQuickResponse?(.neutral)
                        }) {
                            HStack(spacing: 4) {
                                Text("🤔")
                                    .font(.system(size: 12))
                                Text("等一下")
                                    .font(.system(size: 11, weight: .medium, design: .rounded))
                            }
                            .foregroundColor(Color(red: 0.5, green: 0.5, blue: 0.4))  // 溫暖中性色
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.96, green: 0.96, blue: 0.94))  // 溫暖淺灰
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color(red: 0.85, green: 0.85, blue: 0.82), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                    }
                    .padding(.top, 4)
                }
                
                // 時間和類型
                HStack(spacing: 4) {
                    Text(message.formatCreatedTime())
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))  // 改為更明顯的灰色
                    
                    Text("•")
                        .font(.system(size: 11))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))  // 改為更明顯的灰色
                    
                    Text(message.type.displayText)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))  // 改為更明顯的灰色
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

#Preview("Message Bubble") {
    MessageBubbleView(
        message: EmotionChatMessage(
            id: "test-id",
            fromUID: "test-uid",
            fromName: "測試用戶",
            emoji: "🙏",
            text: "對唔住，唔係想傷害你",
            type: .apology,
            createdAt: Timestamp(),
            expiresAt: Timestamp(date: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()),
            replyStatus: nil,
            replyByUID: nil,
            isStarred: false
        ),
        isCurrentUser: false,
        onQuickResponse: { _ in },
        onReply: { _, _ in },
        onToggleStar: { _, _ in }
    )
    .padding()
}