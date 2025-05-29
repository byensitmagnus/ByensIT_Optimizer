#Requires -RunAsAdministrator
<#
.SYNOPSIS
    ByensIT Optimizer - Part 4: WPF GUI
.DESCRIPTION
    Grafisk brugergrænseflade med modul toggles, auto-update og log funktionalitet.
.AUTHOR
    Byens IT - magnususmo@hotmail.dk
.VERSION
    1.0.0
#>

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

# Global variables
$script:config = $null
$script:version = $null
$script:logPath = "$PSScriptRoot\Logs"

function Load-Configuration {
    try {
        $configPath = "$PSScriptRoot\config.json"
        if (Test-Path $configPath) {
            $script:config = Get-Content $configPath | ConvertFrom-Json
        } else {
            throw "Config fil ikke fundet: $configPath"
        }
        
        $versionPath = "$PSScriptRoot\version.json"
        if (Test-Path $versionPath) {
            $script:version = Get-Content $versionPath | ConvertFrom-Json
        } else {
            throw "Version fil ikke fundet: $versionPath"
        }
        
        return $true
    }
    catch {
        [System.Windows.MessageBox]::Show("Fejl ved indlæsning af konfiguration: $($_.Exception.Message)", "ByensIT Optimizer", "OK", "Error")
        return $false
    }
}

function Write-GuiLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    if (!(Test-Path $script:logPath)) {
        New-Item -ItemType Directory -Path $script:logPath -Force | Out-Null
    }
    
    $logFile = Join-Path $script:logPath "ByensIT-Optimizer-$(Get-Date -Format 'yyyy-MM-dd').log"
    Add-Content -Path $logFile -Value $logMessage
    
    # Update GUI log if available
    if ($script:LogTextBox) {
        $script:LogTextBox.Dispatcher.Invoke([Action]{
            $script:LogTextBox.AppendText("$logMessage`n")
            $script:LogTextBox.ScrollToEnd()
        })
    }
}

function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Check-ForUpdates {
    try {
        Write-GuiLog "Checker for opdateringer..."
        
        $webClient = New-Object System.Net.WebClient
        $latestVersionJson = $webClient.DownloadString($script:version.updateUrl)
        $latestVersion = $latestVersionJson | ConvertFrom-Json
        
        if ([version]$latestVersion.version -gt [version]$script:version.version) {
            Write-GuiLog "Ny version tilgængelig: $($latestVersion.version)" -Level "INFO"
            
            $result = [System.Windows.MessageBox]::Show(
                "En ny version ($($latestVersion.version)) er tilgængelig.`n`nVil du downloade og installere den nu?",
                "ByensIT Optimizer - Update",
                "YesNo",
                "Question"
            )
            
            if ($result -eq "Yes") {
                Start-AutoUpdate $latestVersion
            }
        } else {
            Write-GuiLog "Du har den seneste version ($($script:version.version))"
        }
    }
    catch {
        Write-GuiLog "Fejl ved check for opdateringer: $($_.Exception.Message)" -Level "ERROR"
    }
}

function Start-AutoUpdate {
    param($latestVersion)
    
    try {
        Write-GuiLog "Starter auto-update til version $($latestVersion.version)..."
        
        $tempPath = [System.IO.Path]::GetTempPath()
        $downloadPath = Join-Path $tempPath "ByensIT-Optimizer-Update.exe"
        
        # Download update
        $webClient = New-Object System.Net.WebClient
        $webClient.DownloadFile($latestVersion.downloadUrl, $downloadPath)
        
        Write-GuiLog "Update downloaded til: $downloadPath"
        
        # Start update process
        $updateScript = @"
Start-Sleep -Seconds 3
Copy-Item -Path '$downloadPath' -Destination '$($MyInvocation.MyCommand.Path)' -Force
Remove-Item -Path '$downloadPath' -Force
Start-Process -FilePath '$($MyInvocation.MyCommand.Path)'
"@
        
        $updateScriptPath = Join-Path $tempPath "ByensIT-Update.ps1"
        Set-Content -Path $updateScriptPath -Value $updateScript
        
        Start-Process powershell.exe -ArgumentList "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$updateScriptPath`"" -WindowStyle Hidden
        
        [System.Windows.Application]::Current.Shutdown()
    }
    catch {
        Write-GuiLog "Fejl under auto-update: $($_.Exception.Message)" -Level "ERROR"
        [System.Windows.MessageBox]::Show("Fejl under opdatering: $($_.Exception.Message)", "ByensIT Optimizer", "OK", "Error")
    }
}

