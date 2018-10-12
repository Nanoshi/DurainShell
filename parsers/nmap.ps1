[xml]$nmap = Get-Content .\nmap.xml

#Strip out the offline titles
$liveHosts = $nmap.nmaprun.host | ? { $_.status.state -match "up"}

$targets = @()

# Create initial
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
    $_.ports.port | Where-Object {$_.state.state -like 'open'} | ForEach-Object {

        $port = New-Object psobject

        $port = [PSCustomObject]@{
            $_.service.name = [PSCustomObject]@{
                product = $_.service.product
                version = $_.service.version
                ostype = $_.service.ostype
                extrainfo = $_.service.extrainfo
            }
        }

        $entry | Add-Member -MemberType NoteProperty -Name "$($_.service.name)" -Value $port
    }

    $targets += $entry
}

# Additional pieces
