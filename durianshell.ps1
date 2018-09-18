### Prototype  ###

##############
# Initialize #
##############
$tools = New-Object psobject
$import = Get-Content -path "C:\PS\nmap.json" -raw | ConvertFrom-Json
# Import tools, then overlay with user settings

# If the tool is installed, add it to the list
$tools | Add-Member -Name $import.name -Value $import -MemberType NoteProperty

#########################
# Set up the navigation #
#########################

$navigation = New-Object psobject
$navigation | Add-Member -MemberType NoteProperty -Name tool -Value "NMAP"
$navigation | Add-Member -MemberType NoteProperty -Name location -Value "Tools"
$navigation | Add-Member -MemberType NoteProperty -Name param -Value ""

##################
# Menu v2        #
##################

Clear-Host
# Clear the previous choices
$menuChoices = @{}
$counter = 1

# Build menu

# Header Bar
Write-Host "$($navigation.location) > $($navigation.tool) > $($navigation.param)"
Write-Host "Jobs running: NMAP 1, Hydra 2"
Write-Host
Write-Host "Target selected: None"

# if navigation.location -eq tools and .param -eq ""
# Command Builder
Write-Host "Command: $($tools.($navigation.tool).command)" -NoNewline #Notice the trailing space

# Iterate through all of the Tool options, echo the enabled ones
$tools.($navigation.tool).options.PSObject.Properties | Where-Object {
$_.value.enabled -eq $true } | ForEach-Object {Write-Host -NoNewline " $($_.value.output)"} #Add space before

Write-Host "`n`nWhich do you want to toggle?" 
Write-Host "`n<enter> Cancel/Back"

# Iterate through each Tool-Option while keeping the order
$tools.($navigation.tool).options.PSobject.Properties | ForEach-Object {


if ($_.value.enabled){$enabled = "X"}
else {$enabled = " "}
Write-Host -NoNewline $counter
if ($_.value.group){
    Write-Host -NoNewline " ($enabled) "  
}
else {
    Write-Host -NoNewline " [$enabled] "  
}

Write-Host $_.value.description

# Save list and increment
$menuChoices | Add-Member -MemberType NoteProperty -Name $counter -Value $_.Name
$counter++

# Display the extra paramater, if any
if ($_.value.param.required){
Write-Host "  Additional info needed"
}
}
# Final space
Write-Host

# Recieve input
#$choice = Read-Host -Prompt "Pick a number: "

#$userChoices

#Get-Content -Path C:\PS\nmap.json | ConvertFrom-Json


<#
Lots to do here, I'll start with a light framework that I'll replace
In time. 

To do list:
Auto scan menu based on results
Logging per ip
Tool default and history layout 
Tool json layout
Parsers
Object nesting defaults > history > ip
Master log
Output clixml 
Toggle menu
Ip select all many one
Job handler. Job ids
Ssh parser? 
Scp
#>


# Initialize 

# Import all ps1 functions

# Import all .JSON settings

# Scan for installed tools

# Ask if it's a new scan or a old
# ask name or auto generated 

# Import old scan settings

# Navigation loop

<#
Navigate template (maybe dynamic basec on proto options)
Home > Hosts > Protocol > Tool > Results
Home > 1.1 > HTTP > Nikto > R1 / R2 / R3

Proably handle return of menu options here.

Level 1
Refresh
Tools
  Based on target protocols
  Http <1 target>
  Scanners always visible 
  Show all <manually select>
Choose targets <currently>
  List of live, multi select
Global Options
  Auto sub menu 
    Enable disable features
  Localip
  Directory of reports
  Logging level
Change to different save
Exit 

Tool options header 
# Location
# ip selected
# current command
## current option? 

Auto options
Nmap progressive123
  If live system

Jobs running 
# running / # queued name
1/3 nmap 2 nikto 4 dirb

Manage jobs 
  Cancel job
#>
