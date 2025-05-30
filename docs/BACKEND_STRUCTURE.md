# 🗄️ MoodSync 後端架構文件

## 1. 架構概覽

### 1.1 後端服務選擇
**Firebase** - Google 提供的無伺服器後端服務平台

#### 選擇原因
- **快速開發**：無需自建後端服務器
- **即時同步**：Firestore 實時數據庫
- **身份驗證**：完整的用戶管理系統
- **擴展性**：自動擴展，按需付費
- **安全性**：內建安全規則和加密

### 1.2 使用的 Firebase 服務
- **Firebase Authentication**：用戶身份驗證
- **Cloud Firestore**：NoSQL 文檔數據庫
- **Firebase Cloud Messaging (FCM)**：推送通知
- **Firebase Storage**：文件存儲（頭像圖片）
- **Firebase Analytics**：用戶行為分析

## 2. 數據庫設計

### 2.1 Firestore 集合結構

```
📁 firestore-database
├── 👥 users/                    # 用戶集合
│   └── [userID]/               # 用戶文檔
│       ├── partnerships/       # 子集合：配對關係
│       └── moods/             # 子集合：情緒記錄
├── 🤝 partnerships/            # 配對關係集合
└── 📊 analytics/              # 分析數據集合
```

### 2.2 數據模型詳細設計

#### 用戶 (Users Collection)
```typescript
// Path: users/{userID}
interface User {
  userID: string;           // 用戶唯一識別碼
  email: string;            // 電子郵件
  displayName: string;      // 顯示名稱
  avatarURL?: string;       // 頭像 URL
  partnerID?: string;       // 伴侶 ID
  settings: {
    theme: 'light' | 'dark' | 'auto';        // 主題設定
    notifications: {
      enabled: boolean;                       // 通知開關
      doNotDisturbStart?: string;            // 免打擾開始時間
      doNotDisturbEnd?: string;              // 免打擾結束時間
      sound: boolean;                        // 聲音開關
    };
    privacy: {
      shareHistory: boolean;                 // 分享歷史記錄
      analyticsOptIn: boolean;               // 分析數據選擇加入
    };
  };
  metadata: {
    createdAt: Timestamp;                    // 創建時間
    lastActive: Timestamp;                   // 最後活動時間
    version: string;                         // App 版本
    platform: 'ios' | 'android';           // 平台
  };
}
```

#### 配對關係 (Partnerships Collection)
```typescript
// Path: partnerships/{partnershipID}
interface Partnership {
  partnershipID: string;    // 配對關係 ID
  users: {
    user1: {
      userID: string;       // 用戶1 ID
      displayName: string;  // 用戶1 顯示名稱
      joinedAt: Timestamp;  // 加入時間
    };
    user2: {
      userID: string;       // 用戶2 ID
      displayName: string;  // 用戶2 顯示名稱
      joinedAt: Timestamp;  // 加入時間
    };
  };
  status: 'pending' | 'active' | 'inactive'; // 狀態
  inviteCode: string;       // 邀請碼
  createdAt: Timestamp;     // 創建時間
  metadata: {
    inviteExpiry: Timestamp;  // 邀請過期時間
    createdBy: string;        // 創建者 ID
  };
}
```

#### 情緒狀態 (Moods Subcollection)
```typescript
// Path: users/{userID}/moods/{moodID}
interface MoodStatus {
  moodID: string;           // 情緒狀態 ID
  userID: string;           // 用戶 ID
  emotion: {
    emoji: string;          // 表情符號
    category: 'happy' | 'sad' | 'angry' | 'anxious' | 'calm' | 'love'; // 情緒分類
    intensity: number;      // 強度 (1-5)
  };
  message?: string;         // 文字訊息 (最多50字)
  context?: {
    template?: string;      // 預設模板 ID
    tags?: string[];        // 標籤
    location?: string;      // 位置資訊
  };
  timestamp: Timestamp;     // 時間戳記
  isActive: boolean;        // 是否為當前狀態
  privacy: {
    isPrivate: boolean;     // 是否私人
    visibleTo?: string[];   // 可見對象 (目前只有伴侶)
  };
}
```

#### 情緒模板 (Templates Subcollection)
```typescript
// Path: templates/{templateID}
interface MoodTemplate {
  templateID: string;       // 模板 ID
  name: string;            // 模板名稱
  emoji: string;           // 預設 emoji
  message: string;         // 預設訊息
  category: string;        // 分類
  isDefault: boolean;      // 是否為系統預設
  usageCount: number;      // 使用次數
  createdAt: Timestamp;    // 創建時間
}
```

### 2.3 安全規則 (Security Rules)

