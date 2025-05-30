# Firebase 設定指南

## 📋 設定步驟

### 1. 創建 Firebase 專案
1. 前往 [Firebase Console](https://console.firebase.google.com/)
2. 點擊「建立專案」
3. 輸入專案名稱（例如：`mdsync-app`）
4. 選擇是否啟用 Google Analytics（建議開啟）
5. 完成專案創建

### 2. 添加 iOS 應用程式
1. 在 Firebase 專案中點擊「新增應用程式」
2. 選擇 iOS 圖標
3. 輸入應用程式資訊：
   - **iOS 套件 ID**：與 Xcode 專案中的 Bundle Identifier 相同
   - **應用程式暱稱**：`MoodSync`（可選）
   - **App Store ID**：暫時可留空

### 3. 下載設定檔
1. 下載 `GoogleService-Info.plist` 檔案
2. 將檔案拖曳到 Xcode 專案的根目錄
3. 確保選擇「Copy items if needed」
4. 確保 Target 選擇了你的應用程式

### 4. 添加 Firebase SDK
在 Xcode 中：

1. 選擇專案檔案
2. 選擇「Package Dependencies」標籤
3. 點擊「+」按鈕
4. 輸入 Firebase SDK URL：
   ```
   https://github.com/firebase/firebase-ios-sdk
   ```
5. 選擇「Up to Next Major Version」
6. 添加以下套件：
   - **FirebaseAuth**：用於身份驗證
   - **FirebaseFirestore**：用於資料庫操作

### 5. 啟用 Authentication
1. 在 Firebase Console 中，選擇「Authentication」
2. 點擊「開始使用」
3. 選擇「Sign-in method」標籤
4. 啟用「電子郵件/密碼」登入方式

### 6. 設定 Firestore Database
1. 在 Firebase Console 中，選擇「Firestore Database」
2. 點擊「建立資料庫」
3. 選擇「以測試模式啟動」（之後可以更改安全規則）
4. 選擇資料庫位置（建議選擇最近的地區）

## 🔐 Firestore 安全規則

在測試階段，可以使用以下規則（**生產環境請使用更嚴格的規則**）：

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 允許已驗證使用者讀寫自己的資料
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // 其他集合的規則可以在這裡添加
  }
}
```

## ✅ 驗證設定

確保以下檔案已正確配置：

1. **GoogleService-Info.plist** 已添加到 Xcode 專案
2. **Firebase SDK** 已安裝並導入
3. **FirebaseApp.configure()** 已在 AppDelegate 中調用
4. **Authentication** 已在 Firebase Console 中啟用
5. **Firestore** 已創建並設定安全規則

## 🚀 測試驗證

完成設定後，你可以：

1. 在模擬器或實機上運行應用程式
2. 嘗試註冊新帳號
3. 登入已註冊的帳號
4. 檢查 Firebase Console 中的 Authentication 和 Firestore 是否有新資料

## 📱 應用程式功能

設定完成後，應用程式將具有以下功能：

- ✅ **真實註冊**：使用 Firebase Auth 創建帳號
- ✅ **真實登入**：驗證使用者憑證
- ✅ **自動登入**：記住登入狀態
- ✅ **錯誤處理**：顯示中文化的錯誤訊息
- ✅ **登出功能**：安全登出並清除狀態
- ✅ **資料持久化**：使用者資料存儲在 Firestore

## 🛠 故障排除

### 常見問題：

1. **模組未找到錯誤**
   - 確保 Firebase SDK 已正確安裝
   - 清理和重建專案（Cmd+Shift+K，然後 Cmd+B）

2. **GoogleService-Info.plist 未找到**
   - 確保檔案在 Xcode 專案中
   - 檢查檔案是否加入正確的 Target

3. **身份驗證失敗**
   - 檢查 Firebase Console 中的 Authentication 設定
   - 確保電子郵件/密碼登入已啟用

4. **Firestore 權限被拒絕**
   - 檢查 Firestore 安全規則
   - 確保使用者已經過身份驗證 