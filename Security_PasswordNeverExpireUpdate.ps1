# ---csv---
#SamAccountName
#user1
#user2
#user3
import-csv "C:\Users\tkonsonlas\OneDrive - Healthcare Resource Group, Inc\Documents\AD.csv" | ForEach-Object {Set-ADUser -Identity $_.SamAccountName -PasswordNeverExpires:$FALSE}