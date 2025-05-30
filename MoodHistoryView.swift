//
//  MoodHistoryView.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI
import FirebaseFirestore

struct MoodHistoryView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = MoodHistoryViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("Background")
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if viewModel.isLoading && viewModel.moodHistory.isEmpty {
                        // 初次載入狀態
                        LoadingView()
                    } else if viewModel.moodHistory.isEmpty && !viewModel.isLoading {
                        // 空狀態
                        EmptyStateView()
                    } else {
                        // 顯示歷史紀錄
                        HistoryListView()
                    }
                }
            }
            .navigationTitle("心情歷史")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color("PrimaryColor"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.refreshMoodHistory()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("PrimaryColor"))
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .alert("錯誤", isPresented: $viewModel.showAlert) {
                Button("確定", role: .cancel) { }
                Button("重試") {
                    viewModel.refreshMoodHistory()
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .environmentObject(viewModel)
    }
}

// MARK: - Loading View
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color("PrimaryColor"))
            
            Text("載入心情歷史中...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color("SecondaryColor"))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "heart.text.square")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(Color("SecondaryColor").opacity(0.6))
            
            VStack(spacing: 8) {
                Text("還沒有心情紀錄")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("TextColor"))
                
                Text("開始記錄你的每日心情吧！")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SecondaryColor"))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - History List View
struct HistoryListView: View {
    @EnvironmentObject private var viewModel: MoodHistoryViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.moodHistory) { item in
                    MoodHistoryCard(item: item)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .refreshable {
            viewModel.refreshMoodHistory()
        }
        .overlay(alignment: .bottom) {
            if viewModel.isLoading && !viewModel.moodHistory.isEmpty {
                // 重新載入時的loading indicator
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("更新中...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(Color("SecondaryColor"))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                )
                .padding(.bottom, 20)
            }
        }
    }
}

// MARK: - Mood History Card
struct MoodHistoryCard: View {
    let item: MoodHistoryItem
    @EnvironmentObject private var viewModel: MoodHistoryViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji
            Text(item.mood)
                .font(.system(size: 32))
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(.white)
                        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
                )
            
            // 時間資訊
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.formatTimestamp(item.timestamp))
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("TextColor"))
                
                Text(formatDetailTime(item.timestamp))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SecondaryColor"))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 2)
        )
    }
    
    // 格式化詳細時間（顯示週幾）
    private func formatDetailTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_TW")
        
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            return "今天"
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
            return "昨天"
        } else {
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        }
    }
}

// MARK: - Preview
#Preview("MoodHistoryView") {
    MoodHistoryView()
}

#Preview("MoodHistoryCard") {
    MoodHistoryCard(
        item: MoodHistoryItem(
            id: "1",
            data: [
                "mood": "😍",
                "timestamp": Timestamp()
            ]
        )
    )
    .environmentObject(MoodHistoryViewModel())
    .padding()
} 