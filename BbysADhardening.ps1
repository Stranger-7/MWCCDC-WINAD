#Baby's first Windows hardening Script

#----Network----

#disable ipv6
Disable-NetAdapterBinding -Name "Ethernet" -ComponentID ms_tcpip6

#enable local firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

Set-NetFirewallProfile -DefaultInboundAction Block -DefaultOutboundAction Allow

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

Set-SmbServerConfiguration -EnableSMB1Protocl $false

Set-SmbServerConfiguration -EnableSMB2Protocol $true

