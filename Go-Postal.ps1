#Go-Postal.ps1 
#This script expects to be run from C:\gopostal. If you want to run from a different folder you would need to change all instances.
#This script requires an input text file called input.txt. This can be any text file larger than 1kb.
#This script requires an input data file called csvdata.dat for the csv file body made up of 10 columns of comma separated data and many rows.
#This script requires an input text file called csvheader.dat for the csv file headermade up of 10 columns of comma separated data with one header row.
#SF 13JUL2017 adding the ability to attach random files from the \script\dataset folder.

#You may have to set the execution policy to allow this script to run for just process: Set-ExecutionPolicy -Scope Process -ExecutionPolicy AllSigned
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process 

#EDIT THESE FOR YOUR ENVIRONMENT
#Destination: SMTP server location and domainname 
$smtpserver = "151.155.183.142"
$domainname = "sf.gwava.net"
#$domainname = "doc.mf.net"

#Users: Make sure they exist in your email system.
#$userArray = @("Ariel","Briar","Carter","Dakota","Eden","Frankie","Harper","Jordan","Kai","Remy")
#$userArray = @("test0","test1","test2","test3","test4","test5","test6","test7","test8","test9","test10","test11","test12","test13","test14","test15","test16","test17","test18","test19","test20")
$userArray = @("test0","test1","test2","test3","test4","test5","test6","test7","test8","test9")
#$userArray = @("test0")

#VARIABLES
#These are optional to change. 
#number of messages to send each time, if set to send each hour 4 messages will provide an average (96) amount of email per user per day.
$loop = 1
#how big a message to build, default 10 lines
$bodysize = 10
$csvsize = 10

#***Script
#You should not have to edit anything below this line.

#initialize local variables
$scriptDir =  Split-Path $myInvocation.MyCommand.Path
$randnum = 0
$i=1

#This script requires at least v4 of PowerShell
#Requires -Version 4.0

#MAIN
ForEach ($userName in $userArray) {   
    Do{
        #Create Randomize data
		$randnum = Get-Random
        
        #Subject: Select random line of text file for subject line 
        #harvard sentences for data http://www.cs.cmu.edu/afs/cs.cmu.edu/project/fgdata/OldFiles/Recorder.app/utterances/Type1/harvsents.txt
        #pick random https://blogs.technet.microsoft.com/heyscriptingguy/2011/09/08/use-powershell-to-pick-random-winning-users-from-text/
        $subject = Get-Content "$scriptDir\subject.dat.txt" | Sort{Get-Random} | Select -First 1

        #Body: Generate new randomized text file for body
        #"Creating body.tmp"
        #Shuffle the entire file and return the first bodysize lines
        $Idxs = 0..999
        Get-Content "$scriptDir\textdata.dat.txt" -ReadCount 0 | ForEach {
            $sample = Get-Random -InputObject $Idxs -Count $bodysize 
            $_[$sample] | Add-Content "$scriptDir\body.tmp"
        }
        #Set body to randomized text
        $body = Get-Content -Path "$scriptDir\body.tmp" -Raw 
		
        #CSV: Generate new randomized data file for csv attachment
        #"Creating shufdata.csv"
        #Shuffle the entire file and return the first csvsize lines
        $Idxs = 0..999
        Get-Content "$scriptDir\csvdata.dat" -ReadCount 0 | ForEach {
            $sample = Get-Random -InputObject $Idxs  -Count $csvsize 
            $_[$sample] | Add-Content "$scriptDir\shufdata.tmp"
        }
        #CSV: concatentate the header and shuffled body to create a randomized csv file attachment
        #"Creating shuffled.csv"
        Add-Content -Value (Get-Content $scriptDir\csvheader.dat,$scriptDir\shufdata.tmp) -Path $scriptDir\shuffled.csv
		
		#Generate new randomized UTF8 file for attachment
        #"Creating utf8.tmp"
        #Shuffle the entire file and return the first bodysize lines
        $Idxs = 0..999
        Get-Content "$scriptDir\utf.dat" -ReadCount 0 | ForEach {
            $sample = Get-Random -InputObject $Idxs -Count $bodysize 
            $_[$sample] | Add-Content "$scriptDir\utf.txt"
        }

        #Select random file from dataset folder
        #SF 13JUL2017 adding the ability to attach random files from a folder
        $attach = Get-ChildItem "$scriptDir\dataset" | Get-Random -Count 1

        #MAIL: Send Randomized Message
        #"Sending Randomized Message"
        #OPTIONAL: How long does it take to run (~250ms/send)
        #Measure-Command{Send-MailMessage -To "test$usernum@sf.gwava.net" -From "script@sf.gwava.net" -Subject "Go-Postal $randnum" -SmtpServer 10.1.4.213 -Body $body -Attachments "C:\Users\Administrator\dev\shuffled.csv"
        #}
        #Send message with randomized body, and csv attachment and script attachment so make sure it handles non-unique attachments, plus simple version control, add date to the subject line so we can see if there are flag errors more easily, plus random number in subject to make it unique
        #Send-MailMessage -To "$userName@$domainname" -From "script@$domainname" -Subject "$subject $randnum" -SmtpServer ($smtpserver) -Body $body -Attachments "$scriptDir\shuffled.csv","$scriptDir\utf.txt","$scriptDir\Go-Postal.ps1"
        Send-MailMessage -To "$userName@$domainname" -From "script@$domainname" -Subject "$subject $randnum" -SmtpServer ($smtpserver) -Body $body -Attachments  "$scriptDir\shuffled.csv",$scriptDir\dataset\$attach,"$scriptDir\utf.txt"
        
        #cleanup
        "Randomized Message Sent to $userName"
        #increment the email loop counter
        $i++

        #Delete randomized data
        #Remove shufdata.tmp
        #"Deleting shufdata.tmp"
        Remove-Item "$scriptDir\shufdata.tmp"
        #Remove shuffled.csv
        #"Deleting shuffled.csv"
        Remove-Item "$scriptDir\shuffled.csv"
        #Remove body.tmp
        #"Deleting body.tmp"
        Remove-Item "$scriptDir\body.tmp"
        #"Deleting utf.txt"
        Remove-Item "$scriptDir\utf.txt"

    } While ($i -le $loop)

} 

#Primitive version control
#"Sending Code Message"
#$codebody = Get-Content -Path $scriptDir\Go-Postal.ps1 -Raw
#Send-MailMessage -To "code@sf.gwava.net" -From "script@sf.gwava.net" -Subject "Go-Postal Code Message $(Get-Date)" -SmtpServer ($smtpserver) -Body $codebody
#"Code Message Sent"