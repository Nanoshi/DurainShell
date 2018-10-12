<#   NMAP parser for Durian Shell
Input: file path (relative location)?
Output: Object containing target info
#>


[xml]$nmap = Get-Content .\nmap.xml

#Strip out the offline titles
$liveHosts = $nmap.nmaprun.host | ? { $_.status.state -match "up"}

$targets = @()

$liveHosts | ForEach-Object {
    # Process IP and MAC
    if ($_.address.addr.count -gt 1){
        $entry = [PSCustomObject]@{
            IP = $_.address.addr[0]
            MAC = $_.address.addr[1]
        }
    } 
    else {
        $entry = [PSCustomObject]@{
            IP = $_.address.addr[0]
        }
    }

    # OS
    if ($_.os.osmatch.name){
        $entry | Add-Member -MemberType NoteProperty -Name "OS" -Value $_.os.osmatch.name
    }

    # Report only on open ports
    $_.ports.port | Where-Object {$_.state.state -like 'open'} | ForEach-Object {
        
        # Add the protocol entry if it doesn't exist
        if ($entry.($_.service.name) -eq $null) { 
            $entry | Add-Member -MemberType NoteProperty -Name $_.service.name -Value (New-Object PSCustomObject)
        }

        # Port specific details
        $port = [PSCustomObject]@{
            product = $_.service.product
            version = $_.service.version
            ostype = $_.service.ostype
            extrainfo = $_.service.extrainfo
        }

        # Add port to protocol
        $entry.($_.service.name) | Add-Member -MemberType NoteProperty -Name $_.portid -Value $port
    }

    # Add each 
    $targets += $entry
}
