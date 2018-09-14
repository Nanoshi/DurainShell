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
