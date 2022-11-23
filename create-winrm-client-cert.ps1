Param (
    $UserName = "cloudbase-init-user-$(Get-Random)",
    $FileBaseName = 'winrm_client_cert'
)

$USER_NAME = $UserName
$UPN = "$USER_NAME@localhost"
$SUBJECT = "/CN=$USER_NAME"

$PFX_FILE = "$FileBaseName.pfx"
$PEM_FILE = "$FileBaseName.pem"

$PRIVATE_DIR = New-Item -ItemType Directory -Path $env:TEMP -Name "cloudbase-init$(Get-Random)" -Force | Select-Object -ExpandProperty FullName

$EXT_CONF_FILE = New-Item -ItemType File -Path $env:TEMP -Name "cloudbase-init$(Get-Random).conf" -Force | Select-Object -ExpandProperty FullName

$KEY_FILE = "$PRIVATE_DIR\cert.key"

Set-Content -Path $EXT_CONF_FILE -Value @"
distinguished_name  = req_distinguished_name
[req_distinguished_name]
[v3_req_client]
extendedKeyUsage = clientAuth
subjectAltName = otherName:1.3.6.1.4.1.311.20.2.3;UTF8:$UPN
"@

New-Item -Path Env:\ -Name OPENSSL_CONF -Value $EXT_CONF_FILE -Force | Out-Null



openssl.exe req -x509 -nodes -days 3650 -newkey rsa:2048 -out $PEM_FILE -outform PEM -keyout $KEY_FILE -subj $SUBJECT -extensions v3_req_client 2> $null

Remove-Item -Path $EXT_CONF_FILE
Remove-Item -Path Env:\OPENSSL_CONF -Force

openssl.exe pkcs12 -export -in $PEM_FILE -inkey $KEY_FILE -out $PFX_FILE

Remove-Item -Path $PRIVATE_DIR -Recurse -Force -Confirm:$False

$THUMBPRINT = (openssl x509 -inform PEM -in $PEM_FILE -fingerprint -noout) -replace ':' -replace '^.*=(.*)$', '$1'

Write-Host "Certificate Subject: $($SUBJECT -replace '/')"
Write-Host "Certificate Thumbprint: $THUMBPRINT"