#### Firestore 安全規則
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // 用戶文檔規則
    match /users/{userID} {
      // 只允許用戶讀寫自己的文檔
      allow read, write: if request.auth != null && request.auth.uid == userID;
      
      // 情緒子集合規則
      match /moods/{moodID} {
        // 用戶可以讀寫自己的情緒
        allow read, write: if request.auth != null && request.auth.uid == userID;
        
        // 伴侶可以讀取（如果設定為可見）
        allow read: if request.auth != null && 
                   isPartner(request.auth.uid, userID) &&
                   resource.data.privacy.isPrivate == false;
      }
    }
    
    // 配對關係規則
    match /partnerships/{partnershipID} {
      // 只允許參與者讀寫
      allow read, write: if request.auth != null && 
                        (request.auth.uid in resource.data.users.user1.userID ||
                         request.auth.uid in resource.data.users.user2.userID);
    }
    
    // 模板規則（只讀）
    match /templates/{templateID} {
      allow read: if request.auth != null;
    }
    
    // 檢查是否為伴侶的函數
    function isPartner(currentUserID, targetUserID) {
      return exists(/databases/$(database)/documents/users/$(currentUserID)) &&
             get(/databases/$(database)/documents/users/$(currentUserID)).data.partnerID == targetUserID;
    }
  }
}
```

## 3. API 服務層

### 3.1 Authentication Service

#### 用戶註冊
```swift
class AuthService {
    private let auth = Auth.auth()
    
    func signUp(email: String, password: String, displayName: String) async throws -> User {
        // 1. 創建 Firebase Auth 用戶
        let result = try await auth.createUser(withEmail: email, password: password)
        
        // 2. 更新用戶資料
        let changeRequest = result.user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
        
        // 3. 在 Firestore 創建用戶文檔
        let userData = User(
            userID: result.user.uid,
            email: email,
            displayName: displayName,
            settings: UserSettings.default(),
            metadata: UserMetadata.current()
        )
        
        try await FirestoreService.shared.createUser(userData)
        
        return userData
    }
}
```

#### 用戶登入
```swift
func signIn(email: String, password: String) async throws -> User {
    // 1. Firebase Auth 登入
    let result = try await auth.signIn(withEmail: email, password: password)
    
    // 2. 獲取用戶資料
    let userData = try await FirestoreService.shared.getUser(result.user.uid)
    
    // 3. 更新最後活動時間
    try await FirestoreService.shared.updateLastActive(result.user.uid)
    
    return userData
}
```

### 3.2 Firestore Service

#### 基礎操作類
```swift
class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    // MARK: - User Operations
    
    func createUser(_ user: User) async throws {
        try await db.collection("users").document(user.userID).setData(from: user)
    }
    
    func getUser(_ userID: String) async throws -> User {
        let document = try await db.collection("users").document(userID).getDocument()
        return try document.data(as: User.self)
    }
    
    func updateUser(_ user: User) async throws {
        try await db.collection("users").document(user.userID).setData(from: user, merge: true)
    }
    
    // MARK: - Partnership Operations
    
    func createPartnership(_ partnership: Partnership) async throws {
        try await db.collection("partnerships").document(partnership.partnershipID).setData(from: partnership)
    }
    
    func getPartnership(_ partnershipID: String) async throws -> Partnership {
        let document = try await db.collection("partnerships").document(partnershipID).getDocument()
        return try document.data(as: Partnership.self)
    }
    
    // MARK: - Mood Operations
    
    func saveMoodStatus(_ mood: MoodStatus) async throws {
        // 1. 設定當前情緒為非活動狀態
        try await deactivateCurrentMood(for: mood.userID)
        
        // 2. 保存新情緒狀態
        try await db.collection("users")
            .document(mood.userID)
            .collection("moods")
            .document(mood.moodID)
            .setData(from: mood)
    }
    
    private func deactivateCurrentMood(for userID: String) async throws {
        let query = db.collection("users")
            .document(userID)
            .collection("moods")
            .whereField("isActive", isEqualTo: true)
        
        let snapshot = try await query.getDocuments()
        
        for document in snapshot.documents {
            try await document.reference.updateData(["isActive": false])
        }
    }
}
```

### 3.3 Real-time Listeners

#### 伴侶狀態監聽
```swift
class PartnerStatusListener: ObservableObject {
    @Published var partnerMood: MoodStatus?
    @Published var isPartnerOnline: Bool = false
    
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    func startListening(to partnerID: String) {
        // 監聽伴侶的當前情緒狀態
        listener = db.collection("users")
            .document(partnerID)
            .collection("moods")
            .whereField("isActive", isEqualTo: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let documents = snapshot?.documents else { return }
                
                if let moodData = documents.first {
                    do {
                        self?.partnerMood = try moodData.data(as: MoodStatus.self)
                    } catch {
                        print("Error decoding partner mood: \(error)")
                    }
                }
            }
    }
    
    func stopListening() {
        listener?.remove()
        listener = nil
    }
}
```

## 4. 推送通知

### 4.1 FCM 設定

#### 通知類型
```swift
enum NotificationType: String, CaseIterable {
    case partnerMoodUpdate = "partner_mood_update"
    case partnerOnline = "partner_online"
    case partnerOffline = "partner_offline"
    case partnershipRequest = "partnership_request"
}
```

#### 通知發送
```swift
class PushNotificationService {
    static let shared = PushNotificationService()
    
