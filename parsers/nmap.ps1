

$liveHosts = $nmap.nmaprun.host | ? { $_.status.state -match "up"}

$liveHosts[0].os.osmatch

$liveHosts[0].os.osmatch.accuracy
$liveHosts[0].os.osmatch.name

$sesh[0].psobject.Properties | ? {$_.typenameofvalue -notlike 'system.string'}
