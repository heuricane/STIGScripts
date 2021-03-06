

# This function creates the dialog box to choose the checklist file

function Get-FileName($initialDirectory)
{   
 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
 Out-Null

 $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
 $OpenFileDialog.initialDirectory = $initialDirectory
 $OpenFileDialog.ShowHelp = $true
 $OpenFileDialog.filter = "All files (*.ckl)| *.ckl"
 $OpenFileDialog.ShowDialog() | Out-Null
 $OpenFileDialog.filename
} #end function Get-FileName

#Sets the $path variable to the file you chose in the dialog box
$path =Get-FileName -initialDirectory "c:fso"

#Loads the contents as XML
$xml = [xml](Get-Content $path)

#Prints the PowerShell version for some debugging 
$PSVersionTable.PSVersion

#sets the $date variable to the current date and formats it as dd/mm/YYYY and formats the savedate to ISO yyyyMMdd
$date = Get-Date -format d
$savedate = (Get-Date).tostring("yyyyMMdd")

#$dom = $env:userdomain
#$usr = $env:username

#Sets the username to the currently logged in User's fullname
$user = ([adsi]"WinNT://$dom/$usr,user").fullname

<#
The meat of the script. For each $Attr (node) at the VULN level of the tree, 
check the STATUS node for a match to "NotAFinding" 
and then set the COMMENTS node to "Reviewed by LastName, First name on dd/mm/YYYY"
#>
ForEach ($Attr in $xml.CHECKLIST.STIGS.iSTIG.VULN) {
    If ($Attr.STATUS -match "NotAFinding") {
        $Attr.COMMENTS = "Reviewed by $user on $date"
    }
}

#Save the now modified xml back to the file you initially loaded.
$destition = Split-Path -Path $path -Parent
$filename = [io.path]::GetFileNameWithoutExtension("$path")
$xml.Save($destination + $filename + "_modified_$savedate.ckl")
exit