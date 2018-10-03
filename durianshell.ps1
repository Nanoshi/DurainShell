### Prototype  ###

##############
# Initialize #
##############

#region Initialize
# Sleep Timer for debugging
$sleepTimer = 1

# Set PWD to script location
Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)
$tools = New-Object psobject
$import = Get-Content -Path "./tools/nmap.json" -Raw | ConvertFrom-Json
# Import tools, then overlay with user settings

# If the tool is installed, add it to the list
$tools | Add-Member -Name $import.Name -Value $import -MemberType NoteProperty

# Set up the initial navigation #
$scan = $null

$navigation = New-Object psobject
$navigation | Add-Member -MemberType NoteProperty -Name location -Value "Tools"
$navigation | Add-Member -MemberType NoteProperty -Name tool -Value "NMAP"
$navigation | Add-Member -MemberType NoteProperty -Name option -Value ""
#endregion

###########
# Menu v2 #
###########

# Loop forever
while (1) {

	#region Menu Header
	Clear-Host
	# Clear the previous choices
	$menuChoices = New-Object psobject
	$counter = 1

	# Header Bar
	Write-Host
	if ($navigation.location) { Write-Host -NoNewline "$($navigation.location)" }
	if ($navigation.tool) { Write-Host -NoNewline " > $($navigation.tool)" }
	if ($navigation.option) { Write-Host -NoNewline " > $($navigation.option[0])" }
	Write-Host "`n"
	Write-Host "Jobs running: NMAP 1, Hydra 2"
	Write-Host

	# Logic about selected targets
	Write-Host "Target selected: None"
	#endregion

	#region Menu Home
	if ($navigation.location -notlike "Tools"){
		Write-Host "`nWhich folder would you like to save it in?"
		# List Existing Scans
		$autoName = "$(Get-Date -Format yyyymmdd-HH)"
		Write-Host "<enter> For auto-generated $autoName"
	}
	#endregion

	#############
	# Tool Menu #
	#############

	#region Menu - Tool
	if ($navigation.location -like "Tools") {

		#region Menu - Tool Main
		if ($navigation.tool -like "") {
            Write-Host "Which tool would you like to use?`n"
            Write-Host "<enter> Refresh"
            $tools.psobject.Properties | ForEach-Object {
                Write-Host "$counter $($_.Value.name)"
			    $menuChoices | Add-Member -MemberType NoteProperty -Name $counter -Value $_.value.Name
			    $counter++
            }
            Write-Host
		}
		#endregion


		#region Menu - Tool Option selection
		if ($navigation.tool -notlike "") {

			#region Configure scan if blank
			if ($null -eq $scan) {
				$scan = New-Object psobject
				$scan | Add-Member -MemberType NoteProperty -Name "tool" -Value $navigation.tool
				# Iterate through each Tool Option
				$tools.($navigation.tool).options.PSObject.Properties | ForEach-Object {
					$entry = New-Object PSObject
					$entry | Add-Member -MemberType NoteProperty -Name "enabled" -Value ($_.value.enabled -eq $true)
					if ($tools.($navigation.tool).options.($_.Name).param) {
						$entry | Add-Member -MemberType NoteProperty -Name "param" -Value $tools.($navigation.tool).options.$($_.Name).param.defualts[0]
					} else {
						$entry | Add-Member -MemberType NoteProperty -Name "param" -Value ""
					}
					$scan | Add-Member -MemberType NoteProperty -Name $_.Name -Value $entry
				} # End For-Each loop 
			} # End if blank scan
			#endregion

			#region Command Builder
			Write-Host "Command: $($tools.($scan.tool).command)" -NoNewline #Notice the trailing space

			# Display each scan.enabeled tool option with scan.param
			$tools.($scan.tool).options.PSObject.Properties | Where-Object {
				$scan.($_.Name).enabled -eq $true } | ForEach-Object {
				Write-Host -NoNewline " $($tools.$($scan.tool).options.($_.name).output.Replace("<param>","$($scan.($_.name).param)"))"
			} # End For-Each loop
			#endregion

			#region Menu - Tool Option Main
			if ($navigation.option -like "") {

				#region Menu counters and choices
				Write-Host "`n`nWhich do you want to toggle?"
				Write-Host "`n<enter> Cancel/Back"

				# Iterate through each Tool-Option while keeping the order
				$tools.($navigation.tool).options.PSObject.Properties | ForEach-Object {

					if ($scan.($_.Name).enabled) { $enabled = "X" }
					else { $enabled = " " }
					Write-Host -NoNewline $counter
					if ($_.value.group) {
						Write-Host -NoNewline "`t($enabled) "
					}
					else {
						Write-Host -NoNewline "`t[$enabled] "
					}

					Write-Host $_.value.description

					# Save list and increment
					$menuChoices | Add-Member -MemberType NoteProperty -Name $counter -Value $_.Name
					$counter++

					# Display the extra paramater, if any
					if ($_.value.param.required) {
						if ($scan.($_.Name)) {
							Write-Host "$counter `t < $($scan.($_.name).param) >" }
						else {
							Write-Host "$counter `t < Mandatory >" }
						# For param options, saves menu option as an array
						$menuChoices | Add-Member -MemberType NoteProperty -Name $counter -Value ($_.Name,"param")
						$counter++

					}
				} # End of For-Each Option

				Write-Host
				Write-Host "d `tRestore default settings"
				#Write-Host "s `tSave current settings"
				#Write-Host "e `tExit Program"
				Write-Host "r `tRun the scan"
				Write-Host
				#endregion

			} # End Tool Option Main
			#endregion Menu Tool Option Main

			#region Menu -Tool - Option - Param
			if ($navigation.option -notlike "") {
				Write-Host "`n`nWhat would you like to set the parameter as?`n"
				Write-Host "Currently: $($scan.($navigation.option[0]).param)"
				Write-Host "`n<enter> Cancel/Back`n"
                Write-Host "$counter <Type your own parameter>"
               	$menuChoices | Add-Member -MemberType NoteProperty -Name $counter -Value $_
           		$counter++

				# Iterate through each Tool-Option-Parameter keeping the order
                Write-Host "--Default Options"
				$tools.($navigation.tool).options.($navigation.option[0]).param.defualts | % {
					Write-Host "$counter $_"
					# Save list and increment
					$menuChoices | Add-Member -MemberType NoteProperty -Name $counter -Value $_
					$counter++
				} # End defaults section
			} # End Param choice
			#endregion

		} # End Tool - Option
		#endregion Tool - Option


	} # End tool
	#endregion

	##################
	# Receive Inputs #
	##################
    
    #region Recieve and validate input
	[string]$choice = $null
	[string]$choice = Read-Host -Prompt "Pick a number " -ErrorAction SilentlyContinue

	# If back/cancel then clear scan variable
	if ($choice -like "") {
		Write-Host "Going up 1 menu"; Start-Sleep -Seconds $sleepTimer; 
        if ($navigation.option){ $navigation.option = ""; continue;}
        if ($navigation.tool){ $navigation.tool = ""; continue;}
		#$navigation.location = "Home"; continue;
		continue
	}

    if ($navigation.location -like "Home"){
	    if ($choice -like "e") {
		    Write-Host "Exiting program"; Start-Sleep -Seconds $sleepTimer; break;
    	}
    }

    if ($navigation.location -like "Tools"){
	    if ($choice -like "d") {
		    Write-Host "Default settings!";
		    $scan = $null
		    Start-Sleep -Seconds $sleepTimer; continue;
    	}
    }

	if ($choice -notmatch '^[0-9]+$') {
		Write-Host "Please type a number"; Start-Sleep -Seconds $sleepTimer; continue;
	}

	if ([int]$choice -lt 1 -or [int]$choice -ge $counter) {
		Write-Host "Please choose a number in the range above"; Start-Sleep -Seconds $sleepTimer; continue;
	}
    #endregion

	#region Input - Tools - Options
	if ($navigation.location -like "Tools") {

        # Choose a tool
        if ($navigation.tool -like ""){
            $navigation.tool = $menuChoices.($choice)
            continue
        }

        # Choose tool option
        if ($navigation.tool -notlike "") {
            if ($navigation.option -like "") {
		        # Simple 1d choice
		        if ($menuChoices.($choice).count -eq 1) {
			        Write-Host "1 Param"

			        # Save options and execute command
			        if ($menuChoices.($choice) -match "run") { continue; }

			        # Toggle options
				    Write-Host "Toggle"
				    $scan.($menuChoices.($choice)).enabled = !($scan.($menuChoices.($choice)).enabled)
				    # If option grouping is not blank
				    $toggleGroup = $tools.($navigation.tool).options.($menuChoices.($choice)).group
				    if ($toggleGroup -and $scan.($menuChoices.($choice)).enabled) {
					    # Loops through tool-options, then turn off others from group
					    $tools.($scan.tool).options.PSObject.Properties | Where-Object {
						    $tools.($scan.tool).options.($_.Name).group -eq $toggleGroup -and
						    $_.Name -notlike $menuChoices.$choice } | ForEach-Object {
						    $scan.($_.Name).enabled = $false
					    } # End Foreach-Ob Group
				    } # End if group
    			continue # Back to the top of the menu
			    } # End 1 Param
                if ($menuChoices.($choice).count -eq 2) {
			        $navigation.option = $menuChoices.($choice)
			           continue
		        } # End 2 Param  
			} # End Option = Blank
            # Assign param to scan option
			if ($navigation.option -notlike "") {
                if ($choice -like 1) {
                    $scan.($navigation.option[0]).param = Read-Host -Prompt "Type your paramater "
                } else {
				    $scan.($navigation.option[0]).param = $menuChoices.($choice)
                }
                $navigation.option = ""
                continue
			}
        } # End Tool option
		# Paramater handling
	} # End Input Tool Options
	#endregion

	Write-Host "Input didn't match with anything, something went wrong..."; Start-Sleep $sleepTimer; break;
} # End For ever loop, back to the top.

#########
# Notes #
#########
<# new object with properties Test and Foo
$obj = New-Object -TypeName PSObject -Property @{ Test = 1; Foo = 2 }

# remove a property from PSObject.Properties
$obj.PSObject.Properties.Remove('Foo')

#Variables layout

\\config = @{}
+tools
history #Per tool
+session #Per Scan Session
auto #Auto folder
+navigation

Enter tool menu
+if !scan
+    tool default > scan
+display tool + scan options


# Examples

scan.tool=nmap
scan.pn
scan.p.param = 80

tools.namp.pn....

session.targets (all)
session.tools.nmap.... #Same as history

history.nmap[1].p.param #Ref the tools, be careful

#################

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

# Ask if it's a new scan or a old
# ask name or auto generated 

# Import old scan settings

# Navigation loop

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
