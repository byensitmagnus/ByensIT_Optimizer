ByensIT Complete PC Suite – Product Requirements Document (PRD)

Version 2.1 – "One Tool for Everything"

1 │ Executive Summary  

ByensIT Complete PC Suite samler de mest gennemtestede Windows‑optimeringer – inspireret af Hone.gg‑tunings, ShutUp10, Tiny11, Advanced SystemCare og CCleaner – i én modulær platform. Visionen er stadig: “Ét klik til den perfekte PC”, men med fuld gennemsigtighed i præcis hvilke Windows‑kommandoer og registrerings‑tweaks der køres.

2 │ Scope & High‑Level Goals  

 Nr.

 Mål

 Key Metric 

 G1 

 +20 % real‑world FPS boost på mainstream gaming‑PC 

Avg FPS +20 % i Fortnite/CS2 benchmarks

 G2 

 ‑50 % boot‑tid vs. før‑scan 

BootTrace t95 < 15 s

 G3 

 Zero‑Risk: Automatisk system‑restore før ændringer 

100 % rollback‑sikkerhed

 G4 

 No bloat, no ads, GDPR‑clean

Ingen 3rd‑party telemetry

3 │ Baseline Windows Tweaks – "Foundation Commands"

Alle moduler arver dette "command toolbox" som kan køres stand‑alone eller via One‑Click Optimize.

 Kategori

 Kommando/Tweak

 Beskrivelse

System Repair

DISM /Online /Cleanup-Image /RestoreHealth → SFC /scannow

Reparer komponentlager & systemfiler

Disk & FS

chkdsk C: /scan, defrag /C /O, fsutil behavior set DisableDeleteNotify 0

Find fejl, optimer layout, TRIM SSD

Network

ipconfig /flushdns, netsh winsock reset, netsh int ip reset

Frisk DNS‐cache, reset TCP/IP‑stack

Power

powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 → Ultimate Performance

Maks ydeevne på desktop

Services

Disable SysMain,DiagTrack,Xbl*,RetailDemo

Reducér disk‑ & RAM‑spikes

Debloat

`Get-AppxPackage …

Remove-AppxPackage` (liste baseret på Tiny11)

Fjern uønskede UWP‑apps

Privacy

ShutUp10‐inspirerede registry nøgler: AllowTelemetry=0, AdvertisingInfo=0

Slå telemetri & reklame‑ID fra

Gaming

reg add HKLM\SYSTEM\…\GraphicsDrivers /v HwSchMode /t REG_DWORD /d 1

HAGS ON hvis understøttet

Latency

Timer‑res tweak NtSetTimerResolution(0.5 ms)

Lavere input‑lag

Alt logges til Logs\YYYYMMDD‐hhmm.log + automatisk restore‑point.

4 │ Functional Modules (v2.1)

4.1 CORE Module A – Safe‑Repair & Health

Opdateret navn for at fremhæve fundamentet.

 Feature

 Command‑base

 Prioritet

Restore Point

Checkpoint-Computer

P0

DISM + SFC Pipeline

Se baseline

P0

Disk & File System Scan

chkdsk /scan, Get-Volume SMART

P0

Temp & WinSxS Clean

cleanmgr /sageset:1 /sagerun:1 + StorageSense API

P1

4.2 CORE Module B – Performance & Debloat

(fusion af tidligere Module 4 + 6 for tydeligere value‑prop)

 Feature

 Command/Tweak

 Prioritet

UWP Debloat

PowerShell remove list (Tiny11)

P0

Service Optimizer

Set-Service -StartupType Disabled preset

P0

Startup Manager

Get-CimInstance Win32_StartupCommand → toggle

P1

Ultimate Performance Plan

powercfg

P0

Registry Latency Tweaks

GameDVR off, FSO off, TimerRes on

P1

4.3 CORE Module C – Security Lite

(renamed – partner AV still optional)

 Feature

 Integration

 Prioritet

Defender Boost

Configure‐Defender (max) + daily quick‑scan

P0

Malwarebytes CLI hook

mbam.exe /scan /quick

P1

ShutUp10 Privacy Template

50+ OS‑settings via registry

P0

4.4 CORE Module D – Driver & Update Center

Feature

 Command

 Prioritet

Winget Driver Update

winget upgrade NVIDIA.Display.Driver etc.

P0

Windows Update Manager

usoclient StartScan + Defer policy

P1

Rollback Checkpoint

Auto‑create restore pre‑driver

P0

4.5 CORE Module E – Backup & Rollback

Feature

 Command

 Prioritet

System Image

wbAdmin start backup

P0

OneDrive Sync Status

PowerShell ODSync check

P1

Differential File Backup

Robocopy incremental script

P2

4.6 CORE Module F – Analytics Dashboard

Real‑time GPU/CPU/Disk i WPF LiveCharts + Health Score.

5 │ User Experience

One‑Click Optimize viser live log (scrollbare commands) så nørder kan følge med – men skjult som "Expert View" for casuals.

6 │ Success KPIs (rev.)

+20 % FPS (Fortnite DX12 1080p medietest)

‑50 % boot time (BootTrace)

≤3 % crash reports pr. 10 000 runs

NPS > 50

7 │ Roadmap Extract  (ændret for baseline tweaks)

Q

Milestone

Største leverance

 Q1 

 MVP CLI

Foundation Commands, logging, restore‑point

 Q2 

 GUI + One‑Click

WPF dashboard, toggle modules

 Q3 

 Cloud Backup beta

wbAdmin + cloud connectors

 Q4 

 Remote Mgmt

Business tier, multi‑PC console

NB: fuld handlingsplan & Cursor‑setup er beskrevet i docs/Handover.md.

Senest opdateret 29‑05‑2025 af ChatGPT (Byens IT Consultant).

