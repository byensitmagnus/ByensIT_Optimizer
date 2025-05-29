# ByensIT Optimizer - Cursor AI Context

## Projekt Overblik
ByensIT Optimizer er et modulært Windows optimeringsværktøj bygget i PowerShell med WPF GUI. Projektet fokuserer på gaming performance, debloating og systemstabilitet.

## Arkitektur & Moduler

### Part1: Safe Repair (`ByensIT-Optimizer-Part1.ps1`)
- **DISM/SFC repair** - Systemreparation
- **Restore points** - Sikkerhedsbackup
- **Temp cleanup** - Cache og temp filer
- **Windows Update cache** - Renser WU filer

### Part2: Debloat & Privacy (`ByensIT-Optimizer-Part2.ps1`)
- **UWP app removal** - Fjerner bloatware
- **Telemetry disable** - Privacy forbedringer
- **Service optimization** - Deaktiverer unødvendige services
- **Scheduled tasks** - Fjerner tracking tasks

### Part3: Gaming Tweaks (`ByensIT-Optimizer-Part3.ps1`)
- **Ultimate Performance** - Power plan optimering
- **HAGS configuration** - Hardware GPU scheduling
- **Driver updates** - Winget graphics drivers
- **High-res timer** - Gaming præcision
- **Game Mode** - Windows gaming optimering

### Part4: WPF GUI (`ByensIT-Optimizer-Part4_GUI.ps1`)
- **Module selection** - Checkbox toggles
- **Real-time progress** - ProgressBar og status
- **Auto-update** - Version checking og download
- **Log export** - ZIP support funktionalitet

## Konfigurationsfiler

### config.json
Styrer modul aktivering og grundindstillinger:
```json
{
  "modules": {
    "safeRepair": { "enabled": true, "description": "..." },
    "debloat": { "enabled": true, "description": "..." },
    "gamingTweaks": { "enabled": true, "description": "..." }
  },
  "settings": {
    "createRestorePoint": true,
    "enableLogging": true,
    "autoUpdate": true
  }
}
```

### version.json
Auto-update system metadata:
```json
{
  "version": "1.0.0",
  "downloadUrl": "https://github.com/Byens-IT/optimizer/releases/latest/download/...",
  "updateUrl": "https://raw.githubusercontent.com/Byens-IT/optimizer/main/version.json"
}
```

## Logging System
- **Centraliseret logging** via `Write-ByensLog` funktioner
- **Log levels**: INFO, WARN, ERROR
- **Fil format**: `ByensIT-Optimizer-YYYY-MM-DD.log`
- **ZIP export** til support via GUI

## Udviklings Guidelines

### Kode Stil
- **Dansk kommentarer** og beskrivelser
- **Engelsk variable/funktioner** for konsistens
- **Param validation** i alle functions
- **Error handling** med try/catch
- **Logging** ved alle vigtige operationer

### Testing
- **Admin rights check** før kritiske operationer
- **Path validation** før fil operationer
- **Service existence check** før service modificering
- **Registry backup** overvej for kritiske ændringer

### Security
- **#Requires -RunAsAdministrator** på alle scripts
- **Input sanitization** for alle parametre
- **Safe defaults** i konfiguration
- **Restore points** før system ændringer

## AI Assistant Instructions

### Når du hjælper med kode:
1. **Bevar modulær struktur** - Hold funktionalitet adskilt
2. **Dansk bruger-vendte tekster** - Error messages, GUI labels, logs
3. **Konsistent error handling** - Brug samme patterns som eksisterende kode
4. **Logging integration** - Tilføj Write-ByensLog calls ved nye funktioner
5. **Parameter validation** - Valider inputs i nye funktioner

### Når du refactorer:
1. **Bibehol funktionalitet** - Test at eksisterende features virker
2. **Forbedre error handling** - Men bevar eksisterende behavior
3. **Optimer performance** - Især for GUI responsiveness
4. **Dokumenter ændringer** - Opdater kommentarer og README

### Common Tasks:
- **Tilføj nye moduler** → Følg eksisterende Part1-3 struktur
- **Forbedre GUI** → WPF/XAML i Part4, bevar color scheme
- **Debug issues** → Check logs først, derefter PowerShell ISE
- **Registry tweaks** → Altid test eksistens før modification
- **Service changes** → Check service status før stop/disable

## Performance Targets
- **Total runtime**: Under 2 minutter (excl. driver downloads)
- **GUI responsiveness**: Under 100ms click response
- **Memory usage**: Max 500MB during execution
- **Log file size**: Max 10MB per session

## Kritiske Filer at Ikke Ændre
- **System32** operationer skal være read-only checks
- **Boot critical services** må ikke deaktiveres
- **Core Windows apps** (Calculator, Notepad) bevares
- **Network stack** skal bevares funktionel

Dette projekt er designet til stabilitet over extremer - vi optimerer inden for sikre grænser. 