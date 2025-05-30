# MoodSync App UI/UX 設計規劃

## 🎨 色彩與風格指引

### 主色調系統
```
主色 (Primary): #D4A574 (溫暖棕橙)
副色 (Secondary): #E8C5A0 (淺米色)
強調色 (Accent): #C98B5A (深橙棕)
背景色 (Background): #F5F1EB (象牙白)
卡片背景 (Card): #FFFFFF (純白)
文字主色 (Text Primary): #5D4E37 (深棕)
文字副色 (Text Secondary): #8B7355 (中棕)
成功色 (Success): #A8B894 (柔和草綠)
警告色 (Warning): #E6B17A (柔和橙)
錯誤色 (Error): #D4A5A5 (柔和粉紅)
```

### 字體系統
- **主標題**: SF Pro Display, Bold, 28pt
- **副標題**: SF Pro Display, Semibold, 20pt
- **內文**: SF Pro Text, Regular, 16pt
- **說明文字**: SF Pro Text, Regular, 14pt
- **按鈕文字**: SF Pro Text, Medium, 16pt

### UI 元件風格
- **圓角半徑**: 16px (大卡片), 12px (按鈕), 8px (小元件)
- **陰影**: offset(0, 4), blur(12), color(.black.opacity(0.08))
- **間距系統**: 8px, 16px, 24px, 32px, 48px
- **按鈕高度**: 56px (主要), 44px (次要)

---

## 📱 第一批畫面設計 (1-3)

### 1. 歡迎頁 (Welcome Screen)

#### 🖼️ Wireframe 描述
```
┌─────────────────────────────────────┐
│              [Logo Area]             │
│                                     │
│         MoodSync 💕                 │
│                                     │
│      [Illustration: 兩個人心型圖案]     │
│                                     │
│         「與你最愛的人，                │
│          同步每個心情時刻」              │
│                                     │
│                                     │
│        [開始使用 按鈕]                 │
│                                     │
│        [已有帳號？登入]                │
└─────────────────────────────────────┘
```

#### 🎨 色彩配置
- **背景**: 漸層從 #F5F1EB 到 #E8C5A0
- **Logo 文字**: #D4A574
- **主標題**: #5D4E37
- **副標題**: #8B7355
- **主按鈕**: #D4A574 背景，#FFFFFF 文字
- **次按鈕**: 透明背景，#D4A574 文字

#### 📐 SwiftUI 元件建議
```swift
VStack(spacing: 32) {
    Spacer()
    
    // Logo 區域
    VStack(spacing: 16) {
        Image(systemName: "heart.fill")
        Text("MoodSync")
    }
    
    // 插圖區域
    ZStack {
        // 自定義插圖或 Lottie 動畫
    }
    
    // 文字說明
    VStack(spacing: 8) {
        Text("與你最愛的人，")
        Text("同步每個心情時刻")
    }
    
    Spacer()
    
    // 按鈕組
    VStack(spacing: 16) {
        Button("開始使用") { }
            .buttonStyle(PrimaryButtonStyle())
        
        Button("已有帳號？登入") { }
            .buttonStyle(SecondaryButtonStyle())
    }
    .padding(.horizontal, 24)
}
```

#### 💡 設計說明
- 使用溫暖漸層背景營造舒適感
- 簡潔的文字說明，強調情侶連結
- 大按鈕設計，易於觸控
- 插圖可使用情侶、心型等元素

---

### 2. 登入與註冊畫面 (Login / Sign Up)

#### 🖼️ Wireframe 描述
```
┌─────────────────────────────────────┐
│            ← [返回]                  │
│                                     │
│              歡迎回來 💕              │
│                                     │
│         [Email 輸入框]               │
│                                     │
│         [密碼 輸入框]                 │
│                                     │
│              [登入按鈕]               │
│                                     │
│         [忘記密碼？]                  │
│                                     │
│            ─── 或 ───                │
│                                     │
│        [Google 登入按鈕]             │
│        [Apple 登入按鈕]              │
│                                     │
│        [還沒有帳號？註冊]              │
└─────────────────────────────────────┘
```

#### 🎨 色彩配置
- **背景**: #F5F1EB
- **卡片背景**: #FFFFFF
- **輸入框邊框**: #E8C5A0 (正常), #D4A574 (焦點)
- **輸入框文字**: #5D4E37
- **佔位符文字**: #8B7355
- **主按鈕**: #D4A574 背景
- **社交登入按鈕**: #FFFFFF 背景，#5D4E37 邊框

#### 📐 SwiftUI 元件建議
```swift
VStack(spacing: 24) {
    // 頂部導航
    HStack {
        Button(action: {}) {
            Image(systemName: "chevron.left")
        }
        Spacer()
    }
    
    Spacer()
    
    // 主要內容卡片
    VStack(spacing: 24) {
        // 標題
        VStack(spacing: 8) {
            Text("歡迎回來")
            Text("💕")
        }
        
        // 輸入欄位
        VStack(spacing: 16) {
            CustomTextField("電子郵件", text: $email)
            CustomSecureField("密碼", text: $password)
        }
        
        // 登入按鈕
        Button("登入") { }
            .buttonStyle(PrimaryButtonStyle())
        
        // 忘記密碼
        Button("忘記密碼？") { }
            .buttonStyle(TextButtonStyle())
        
        // 分隔線
        HStack {
            Rectangle().frame(height: 1)
            Text("或")
            Rectangle().frame(height: 1)
        }
        
        // 社交登入
        VStack(spacing: 12) {
            SocialLoginButton("使用 Google 登入", icon: "google")
            SocialLoginButton("使用 Apple 登入", icon: "apple")
        }
        
        // 註冊連結
        Button("還沒有帳號？註冊") { }
            .buttonStyle(TextButtonStyle())
    }
    .padding(24)
    .background(Color.white)
    .cornerRadius(24)
    
    Spacer()
}
.padding(.horizontal, 24)
```

