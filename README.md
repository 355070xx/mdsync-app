# MoodSync - 心情同步應用程式

## 功能概述

MoodSync 是一個讓伴侶間分享即時心情的 iOS 應用程式。

## ✨ 最新功能：配對系統

### 配對功能說明
1. **配對設定頁面（PairingView）**
   - 顯示用戶自己的配對碼（UID）
   - 一鍵複製配對碼分享給另一半
   - 輸入對方配對碼完成情侶配對
   - 顯示配對狀態和解除配對選項

2. **配對邏輯流程**
   - 用戶輸入對方的 UID
   - 系統驗證對方用戶是否存在
   - 確認對方未與其他人配對
   - 雙向綁定：更新雙方的 `pairedWith` 欄位
   - 配對成功後可即時查看對方心情

3. **伴侶心情同步**
   - 主畫面顯示另一半的當前心情
   - 即時同步對方的心情變化
   - 顯示對方最後更新時間

### Firestore 資料結構
```
users/{uid}
├── mood: "😊"              // 當前心情 emoji
├── lastUpdated: Timestamp  // 最後更新時間
├── pairedWith: "{partnerUID}" // 配對伴侶的 UID
├── name: String           // 用戶名稱
└── email: String          // 電子郵件
```

## 🎯 心情選擇與同步功能

### 功能描述
1. **MainView 心情顯示**
   - 顯示目前用戶的心情 emoji
   - 顯示配對伴侶的心情（已配對時）
   - 顯示最後更新時間
   - 點擊卡片可開啟心情選擇器

2. **EmojiPickerView 心情選擇**
   - 分類式心情選擇（開心、難過、生氣、緊張、愛心、疲憊）
   - 每個分類包含 8 個相關 emoji
   - 選擇後自動儲存至 Firestore
   - 即時回饋與觸覺效果

### 技術實作

#### 新增檔案
- `PairingViewModel.swift` - 配對邏輯管理
- `PairingView.swift` - 配對設定介面

#### 核心檔案
- `MoodViewModel.swift` - 心情資料管理（已擴展配對功能）
- `EmojiPickerView.swift` - 心情選擇介面  
- `MainView.swift` - 主介面（已整合配對功能）

#### 核心功能

1. **PairingViewModel**
   - `performPairing()` - 執行配對邏輯
   - `unpair()` - 解除配對
   - `copyUIDToClipboard()` - 複製配對碼
   - `checkPairingStatus()` - 檢查配對狀態

2. **MoodViewModel（已擴展）**
   - `loadPartnerMood()` - 載入伴侶心情
   - `checkPairingStatus()` - 檢查配對狀態
   - 自動同步伴侶心情變化

3. **PairingView 組件**
   - `MyPairingCodeCard` - 我的配對碼卡片
   - `PartnerPairingCodeCard` - 輸入配對碼卡片
   - `PairedStatusCard` - 已配對狀態卡片

### 使用流程

#### 配對流程
1. 雙方都在 MainView 點擊「配對」按鈕
2. 其中一方複製自己的配對碼分享給對方
3. 對方輸入配對碼並點擊「送出配對」
4. 系統驗證並建立雙向配對關係
5. 配對成功後可在主畫面看到對方心情

#### 心情同步流程
1. 配對成功後，MainView 會顯示兩個心情卡片
2. 用戶更新自己心情時，對方會即時看到變化
3. 支援即時查看對方的心情和更新時間

### 安全性與錯誤處理
- 防止用戶與自己配對
- 檢查對方是否已與其他人配對
- 使用 Firestore 批次寫入確保原子性操作
- 完整的錯誤提示和用戶回饋
- Loading 狀態顯示

### 架構特點
- 使用 SwiftUI + MVVM 架構
- Firebase Firestore 資料同步
- 響應式 UI 設計
- 組件化設計便於維護
- 錯誤處理與使用者體驗優化

## 開發環境
- iOS 16.0+
- Swift 6.1
- Firebase SDK
- SwiftUI 