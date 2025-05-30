# 🎨 MoodSync 前端設計指南

## 1. 設計理念

### 1.1 核心價值
- **情感化設計**：溫暖、親密、舒適的感受
- **極簡主義**：去除複雜性，專注核心功能
- **直覺操作**：符合用戶心理模型的互動方式
- **情侶專屬**：私密而浪漫的視覺語言

### 1.2 設計原則
- **清晰明確** (Clarity)：每個元素都有明確目的
- **一致性** (Consistency)：統一的視覺和互動語言
- **反饋性** (Feedback)：即時的視覺和觸覺反饋
- **包容性** (Accessibility)：無障礙的設計標準

## 2. 視覺風格

### 2.1 色彩系統

#### 主色調 (Primary Colors)
```
- 主色：#FF6B9D (粉色系 - 代表愛情和溫暖)
- 輔助色：#A8E6CF (薄荷綠 - 代表平靜和理解)
- 強調色：#FFD93D (暖黃色 - 代表快樂和活力)
```

#### 中性色 (Neutral Colors)
```
- 深灰：#2C3E50 (文字主色)
- 中灰：#7F8C8D (輔助文字)
- 淺灰：#ECF0F1 (背景色)
- 白色：#FFFFFF (卡片背景)
```

#### 情緒色彩 (Emotion Colors)
```
- 快樂：#FFD93D (黃色)
- 愛意：#FF6B9D (粉色)
- 平靜：#A8E6CF (綠色)
- 難過：#74B9FF (藍色)
- 生氣：#FD79A8 (橘紅色)
- 焦慮：#FDCB6E (橙色)
```

#### 深色模式 (Dark Mode)
```
- 主背景：#1A1A1A
- 次背景：#2D2D2D
- 卡片背景：#3A3A3A
- 文字主色：#FFFFFF
- 文字次色：#B0B0B0
```

### 2.2 字體系統

#### 字體族 (Font Family)
```
- 主字體：SF Pro Display (iOS 系統字體)
- 輔助字體：SF Pro Text
- 數字字體：SF Mono (用於時間和數據)
```

#### 字體大小 (Font Sizes)
```
- 大標題：28pt (Bold)
- 標題：22pt (Semibold)
- 副標題：18pt (Medium)
- 正文：16pt (Regular)
- 輔助文字：14pt (Regular)
- 說明文字：12pt (Light)
```

#### 行距 (Line Heights)
```
- 大標題：1.2
- 標題：1.3
- 正文：1.5
- 輔助文字：1.4
```

### 2.3 間距系統

#### 基礎單位 (Base Unit)
```
基礎單位：8pt
```

#### 間距比例 (Spacing Scale)
```
- xs: 4pt (0.5x)
- sm: 8pt (1x)
- md: 16pt (2x)
- lg: 24pt (3x)
- xl: 32pt (4x)
- xxl: 48pt (6x)
```

#### 頁面邊距 (Page Margins)
```
- 左右邊距：20pt
- 上下邊距：24pt
- 元件間距：16pt
```

## 3. 元件庫 (Component Library)

### 3.1 按鈕 (Buttons)

#### 主要按鈕 (Primary Button)
```swift
// 樣式規範
- 背景色：主色 (#FF6B9D)
- 文字色：白色
- 圓角：12pt
- 高度：48pt
- 字體：16pt Semibold
- 觸摸回饋：0.95 縮放動畫
```

#### 次要按鈕 (Secondary Button)
```swift
// 樣式規範
- 背景色：透明
- 邊框：2pt 主色
- 文字色：主色
- 圓角：12pt
- 高度：48pt
- 字體：16pt Medium
```

#### 文字按鈕 (Text Button)
```swift
// 樣式規範
- 背景色：透明
- 文字色：主色
- 字體：16pt Medium
- 最小點擊區域：44x44pt
```

### 3.2 輸入元件 (Input Components)

#### 文字輸入框 (Text Field)
```swift
// 樣式規範
- 背景色：淺灰 (#F8F9FA)
- 邊框：1pt 透明 (正常狀態)
- 邊框：2pt 主色 (聚焦狀態)
- 圓角：8pt
- 高度：48pt
- 內邊距：16pt (左右)
- 佔位符顏色：中灰
```

#### Emoji 選擇器
```swift
// 樣式規範
- 網格佈局：6 列
- Emoji 大小：32pt
- 選中狀態：圓形背景 + 縮放效果
- 間距：12pt
- 分類標籤：18pt Semibold
```

### 3.3 卡片元件 (Cards)

#### 狀態卡片 (Status Card)
```swift
// 樣式規範
- 背景色：白色
- 陰影：(0, 2, 8, rgba(0,0,0,0.1))
- 圓角：16pt
- 內邊距：20pt
- 邊框：無
```

#### 情緒歷史卡片
```swift
// 樣式規範
- 背景色：白色
- 圓角：12pt
- 內邊距：16pt
- 左側色條：4pt 寬度，對應情緒色彩
```

