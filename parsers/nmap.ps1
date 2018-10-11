[xml]$nmap = Get-Content .\nmap.xml

#Strip out the offline titles
$liveHosts = $nmap.nmaprun.host | ? { $_.status.state -match "up"}

$targets = @()

$liveHosts | ForEach-Object {
    $entry = New-Object psobject
    if ($_.address.addr.count -gt 1){
        $entry | Add-Member -MemberType NoteProperty -Name "IP" -Value $_.address.addr[0]
        $entry | Add-Member -MemberType NoteProperty -Name "MAC" -Value $_.address.addr[1]
    } 
    else {
        $entry | Add-Member -MemberType NoteProperty -Name "IP" -Value $_.address.addr
    }
    if ($_.os.osmatch.name){
        $entry | Add-Member -MemberType NoteProperty -Name "OS" -Value $_.os.osmatch.name
    }

    $targets += $entry
}


# $sesh[0].psobject.Prerties | ? {$_.typenameofvalue -notlike 'system.string'}
