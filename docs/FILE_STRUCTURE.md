# 📋 MoodSync 檔案結構文件

## 1. 項目根目錄結構

```
MoodSync/
├── 📱 MoodSync/                    # 主要 App 目錄
├── 📋 MoodSyncTests/              # 單元測試
├── 🧪 MoodSyncUITests/            # UI 測試
├── 📄 README.md                   # 項目說明
├── 📄 .gitignore                  # Git 忽略文件
├── 📄 Package.swift               # SPM 依賴管理
├── 📄 .swiftlint.yml             # SwiftLint 配置
├── 📁 docs/                       # 文檔目錄
└── 📁 Resources/                  # 共享資源
```

## 2. 主要 App 目錄結構

### 2.1 完整目錄樹
```
MoodSync/
├── 🚀 App/                        # App 生命週期
│   ├── MoodSyncApp.swift          # App 入口點
│   ├── AppDelegate.swift          # App 委託
│   └── SceneDelegate.swift        # 場景委託
│
├── 📱 Views/                      # UI 視圖層
│   ├── Components/                # 可重用元件
│   │   ├── Buttons/
│   │   │   ├── PrimaryButton.swift
│   │   │   ├── SecondaryButton.swift
│   │   │   └── TextButton.swift
│   │   ├── Cards/
│   │   │   ├── StatusCard.swift
│   │   │   ├── MoodHistoryCard.swift
│   │   │   └── PartnerCard.swift
│   │   ├── Input/
│   │   │   ├── CustomTextField.swift
│   │   │   ├── EmojiPicker.swift
│   │   │   └── IntensitySlider.swift
│   │   └── Navigation/
│   │       ├── CustomTabBar.swift
│   │       └── NavigationHeader.swift
│   │
│   ├── Screens/                   # 完整頁面
│   │   ├── Auth/
│   │   │   ├── WelcomeView.swift
│   │   │   ├── LoginView.swift
│   │   │   ├── RegisterView.swift
│   │   │   └── ForgotPasswordView.swift
│   │   ├── Onboarding/
│   │   │   ├── ProfileSetupView.swift
│   │   │   └── PairingView.swift
│   │   ├── Main/
│   │   │   ├── DashboardView.swift
│   │   │   ├── MoodSelectionView.swift
│   │   │   ├── HistoryView.swift
│   │   │   └── SettingsView.swift
│   │   └── Modals/
│   │       ├── MoodDetailModal.swift
│   │       └── ProfileEditModal.swift
│   │
│   ├── Modifiers/                 # SwiftUI 修飾器
│   │   ├── ViewModifiers.swift
│   │   ├── ButtonStyles.swift
│   │   └── TextFieldStyles.swift
│   │
│   └── Utilities/                 # UI 工具
│       ├── ColorExtensions.swift
│       ├── FontExtensions.swift
│       └── ViewExtensions.swift
│
├── 🧠 ViewModels/                 # 視圖模型層
│   ├── Auth/
│   │   ├── AuthViewModel.swift
│   │   └── ProfileSetupViewModel.swift
│   ├── Main/
│   │   ├── DashboardViewModel.swift
│   │   ├── MoodSelectionViewModel.swift
│   │   ├── HistoryViewModel.swift
│   │   └── SettingsViewModel.swift
│   └── Shared/
│       ├── UserSessionViewModel.swift
│       └── NavigationViewModel.swift
│
├── 📊 Models/                     # 數據模型層
│   ├── Core/
│   │   ├── User.swift
│   │   ├── MoodStatus.swift
│   │   ├── Partnership.swift
│   │   └── MoodTemplate.swift
│   ├── Enums/
│   │   ├── AppState.swift
│   │   ├── MoodCategory.swift
│   │   ├── UserStatus.swift
│   │   └── NotificationType.swift
│   └── DTOs/
│       ├── LoginRequest.swift
│       ├── RegisterRequest.swift
│       └── MoodUpdateRequest.swift
│
├── 🔧 Services/                   # 服務層
│   ├── Firebase/
│   │   ├── AuthService.swift
│   │   ├── FirestoreService.swift
│   │   ├── StorageService.swift
│   │   └── MessagingService.swift
│   ├── Local/
│   │   ├── CoreDataService.swift
│   │   ├── UserDefaultsService.swift
│   │   └── KeychainService.swift
│   ├── Network/
│   │   ├── NetworkMonitor.swift
│   │   └── APIClient.swift
│   └── Utilities/
│       ├── ImageProcessor.swift
│       ├── DateFormatter.swift
│       └── ValidationService.swift
│
├── 🔗 Extensions/                 # 擴展
│   ├── Foundation/
│   │   ├── String+Extensions.swift
│   │   ├── Date+Extensions.swift
│   │   └── URL+Extensions.swift
│   ├── UIKit/
│   │   ├── UIColor+Extensions.swift
│   │   ├── UIImage+Extensions.swift
│   │   └── UIViewController+Extensions.swift
│   └── SwiftUI/
│       ├── View+Extensions.swift
│       ├── Color+Extensions.swift
│       └── Font+Extensions.swift
│
├── 🎨 Resources/                  # 資源文件
│   ├── Assets.xcassets/           # 圖片資源
│   │   ├── AppIcon.appiconset/
│   │   ├── Colors/
│   │   ├── Images/
│   │   └── Symbols/
│   ├── Localizable.strings        # 多語言文件
│   ├── GoogleService-Info.plist   # Firebase 配置
│   └── Info.plist                 # App 配置
│
├── 💾 CoreData/                   # Core Data 模型
│   ├── MoodSync.xcdatamodeld/
│   ├── CoreDataStack.swift
│   └── NSManagedObject+Extensions.swift
│
└── 🔧 Supporting Files/           # 支援文件
    ├── Constants.swift            # 常數定義
    ├── Configuration.swift        # 配置管理
    └── AppEnvironment.swift       # 環境設定
```

