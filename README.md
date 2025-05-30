# MoodSync - 心情同步應用程式

## 功能概述

MoodSync 是一個讓伴侶間分享即時心情的 iOS 應用程式。

## 最新功能：心情選擇與同步

### 功能描述
1. **MainView 心情顯示**
   - 顯示目前用戶的心情 emoji
   - 顯示最後更新時間
   - 點擊卡片可開啟心情選擇器

2. **EmojiPickerView 心情選擇**
   - 分類式心情選擇（開心、難過、生氣、緊張、愛心、疲憊）
   - 每個分類包含 8 個相關 emoji
   - 選擇後自動儲存至 Firestore
   - 即時回饋與觸覺效果

3. **Firestore 資料結構**
   ```
   users/{uid}
   ├── mood: "😊"              // 當前心情 emoji
   ├── lastUpdated: Timestamp  // 最後更新時間
   ├── name: String           // 用戶名稱
   └── email: String          // 電子郵件
   ```

### 技術實作

#### 檔案結構
- `MoodViewModel.swift` - 心情資料管理
- `EmojiPickerView.swift` - 心情選擇介面  
- `MainView.swift` - 主介面（已更新）

#### 核心功能
1. **MoodViewModel**
   - `loadCurrentMood()` - 載入用戶當前心情
   - `updateMood(_:)` - 更新心情至 Firestore
   - `formatLastUpdated()` - 格式化時間顯示

2. **EmojiPickerView**
   - 分類式 emoji 選擇
   - 即時更新與回饋
   - 錯誤處理與載入狀態

### 使用流程
1. 用戶登入後在 MainView 看到心情卡片
2. 點擊「選擇今日心情」開啟 EmojiPickerView
3. 選擇分類並點擊 emoji
4. 系統自動儲存至 Firestore
5. 回到 MainView 即時顯示新心情

### 架構特點
- 使用 SwiftUI + MVVM 架構
- Firebase Firestore 資料同步
- 響應式 UI 設計
- 錯誤處理與使用者體驗優化

## 開發環境
- iOS 16.0+
- Swift 6.1
- Firebase SDK
- SwiftUI 