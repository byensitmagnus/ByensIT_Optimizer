# ByensIT Optimizer Build Script
# Builds the application for different configurations

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Debug", "Release", "Both")]
    [string]$Configuration = "Release",
    
    [Parameter(Mandatory=$false)]
    [switch]$SelfContained,
    
    [Parameter(Mandatory=$false)]
    [switch]$SingleFile,
    
    [Parameter(Mandatory=$false)]
    [switch]$Publish,
    
    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ".\dist"
)

Write-Host "ByensIT Optimizer Build Script v2.0" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if .NET SDK is installed
try {
    $dotnetVersion = dotnet --version
    Write-Host "✅ .NET SDK Version: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ .NET SDK not found. Please install .NET 6.0 SDK" -ForegroundColor Red
    Write-Host "   Download from: https://dotnet.microsoft.com/download/dotnet/6.0" -ForegroundColor Yellow
    exit 1
}

# Clean previous builds
Write-Host ""
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
if (Test-Path $OutputPath) {
    Remove-Item $OutputPath -Recurse -Force
}
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null

# Restore packages
Write-Host ""
Write-Host "Restoring NuGet packages..." -ForegroundColor Yellow
dotnet restore

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Package restore failed" -ForegroundColor Red
    exit 1
}

# Build function
function Build-Configuration {
    param([string]$Config)
    
    Write-Host ""
    Write-Host "Building $Config configuration..." -ForegroundColor Yellow
    
    $buildArgs = @(
        "build"
        "--configuration", $Config
        "--no-restore"
        "--verbosity", "minimal"
    )
    
    & dotnet $buildArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Build failed for $Config" -ForegroundColor Red
        return $false
    }
    
    Write-Host "✅ $Config build completed" -ForegroundColor Green
    return $true
}

# Publish function
function Publish-Configuration {
    param([string]$Config)
    
    Write-Host ""
    Write-Host "Publishing $Config configuration..." -ForegroundColor Yellow
    
    $publishPath = Join-Path $OutputPath $Config
    
    $publishArgs = @(
        "publish"
        "--configuration", $Config
        "--output", $publishPath
        "--no-restore"
        "--verbosity", "minimal"
    )
    
    if ($SelfContained) {
        $publishArgs += "--self-contained", "true"
        $publishArgs += "--runtime", "win-x64"
        Write-Host "   Self-contained: Yes" -ForegroundColor Cyan
    } else {
        $publishArgs += "--self-contained", "false"
        Write-Host "   Self-contained: No (requires .NET Runtime)" -ForegroundColor Cyan
    }
    
    if ($SingleFile) {
        $publishArgs += "-p:PublishSingleFile=true"
        $publishArgs += "-p:IncludeNativeLibrariesForSelfExtract=true"
        Write-Host "   Single file: Yes" -ForegroundColor Cyan
    }
    
    & dotnet $publishArgs
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Publish failed for $Config" -ForegroundColor Red
        return $false
    }
    
    # Copy additional files
    Copy-Item "README.md" $publishPath -ErrorAction SilentlyContinue
    if (Test-Path "Database\DatabaseSchema.sql") {
        Copy-Item "Database\DatabaseSchema.sql" $publishPath -ErrorAction SilentlyContinue
    }
    
    Write-Host "✅ $Config published to: $publishPath" -ForegroundColor Green
    
    # Show folder contents
    $exeFiles = Get-ChildItem $publishPath -Filter "*.exe"
    if ($exeFiles.Count -gt 0) {
        $exeFile = $exeFiles[0]
        $fileSizeMB = [math]::Round($exeFile.Length / 1MB, 2)
        Write-Host "   Executable: $($exeFile.Name) ($fileSizeMB MB)" -ForegroundColor Cyan
    }
    
    return $true
}

# Build configurations
$configs = switch ($Configuration) {
    "Both" { @("Debug", "Release") }
    default { @($Configuration) }
}

$success = $true

foreach ($config in $configs) {
    if (-not (Build-Configuration $config)) {
        $success = $false
        break
    }
    
    if ($Publish) {
        if (-not (Publish-Configuration $config)) {
            $success = $false
            break
        }
    }
}

if ($success) {
    Write-Host ""
    Write-Host "Build completed successfully!" -ForegroundColor Green
    
    if ($Publish) {
        Write-Host ""
        Write-Host "Output directory: $OutputPath" -ForegroundColor Yellow
        Write-Host "You can now run the application from the published folder." -ForegroundColor White
        
        if ($SelfContained) {
            Write-Host "✅ No .NET Runtime required on target machine" -ForegroundColor Green
        } else {
            Write-Host "⚠️  Requires .NET 6.0 Runtime on target machine" -ForegroundColor Yellow
        }
    }
    
    Write-Host ""
    Write-Host "Ready to launch ByensIT Complete PC Suite v2.0!" -ForegroundColor Green
} else {
    Write-Host ""
    Write-Host "❌ Build failed" -ForegroundColor Red
    exit 1
}

# Examples
Write-Host ""
Write-Host "Usage Examples:" -ForegroundColor Cyan
Write-Host "   .\build.ps1 -Configuration Release -Publish" -ForegroundColor White
Write-Host "   .\build.ps1 -Configuration Debug -Publish -SelfContained" -ForegroundColor White
Write-Host "   .\build.ps1 -Configuration Release -Publish -SelfContained -SingleFile" -ForegroundColor White 