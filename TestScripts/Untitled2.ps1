CBO TQA
CBO Supervisor
Vice President
HIM Director
HIM Senior Director
HIM Supervisor
HIM Audit
SPAY TQA
Proj TQA
HQ Supervisor of TQA
HIM Project Specialist

get-adgroupmember -identity "CBO TQA" | export-csv "C:\Users\tkonsonlas\Documents\A.csv"


$Users = Import-Csv -Path "C:\temp\users.csv"       
foreach ($User in $Users)
{
    $SAM = $User.Firstname + "." + $User.Lastname 
    $ADGroups = $User.Groups -split ";"
    foreach ($ADGroup in $ADGroups)
    {
        Add-ADGroupMember -Identity $ADGroup -Members $SAM
    }
}