param (
    [string]$ComputerName = $(throw "-ComputerName is required."),
    [string]$CertificateSubject = $(throw "-CertificateSubject is required.")
 )

$store = New-Object System.Security.Cryptography.X509Certificates.X509Store(
    [System.Security.Cryptography.X509Certificates.StoreName]::My,
    [System.Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser)
$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadOnly)

foreach($cert in $store.Certificates) {
    if ($cert.Subject -eq $CertificateSubject) {
        $sessionCert = $cert
        break
    }
}

if (!$sessionCert) {
    throw "An X509 certificate matching subject `"$CertificateSubject`" could not be found."
}

$opt = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$session = New-PSSession -ComputerName $ComputerName -UseSSL -CertificateThumbprint $sessionCert.Thumbprint -SessionOption $opt
Enter-PSSession $session
