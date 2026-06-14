# gri. backend — temiz başlatma (eski uvicorn süreçlerini kapatır)
Get-CimInstance Win32_Process -Filter "Name='python.exe'" |
  Where-Object { $_.CommandLine -like '*uvicorn*' -or $_.CommandLine -like '*multiprocessing.spawn*spawn_main*' } |
  ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }

Start-Sleep -Seconds 2
Set-Location $PSScriptRoot
.\.venv\Scripts\python.exe -m uvicorn app.main:app --reload --host 127.0.0.1 --port 8000
