get-aduser -filter "(enabled -eq 'true')" -properties title, company, department,officephone, canonicalname, whencreated, officephone,office,mail,lastlogontimestamp,employeeID | export-csv "C:\Users\tkonsonlas\OneDrive - Healthcare Resource Group, Inc\Desktop\AD.csv"