# DiskWatcher monitor's disk space and email alert based on min Size
# Drives to check: set to $null or empty to check all local (non-network) drives
# $drives = @("C","D");
$drives = $null;

# The minimum disk size to check for raising the warning
$warninglvl = 20;

# SMTP configuration: username, password & so on
$email_username = "MAIL USER"; 
$email_password = "MAIL USER PASSWORD";
$email_smtp_host = "HOST ADDRESS";
$email_smtp_port = 25;
$email_smtp_SSL = 0;
$email_from_address = "FROM EMAIL ADDRESS";
$email_to_addressArray = @("user1@domain.com","user2@domain.com");


if ($drives -eq $null -Or $drives -lt 1) {
	$localVolumes = Get-WMIObject win32_volume;
	$drives = @();
    foreach ($vol in $localVolumes) {
	    if ($vol.DriveType -eq 3 -And $vol.DriveLetter -ne $null ) {
  		    $drives += $vol.DriveLetter[0];
		}
	}
}
foreach ($d in $drives) {
	Write-Host ("`r`n");
	Write-Host ("Checking drive " + $d + " ...");
	$disk = Get-PSDrive $d;
    $hminsize  = [System.Math]::Round((($minSize) / 1GB))
    $hdiskused = [System.Math]::Round((($disk.Used) / 1GB))
    $hdiskfree = [System.Math]::Round((($disk.Free) / 1GB))
	$totspace = [int]$hdiskused + [int]$hdiskfree
	$freePercent = ($hdiskfree/$totspace) * 100
	$freePercent = [Math]::Round($freePercent,0)

	if ($freePercent -lt $warninglvl) {
		Write-Host ("Drive " + $d + " has less than " + $warninglvl `
			+ " bytes free (" + $disk.free + "): sending e-mail...");
		
		$message = new-object Net.Mail.MailMessage;
		$message.From = $email_from_address;
		foreach ($to in $email_to_addressArray) {
			$message.To.Add($to);
		}
       
		$message.Subject = 	("Running low on free space " + $env:computername + " drive " + $d);
		$message.Body =		"Hello there, `r`n`r`n";
		$message.Body += 	"This is an automatic alert e-mail ";
		$message.Body += 	"sent by DiskWatcher ";
		$message.Body += 	("to inform you that " + $env:computername + " drive " + $d +" has less than " + $warninglvl);
		$message.Body += 	" % currently available free space is "  + $freePercent+ " %  `r`n"
		$message.Body += 	"--------------------------------------------------------------";
		$message.Body +=	"`r`n";
		$message.Body += 	("Machine HostName: " + $env:computername + " `r`n");
		$message.Body += 	"Machine IP Address(es): ";
        $ipAddresses = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter 'IPEnabled = True'| Select IPAddress
		foreach ($ip in $ipAddresses) {
		    if ($ip.IPAddress -like "127.0.0.1") {
			    continue;
			}
		    $message.Body += ($ip.IPAddress + " ");
		}
		$message.Body += 	"`r`n";
        	$message.Body += 	"`r`n";
		$message.Body += 	("Used space on drive " + $d + ": " + $hdiskused + " GB. `r`n");
		$message.Body += 	("Free space on drive " + $d + ": " + $hdiskfree + " GB. `r`n");
		$message.Body += 	("Total space on drive " + $d + ": " + $totspace + " GB. `r`n");
		$message.Body += 	"--------------------------------------------------------------";
		$message.Body +=	"`r`n`r`n";
		$message.Body += 	"This warning will fire when the free space is lower ";
		$message.Body +=	("than " + $warninglvl + " % `r`n`r`n");
		$message.Body += 	"Regards, `r`n`r`n";
		$message.Body += 	"-- `r`n";
		$message.Body += 	"DiskWatcher`r`n";

		$smtp = new-object Net.Mail.SmtpClient($email_smtp_host, $email_smtp_port);
		$smtp.EnableSSL = $email_smtp_SSL;
		$smtp.Credentials = New-Object System.Net.NetworkCredential($email_username, $email_password);
		$smtp.send($message);
		$message.Dispose();
		write-host "... E-Mail sent!" ; 
	}
	else {
		Write-Host ("Drive " + $d + " has more than " + $minSize + " bytes free: nothing to do.");
	}
}
