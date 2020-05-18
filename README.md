# GoPostal
#Go-Postal.ps1 

This is a script that will send email unique, searchable messages to your email system. This will also create unique csv attachments. 
Using this script with Task Scheduler will allow you to have a steady flow of test messages in your system.

Requirements:
The script expects to be in C:\gopostal.
In your email system, you must have 10 users named test0-test9.
In the script, you must set the domain name and smpt address of your email server.
Use Task Scheduler to have the script run every hour, Action: Start a program, Program: C:\Windows\SysWOW64\WindowsPowerShell\v1.0\Powershell.exe, Add arguments: -File “C:\gopostal\Go-Postal.ps1”.

Changing defaults:
By default the script expects to be in C:\gopostal with the support files:
textdata.dat This is a text file, currently using Alice in Wonderland, a public domain text. Any large text file can be used.
csvdata.dat This is a comma delimited file used as a base to fill the csv file attachment.
csvheader.dat This is a comma delimited file used as the header to the csv file attachment. 
You can change the folder the script is in but make sure to change it everywhere.
You can change the name and numbers of users as well, if you need a larger sample.
You can change how many times the script loops to change how many messages it sends to each user. 4 loops will send 4 messages/hour for 96 messages/day which is typical of an average email user.

IMPORTANT: This script has no error checking or other safeties in place. It expects you to know what you are doing. 

WARNING: For internal use only. This will send lots of email very qiuckly. This script acts like a simple spambot and most real world mail servers are configured to block domains that spam.
