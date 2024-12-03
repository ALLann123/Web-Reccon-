# Web-Reccon-
Bash scripting to automate enumeration of web applications. 
Automated port scaning with nmap, directory bruteforcing with dirsearch and finding web certificates using curl to fetch it from the crt.sh web site for domain certificates. After gathering the above details the tool automatically generates a report for the enumeration carried out.

On kali make sure to install nmap and dirsearch to use the tool:
        kali> sudo apt update                     #update the repository
        kali>sudo apt install nmap                #for port scanning
        kali>sudo apt install dirsearch                        #for directory bruteforcing

usage to get help do:
![usage_web](https://github.com/user-attachments/assets/c6fc6ec6-4fa5-4a21-8502-4e4f365345bd)

To perform all scans:
![image](https://github.com/user-attachments/assets/11c5394c-53a5-4d70-b562-ecd565a2b55a)

To do for a single tool:
  kali>./web_reccon.sh -m nmap <target_domain>
  
scanning multiple targets is also possible do:

  kali>./web_reccon.sh -m all <target_domain_1> <target_domain_2>
  
Note: Automating enumeration saves alot of time during red team engagement and allows us to chain multiple tools for this process.
