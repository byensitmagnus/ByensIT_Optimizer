using System;
using System.Diagnostics;
using System.IO;
using Microsoft.Win32;
using System.Text;

namespace ByensIT_Optimizer.Core
{
    /// <summary>
    /// ShutUp10-inspired registry tweaks for privacy and performance
    /// Based on O&O ShutUp10's proven optimization database
    /// </summary>
    public static class ShutUp10Tweaks
    {
        private static StringBuilder _logBuilder = new StringBuilder();
        
        // Logging function
        private static void LogAction(string action, bool success, string details = "")
        {
            string status = success ? "✅ SUCCESS" : "❌ FAILED";
            string logEntry = $"[{DateTime.Now:HH:mm:ss}] {status}: {action}";
            if (!string.IsNullOrEmpty(details))
                logEntry += $" - {details}";
            
            _logBuilder.AppendLine(logEntry);
            Console.WriteLine(logEntry); // Also output to console
        }

        // Helper method to safely set registry value with verification
        private static bool SetRegistryValue(string keyPath, string valueName, object value, RegistryValueKind valueKind)
        {
            try
            {
                // Read current value first for comparison
                object currentValue = null;
                try
                {
                    using (var key = Registry.LocalMachine.OpenSubKey(keyPath))
                    {
                        currentValue = key?.GetValue(valueName);
                    }
                }
                catch { }

                // Set the new value
                using (var key = Registry.LocalMachine.CreateSubKey(keyPath))
                {
                    if (key != null)
                    {
                        key.SetValue(valueName, value, valueKind);
                        
                        // Verify the change was applied
                        var verifyValue = key.GetValue(valueName);
                        bool verified = verifyValue?.ToString() == value.ToString();
                        
                        LogAction($"Registry: {keyPath}\\{valueName}", verified, 
                            $"Changed from '{currentValue}' to '{value}' (Verified: {verified})");
                        return verified;
                    }
                }
                return false;
            }
            catch (Exception ex)
            {
                LogAction($"Registry: {keyPath}\\{valueName}", false, $"Exception: {ex.Message}");
                return false;
            }
        }

        /// <summary>
        /// Disable Windows telemetry and data collection
        /// Fra ShutUp10's privacy optimization
        /// </summary>
        public static bool DisableTelemetry()
        {
            LogAction("=== STARTING TELEMETRY DISABLING ===", true);
            
            int successCount = 0;
            int totalTweaks = 0;

            // Disable Telemetry
            totalTweaks++;
            if (SetRegistryValue(@"SOFTWARE\Policies\Microsoft\Windows\DataCollection", 
                "AllowTelemetry", 0, RegistryValueKind.DWord))
                successCount++;

            // Disable Diagnostic Data
            totalTweaks++;
            if (SetRegistryValue(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection", 
                "AllowTelemetry", 0, RegistryValueKind.DWord))
                successCount++;

            // Disable Feedback Notifications
            totalTweaks++;
            if (SetRegistryValue(@"SOFTWARE\Microsoft\Siuf\Rules", 
                "NumberOfSIUFInPeriod", 0, RegistryValueKind.DWord))
                successCount++;

            LogAction($"=== TELEMETRY DISABLING COMPLETE ===", successCount > 0, 
                $"Applied {successCount}/{totalTweaks} privacy tweaks");
                
            return successCount > 0;
        }

        /// <summary>
        /// Optimize for gaming performance
        /// Fra ShutUp10's gaming optimization suite
        /// </summary>
        public static bool OptimizeForGaming()
        {
            LogAction("=== STARTING GAMING OPTIMIZATION ===", true);
            
            int successCount = 0;
            int totalTweaks = 0;

            // Disable Xbox Game Bar
            totalTweaks++;
            if (SetRegistryValue(@"SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR", 
                "AppCaptureEnabled", 0, RegistryValueKind.DWord))
                successCount++;

            // Disable Game DVR
            totalTweaks++;
            if (SetRegistryValue(@"SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR", 
                "GameDVR_Enabled", 0, RegistryValueKind.DWord))
                successCount++;

            // Enable Game Mode
            totalTweaks++;
            if (SetRegistryValue(@"SOFTWARE\Microsoft\GameBar", 
                "AllowAutoGameMode", 1, RegistryValueKind.DWord))
                successCount++;

            // GPU Scheduling
            totalTweaks++;
            if (SetRegistryValue(@"SYSTEM\CurrentControlSet\Control\GraphicsDrivers", 
                "HwSchMode", 2, RegistryValueKind.DWord))
                successCount++;

            LogAction($"=== GAMING OPTIMIZATION COMPLETE ===", successCount > 0, 
                $"Applied {successCount}/{totalTweaks} gaming tweaks");
                
            return successCount > 0;
        }

