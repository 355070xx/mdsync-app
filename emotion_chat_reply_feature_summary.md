# 冷靜通道回覆標籤功能

## 📝 功能概述

在冷靜通道中，用戶現在可以對特定類型的訊息進行回覆，例如道歉、擁抱或拒絕訊息。這個功能允許接收者表達他們對訊息的回應，促進更好的溝通。

## 🎯 功能特點

### 可回覆的訊息類型
- `apology` (道歉) 🙏
- `hug` (擁抱) 🫂
- `reject` (拒絕) ❌

### 回覆選項
- ✅ **接受** (`accepted`) - 表示接受對方的道歉/擁抱/請求
- 🕓 **稍後再回應** (`later`) - 表示暫時不想回應，需要更多時間

## 🧱 技術實現

### 數據結構
```swift
struct EmotionChatMessage {
    // ... 原有欄位 ...
    let replyStatus: ReplyStatus?     // 回覆狀態
    let replyByUID: String?          // 回覆者的 UID
}

enum ReplyStatus: String, CaseIterable, Codable {
    case accepted = "accepted"       // 接受
    case later = "later"             // 稍後再回應
}
```

### Firestore 結構
```
emotionChats/{pairID}/messages/{messageID}
{
  fromUID: string,
  fromName: string,
  emoji: string?,
  text: string?,
  type: "apology" | "hug" | "reject" | "message" | "neutral",
  createdAt: timestamp,
  expiresAt: timestamp,
  replyStatus: "accepted" | "later" | null,
  replyByUID: string | null
}
```

## 🔒 安全規則

Firestore 規則確保：
1. 只有配對的用戶可以回覆訊息
2. 用戶不能回覆自己的訊息
3. 每個訊息只能被回覆一次
4. 只能更新 `replyStatus` 和 `replyByUID` 欄位
5. 回覆者的 UID 必須匹配當前用戶

## 🎨 UI 設計

### 回覆按鈕
- 只在符合條件的訊息下方顯示
- 包含「回覆這段訊息？」提示文字
- 兩個按鈕：「✅ 接受」和「🕓 稍後再回應」

### 回覆狀態顯示
- 已回覆的訊息會顯示回覆狀態
- 格式：「你/對方 + 接受/選擇稍後再回應 + 這個道歉/擁抱/拒絕」
- 帶有對應的 emoji 圖示

## 📱 使用流程

1. **發送可回覆訊息**
   - 用戶 A 發送道歉、擁抱或拒絕類型的訊息

2. **顯示回覆選項**
   - 用戶 B 看到訊息下方的回覆按鈕
   - 只有對方的訊息且未被回覆過才顯示

3. **進行回覆**
   - 用戶 B 點選「接受」或「稍後再回應」
   - 系統更新訊息的回覆狀態

4. **顯示回覆結果**
   - 雙方都能看到回覆狀態
   - 回覆按鈕消失，不能重複回覆

## 🧠 注意事項

### 限制條件
- 一個訊息只能被回覆一次
- 用戶只能回覆對方發的訊息，不能回覆自己發的
- 只有特定類型的訊息可以被回覆
- 訊息過期後仍可查看回覆狀態

### 相容性
- 保留原有的快速回應功能
- 不影響現有的訊息發送和接收功能
- 與現有的通知系統整合

## 🔧 維護和擴展

### 未來可能的增強
- 添加更多回覆選項
- 支援自定義回覆文字
- 回覆統計和分析功能
- 回覆提醒功能

### 監控指標
- 回覆率統計
- 不同回覆類型的使用頻率
- 功能使用情況分析 