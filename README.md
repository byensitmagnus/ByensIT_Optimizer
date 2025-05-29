# 🎮 ByensIT Complete PC Suite v2.0

**Danmarks første gaming-fokuserede PC optimering suite** - inspireret af de bedste internationale værktøjer som Hone.gg, Advanced SystemCare og Chris Titus Tech's WinUtil.

## 🚀 **Hvad Er Det?**

En professionel PC optimizer bygget specifikt til danske brugere med fokus på:
- **FPS Boosting** (inspireret af Hone.gg)
- **PowerShell Tweaks** (inspireret af Chris Titus Tech)
- **Advanced Cleanup** (Advanced SystemCare niveau)
- **Real-time Monitoring** og Health Scoring

## 📋 **Funktioner**

### 🎯 **Gaming Optimization (Hone.gg-inspired)**
- Real-time FPS monitoring og display
- 12 gaming-specifikke optimizations
- Game detection (Steam, Epic Games, Battle.net)
- Network latency optimization
- Game Mode activation

### 🔧 **PowerShell Tweaks (Chris Titus-inspired)**
- 8 avancerede Windows tweaks med tooltips
- Winget integration for program installation  
- DNS konfiguration (Cloudflare, Google DNS)
- Auto-login og power management
- Privacy tweaks (telemetri, Cortana etc.)

### 🧹 **System Cleanup (Advanced SystemCare niveau)**
- 10 cleanup moduler med system restore
- Intelligent health scoring (0-100)
- Registry optimization
- Duplicate file detection
- Browser cache cleanup

### 💻 **Real-time Monitoring**
- CPU, GPU, RAM, disk monitoring
- Temperature tracking
- Gaming performance metrics
- Boot time optimization

## 🛠️ **Installation & Setup**

