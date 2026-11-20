#Baby's first Windows hardening Script

#Create Ping castle Service account
Import-Module ActiveDirectory

$Domain = (Get-ADDomain).DNSRoot
$UserName = "svc-pingcastle"
$Password = Read-Host -Prompt "Enter a strong password for $UserName" -AsSecureString

New-ADUser `
    -Name "PingCastle Service Account" `
    -DisplayName "PingCastle Service Account" `
    -SamAccountName $UserName `
    -UserPrincipalName "$UserName@$Domain" `
    -Path "OU=Service Accounts" `
    -AccountPassword $Password `
    -Enabled $true `
    -PasswordNeverExpires $false `
    -CannotChangePassword $true `
    -Description "Least-privilege service account for PingCastle AD health checks"



#----Network----

#disable ipv6
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6



#log dropped packets
Set-NetFirewallProfile -Profile domain,public,private -LogBlocked True -LogIgnored True -LogMaxSizeKilobytes 32767

#Disable NetBios
$base = "HKLM:SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces"

$interfaces = Get-ChildItem $base | Select -ExpandProperty PSChildName

foreach($interface in $interfaces) {
    Set-ItemProperty -Path "$base\$interface" -Name "NetbiosOptions" -Value 2
}


#Disable SMBv1
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

Set-SmbServerConfiguration -EnableSMB1Protocol $false

Set-SmbServerConfiguration -EnableSMB2Protocol $true

Write-Output "Go to https://www.pingcastle.com/download/ to download the latest version of pingcastle"