#### 💡 設計說明
- 卡片式設計增加層次感
- 清晰的輸入框設計，提供良好的焦點狀態
- 提供多種登入方式
- 溫馨的 emoji 增加親和力

---

### 3. 主畫面 (Dashboard - 雙人心情狀態)

#### 🖼️ Wireframe 描述
```
┌─────────────────────────────────────┐
│  [個人頭像]  MoodSync  [設定] ⚙️      │
│                                     │
│              今天心情如何？             │
│                                     │
│  ┌─────────────┐  ┌─────────────┐    │
│  │     你       │  │    對方      │    │
│  │             │  │             │    │
│  │    😊       │  │     😔      │    │
│  │   開心       │  │   有點累     │    │
│  │             │  │             │    │
│  │ [更新心情]    │  │  2分鐘前更新  │    │
│  └─────────────┘  └─────────────┘    │
│                                     │
│            快速心情選擇               │
│                                     │
│   😊  😢  😡  😴  💕  😅  🤔  😌      │
│                                     │
│              ──────                 │
│                                     │
│            💌 今日心情筆記             │
│                                     │
│  ┌─────────────────────────────────┐  │
│  │ "今天工作有點累，但看到你傳的照片     │  │
│  │  就覺得很溫暖 💕"                  │  │
│  │                        [編輯]   │  │
│  └─────────────────────────────────┘  │
│                                     │
│        [查看心情歷史] [配對設定]        │
└─────────────────────────────────────┘
```

#### 🎨 色彩配置
- **背景**: #F5F1EB
- **頂部導航**: #FFFFFF
- **心情卡片背景**: #FFFFFF
- **你的卡片邊框**: #A8B894 (成功色)
- **對方卡片邊框**: #E6B17A (溫暖橙)
- **心情 emoji 背景**: #E8C5A0
- **筆記卡片**: #FFFFFF
- **快速選擇按鈕**: #E8C5A0 (未選中), #D4A574 (已選中)

#### 📐 SwiftUI 元件建議
```swift
VStack(spacing: 0) {
    // 頂部導航欄
    HStack {
        ProfileImageView(size: 40)
        
        Text("MoodSync")
            .font(.title2)
            .fontWeight(.semibold)
        
        Spacer()
        
        Button(action: {}) {
            Image(systemName: "gearshape.fill")
        }
    }
    .padding(.horizontal, 24)
    .padding(.vertical, 16)
    .background(Color.white)
    
    ScrollView {
        VStack(spacing: 24) {
            // 標題
            Text("今天心情如何？")
                .font(.title2)
                .fontWeight(.semibold)
            
            // 雙人心情卡片
            HStack(spacing: 16) {
                MoodCard(
                    title: "你",
                    emoji: "😊",
                    mood: "開心",
                    action: "更新心情",
                    isCurrentUser: true
                )
                
                MoodCard(
                    title: "對方",
                    emoji: "😔", 
                    mood: "有點累",
                    action: "2分鐘前更新",
                    isCurrentUser: false
                )
            }
            
            // 快速心情選擇
            VStack(spacing: 16) {
                Text("快速心情選擇")
                    .font(.headline)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                    ForEach(quickMoods, id: \.self) { emoji in
                        MoodQuickButton(emoji: emoji)
                    }
                }
            }
            
            // 今日心情筆記
            VStack(alignment: .leading, spacing: 12) {
                Text("💌 今日心情筆記")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("今天工作有點累，但看到你傳的照片就覺得很溫暖 💕")
                        .font(.body)
                    
                    HStack {
                        Spacer()
                        Button("編輯") { }
                            .buttonStyle(TextButtonStyle())
                    }
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(12)
            }
            
            // 底部功能按鈕
            HStack(spacing: 16) {
                Button("查看心情歷史") { }
                    .buttonStyle(SecondaryButtonStyle())
                
                Button("配對設定") { }
                    .buttonStyle(SecondaryButtonStyle())
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
    }
}
```

#### 💡 設計說明
- 雙卡片設計清楚區分自己與對方的狀態
- 大 emoji 顯示，直觀表達情緒
- 快速選擇區讓用戶能快速更新心情
- 心情筆記功能增加情感深度
- 圓角卡片與柔和陰影營造溫馨感

---

## 🔄 使用流程說明

### 第一次使用流程
1. **歡迎頁** → 點擊「開始使用」
2. **註冊畫面** → 填寫資料並註冊
3. **配對畫面** → 與伴侶配對
4. **主畫面** → 開始同步心情

### 日常使用流程
1. **主畫面** → 查看對方當前心情
2. **點擊更新心情** → 選擇 emoji 和簡短描述
3. **查看心情歷史** → 了解情緒變化趨勢
4. **編寫心情筆記** → 記錄當日感受

---

## 📋 下一批畫面預告 (4-6)
- emoji 選擇器 (豐富的情緒表達選項)
- 生氣原因設定 (預設情況選擇)
- 情緒歷史紀錄 (時間軸式顯示)

---

*本設計遵循 iOS Human Interface Guidelines，並針對情感連結 App 進行最佳化設計。* 