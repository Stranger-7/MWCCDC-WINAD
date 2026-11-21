#This script was NOT DEVELOPED BY Me it was gifted to me for use during CCDC competitions to enumerat AD users and Groups. 
Import-Module ActiveDirectory

# ---- CONFIG ----
$OutputFile = "ADUsers.csv"

# ---- HELPER: FORMAT GROUPS (6 PER LINE) ----
function Format-Groups {
    param ([array]$groups)

    if (-not $groups) {
        return "No Groups"
    }

    $chunkSize = 6
    $chunks = @()

    for ($i = 0; $i -lt $groups.Count; $i += $chunkSize) {
        $end = [Math]::Min($i + $chunkSize - 1, $groups.Count - 1)
        $chunks += ($groups[$i..$end] -join " | ")
    }

    return ($chunks -join "`r`n")
}

# ---- STEP 1: GET DOMAIN ROOT ----
$domain = Get-ADDomain
$rootDN = $domain.DistinguishedName

Write-Host "Starting user audit for domain: $($domain.DNSRoot)"

# ---- STEP 2: GET ALL USERS (for progress tracking) ----
Write-Host "Enumerating users..."

$allUsers = Get-ADUser -Filter * -SearchBase $rootDN -Properties MemberOf, DistinguishedName -ResultSetSize $null
$totalUsers = $allUsers.Count
$currentUser = 0

# ---- STEP 3: PROCESS USERS ----
$Results = foreach ($user in $allUsers) {

    $currentUser++

    Write-Progress -Activity "Processing Users" `
                   -Status "$currentUser / $totalUsers - $($user.SamAccountName)" `
                   -PercentComplete (($currentUser / $totalUsers) * 100)

    # Extract OU from DN
    $ouPath = ($user.DistinguishedName -replace '^CN=.*?(?<!\\),','')

    # Get group names
    $groupNames = @()

    if ($user.MemberOf) {
        $groupNames = $user.MemberOf | ForEach-Object {
            ($_ -split ",")[0] -replace "^CN="
        }
    }

    # Format groups (6 per line)
    $groupList = Format-Groups -groups $groupNames

    # Output object
    [PSCustomObject]@{
        OU     = $ouPath
        User   = $user.Name
        Groups = $groupList
    }
}

Write-Progress -Activity "Processing Users" -Completed

# ---- STEP 4: EXPORT ----
Write-Host "Exporting results..."

$Results | Export-Csv -Path $OutputFile -NoTypeInformation

Write-Host "Report exported to $OutputFile"
