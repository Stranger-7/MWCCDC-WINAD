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

#enable local firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

Set-NetFirewallProfile -DefaultInboundAction Block -DefaultOutboundAction Allow

#New-NetFirewallRule -DisplayName "Allow DNS UDP" -Direction Inbound -LocalPort 53 -Protocol udp -Action Allow
#New-NetFirewallRule -DisplayName "Allow DNS TCP" -Direction Inbound -LocalPort 53 -Protocol tcp -Action Allow
#New-NetFirewallRule -DisplayName "Allow Kerberos auth TCP" -Direction Inbound -LocalPort 88 -Protocol tcp -Action Allow
#New-NetFirewallRule -DisplayName "Allow Kerberos auth UDP" -Direction Inbound -LocalPort 88 -Protocol udp -Action Allow
#New-NetFirewallRule -DisplayName "Allow W32Time" -Direction Inbound -LocalPort 123 -Protocol udp -Action Allow
#New-NetFirewallRule -DisplayName "Allow LDAP udp" -Direction Inbound -LocalPort 389 -Protocol udp -Action Allow
#New-NetFirewallRule -DisplayName "Allow LDAP TCP" -Direction Inbound -LocalPort 389 -Protocol tcp -Action Allow
#New-NetFirewallRule -DisplayName "WATCH ALLOW SMB" -Direction Inbound -LocalPort 389 -Protocol tcp -Action Allow
#New-NetFirewallRule -DisplayName "Allow Kbrs password change" -Direction Inbound -LocalPort 464 -Protocol tcp -Action Allow
#New-NetFirewallRule -DisplayName "Allow Kbrs password change" -Direction Inbound -LocalPort 464 -Protocol udp -Action Allow
#New-NetFirewallRule -DisplayName "Allow LDAP SSL" -Direction Inbound -LocalPort 636 -Protocol tcp -Action Allow
#New-NetFirewallRule -DisplayName "Allow AD Web Service" -Direction Inbound -LocalPort 9389 -Protocol tcp -Action Allow
#New-NetFirewallRule -DisplayName "Allow LDAP Global Cat/LDAP GC SSL" -Direction Inbound -LocalPort 3268,3269 -Protocol tcp -Action Allow
#New-NetFirewallRule -DisplayName "Allow RPC Ephemeral" -Direction Inbound -LocalPort 49152-65535 -Protocol tcp -Action Allow



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