function Export-LogsToZip {
    try {
        Write-GuiLog "Eksporterer logs til ZIP..."
        
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $zipPath = Join-Path $desktopPath "ByensIT-Optimizer-Logs-$(Get-Date -Format 'yyyy-MM-dd-HHmm').zip"
        
        if (Test-Path $script:logPath) {
            Compress-Archive -Path "$script:logPath\*" -DestinationPath $zipPath -Force
            
            # Copy path to clipboard
            Set-Clipboard -Value $zipPath
            
            Write-GuiLog "Logs eksporteret til: $zipPath"
            [System.Windows.MessageBox]::Show(
                "Logs eksporteret til:`n$zipPath`n`nSti kopieret til udklipsholder.",
                "ByensIT Optimizer",
                "OK",
                "Information"
            )
        } else {
            [System.Windows.MessageBox]::Show("Ingen logs fundet til eksport.", "ByensIT Optimizer", "OK", "Warning")
        }
    }
    catch {
        Write-GuiLog "Fejl ved eksport af logs: $($_.Exception.Message)" -Level "ERROR"
        [System.Windows.MessageBox]::Show("Fejl ved eksport af logs: $($_.Exception.Message)", "ByensIT Optimizer", "OK", "Error")
    }
}

function Start-OptimizationProcess {
    param($selectedModules)
    
    try {
        Write-GuiLog "=== ByensIT Optimizer Process Started ==="
        
        $script:ProgressBar.Value = 0
        $script:StatusLabel.Content = "Starter optimering..."
        
        $totalSteps = $selectedModules.Count
        $currentStep = 0
        
        foreach ($module in $selectedModules) {
            $currentStep++
            $progress = ($currentStep / $totalSteps) * 100
            
            $script:ProgressBar.Dispatcher.Invoke([Action]{
                $script:ProgressBar.Value = $progress
            })
            
            $script:StatusLabel.Dispatcher.Invoke([Action]{
                $script:StatusLabel.Content = "Kører: $($script:config.modules.$module.description)"
            })
            
            Write-GuiLog "Starter modul: $module"
            
            switch ($module) {
                "safeRepair" {
                    & "$PSScriptRoot\ByensIT-Optimizer-Part1.ps1" -Silent -LogPath $script:logPath
                }
                "debloat" {
                    & "$PSScriptRoot\ByensIT-Optimizer-Part2.ps1" -Silent -LogPath $script:logPath
                }
                "gamingTweaks" {
                    & "$PSScriptRoot\ByensIT-Optimizer-Part3.ps1" -Silent -LogPath $script:logPath
                }
            }
            
            Write-GuiLog "Modul $module completed"
        }
        
        $script:ProgressBar.Dispatcher.Invoke([Action]{
            $script:ProgressBar.Value = 100
        })
        
        $script:StatusLabel.Dispatcher.Invoke([Action]{
            $script:StatusLabel.Content = "Optimering completed!"
        })
        
        Write-GuiLog "=== ByensIT Optimizer Process Completed ==="
        
        [System.Windows.MessageBox]::Show(
            "Optimering completed succesfuldt!`n`nGenstart anbefales for at alle ændringer træder i kraft.",
            "ByensIT Optimizer",
            "OK",
            "Information"
        )
        
    }
    catch {
        Write-GuiLog "Fejl under optimering: $($_.Exception.Message)" -Level "ERROR"
        [System.Windows.MessageBox]::Show("Fejl under optimering: $($_.Exception.Message)", "ByensIT Optimizer", "OK", "Error")
    }
}