## 3. 命名規範

### 3.1 檔案命名

#### Swift 檔案
```swift
// Views (SwiftUI)
LoginView.swift
DashboardView.swift
MoodSelectionView.swift

// ViewModels
AuthViewModel.swift
DashboardViewModel.swift

// Models
User.swift
MoodStatus.swift

// Services
AuthService.swift
FirestoreService.swift

// Extensions
String+Extensions.swift
View+Extensions.swift
```

#### 資源檔案
```
// 圖片
icon_home.png
icon_settings.png
background_gradient.png

// 顏色
primary_color
secondary_color
accent_color
```

### 3.2 類別和結構命名

#### 視圖 (Views)
```swift
// 頁面級視圖
struct LoginView: View
struct DashboardView: View

// 元件級視圖
struct PrimaryButton: View
struct StatusCard: View

// 修飾器
struct PrimaryButtonStyle: ButtonStyle
```

#### 視圖模型 (ViewModels)
```swift
class AuthViewModel: ObservableObject
class DashboardViewModel: ObservableObject
class MoodSelectionViewModel: ObservableObject
```

#### 模型 (Models)
```swift
struct User: Codable, Identifiable
struct MoodStatus: Codable, Identifiable
enum MoodCategory: String, CaseIterable
```

#### 服務 (Services)
```swift
class AuthService
class FirestoreService
protocol NetworkServiceProtocol
```

### 3.3 變數和函數命名

#### 屬性
```swift
// 狀態屬性
@Published var isLoading: Bool
@Published var currentUser: User?
@Published var errorMessage: String?

// 私有屬性
private var cancellables = Set<AnyCancellable>()
private let authService = AuthService()
```

#### 函數
```swift
// 動作函數
func signIn(email: String, password: String)
func updateMoodStatus(_ mood: MoodStatus)
func loadMoodHistory()

// 私有輔助函數
private func validateInput() -> Bool
private func handleError(_ error: Error)
```

## 4. 資源組織

