//
//  PairingView.swift
//  mdsync
//
//  Created by AI Assistant on 30/5/2025.
//

import SwiftUI

struct PairingView: View {
    @StateObject private var viewModel = PairingViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State private var showCopyConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景色
                Color("Background")
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // 頂部說明
                        VStack(spacing: 16) {
                            Image(systemName: "person.2.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(Color("PrimaryColor"))
                                .shadow(color: Color("PrimaryColor").opacity(0.3), radius: 8, x: 0, y: 4)
                            
                            VStack(spacing: 8) {
                                Text("情侶配對")
                                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                                    .foregroundColor(Color("TextColor"))
                                
                                Text("與你的另一半同步心情")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color("SecondaryColor"))
                            }
                        }
                        .padding(.top, 20)
                        
                        // 如果已配對，顯示配對狀態
                        if !viewModel.pairedWith.isEmpty {
                            PairedStatusCard(
                                pairedWithUID: viewModel.pairedWith,
                                partnerName: viewModel.partnerName,
                                onUnpair: {
                                    Task {
                                        await viewModel.unpair()
                                    }
                                },
                                isLoading: viewModel.isLoading
                            )
                        } else {
                            // 配對功能卡片
                            VStack(spacing: 24) {
                                // 我的配對碼
                                MyPairingCodeCard(
                                    uid: viewModel.currentUserUID,
                                    onCopy: {
                                        viewModel.copyUIDToClipboard()
                                        showCopyConfirmation = true
                                    }
                                )
                                
                                // 分隔線
                                HStack {
                                    Rectangle()
                                        .fill(Color("SecondaryColor").opacity(0.3))
                                        .frame(height: 1)
                                    
                                    Text("或")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(Color("SecondaryColor"))
                                        .padding(.horizontal, 16)
                                    
                                    Rectangle()
                                        .fill(Color("SecondaryColor").opacity(0.3))
                                        .frame(height: 1)
                                }
                                
                                // 輸入對方配對碼
                                PartnerPairingCodeCard(
                                    partnerUID: $viewModel.partnerUID,
                                    onPair: {
                                        Task {
                                            await viewModel.performPairing()
                                        }
                                    },
                                    isLoading: viewModel.isLoading
                                )
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }
            .navigationTitle("配對設定")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("PrimaryColor"))
                    }
                }
            }
        }
        .alert("錯誤", isPresented: $viewModel.showAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage)
        }
        .alert("成功", isPresented: $viewModel.showSuccessAlert) {
            Button("確定", role: .cancel) {
                if !viewModel.pairedWith.isEmpty {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        } message: {
            Text(viewModel.pairedWith.isEmpty ? "已成功解除配對" : "配對成功！現在可以與另一半同步心情了")
        }
        .toast(isPresented: $showCopyConfirmation, message: "已複製配對碼")
    }
}

// MARK: - 我的配對碼卡片
struct MyPairingCodeCard: View {
    let uid: String
    let onCopy: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("我的配對碼")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color("TextColor"))
            
            VStack(spacing: 12) {
                Text("分享此配對碼給你的另一半")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SecondaryColor"))
                    .multilineTextAlignment(.center)
                
                // 配對碼顯示區域
                HStack {
                    Text(uid)
                        .font(.system(size: 16, weight: .medium, design: .monospaced))
                        .foregroundColor(Color("TextColor"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color("SecondaryColor").opacity(0.1))
                        )
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    
                    Button(action: onCopy) {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color("PrimaryColor"))
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("PrimaryColor").opacity(0.1))
                            )
                    }
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - 輸入對方配對碼卡片
struct PartnerPairingCodeCard: View {
    @Binding var partnerUID: String
    let onPair: () -> Void
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            Text("輸入對方配對碼")
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color("TextColor"))
            
            VStack(spacing: 16) {
                Text("請輸入另一半的配對碼完成配對")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SecondaryColor"))
                    .multilineTextAlignment(.center)
                
                // 輸入框
                TextField("請貼上配對碼", text: $partnerUID)
                    .font(.system(size: 16, weight: .medium, design: .monospaced))
                    .foregroundColor(Color("TextColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("SecondaryColor").opacity(0.3), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white)
                            )
                    )
                    .disabled(isLoading)
                
                // 配對按鈕
                Button(action: onPair) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.8)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16, weight: .medium))
                        }
                        
                        Text(isLoading ? "配對中..." : "送出配對")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(partnerUID.isEmpty ? Color("SecondaryColor") : Color("PrimaryColor"))
                    )
                }
                .disabled(partnerUID.isEmpty || isLoading)
                .buttonStyle(GentlePressStyle())
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - 已配對狀態卡片
struct PairedStatusCard: View {
    let pairedWithUID: String
    let partnerName: String
    let onUnpair: () -> Void
    let isLoading: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            // 成功圖示
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
                .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
            
            VStack(spacing: 12) {
                Text("配對成功！")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundColor(Color("TextColor"))
                
                Text("你已與另一半配對成功")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color("SecondaryColor"))
                
                // 配對對象名稱
                Text("配對對象：\(partnerName.isEmpty ? "載入中..." : partnerName)")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(Color("TextColor"))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color("PrimaryColor").opacity(0.1))
                    )
            }
            
            // 解除配對按鈕
            Button(action: onUnpair) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.red)
                    } else {
                        Image(systemName: "heart.slash")
                            .font(.system(size: 16, weight: .medium))
                    }
                    
                    Text(isLoading ? "解除中..." : "解除配對")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.red, lineWidth: 1)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.white)
                        )
                )
            }
            .disabled(isLoading)
            .buttonStyle(GentlePressStyle())
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
        )
    }
}

// MARK: - Toast 通知組件
extension View {
    func toast(isPresented: Binding<Bool>, message: String) -> some View {
        ZStack {
            self
            
            if isPresented.wrappedValue {
                VStack {
                    Spacer()
                    
                    Text(message)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.black.opacity(0.8))
                        )
                        .padding(.bottom, 100)
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        isPresented.wrappedValue = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    PairingView()
} 