function Create-MainWindow {
    # XAML for WPF interface
    $xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="ByensIT Optimizer v$($script:version.version)" Height="600" Width="800"
        ResizeMode="CanMinimize" WindowStartupLocation="CenterScreen">
    <Grid Background="#FF2D2D30">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="100"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <!-- Header -->
        <Border Grid.Row="0" Background="#FF007ACC" Padding="10">
            <StackPanel Orientation="Horizontal">
                <TextBlock Text="[*]" FontSize="24" Foreground="White" VerticalAlignment="Center" Margin="0,0,10,0"/>
                <TextBlock Text="ByensIT Optimizer" FontSize="20" FontWeight="Bold" Foreground="White" VerticalAlignment="Center"/>
                <TextBlock Text="v$($script:version.version)" FontSize="12" Foreground="#FFCCCCCC" VerticalAlignment="Bottom" Margin="10,0,0,2"/>
            </StackPanel>
        </Border>
        
        <!-- Module Selection -->
        <ScrollViewer Grid.Row="1" Margin="10">
            <StackPanel Name="ModulePanel">
                <TextBlock Text="Vaelg optimeringsmoduler:" FontSize="16" FontWeight="Bold" Foreground="White" Margin="0,0,0,10"/>
                
                <CheckBox Name="SafeRepairCheckBox" Content="[REPAIR] Safe Repair - System reparation og cleanup" 
                         Foreground="White" IsChecked="True" Margin="0,5"/>
                <TextBlock Text="   Inkluderer DISM, SFC, temp cleanup og system repair" 
                          Foreground="#FFCCCCCC" FontSize="10" Margin="0,0,0,10"/>
                
                <CheckBox Name="DebloatCheckBox" Content="[CLEAN] Debloat &amp; Privacy - Fjern bloatware og telemetri" 
                         Foreground="White" IsChecked="True" Margin="0,5"/>
                <TextBlock Text="   Fjerner UWP apps, deaktiverer telemetri og forbedrer privatliv" 
                          Foreground="#FFCCCCCC" FontSize="10" Margin="0,0,0,10"/>
                
                <CheckBox Name="GamingTweaksCheckBox" Content="[GAME] Gaming Tweaks - FPS optimering og driver updates" 
                         Foreground="White" IsChecked="True" Margin="0,5"/>
                <TextBlock Text="   Ultimate Performance, HAGS, driver updates og gaming optimering" 
                          Foreground="#FFCCCCCC" FontSize="10" Margin="0,0,0,10"/>
            </StackPanel>
        </ScrollViewer>
        
        <!-- Progress -->
        <StackPanel Grid.Row="2" Margin="10">
            <TextBlock Name="StatusLabel" Text="Klar til optimering..." Foreground="White" Margin="0,0,0,5"/>
            <ProgressBar Name="ProgressBar" Height="20" Background="#FF404040" Foreground="#FF007ACC"/>
        </StackPanel>
        
        <!-- Log Output -->
        <Border Grid.Row="3" Background="#FF1E1E1E" Margin="10" BorderBrush="#FF404040" BorderThickness="1">
            <ScrollViewer>
                <TextBox Name="LogTextBox" Background="Transparent" Foreground="#FFCCCCCC" 
                        BorderThickness="0" IsReadOnly="True" TextWrapping="Wrap" 
                        VerticalScrollBarVisibility="Auto" FontFamily="Consolas" FontSize="10"/>
            </ScrollViewer>
        </Border>
        
        <!-- Buttons -->
        <StackPanel Grid.Row="4" Orientation="Horizontal" HorizontalAlignment="Center" Margin="10">
            <Button Name="OptimizeButton" Content="START Optimering" Width="150" Height="35" 
                   Background="#FF007ACC" Foreground="White" FontWeight="Bold" Margin="5"/>
            <Button Name="UpdateButton" Content="CHECK for Updates" Width="150" Height="35" 
                   Background="#FF404040" Foreground="White" Margin="5"/>
            <Button Name="ExportLogsButton" Content="EXPORT Logs" Width="150" Height="35" 
                   Background="#FF404040" Foreground="White" Margin="5"/>
            <Button Name="ExitButton" Content="EXIT" Width="100" Height="35" 
                   Background="#FF8B0000" Foreground="White" Margin="5"/>
        </StackPanel>
    </Grid>
</Window>
"@

    $reader = [System.Xml.XmlNodeReader]::new([xml]$xaml)
    $window = [Windows.Markup.XamlReader]::Load($reader)
    
    # Get controls
    $script:ProgressBar = $window.FindName("ProgressBar")
    $script:StatusLabel = $window.FindName("StatusLabel")
    $script:LogTextBox = $window.FindName("LogTextBox")
    
    $safeRepairCheckBox = $window.FindName("SafeRepairCheckBox")
    $debloatCheckBox = $window.FindName("DebloatCheckBox")
    $gamingTweaksCheckBox = $window.FindName("GamingTweaksCheckBox")
    
    $optimizeButton = $window.FindName("OptimizeButton")
    $updateButton = $window.FindName("UpdateButton")
    $exportLogsButton = $window.FindName("ExportLogsButton")
    $exitButton = $window.FindName("ExitButton")
    
    # Event handlers
    $optimizeButton.Add_Click({
        $selectedModules = @()
        
        if ($safeRepairCheckBox.IsChecked) { $selectedModules += "safeRepair" }
        if ($debloatCheckBox.IsChecked) { $selectedModules += "debloat" }
        if ($gamingTweaksCheckBox.IsChecked) { $selectedModules += "gamingTweaks" }
        
        if ($selectedModules.Count -eq 0) {
            [System.Windows.MessageBox]::Show("Vælg mindst ét modul.", "ByensIT Optimizer", "OK", "Warning")
            return
        }
        
        $optimizeButton.IsEnabled = $false
        
        # Run optimization in background
        $runspace = [runspacefactory]::CreateRunspace()
        $runspace.Open()
        $runspace.SessionStateProxy.SetVariable("selectedModules", $selectedModules)
        $runspace.SessionStateProxy.SetVariable("script:ProgressBar", $script:ProgressBar)
        $runspace.SessionStateProxy.SetVariable("script:StatusLabel", $script:StatusLabel)
        $runspace.SessionStateProxy.SetVariable("script:logPath", $script:logPath)
        $runspace.SessionStateProxy.SetVariable("PSScriptRoot", $PSScriptRoot)
        
        $powershell = [powershell]::Create()
        $powershell.Runspace = $runspace
        $powershell.AddScript({
            param($modules)
            Start-OptimizationProcess $modules
        }).AddArgument($selectedModules)
        
        $handle = $powershell.BeginInvoke()
        
        # Re-enable button when done
        Register-ObjectEvent -InputObject $powershell -EventName InvocationStateChanged -Action {
            if ($Event.Sender.InvocationStateInfo.State -eq "Completed") {
                $optimizeButton.Dispatcher.Invoke([Action]{
                    $optimizeButton.IsEnabled = $true
                })
            }
        } | Out-Null
    })
    
    $updateButton.Add_Click({
        Check-ForUpdates
    })
    
    $exportLogsButton.Add_Click({
        Export-LogsToZip
    })
    
    $exitButton.Add_Click({
        $window.Close()
    })
    
    # Initial log message
    Write-GuiLog "ByensIT Optimizer v$($script:version.version) startet"
    Write-GuiLog "Konfiguration indlæst - $($script:config.modules.Count) moduler tilgængelige"
    
    if (!(Test-AdminRights)) {
        Write-GuiLog "ADVARSEL: Ikke kørt som administrator - nogle funktioner virker muligvis ikke" -Level "WARN"
        [System.Windows.MessageBox]::Show(
            "Appen er ikke kørt som administrator.`n`nNogle optimeringer virker muligvis ikke korrekt.`n`nGenstart som administrator for bedste resultat.",
            "ByensIT Optimizer",
            "OK",
            "Warning"
        )
    }
    
    return $window
}

# Main execution
if (!(Load-Configuration)) {
    exit 1
}

$window = Create-MainWindow
$window.ShowDialog() | Out-Null 