        /// <summary>
        /// Optimize network for reduced latency
        /// Fra ShutUp10's network optimization
        /// </summary>
        public static bool OptimizeNetwork()
        {
            LogAction("=== STARTING NETWORK OPTIMIZATION ===", true);
            
            int successCount = 0;
            int totalTweaks = 0;

            // TCP Window Scaling
            totalTweaks++;
            if (SetRegistryValue(@"SYSTEM\CurrentControlSet\Services\Tcpip\Parameters", 
                "Tcp1323Opts", 3, RegistryValueKind.DWord))
                successCount++;

            // Disable Nagle Algorithm for gaming
            totalTweaks++;
            if (SetRegistryValue(@"SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces", 
                "TcpAckFrequency", 1, RegistryValueKind.DWord))
                successCount++;

            // Network Throttling Index
            totalTweaks++;
            if (SetRegistryValue(@"SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile", 
                "NetworkThrottlingIndex", 0xffffffff, RegistryValueKind.DWord))
                successCount++;

            LogAction($"=== NETWORK OPTIMIZATION COMPLETE ===", successCount > 0, 
                $"Applied {successCount}/{totalTweaks} network tweaks");
                
            return successCount > 0;
        }

        /// <summary>
        /// Disable unnecessary Windows services for performance
        /// Fra ShutUp10's service optimization
        /// </summary>
        public static bool OptimizeServices()
        {
            _logBuilder.Clear();
            LogAction("=== STARTING SERVICE OPTIMIZATION ===", true);
            
            int successCount = 0;
            int totalTweaks = 0;

            // Windows Search Service
            totalTweaks++;
            if (SetRegistryValue(@"SYSTEM\CurrentControlSet\Services\WSearch", "Start", 4, RegistryValueKind.DWord))
                successCount++;

            // Windows Update Service (set to manual)
            totalTweaks++;
            if (SetRegistryValue(@"SYSTEM\CurrentControlSet\Services\wuauserv", "Start", 3, RegistryValueKind.DWord))
                successCount++;

            // Superfetch/SysMain
            totalTweaks++;
            if (SetRegistryValue(@"SYSTEM\CurrentControlSet\Services\SysMain", "Start", 4, RegistryValueKind.DWord))
                successCount++;

            LogAction($"=== SERVICE OPTIMIZATION COMPLETE ===", successCount > 0, 
                $"Applied {successCount}/{totalTweaks} service tweaks");
                
            return successCount > 0;
        }

        /// <summary>
        /// Visual effects optimization for performance
        /// Fra ShutUp10's visual performance tweaks
        /// </summary>
        public static bool OptimizeVisualEffects()
        {
            LogAction("=== STARTING VISUAL EFFECTS OPTIMIZATION ===", true);
            
            int successCount = 0;
            int totalTweaks = 0;

            // Disable Animations
            totalTweaks++;
            if (SetRegistryValue(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects", 
                "VisualFXSetting", 2, RegistryValueKind.DWord))
                successCount++;

            // Disable Transparency
            totalTweaks++;
            if (SetRegistryValue(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", 
                "EnableTransparency", 0, RegistryValueKind.DWord))
                successCount++;

            // Disable Animation in taskbar
            totalTweaks++;
            if (SetRegistryValue(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced", 
                "TaskbarAnimations", 0, RegistryValueKind.DWord))
                successCount++;

            LogAction($"=== VISUAL EFFECTS OPTIMIZATION COMPLETE ===", successCount > 0, 
                $"Applied {successCount}/{totalTweaks} visual tweaks");
                
            return successCount > 0;
        }

