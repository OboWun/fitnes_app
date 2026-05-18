$adb = "C:\Users\klari\Desktop\android-testing\platform-tools\adb.exe"
$backendPort = 3001

Write-Host "Forwarding port $backendPort..." -ForegroundColor Cyan
& $adb reverse tcp:$backendPort tcp:$backendPort

Write-Host "Launching debug APK..." -ForegroundColor Cyan
fvm flutter run --debug
