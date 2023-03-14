#SMTP Load Test
#GNU AFFERO GENERAL PUBLIC LICENSE Version 3
#
#Version Number 0.01
#By Scorpion



# Prompt the user for the sender's email address, remote server names or IPs, SMTP server IP, email subject, email body,
# and recipient's email addresses
$from = Read-Host -Prompt "Enter the sender's email address"
$servers = Read-Host -Prompt "Enter the name or IP address of the remote servers separated by comma"
$smtpServer = Read-Host -Prompt "Enter the IP address of the SMTP server"
$subject = Read-Host -Prompt "Enter the subject of the email"
$body = Read-Host -Prompt "Enter the body of the email"
$recipients = Read-Host -Prompt "Enter the recipient's email addresses separated by comma"
$numberOfEmails = Read-Host -Prompt "Enter the number of emails to send"

# Split the server list into an array
$serverList = $servers -split ','

# Loop through each server in the list
foreach ($server in $serverList) {
    # Prompt the user for the server credentials and create a new PSSession
    $creds = Get-Credential
    $session = New-PSSession -ComputerName $server -Credential $creds
    # Invoke a script block on the remote server
    Invoke-Command -Session $session -ScriptBlock {
        # Split the recipient list into an array
        $to = $using:recipients -split ','
        # Loop through 10 times to send 10 emails
        for ($i = 1; $i -le $using:numberOfEmails; $i++) {
            # Set the email subject to the input subject concatenated with the current server name
            $subjectWithServer = "$using:subject $($env:COMPUTERNAME)"
            # Set the email body to the input body concatenated with the current email number
            $emailBody = "$using:body $($env:COMPUTERNAME) $i "
            # Send the email using the specified "From" address, recipients, subject, body, and SMTP server
            Send-MailMessage -From $using:from -To $to -Subject $subjectWithServer -Body $emailBody -SmtpServer $using:smtpServer
        }
    }
    # Remove the PSSession
    Remove-PSSession -Session $session
}
