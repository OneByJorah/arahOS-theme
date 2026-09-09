#Requires -Version 5.1

Write-Host "arahOS Help Desk — osTicket Theme installer (PowerShell)" -ForegroundColor Green
Write-Host "This script deploys the theme files onto an existing osTicket 1.18.x installation." -ForegroundColor Yellow
Write-Host "" -NoNewline

$target = Read-Host "Enter osTicket upload directory (default: C:\inetpub\wwwroot\osticket)"
if (-not $target) { $target = "C:\inetpub\wwwroot\osticket" }

if (-not (Test-Path "$target\main.inc.php")) {
    Write-Error "'$target' does not look like an osTicket upload/ directory."
    Write-Host "Please provide the correct path to your osTicket upload directory." -ForegroundColor Red
    exit 1
}

$here = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
Write-Host "Installing theme files into: $target" -ForegroundColor Cyan

# Copy plugin files
New-Item -ItemType Directory -Force -Path "$target\include\plugins\arahOS-theme" | Out-Null
Copy-Item "$here\plugin\*" -Destination "$target\include\plugins\arahOS-theme\" -Force
Write-Host "    Plugin files copied" -ForegroundColor Gray

# Copy CSS files
New-Item -ItemType Directory -Force -Path "$target\css\arahOS" | Out-Null
Copy-Item "$here\css\arahOS\arahOS-*.css" -Destination "$target\css\arahOS\" -Force
Write-Host "    Theme CSS copied" -ForegroundColor Gray

# Copy JS files
New-Item -ItemType Directory -Force -Path "$target\js\arahOS" | Out-Null
Copy-Item "$here\js\arahOS\arahOS-*.js" -Destination "$target\js\arahOS\" -Force
Write-Host "    Theme JS copied" -ForegroundColor Gray

# Copy templates
$templates = @(
    "include\staff\login.tpl.php",
    "include\staff\login.header.php",
    "include\staff\header.inc.php",
    "include\staff\footer.inc.php",
    "include\client\header.inc.php",
    "include\client\footer.inc.php",
    "include\client\login.inc.php",
    "include\client\accesslink.inc.php"
)

foreach ($template in $templates) {
    $source = "$here\$template"
    $dest = "$target\$template"
    if (Test-Path $source) {
        Copy-Item $source -Destination $dest -Force
        Write-Host "    Copied $template" -ForegroundColor Gray
    } else {
        Write-Warning "Source not found: $source"
    }
}

# Copy landing page
Copy-Item "$here\index.php" -Destination "$target\index.php" -Force
Write-Host "    Landing page copied" -ForegroundColor Gray

# Copy PWA files
$manifest = "$here\manifest.webmanifest"
if (Test-Path $manifest) {
    Copy-Item $manifest -Destination "$target\manifest.webmanifest" -Force
}

Copy-Item "$here\sw.js" -Destination "$target\sw.js" -Force
Copy-Item "$here\offline.html" -Destination "$target\offline.html" -Force
Copy-Item "$here\.htaccess" -Destination "$target\.htaccess" -Force

if (Test-Path "$here\images\arahOS") {
    Copy-Item "$here\images\arahOS\*" -Destination "$target\images\arahOS\" -Force -Recurse
}
Write-Host "    PWA + images copied" -ForegroundColor Gray

# Copy showcase (optional)
if (Test-Path "$here\showcase") {
    Copy-Item "$here\showcase" -Destination "$target\" -Force -Recurse
    Write-Host "    Showcase copied" -ForegroundColor Gray
}

Write-Host "" -NoNewline
Write-Host "==> Installation complete!" -ForegroundColor Green
Write-Host "" -NoNewline
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "    1. Admin Panel → Manage → Plugins → enable 'arahOS Help Desk Theme'" -ForegroundColor White
Write-Host "    2. (Optional) Run: mysql -u <user> -p <db> < $here\db\kb-seed.sql" -ForegroundColor White
Write-Host "    3. Visit /showcase/responsive.html to see the theme at phone/tablet/laptop sizes" -ForegroundColor White
Write-Host "" -NoNewline
