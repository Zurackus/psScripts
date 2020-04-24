get-aduser -filter "(enabled -eq 'true') -AND (company -eq 'Healthcare Resource Group')" -properties title, department, mail | ? {$_.DistinguishedName -notlike "*,OU=Non_Employee,*"} | select Department, Name, Mail, SamAccountName, Title | export-csv C:\Users\tkonsonlas\Desktop\AD8.csv