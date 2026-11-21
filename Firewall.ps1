#enable local firewall

Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

Set-NetFirewallProfile -DefaultInboundAction Block -DefaultOutboundAction Allow

New-NetFirewallRule -DisplayName "Allow DNS UDP" -Direction Inbound -LocalPort 53 -Protocol udp -Action Allow
New-NetFirewallRule -DisplayName "Allow DNS TCP" -Direction Inbound -LocalPort 53 -Protocol tcp -Action Allow
New-NetFirewallRule -DisplayName "Allow Kerberos auth TCP" -Direction Inbound -LocalPort 88 -Protocol tcp -Action Allow
New-NetFirewallRule -DisplayName "Allow Kerberos auth UDP" -Direction Inbound -LocalPort 88 -Protocol udp -Action Allow
New-NetFirewallRule -DisplayName "Allow W32Time" -Direction Inbound -LocalPort 123 -Protocol udp -Action Allow
New-NetFirewallRule -DisplayName "Allow LDAP udp" -Direction Inbound -LocalPort 389 -Protocol udp -Action Allow
New-NetFirewallRule -DisplayName "Allow LDAP TCP" -Direction Inbound -LocalPort 389 -Protocol tcp -Action Allow
New-NetFirewallRule -DisplayName "WATCH ALLOW SMB" -Direction Inbound -LocalPort 389 -Protocol tcp -Action Allow
New-NetFirewallRule -DisplayName "Allow Kbrs password change" -Direction Inbound -LocalPort 464 -Protocol tcp -Action Allow
New-NetFirewallRule -DisplayName "Allow Kbrs password change" -Direction Inbound -LocalPort 464 -Protocol udp -Action Allow
New-NetFirewallRule -DisplayName "Allow LDAP SSL" -Direction Inbound -LocalPort 636 -Protocol tcp -Action Allow
New-NetFirewallRule -DisplayName "Allow AD Web Service" -Direction Inbound -LocalPort 9389 -Protocol tcp -Action Allow
New-NetFirewallRule -DisplayName "Allow LDAP Global Cat/LDAP GC SSL" -Direction Inbound -LocalPort 3268,3269 -Protocol tcp -Action Allow
New-NetFirewallRule -DisplayName "Allow RPC Ephemeral" -Direction Inbound -LocalPort 49152-65535 -Protocol tcp -Action Allow


# 1. Open a GPO session
$GpoSession = Open-NetGPO -PolicyStore "CHANGEME.com\CHANGEME-GPO-Name"

# 2. Enable the firewall for all profiles (Domain, Private, Public)
Set-NetFirewallProfile -GPOSession $GpoSession -Profile Domain,Private,Public -Enabled True
#Example for how to create a firewall rule in GP
New-NetFirewallRule -GPOSession $GpoSession `
    -DisplayName "RULE-NAME" `
    -Direction  `
    -Protocol TCP/UDP `
    -LocalPort 8443 `
    -Action Allow `
    -Profile Domain

# 3. Save and close the GPO session
Save-NetGPO -GPOSession $GpoSession
