# MoodSync - 心情同步應用程式

## 功能特色

### 💕 核心功能
- **心情同步**: 設定你的日常心情，與伴侶即時同步
- **伴侶配對**: 透過安全的配對系統連接你和另一半
- **心情歷史**: 追蹤和回顧過去的心情變化
- **🆕 Emoji 回應**: 對伴侶的心情發送可愛的 emoji 回應

### 🎯 新功能：Emoji 回應系統
在主畫面的伴侶心情顯示區中，您現在可以：
- 點擊 6 個預設的 emoji 回應（❤️ 🤗 💨 👍 😘 🥺）
- 向伴侶發送即時回應
- 查看成功送出的回饋訊息：「已送出 ❤️ 給 [伴侶名稱]」
- 防止重複點擊的載入狀態保護

### 📁 Firestore 資料結構
```
users/{userUID}/
├── mood: String              // 當前心情 emoji
├── lastUpdated: Timestamp    // 心情更新時間
├── name: String             // 用戶名稱
├── pairedWith: String       // 配對伴侶的 UID
├── moodHistory/             // 心情歷史子集合
│   └── {auto-id}/
│       ├── mood: String
│       └── timestamp: Timestamp
└── reactions/               // 🆕 接收到的回應子集合
    └── {auto-id}/
        ├── fromUID: String     // 發送者 UID
        ├── fromName: String    // 發送者名稱
        ├── emoji: String       // 回應的 emoji
        └── timestamp: Timestamp // 發送時間
```

### 🔒 安全性設計
- **Firestore 安全規則**: 確保用戶只能讀取自己收到的回應
- **身份驗證**: 回應功能需要用戶登入
- **資料驗證**: 嚴格的欄位驗證，防止惡意資料寫入
- **防重複點擊**: UI 層面的載入狀態保護

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

## 開始使用

### 前置需求
- iOS 15.0+
- Xcode 14.0+
- Firebase 專案設定

### 安裝步驟
1. 複製此專案
2. 在 Firebase Console 建立新專案
3. 下載 `GoogleService-Info.plist` 並加入專案
4. 設定 Firestore 安全規則（參考 `firestore.rules`）
5. 建置並執行專案

### Firebase 設定
1. 啟用 Authentication 與 Firestore
2. 上傳提供的 `firestore.rules` 檔案
3. 設定適當的 iOS bundle ID

## 使用說明

### 🚀 基本使用流程
1. **註冊/登入**: 建立帳號或使用現有帳號登入
2. **設定心情**: 選擇代表當前心情的 emoji
3. **配對伴侶**: 輸入伴侶的配對碼進行連接
4. **同步心情**: 查看伴侶的即時心情狀態
5. **🆕 發送回應**: 點擊 emoji 按鈕向伴侶表達關心

### 💡 使用技巧
- 定期更新心情讓伴侶了解你的狀態
- 使用 emoji 回應功能增進感情互動
- 查看心情歷史了解彼此的情緒變化趨勢
- 保持應用程式更新以獲得最新功能

## 安全性與隱私

### 🔐 資料保護
- 所有用戶資料加密儲存在 Firebase
- 嚴格的存取控制規則
- 伴侶間的資料完全隔離

### 🛡️ 隱私政策
- 不收集不必要的個人資訊
- 用戶可隨時刪除帳號和所有資料
- 遵循 Apple 和 Firebase 的隱私標準

## 開發計劃

### 🚧 即將推出
- 自訂 emoji 回應選項
- 回應通知推送
- 更豐富的心情類別
- 深色模式支援
- Widget 小工具

### 💭 未來功能
- 心情統計圖表
- 紀念日提醒
- 共享相簿
- 語音心情記錄

## 授權條款

此專案採用 MIT 授權條款。詳細內容請參考 LICENSE 檔案。

## 聯絡資訊

如有任何問題或建議，歡迎通過以下方式聯絡：
- Email: [your-email@example.com]
- GitHub Issues: [專案 Issues 頁面]

---

💕 讓愛情透過科技更緊密連結！ 