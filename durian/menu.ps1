<#
Still deciding on a menu structure

Might use Out-menu: https://github.com/gangstanthony/PowerShell/blob/master/Out-Menu.ps1
or out-gridview -passthrough. Probably going for the latter.

Input: PSObject (any fields + return)
Output: Index of object chosen? 

Combine the 2 options! Use meun for fast movement and Gridview for complex choices


    Title
Name                  Paramater   Group ID

<back/cancel> Go back to previous screen
<save/commit> Save settings
Current command: NMAP <IP> 
Current param: -PS 443,80

Group name            <required>  
(x) Radio 1           <required>  Gr1-R1 
( ) Radio 2           <optional>
Toggle
[x] Enable x          <N/A>

#>



##################
# Menu v2        #
##################

clear
# Clear the previous choices
$menuChoices = @{}

# Counter
$counter = 1

#if navigation.location -eq tools and .param -eq ""
    
$navigation.tool
#Get all options
<# $optionlist = $tools.($navigation.tool).options | 
    Get-Member | ? {$_.membertype -eq "NoteProperty"} | % {$_.name} | % {
#>


# Build menu
Write-Host "Which do you want to toggle?" 
$tools.($navigation.tool).options | 
    Get-Member | ? {$_.membertype -eq "NoteProperty"} | % {$_.name} | % {

if ($tool.($toolChoice).options.($_).enabled){$enabled = "X"}
else {$enabled = " "}
Write-Host -NoNewline $counter
Write-Host -NoNewline " [$enabled] "  
Write-Host -NoNewline $tools.($toolChoice).options.($_).description
Write-Host

# Save list and increment
$menuChoices | Add-Member -MemberType NoteProperty -Name $counter -Value $tools.($toolChoice).options.($_)
$counter++
}