    func sendMoodUpdateNotification(to partnerToken: String, mood: MoodStatus) async {
        let notification = PushNotification(
            to: partnerToken,
            notification: NotificationPayload(
                title: "💕 伴侶狀態更新",
                body: "\(mood.emotion.emoji) 你的伴侶更新了情緒狀態",
                sound: "default"
            ),
            data: [
                "type": NotificationType.partnerMoodUpdate.rawValue,
                "moodID": mood.moodID,
                "userID": mood.userID
            ]
        )
        
        // 發送到 FCM
        try await FCMService.send(notification)
    }
}
```

## 5. 離線支援

### 5.1 本地緩存

#### Core Data 模型
```swift
// 本地緩存用戶數據
@Entity
class CachedUser: NSManagedObject {
    @NSManaged var userID: String
    @NSManaged var displayName: String
    @NSManaged var email: String
    @NSManaged var avatarURL: String?
    @NSManaged var lastSyncDate: Date
}

// 本地緩存情緒數據
@Entity
class CachedMood: NSManagedObject {
    @NSManaged var moodID: String
    @NSManaged var userID: String
    @NSManaged var emoji: String
    @NSManaged var message: String?
    @NSManaged var timestamp: Date
    @NSManaged var isSynced: Bool
}
```

#### 離線同步邏輯
```swift
class OfflineSyncService {
    func syncPendingData() async {
        // 1. 檢查網路連線
        guard NetworkMonitor.shared.isConnected else { return }
        
        // 2. 同步未上傳的情緒數據
        let pendingMoods = try await getCachedUnsyncedMoods()
        for mood in pendingMoods {
            do {
                try await FirestoreService.shared.saveMoodStatus(mood)
                try await markMoodAsSynced(mood.moodID)
            } catch {
                print("Failed to sync mood: \(error)")
            }
        }
        
        // 3. 同步最新的伴侶數據
        try await syncPartnerData()
    }
}
```

## 6. 性能優化

### 6.1 數據查詢優化

#### 索引設定
```
// Firestore 複合索引
Collection: users/{userID}/moods
Fields: isActive (Ascending), timestamp (Descending)

Collection: partnerships
Fields: status (Ascending), createdAt (Descending)
```

#### 分頁查詢
```swift
func getMoodHistory(for userID: String, limit: Int = 20, lastDocument: DocumentSnapshot? = nil) async throws -> ([MoodStatus], DocumentSnapshot?) {
    var query = db.collection("users")
        .document(userID)
        .collection("moods")
        .order(by: "timestamp", descending: true)
        .limit(to: limit)
    
    if let lastDocument = lastDocument {
        query = query.start(afterDocument: lastDocument)
    }
    
    let snapshot = try await query.getDocuments()
    let moods = try snapshot.documents.map { try $0.data(as: MoodStatus.self) }
    
    return (moods, snapshot.documents.last)
}
```

### 6.2 網路使用優化

#### 壓縮和緩存
```swift
// 圖片壓縮上傳
func uploadAvatar(_ image: UIImage) async throws -> String {
    // 1. 壓縮圖片
    guard let imageData = image.jpegData(compressionQuality: 0.7) else {
        throw UploadError.compressionFailed
    }
    
    // 2. 上傳到 Firebase Storage
    let storageRef = Storage.storage().reference()
    let avatarRef = storageRef.child("avatars/\(UUID().uuidString).jpg")
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    
    _ = try await avatarRef.putDataAsync(imageData, metadata: metadata)
    
    // 3. 獲取下載 URL
    let downloadURL = try await avatarRef.downloadURL()
    return downloadURL.absoluteString
}
```

## 7. 監控和分析

### 7.1 錯誤追蹤

#### Crashlytics 整合
```swift
import FirebaseCrashlytics

class ErrorTracker {
    static func log(_ error: Error, context: [String: Any] = [:]) {
        Crashlytics.crashlytics().record(error: error)
        
        for (key, value) in context {
            Crashlytics.crashlytics().setCustomValue(value, forKey: key)
        }
    }
    
    static func logNonFatal(_ message: String, context: [String: Any] = [:]) {
        let error = NSError(domain: "MoodSyncError", code: 0, userInfo: [
            NSLocalizedDescriptionKey: message
        ])
        
        Crashlytics.crashlytics().record(error: error)
    }
}
```

### 7.2 使用分析

#### Analytics 事件
```swift
enum AnalyticsEvent {
    case moodCreated(category: String, intensity: Int)
    case partnershipCreated
    case notificationReceived(type: String)
    
    var name: String {
        switch self {
        case .moodCreated: return "mood_created"
        case .partnershipCreated: return "partnership_created"
        case .notificationReceived: return "notification_received"
        }
    }
    
    var parameters: [String: Any] {
        switch self {
        case .moodCreated(let category, let intensity):
            return ["mood_category": category, "mood_intensity": intensity]
        case .partnershipCreated:
            return [:]
        case .notificationReceived(let type):
            return ["notification_type": type]
        }
    }
}

class AnalyticsService {
    static func track(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
}
```

---

**架構文件版本**: v1.0  
**最後更新**: 2024年12月  
**後端團隊**: MoodSync Backend Team 