### 4.1 圖片資源
```
Assets.xcassets/
├── AppIcon.appiconset/            # App 圖示
├── LaunchImage.imageset/          # 啟動圖片
├── Colors/                        # 顏色資源
│   ├── PrimaryColor.colorset
│   ├── SecondaryColor.colorset
│   └── AccentColor.colorset
├── Icons/                         # 圖示
│   ├── TabBar/
│   │   ├── home.imageset
│   │   ├── history.imageset
│   │   └── settings.imageset
│   └── UI/
│       ├── plus.imageset
│       └── heart.imageset
└── Illustrations/                 # 插圖
    ├── welcome.imageset
    └── empty_state.imageset
```

### 4.2 多語言支援
```
Localizable.strings (繁體中文)
Localizable.strings (簡體中文)
Localizable.strings (English)

// 使用範例
"login.title" = "登入";
"login.email.placeholder" = "電子郵件";
"login.password.placeholder" = "密碼";
```

## 5. 配置文件

### 5.1 Info.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<dict>
    <key>CFBundleDisplayName</key>
    <string>MoodSync</string>
    <key>CFBundleIdentifier</key>
    <string>com.moodsync.app</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <!-- 其他配置 -->
</dict>
```

### 5.2 SwiftLint 配置
```yaml
# .swiftlint.yml
disabled_rules:
  - trailing_whitespace
  - line_length

opt_in_rules:
  - empty_count
  - closure_spacing
  - force_unwrapping

included:
  - MoodSync

excluded:
  - Pods
  - MoodSyncTests
  - MoodSyncUITests

line_length: 120
type_body_length: 300
function_body_length: 50
```

## 6. 測試檔案結構

### 6.1 單元測試
```
MoodSyncTests/
├── ViewModels/
│   ├── AuthViewModelTests.swift
│   ├── DashboardViewModelTests.swift
│   └── MoodSelectionViewModelTests.swift
├── Services/
│   ├── AuthServiceTests.swift
│   ├── FirestoreServiceTests.swift
│   └── ValidationServiceTests.swift
├── Models/
│   ├── UserTests.swift
│   └── MoodStatusTests.swift
└── Utilities/
    ├── TestHelpers.swift
    └── MockServices.swift
```

### 6.2 UI 測試
```
MoodSyncUITests/
├── AuthFlowTests.swift
├── DashboardTests.swift
├── MoodSelectionTests.swift
└── SettingsTests.swift
```

## 7. 文檔結構

### 7.1 文檔目錄
```
docs/
├── PROJECT_REQUIREMENTS.md       # 項目需求
├── FRONTEND_GUIDELINES.md        # 前端指南
├── BACKEND_STRUCTURE.md          # 後端架構
├── APP_FLOW.md                   # 應用流程
├── TECH_STACK.md                 # 技術棧
├── FILE_STRUCTURE.md             # 檔案結構
├── API_DOCUMENTATION.md          # API 文檔
├── DEPLOYMENT_GUIDE.md           # 部署指南
└── CHANGELOG.md                  # 更新日誌
```

## 8. 版本控制

### 8.1 Git 忽略文件
```gitignore
# Xcode
*.xcodeproj/*
!*.xcodeproj/project.pbxproj
!*.xcodeproj/xcshareddata/
!*.xcworkspace/contents.xcworkspacedata

# Firebase
GoogleService-Info.plist

# Dependencies
Pods/
Carthage/

# Build
build/
DerivedData/

# User settings
*.xcuserstate
*.xcuserdatad/
```

### 8.2 分支策略
```
main                    # 主分支 (生產環境)
├── develop            # 開發分支
├── feature/auth       # 功能分支
├── feature/dashboard  # 功能分支
├── hotfix/bug-fix     # 熱修復分支
└── release/v1.0.0     # 發布分支
```

## 9. 建構配置

### 9.1 Target 配置
```
MoodSync (主要 Target)
├── Debug 配置
│   ├── 開發環境 Firebase
│   ├── 詳細日誌
│   └── 調試符號
└── Release 配置
    ├── 生產環境 Firebase
    ├── 代碼優化
    └── 混淆處理
```

### 9.2 Scheme 配置
```
MoodSync
├── Run (Debug)
├── Test (Debug)
├── Profile (Release)
└── Archive (Release)
```

---

**檔案結構版本**: v1.0  
**最後更新**: 2024年12月  
**架構團隊**: MoodSync Architecture Team 