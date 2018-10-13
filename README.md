# DurianShell
Command line parameter generater and automated vulnerability tester. It's fully modular with the ability to add any tool that you choose.

Not functional just yet but I plan to use the functionality an robustness of powershell to automate my Nmap scans and do future scans based on the results. 

Tools can use the outputs of other tools.  

## NMAP Parser example
Imports nmap.xml and converts it to an array of objects. More tool output will be added to the $targets variable as more scans are conducted.
```
$targets

IP   : 192.168.168.1
MAC  : 0C:80:63:43:xx:xx
OS   : Linux 2.6.32 - 3.10
ssh  : @{22=}
http : @{80=; 443=}

IP  : 192.168.168.106
MAC : E0:A3:AC:C8:xx:xx

IP  : 192.168.168.108
MAC : F4:F5:24:00:xx:xx

IP  : 192.168.168.154
MAC : C8:60:00:E3:xx:xx

IP          : 192.168.168.139
OS          : Microsoft Windows 10 10586 - 14393
netbios-ssn : @{139=}
```


Looking deeper into the first target:
```
$targets[0].ssh.22

product       version ostype extrainfo   
-------       ------- ------ ---------   
Dropbear sshd 2011.54 Linux  protocol 2.0

$targets[0].http.443

product      version ostype extrainfo
-------      ------- ------ ---------
BusyBox http 1.19.4  Linux          
```