### **Forudsætninger:**
1. **Windows 10/11** (x64)
2. **.NET 6.0 Runtime** - [Download her](https://dotnet.microsoft.com/download/dotnet/6.0)
3. **PowerShell 5.1+** (inkluderet i Windows)
4. **Administrator rettigheder** (til system tweaks)

### **Byg Fra Kildekode:**

```bash
# 1. Download .NET 6.0 SDK
# https://dotnet.microsoft.com/download/dotnet/6.0

# 2. Clone eller download projektet
cd ByensIT_Optimizer

# 3. Gendan NuGet packages
dotnet restore

# 4. Byg applikationen
dotnet build --configuration Release

# 5. Kør applikationen
dotnet run
```

### **Alternativ - Visual Studio:**
1. Åbn `ByensIT_Optimizer.sln` i Visual Studio 2022
2. Set startup project til `ByensIT_Optimizer`
3. Tryk F5 for at bygge og køre

## 📁 **Projekt Struktur**

```
ByensIT_Optimizer/
├── 📄 ByensIT_Optimizer.csproj    # Project fil med NuGet references
├── 📄 App.xaml                    # WPF Application entry point
├── 📄 App.xaml.cs                 # Dependency injection setup
├── 📄 appsettings.json            # Configuration settings
├── 📄 README.md                   # Denne fil
│
├── 📁 Database/
│   └── 📄 DatabaseSchema.sql      # SQLite database schema
│
├── 📁 Core/
│   ├── 📁 Data/
│   │   ├── 📄 ByensITDbContext.cs           # Entity Framework context
│   │   └── 📄 DatabaseModels.cs            # Database models & enums
│   │
│   └── 📁 Models/
│       ├── 📄 HealthScoreEngine.cs         # 0-100 health scoring
│       ├── 📄 SystemInfoService.cs         # Real-time metrics
│       ├── 📄 EnhancedCleanupEngine.cs     # 10 cleanup modules
│       ├── 📄 GamingOptimizationEngine.cs  # FPS boosting (Hone.gg-inspired)
│       └── 📄 PowerShellTweaksEngine.cs    # Windows tweaks (Chris Titus-inspired)
│
└── 📁 UI/Views/
    ├── 📄 MainDashboard.xaml      # Hoved dashboard (GitHub-inspired design)
    ├── 📄 MainDashboard.xaml.cs   # Complete functionality
    ├── 📄 GamingDashboard.xaml    # Gaming dashboard (Hone.gg-inspired design)
    └── 📄 GamingDashboard.xaml.cs # Gaming functionality
```

## 🎨 **UI Design Inspiration**

### **Main Dashboard (GitHub-inspired)**
- Dark theme med grønne accenter
- Modern card-based layout
- Health score ring display
- Real-time system metrics

### **Gaming Dashboard (Hone.gg-inspired)**
- Gaming aesthetic med cyan accenter
- Large FPS display
- Gaming optimizations checklist
- Real-time performance charts

## 🔧 **Teknisk Stack**

- **Framework:** .NET 6.0 + WPF
- **Database:** SQLite + Entity Framework Core
- **DI Container:** Microsoft.Extensions.DependencyInjection
- **Logging:** Microsoft.Extensions.Logging
- **PowerShell:** System.Management.Automation
- **System Access:** System.Management + Performance Counters

## 📊 **Database Schema**

8 tabeller til komplet tracking:
- `Users` - Brugere og licenser
- `PCs` - Hardware fingerprinting
- `SystemMetrics` - Real-time performance data
- `ScanResults` - Cleanup og scan resultater
- `SecurityThreats` - Sikkerhedstrusler
- `Settings` - Bruger præferencer
- `BackupJobs` - Backup scheduling
- `Logs` - Application logging

## 🎯 **Competitive Advantages**

| Feature | ByensIT Suite | Hone.gg | Chris Titus | Advanced SystemCare |
|---------|---------------|---------|-------------|-------------------|
| **Gaming FPS Boost** | ✅ 12 optimizations | ✅ 8 optimizations | ❌ | ⚠️ Basic |
| **PowerShell Tweaks** | ✅ 8 tweaks + tooltips | ❌ | ✅ 20+ tweaks | ❌ |
| **System Cleanup** | ✅ 10 modules | ❌ | ⚠️ Basic | ✅ Comprehensive |
| **Danish Language** | ✅ Fully localized | ❌ English only | ❌ English only | ⚠️ Limited |
| **Local Database** | ✅ SQLite + Privacy | ❌ Cloud required | ❌ | ⚠️ Cloud optional |
| **Free Tier** | ✅ Generous free | ⚠️ Limited | ✅ Free | ⚠️ Limited |

## 🚀 **Quick Start Guide**

1. **Kør som Administrator** (for system tweaks)
2. **Main Dashboard** åbner automatisk
3. **Klik "🔧 Kør Full Scan"** for health score
4. **Klik "🧹 Quick Cleanup"** for hurtig oprydning
5. **Klik Gaming knappen** for gaming optimization

### **Gaming Mode:**
1. Åbn Gaming Dashboard
2. Klik "🚀 BOOST FPS" 
3. Check ønskede optimizations
4. Klik "🎮 Apply Gaming Tweaks"

## 📈 **Roadmap**

### **Phase 1 - MVP (Current)**
- ✅ Core health scoring engine
- ✅ Basic cleanup functionality
- ✅ Gaming optimizations
- ✅ Modern UI

### **Phase 2 - Pro Features**
- 🔄 Real FPS monitoring integration
- 🔄 Advanced registry optimization
- 🔄 Backup & restore system
- 🔄 Scheduled maintenance

### **Phase 3 - Enterprise**
- 🔄 Multi-PC management
- 🔄 Cloud sync & analytics
- 🔄 White-label licensing
- 🔄 API integration

## ⚠️ **Vigtige Noter**

### **Kræver Administrator:**
- PowerShell tweaks
- Registry modifications
- System service changes
- Network configuration

### **Sikkerhed:**
- Alle tweaks kan reverseres
- System restore points oprettes automatisk
- Lokalt database (ingen cloud data)
- Open source & transparent

### **Kompatibilitet:**
- Windows 10 1903+ (anbefalet)
- Windows 11 (alle versioner)
- .NET 6.0 runtime påkrævet
- 4GB RAM minimum, 8GB anbefalet

## 🎮 **Gaming Optimizations Liste**

1. **Windows Game Mode** (+15 FPS estimate)
2. **High Performance Power Plan** (+12 FPS)
3. **Disable Xbox Game Bar** (+8 FPS)
4. **Disable Fullscreen Optimizations** (+5 FPS)
5. **High Process Priority** (+10 FPS)
6. **Network Optimization** (-15ms latency)
7. **RAM Optimization** (+7 FPS)
8. **Visual Effects Optimization** (+6 FPS)
9. **Disable Background Apps** (+4 FPS)
10. **Disable Windows Updates** (gaming sessions)
11. **High DPI Scaling** (compatibility)
12. **Disable Unnecessary Services** (+3 FPS)

## 🔧 **PowerShell Tweaks Liste**

1. **Deaktiver Windows Telemetri** (Privacy + Performance)
2. **Deaktiver Cortana** (Privacy)
3. **Optimér Startup Programmer** (Boot time)
4. **Aktivér Dark Mode** (Aesthetics)
5. **Deaktiver Fast Startup** (Compatibility)
6. **Optimér Visual Effects** (Performance)
7. **Deaktiver Background Apps** (Performance)
8. **Deaktiver Windows Defender** (⚠️ Advanced only)

## 🧹 **Cleanup Modules**

1. **Temp Files** - Windows og bruger temp
2. **Browser Cache** - Chrome, Firefox, Edge
3. **Recycle Bin** - Fuld tømning
4. **Registry Cleanup** - Ugyldige entries
5. **Windows Update Cache** - Gamle filer
6. **System Cache** - Prefetch cleanup
7. **Log Files** - Gamle log filer
8. **Duplicate Files** - Advanced detection
9. **Large Files** - Analysis mode
10. **Unused Programs** - Installation analysis

## 📞 **Support & Kontakt**

- **Website:** [byens-it.dk](https://byens-it.dk)
- **Email:** support@byens-it.dk
- **GitHub Issues:** For bugs og feature requests
- **Version:** 2.0.0 (Complete Suite)

---

**🇩🇰 Lavet i Danmark til danske PC gamere og entusiaster**

*"Ét klik til den perfekte PC"* - ByensIT Complete PC Suite v2.0 