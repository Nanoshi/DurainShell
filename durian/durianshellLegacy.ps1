### Prototype  ###

##############
# Initialize #
##############

#region Initialize
# Sleep Timer for debugging
$sleepTimer = 1

# Set PWD to script location
Set-Location (Split-Path $script:MyInvocation.MyCommand.Path)

# Import tools, then overlay with user settings
$import = Get-Content -Path "./tools/nmap.json" -Raw | ConvertFrom-Json

# If the tool is installed, add it to the list, add some validation later
$tools = [PSCustomObject]@{
    $import.name = $import
}

# Set up the initial navigation
$scan = $null
$reportFolder = $null

# Set up Navi
$navigation = [PSCustomObject]@{
    location = "Start" #Tools
    tool = "" #NMAP
    option = ""
}
#endregion

###########
# Menu v2 #
###########

# Loop forever
while (1) {

	#region Menu Header
	Clear-Host
	# Clear the previous choices
	$menuChoices = New-Object PSCustomObject
	$counter = 1

	# Header Bar
	Write-Host
	if ($navigation.location) { Write-Host -NoNewline "$($navigation.location)" }
	if ($navigation.tool) { Write-Host -NoNewline " > $($navigation.tool)" }
	if ($navigation.option) { Write-Host -NoNewline " > $($navigation.option[0])" }
    Write-Host

    # Start Menu
	#region Menu Home
    # List existing directories

	if ($navigation.location -like "Start"){
        Write-Host "
d8888b. db    db d8888b. d888888b  .d8b.  d8b   db  
88  '8D 88    88 88  '8D   '88'   d8' '8b 888o  88  
88   88 88    88 88oobY'    88    88ooo88 88V8o 88  
88   88 88    88 88'8b      88    88~~~88 88 V8o88  
88  .8D 88b  d88 88 '88.   .88.   88   88 88  V888  
Y8888D' ~Y8888P' 88   YD Y888888P YP   YP VP   V8P  
                                                                           
     .d8888. db   db d88888b db      db      
     88'  YP 88   88 88'     88      88      
     '8bo.   88ooo88 88ooooo 88      88      
       'Y8b. 88~~~88 88~~~~~ 88      88      
     db   8D 88   88 88.     88booo. 88booo. 
     '8888Y' YP   YP Y88888P Y88888P Y88888P"
     
		Write-Host "`nWhich folder do you want to work from?`n"

		# List Existing Scans
        $(Get-ChildItem -Directory .\results).name
		Write-Host "`n<enter> none, no saved settings`n"
	}
	#endregion

    # Top status bar
    if ($navigation.location -notlike "Start"){
	    Write-Host "Jobs running: NMAP 1, Hydra 2"
	    Write-Host

	    # Logic about selected targets
        Write-Host "Working Folder: $reportFolder"
	    Write-Host "Target selected: None`n"
	    #endregion
    }

    if ($navigation.location -like "Home"){
        Write-Host "<enter> - Refresh status"
        Write-Host "t - Tools section"
        Write-Host "l - Loot"
        Write-Host "j - Job details"
        Write-Host "s - Set active targets"
        Write-Host "g - Global settings"
        Write-Host "c - Change working directory"
        Write-Host "e - Exit"
    }

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
                # Can't splat here because of the logic
				$scan = New-Object PSCustomObject
                $scan | Add-Member -MemberType NoteProperty -Name "tool" -Value $navigation.tool
				# Iterate through each Tool Option
				$tools.($navigation.tool).options.PSObject.Properties | ForEach-Object {
					$entry = New-Object PSCustomObject
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
	[string]$choice = Read-Host -Prompt "Make your selection " -ErrorAction SilentlyContinue

    # Start Menu Catch
    if ($navigation.location -like "Start"){
        if ($choice -like "")
        { $navigation.location = "Home"; $reportFolder = ""; continue;}
        # Validate folder name
        if ($choice -notmatch '^[a-zA-Z0-9-_]+$')
        { Write-Host "`nPlease use only a-z, A-Z, 0-9, -, and _ (no spaces)"; sleep -Seconds 3; Continue;}
        
        # Make dir and set report variable
        if (-not (Test-Path "$PWD\results\$choice")){
            New-Item -Path "$PWD\results\" -Name $choice -ItemType Directory | Out-Null
        }
        $reportFolder = "$PWD\results\$choice"
        $navigation.location = "Home"
        Continue
    }

    # Home Menu Catch
    if ($navigation.location -like "Home"){
        Switch($choice){
            "" {continue} # Refresh
            "t" {$navigation.location = "Tools"; continue}
            "l" {$navigation.location = "Loot"; continue}
            "j" {$navigation.location = "Jobs"; continue}
            "s" {$navigation.location = "Targets"; continue}
            "g" {$navigation.location = "Global"; continue}
            "c" {$navigation.location = "Start"; continue}
            default{Write-Host "Choose one of the above options"; sleep -Seconds 2}
        }
        if ($choice -like "e") { break }
        continue
    }

	# If <blank/enter> adjust the navigation back 1 step
	if ($choice -like "") {
        if ($navigation.option){ $navigation.option = ""; continue;}
        if ($navigation.tool){ $navigation.tool = ""; continue;}
		$navigation.location = "Home"; continue;
		continue
	}

    # Validate for non-numbers
	if ($choice -notmatch '^[0-9dDrR]+$') {
		Write-Host "Please type a number"; Start-Sleep -Seconds $sleepTimer; continue;
	}
        
    # Check if it's in the choice range
	if ([int]$choice -lt 1 -or [int]$choice -ge $counter) {
		Write-Host "Please choose a number in the range above"; Start-Sleep -Seconds $sleepTimer; continue;
	}
    #endregion

	#region Input - Tools - Options
	if ($navigation.location -like "Tools"){

        # Choose a tool
        if ($navigation.tool -like ""){
            $navigation.tool = $menuChoices.($choice)
            continue
        }

        # Choose tool option
        if ($navigation.tool -notlike "") {
            if ($navigation.option -like "") {

                # Reset defaults
	            if ($choice -like "d") {
		            Write-Host "Default settings!"; $scan = $null;
		            Start-Sleep -Seconds $sleepTimer; continue;
    	        }

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

                # 2d choice
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

# Done! 