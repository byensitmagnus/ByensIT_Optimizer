-- ByensIT Complete PC Suite - Database Schema
-- SQLite Database Structure for Core Architecture

-- Users table - Brugerkonti og subscription info
CREATE TABLE IF NOT EXISTS Users (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    Email TEXT UNIQUE NOT NULL,
    DisplayName TEXT NOT NULL,
    Plan TEXT NOT NULL DEFAULT 'Basic', -- Basic, Pro, Ultimate, Business
    SubscriptionStatus TEXT DEFAULT 'Active', -- Active, Expired, Trial
    CreatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    LastActive DATETIME DEFAULT CURRENT_TIMESTAMP,
    TrialStartDate DATETIME,
    SubscriptionExpiry DATETIME,
    PaymentId TEXT, -- Stripe/PayPal ID
    PreferredLanguage TEXT DEFAULT 'da-DK'
);

-- PCs table - Registrerede computere per bruger
CREATE TABLE IF NOT EXISTS PCs (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    UserId INTEGER NOT NULL,
    Hostname TEXT NOT NULL,
    HardwareId TEXT UNIQUE NOT NULL, -- Unique hardware fingerprint
    OperatingSystem TEXT NOT NULL,
    OSVersion TEXT NOT NULL,
    Architecture TEXT NOT NULL, -- x64, x86
    TotalRAM INTEGER, -- MB
    CPUModel TEXT,
    GPUModel TEXT,
    StorageType TEXT, -- SSD, HDD, Hybrid
    LastSeen DATETIME DEFAULT CURRENT_TIMESTAMP,
    IsActive BOOLEAN DEFAULT 1,
    PCNickname TEXT, -- User friendly name
    
    FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE
);

-- ScanResults table - Resultater fra alle optimerings scans
CREATE TABLE IF NOT EXISTS ScanResults (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    PCId INTEGER NOT NULL,
    ScanType TEXT NOT NULL, -- 'FullScan', 'QuickScan', 'SecurityScan', 'CleanupScan'
    Status TEXT NOT NULL, -- 'Running', 'Completed', 'Failed', 'Cancelled'
    StartTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    EndTime DATETIME,
    Results TEXT, -- JSON with detailed results
    IssuesFound INTEGER DEFAULT 0,
    IssuesFixed INTEGER DEFAULT 0,
    SpaceFreed INTEGER DEFAULT 0, -- MB
    PerformanceImprovement REAL DEFAULT 0.0, -- Percentage
    HealthScoreBefore INTEGER, -- 0-100
    HealthScoreAfter INTEGER, -- 0-100
    ModulesRun TEXT, -- JSON array of modules executed
    
    FOREIGN KEY (PCId) REFERENCES PCs(Id) ON DELETE CASCADE
);

-- Settings table - Brugerindstillinger og præferencer
CREATE TABLE IF NOT EXISTS Settings (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    UserId INTEGER NOT NULL,
    PCId INTEGER, -- NULL for global user settings
    SettingKey TEXT NOT NULL,
    SettingValue TEXT NOT NULL,
    SettingType TEXT NOT NULL, -- 'Boolean', 'String', 'Integer', 'JSON'
    Category TEXT NOT NULL, -- 'General', 'Modules', 'Privacy', 'Gaming', 'Backup'
    LastModified DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE CASCADE,
    FOREIGN KEY (PCId) REFERENCES PCs(Id) ON DELETE CASCADE,
    
    UNIQUE(UserId, PCId, SettingKey)
);

-- SystemMetrics table - Performance metrics over tid
CREATE TABLE IF NOT EXISTS SystemMetrics (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    PCId INTEGER NOT NULL,
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    CPUUsage REAL, -- Percentage
    RAMUsage REAL, -- Percentage  
    DiskUsage REAL, -- Percentage
    NetworkLatency INTEGER, -- ms
    FPSAverage REAL, -- Gaming sessions
    BootTime INTEGER, -- seconds
    TemperatureCPU REAL, -- Celsius
    TemperatureGPU REAL, -- Celsius
    HealthScore INTEGER, -- 0-100 calculated score
    
    FOREIGN KEY (PCId) REFERENCES PCs(Id) ON DELETE CASCADE
);

-- BackupJobs table - Backup operationer og status
CREATE TABLE IF NOT EXISTS BackupJobs (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    PCId INTEGER NOT NULL,
    JobType TEXT NOT NULL, -- 'Files', 'SystemImage', 'Registry', 'Drivers'
    Status TEXT NOT NULL, -- 'Scheduled', 'Running', 'Completed', 'Failed'
    CloudProvider TEXT, -- 'OneDrive', 'GoogleDrive', 'Dropbox', 'Local'
    SourcePath TEXT NOT NULL,
    DestinationPath TEXT NOT NULL,
    FileCount INTEGER DEFAULT 0,
    TotalSize INTEGER DEFAULT 0, -- MB
    CompressedSize INTEGER DEFAULT 0, -- MB
    ScheduledTime DATETIME,
    StartTime DATETIME,
    EndTime DATETIME,
    ErrorMessage TEXT,
    
    FOREIGN KEY (PCId) REFERENCES PCs(Id) ON DELETE CASCADE
);

