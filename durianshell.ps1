### Prototype  ###

##############
# Initialize #
##############
$tools = New-Object psobject
$import = Get-Content -Raw C:\PS\nmap.json | ConvertFrom-Json

# Import tools, then overlay with user settings

# If the tool is installed, add it to the list
$tools | Add-Member -Name $import.name -Value $import -MemberType NoteProperty

# Get all tools, might be redundant willb e calculated in the menu later
$toolList = $tools | Get-Member | ? {$_.membertype -eq "NoteProperty"} | % {$_.name}

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
