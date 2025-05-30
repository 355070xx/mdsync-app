//
//  EmojiPickerView.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI

struct EmojiPickerView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var moodViewModel: MoodViewModel
    
    // 心情 emoji 分類
    let happyEmojis = ["😊", "😄", "😃", "🥰", "😍", "🤩", "😎", "🥳"]
    let sadEmojis = ["😢", "😭", "😞", "😔", "😟", "😦", "😧", "🥺"]
    let angryEmojis = ["😠", "😡", "🤬", "😤", "😒", "🙄", "😑", "😐"]
    let nervousEmojis = ["😰", "😨", "😱", "🤯", "😳", "🫨", "😵‍💫", "🤪"]
    let loveEmojis = ["🥰", "😘", "😍", "🤗", "💕", "💖", "💝", "💗"]
    let tiredEmojis = ["😴", "🥱", "😪", "🤤", "😵", "🫥", "😮‍💨", "🤧"]
    
    @State private var selectedCategory: EmojiCategory = .happy
    @State private var isUpdating = false
    
    enum EmojiCategory: String, CaseIterable {
        case happy = "開心"
        case sad = "難過"
        case angry = "生氣"
        case nervous = "緊張"
        case love = "愛心"
        case tired = "疲憊"
        
        var icon: String {
            switch self {
            case .happy: return "face.smiling"
            case .sad: return "face.dashed"
            case .angry: return "flame"
            case .nervous: return "bolt"
            case .love: return "heart"
            case .tired: return "zzz"
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // 標題區域
                    VStack(spacing: 8) {
                        Text("選擇今日心情")
                            .font(.system(size: 24, weight: .semibold, design: .rounded))
                            .foregroundColor(Color("TextColor"))
                        
                        Text("告訴你的另一半你現在的感受")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(Color("SecondaryColor"))
                    }
                    .padding(.top, 16)
                    
                    // 分類選擇器
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(EmojiCategory.allCases, id: \.self) { category in
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category
                                ) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        selectedCategory = category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 28)
                    }
                    .padding(.horizontal, -4)
                    
                    // Emoji 網格
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 4), spacing: 20) {
                            ForEach(getEmojisForCategory(selectedCategory), id: \.self) { emoji in
                                EmojiButton(emoji: emoji) {
                                    Task {
                                        await selectEmoji(emoji)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color("PrimaryColor"))
                }
            }
            .overlay {
                if isUpdating {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                        
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.2)
                                .tint(Color("PrimaryColor"))
                            
                            Text("更新心情中...")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color("TextColor"))
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                    }
                }
            }
        }
        .alert("錯誤", isPresented: $moodViewModel.showAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(moodViewModel.errorMessage)
        }
    }
    
    // MARK: - Helper Functions
    private func getEmojisForCategory(_ category: EmojiCategory) -> [String] {
        switch category {
        case .happy: return happyEmojis
        case .sad: return sadEmojis
        case .angry: return angryEmojis
        case .nervous: return nervousEmojis
        case .love: return loveEmojis
        case .tired: return tiredEmojis
        }
    }
    
    private func selectEmoji(_ emoji: String) async {
        isUpdating = true
        
        // 添加觸覺反饋
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        await moodViewModel.updateMood(emoji)
        
        isUpdating = false
        
        // 延遲一小段時間讓使用者看到選擇效果
        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 秒
        
        dismiss()
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let category: EmojiPickerView.EmojiCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 14, weight: .medium))
                
                Text(category.rawValue)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : Color("SecondaryColor"))
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(isSelected ? Color("PrimaryColor") : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(Color("SecondaryColor").opacity(0.3), lineWidth: isSelected ? 0 : 1)
                    )
            )
        }
        .buttonStyle(GentlePressStyle())
    }
}

// MARK: - Emoji Button
struct EmojiButton: View {
    let emoji: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            Text(emoji)
                .font(.system(size: 44))
                .frame(width: 70, height: 70)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white)
                        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .onLongPressGesture(minimumDuration: 0, perform: {
            // 不需要執行任何動作，只是為了滿足語法要求
        }, onPressingChanged: { pressing in
            isPressed = pressing
        })
    }
}

// MARK: - Preview
#Preview("EmojiPickerView") {
    EmojiPickerView()
        .environmentObject(MoodViewModel())
} 