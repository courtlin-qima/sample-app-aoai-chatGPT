. ./scripts/loadenv.ps1

$venvPythonPath = "./venvs/.venv/scripts/python.exe"
if (Test-Path -Path "/usr") {
  # fallback to Linux venv path
  $venvPythonPath = "./venvs/.venv/bin/python"
}

Write-Host 'Running "auth_update.py"'
Start-Process -FilePath $venvPythonPath -ArgumentList "./scripts/auth_update.py --appid $env:AUTH_APP_ID --uri $env:BACKEND_URI" -Wait -NoNewWindow

Write-Host 'Running "prepdocs.py"'
$cwd = (Get-Location)
Start-Process -FilePath $venvPythonPath -ArgumentList "./scripts/prepdocs.py --searchservice $env:AZURE_SEARCH_SERVICE --index $env:AZURE_SEARCH_INDEX --formrecognizerservice $env:AZURE_FORMRECOGNIZER_SERVICE --tenantid $env:AZURE_TENANT_ID" -Wait -NoNewWindow
