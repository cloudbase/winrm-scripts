# Copyright 2013 Cloudbase Solutions Srl
#
#    Licensed under the Apache License, Version 2.0 (the 'License'); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an 'AS IS' BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

param (
    [string]$path = $(throw "The PFX certificate path is required."),
    [System.Security.SecureString]$password = $( Read-Host -assecurestring "Pfx file password")
 )

$store = New-Object System.Security.Cryptography.X509Certificates.X509Store(
    [System.Security.Cryptography.X509Certificates.StoreName]::My,
    [System.Security.Cryptography.X509Certificates.StoreLocation]::CurrentUser)
$store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)

$cert = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2(
    $path, $password,
    ([System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::UserKeySet -bor
     [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::PersistKeySet))
$store.Add($cert)

Write-Host "Imported certificate subject: $($cert.Subject)"