-- SecurityThreats table - Sikkerhedstrusler og behandling
CREATE TABLE IF NOT EXISTS SecurityThreats (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    PCId INTEGER NOT NULL,
    ThreatType TEXT NOT NULL, -- 'Malware', 'PUP', 'Adware', 'Tracking', 'Vulnerability'
    ThreatName TEXT NOT NULL,
    FilePath TEXT,
    RegistryKey TEXT,
    Severity TEXT NOT NULL, -- 'Low', 'Medium', 'High', 'Critical'
    Status TEXT NOT NULL, -- 'Detected', 'Quarantined', 'Removed', 'Ignored', 'Whitelisted'
    DetectedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    ResolvedAt DATETIME,
    DetectionEngine TEXT, -- 'WindowsDefender', 'ByensIT', 'Malwarebytes'
    
    FOREIGN KEY (PCId) REFERENCES PCs(Id) ON DELETE CASCADE
);

-- Logs table - Detaljeret system logging
CREATE TABLE IF NOT EXISTS Logs (
    Id INTEGER PRIMARY KEY AUTOINCREMENT,
    PCId INTEGER,
    UserId INTEGER,
    Level TEXT NOT NULL, -- 'DEBUG', 'INFO', 'WARN', 'ERROR', 'FATAL'
    Message TEXT NOT NULL,
    Component TEXT, -- 'OptimizationEngine', 'SecurityEngine', 'BackupEngine', 'GUI'
    Context TEXT, -- JSON with additional context
    Exception TEXT, -- Stack trace if error
    Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (PCId) REFERENCES PCs(Id) ON DELETE SET NULL,
    FOREIGN KEY (UserId) REFERENCES Users(Id) ON DELETE SET NULL
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_users_email ON Users(Email);
CREATE INDEX IF NOT EXISTS idx_pcs_userid ON PCs(UserId);
CREATE INDEX IF NOT EXISTS idx_pcs_hardwareid ON PCs(HardwareId);
CREATE INDEX IF NOT EXISTS idx_scanresults_pcid ON ScanResults(PCId);
CREATE INDEX IF NOT EXISTS idx_scanresults_scantype ON ScanResults(ScanType);
CREATE INDEX IF NOT EXISTS idx_settings_user_pc ON Settings(UserId, PCId);
CREATE INDEX IF NOT EXISTS idx_systemmetrics_pcid_timestamp ON SystemMetrics(PCId, Timestamp);
CREATE INDEX IF NOT EXISTS idx_logs_level_timestamp ON Logs(Level, Timestamp);
CREATE INDEX IF NOT EXISTS idx_securitythreats_pcid_status ON SecurityThreats(PCId, Status);

-- Default settings ved ny bruger
INSERT OR IGNORE INTO Settings (UserId, SettingKey, SettingValue, SettingType, Category) VALUES
(1, 'autoUpdate', 'true', 'Boolean', 'General'),
(1, 'createRestorePoint', 'true', 'Boolean', 'General'),
(1, 'enableTelemetry', 'false', 'Boolean', 'Privacy'),
(1, 'optimizationFrequency', 'Weekly', 'String', 'General'),
(1, 'gamingMode', 'true', 'Boolean', 'Gaming'),
(1, 'autoBackup', 'true', 'Boolean', 'Backup'),
(1, 'backupFrequency', 'Daily', 'String', 'Backup'),
(1, 'cloudProvider', 'OneDrive', 'String', 'Backup'),
(1, 'healthThreshold', '70', 'Integer', 'General');

-- Views for common queries
CREATE VIEW IF NOT EXISTS PC_Health_Summary AS
SELECT 
    p.Id,
    p.Hostname,
    p.PCNickname,
    p.LastSeen,
    (
        SELECT sm.HealthScore 
        FROM SystemMetrics sm 
        WHERE sm.PCId = p.Id 
        ORDER BY sm.Timestamp DESC 
        LIMIT 1
    ) AS CurrentHealthScore,
    (
        SELECT COUNT(*) 
        FROM ScanResults sr 
        WHERE sr.PCId = p.Id 
        AND sr.Status = 'Completed'
        AND DATE(sr.StartTime) = DATE('now')
    ) AS ScansToday,
    (
        SELECT COUNT(*) 
        FROM SecurityThreats st 
        WHERE st.PCId = p.Id 
        AND st.Status = 'Detected'
    ) AS ActiveThreats
FROM PCs p 
WHERE p.IsActive = 1;

CREATE VIEW IF NOT EXISTS User_Subscription_Status AS
SELECT 
    u.Id,
    u.Email,
    u.DisplayName,
    u.Plan,
    u.SubscriptionStatus,
    u.SubscriptionExpiry,
    CASE 
        WHEN u.SubscriptionExpiry IS NULL THEN 999999
        WHEN u.SubscriptionExpiry > datetime('now') THEN 
            CAST((julianday(u.SubscriptionExpiry) - julianday('now')) AS INTEGER)
        ELSE 0
    END AS DaysRemaining,
    (SELECT COUNT(*) FROM PCs WHERE UserId = u.Id AND IsActive = 1) AS ActivePCs
FROM Users u; 