# CostBridge Local Development Launcher (using Neon Database)
$projectPath = $PSScriptRoot
$backendPath = Join-Path $projectPath 'backend'
$frontendPath = Join-Path $projectPath 'frontend'
$pythonPath = Join-Path $projectPath '.venv\Scripts\python.exe'

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Starting CostBridge Development Servers  " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Automatically clean up lingering processes on ports 8001 and 3000
foreach ($port in 8001, 3000) {
    $conns = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
    if ($conns) {
        $pids = $conns | Select-Object -ExpandProperty OwningProcess -Unique
        foreach ($pidToKill in $pids) {
            if ($pidToKill -gt 0) {
                Write-Host "Freeing port $port (closing previous process PID $pidToKill)..." -ForegroundColor DarkGray
                Stop-Process -Id $pidToKill -Force -ErrorAction SilentlyContinue
            }
        }
    }
}

# 1. Start Backend in a new window
Write-Host "`n[1/2] Starting FastAPI Backend on http://127.0.0.1:8001..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath'; .\.venv\Scripts\Activate.ps1; python -m uvicorn backend.server:app --host 127.0.0.1 --port 8001 --reload"

# 2. Start Frontend in a new window
Write-Host "[2/2] Starting React Frontend on http://localhost:3000..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$frontendPath'; npm start"

Write-Host "`nBoth servers are launching in separate windows!" -ForegroundColor Green
Write-Host "Frontend will open at: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Backend API docs at:   http://127.0.0.1:8001/docs" -ForegroundColor Cyan
