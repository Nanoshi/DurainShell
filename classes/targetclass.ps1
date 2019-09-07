class Target {
    [IPAddress] $IPAddress
    [String] $ComputerName
    [String] $Nick
    [String] $Description

    # Constructor asdfas
    Target([IPAddress] $IPAddress) {
        $this.IPAddress
    }

    # Methods
    [Bool] isOnline() {
        return(Test-Connection -Count 1 -Quiet $this.IPAddress)
    }
    [int] testJob() {
        $job = Start-Job -ScriptBlock { $true }
        return($job)
    }

}