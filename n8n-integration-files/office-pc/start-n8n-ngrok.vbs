Set WshShell = CreateObject("WScript.Shell")

Dim fso, scriptDir, proxyJs
Set fso = CreateObject("Scripting.FileSystemObject")
scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
proxyJs = scriptDir & "\dahua-proxy.js"

' --- WAIT FOR ZEROTIER CONNECTION ---
WScript.Sleep 30000  ' 30 seconds, adjust if needed

' --- Step 1: Kill any running node.exe (n8n or proxies) ---
On Error Resume Next
WshShell.Run "cmd /c taskkill /F /IM node.exe", 0, True
On Error GoTo 0

' --- Step 2: Start n8n hidden with environment variables ---
n8nCommand = "$env:N8N_HOST='0.0.0.0'; " & _
             "$env:N8N_PORT='5678'; " & _
             "$env:WEBHOOK_URL='http://192.168.192.197:5679/'; " & _
             "$env:N8N_SECURE_COOKIE='false'; " & _
             "n8n start"

WshShell.Run "powershell -NoProfile -NoExit -Command" & Chr(34) & n8nCommand & Chr(34), 0, False

' --- Step 3: Start ngrok hidden with YAML config ---
ngrokPath = "C:\Program Files\WindowsApps\ngrok.ngrok_3.36.1.0_x64__1g87z0zv29zzc\ngrok.exe"
ngrokConfig = "C:\Users\Admin\AppData\Local\ngrok\ngrok.yml"

WshShell.Run """" & ngrokPath & """ start --config """ & ngrokConfig & """ n8n", 0, False

' --- Step 4: Start Dahua Proxy hidden (same folder as this .vbs) ---
WshShell.Run "node """ & proxyJs & """", 0, False

' --- Step 5: Wait for services to start ---
WScript.Sleep 15000  ' 15 seconds, adjust if needed

' --- Step 6: Open n8n dashboard in Chrome ---
chromePath = "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
dashboardURL = "http://192.168.192.197:5678/workflow/WZH7ZiaPnLjB2IdJ"

' First open
WshShell.Run """" & chromePath & """ " & dashboardURL, 1, False

' Wait a bit for page to load
WScript.Sleep 5000  ' 5 seconds (adjust if needed)

' "Refresh" by opening again
WshShell.Run """" & chromePath & """ " & dashboardURL, 1, False