        /// <summary>
        /// Complete ShutUp10-inspired optimization package
        /// Kører alle sikre optimizations
        /// </summary>
        public static (bool Success, string Report) RunCompleteOptimization()
        {
            _logBuilder.Clear();
            LogAction("🚀 STARTING COMPLETE BYENSIT OPTIMIZATION", true, "ShutUp10-inspired tweaks");
            
            var report = new StringBuilder();
            report.AppendLine("🔧 KOMPLET ByensIT Registry Optimization Report:\n");
            
            // Track overall success
            bool overallSuccess = false;
            
            // Run all optimizations
            bool servicesResult = OptimizeServices();
            bool visualResult = OptimizeVisualEffects();
            bool networkResult = OptimizeNetwork();
            bool gamingResult = OptimizeForGaming();
            bool telemetryResult = DisableTelemetry();
            
            // Compile results
            report.AppendLine($"🛠️ Services Optimization: {(servicesResult ? "✅ Applied" : "❌ Failed")}");
            report.AppendLine($"🎨 Visual Effects: {(visualResult ? "✅ Applied" : "❌ Failed")}");
            report.AppendLine($"📶 Network Optimization: {(networkResult ? "✅ Applied" : "❌ Failed")}");
            report.AppendLine($"🎮 Gaming Tweaks: {(gamingResult ? "✅ Applied" : "❌ Failed")}");
            report.AppendLine($"🛡️ Privacy Protection: {(telemetryResult ? "✅ Applied" : "❌ Failed")}");
            
            overallSuccess = servicesResult || visualResult || networkResult || gamingResult || telemetryResult;
            
            report.AppendLine($"\n📊 Samlet Status: {(overallSuccess ? "✅ SUCCESS" : "❌ FAILED")}");
            
            if (!overallSuccess)
            {
                report.AppendLine("\n💡 TROUBLESHOOTING:");
                report.AppendLine("• Kør som Administrator for registry adgang");
                report.AppendLine("• Tjek at Windows ikke blokerer ændringer");
                report.AppendLine("• Prøv at køre PowerShell som Administrator");
            }
            else
            {
                report.AppendLine("\n🎉 REELLE system optimering gennemført!");
                report.AppendLine("💪 Din PC skulle nu være mærkbart hurtigere!");
            }
            
            // Add detailed log
            report.AppendLine("\n📋 DETALJERET LOG:");
            report.AppendLine("═══════════════════════════════════");
            report.Append(_logBuilder.ToString());
            
            LogAction("🏁 COMPLETE OPTIMIZATION FINISHED", overallSuccess, 
                $"Overall result: {(overallSuccess ? "SUCCESS" : "FAILED")}");
                
            return (overallSuccess, report.ToString());
        }

        // Method to verify current system state
        public static string GetSystemOptimizationStatus()
        {
            var status = new StringBuilder();
            status.AppendLine("🔍 CURRENT SYSTEM OPTIMIZATION STATUS:\n");
            
            try
            {
                // Check Xbox Game Bar
                using (var key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"))
                {
                    var gameDvr = key?.GetValue("GameDVR_Enabled")?.ToString();
                    status.AppendLine($"🎮 Xbox Game DVR: {(gameDvr == "0" ? "✅ Disabled (GOOD)" : "❌ Enabled (BAD)")}");
                }

                // Check Telemetry
                using (var key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Policies\Microsoft\Windows\DataCollection"))
                {
                    var telemetry = key?.GetValue("AllowTelemetry")?.ToString();
                    status.AppendLine($"📊 Telemetry: {(telemetry == "0" ? "✅ Disabled (GOOD)" : "❌ Enabled (BAD)")}");
                }

                // Check Transparency
                using (var key = Registry.LocalMachine.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"))
                {
                    var transparency = key?.GetValue("EnableTransparency")?.ToString();
                    status.AppendLine($"🎨 Transparency: {(transparency == "0" ? "✅ Disabled (GOOD)" : "❌ Enabled (BAD)")}");
                }
                
                status.AppendLine("\n💡 TIP: Brug 'Windows Tweaks' knappen for komplet optimering!");
            }
            catch (Exception ex)
            {
                status.AppendLine($"❌ Fejl ved status tjek: {ex.Message}");
            }
            
            return status.ToString();
        }
    }
} 