### 3.4 導航元件 (Navigation)

#### 標籤欄 (Tab Bar)
```swift
// 樣式規範
- 背景色：白色 (淺色模式) / #2D2D2D (深色模式)
- 高度：83pt (包含安全區域)
- 圖示大小：24pt
- 選中色：主色
- 未選中色：中灰
- 圓角：頂部 20pt
```

#### 導航欄 (Navigation Bar)
```swift
// 樣式規範
- 背景色：透明
- 標題字體：18pt Semibold
- 按鈕字體：16pt Medium
- 高度：44pt + 安全區域
```

### 3.5 通知元件 (Notifications)

#### Toast 通知
```swift
// 樣式規範
- 背景色：深灰半透明
- 文字色：白色
- 圓角：12pt
- 內邊距：16pt (左右), 12pt (上下)
- 最大寬度：螢幕寬度 - 40pt
- 動畫：淡入淡出 + 滑動
```

#### Banner 通知
```swift
// 樣式規範
- 背景色：主色
- 文字色：白色
- 高度：64pt
- 內邊距：20pt
- 位置：頂部安全區域下方
```

## 4. 互動設計

### 4.1 動畫效果

#### 頁面轉場
```swift
// 導航轉場
- 推入：右滑進入，左滑退出
- 模態：底部滑入，向下滑出
- 時長：0.3s
- 緩動：ease-in-out
```

#### 元件動畫
```swift
// 按鈕點擊
- 縮放：0.95 (0.1s)
- 回彈：1.0 (0.1s)

// Emoji 選擇
- 放大：1.2 (0.2s)
- 回彈：1.0 (0.1s)
- 背景：淡入淡出 (0.2s)
```

### 4.2 手勢操作

#### 支援手勢
```
- 點擊：主要互動方式
- 長按：快速操作選單
- 滑動：列表滾動、頁面導航
- 捏合：縮放檢視（歷史圖表）
```

#### 觸覺回饋
```swift
// 回饋類型
- 輕觸：UIImpactFeedbackGenerator.light
- 成功：UINotificationFeedbackGenerator.success
- 錯誤：UINotificationFeedbackGenerator.error
- 選擇：UISelectionFeedbackGenerator
```

## 5. 響應式設計

### 5.1 設備適配

#### iPhone 尺寸適配
```
- iPhone SE (375x667): 緊湊佈局
- iPhone 標準 (390x844): 標準佈局
- iPhone Plus (428x926): 寬鬆佈局
- iPhone Pro Max (430x932): 最大化利用空間
```

#### 安全區域
```swift
// 佈局規則
- 遵循 safeAreaLayoutGuide
- 底部標籤欄預留空間
- 頂部狀態欄考慮劉海
```

### 5.2 方向適配

#### 直屏模式 (Portrait)
```
- 主要支援方向
- 標準佈局設計
- 單欄式內容排列
```

#### 橫屏模式 (Landscape)
```
- 部分頁面支援
- 雙欄式佈局
- 內容重新排列
```

## 6. 無障礙設計

### 6.1 視覺無障礙

#### 色彩對比
```
- 正常文字：至少 4.5:1
- 大文字：至少 3:1
- 重要元素：至少 7:1
```

#### 字體大小
```
- 支援動態字體大小
- 最小可讀尺寸：12pt
- 最大支援：200% 縮放
```

### 6.2 操作無障礙

#### VoiceOver 支援
```swift
// 無障礙標籤
- accessibilityLabel：描述元件功能
- accessibilityHint：使用提示
- accessibilityValue：當前值
- accessibilityTraits：元件類型
```

#### 點擊區域
```
- 最小點擊區域：44x44pt
- 重要按鈕：適當增大
- 間距充足避免誤觸
```

## 7. 性能優化

### 7.1 圖片優化
```
- 使用 SF Symbols 代替點陣圖
- SVG 格式向量圖
- @2x, @3x 多解析度支援
- 懶載入大圖片
```

### 7.2 動畫優化
```
- 使用 Core Animation
- 避免同時多個複雜動畫
- 60fps 流暢度目標
- 低電量模式適配
```

## 8. 開發規範

### 8.1 檔案結構
```
Views/
├── Components/          # 可重用元件
├── Screens/            # 完整頁面
├── Modifiers/          # SwiftUI 修飾器
└── Utilities/          # 工具類別
```

### 8.2 命名規範
```swift
// SwiftUI View
struct MoodSelectionView: View

// 元件名稱
struct PrimaryButton: View
struct StatusCard: View

// 修飾器
extension View {
    func primaryButtonStyle() -> some View
}
```

### 8.3 代碼風格
```swift
// 使用 SwiftUI 優先
// 遵循 Apple 設計指南
// 保持代碼簡潔易讀
// 適當註釋說明
```

---

**設計指南版本**: v1.0  
**最後更新**: 2024年12月  
**設計團隊**: MoodSync Design Team 