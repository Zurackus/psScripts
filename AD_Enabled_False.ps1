get-aduser -filter "(enabled -eq 'false')" -properties title, company, department,officephone, canonicalname, whencreated, officephone,office,mail,lastlogontimestamp | export-csv "C:\Users\tkonsonlas\Documents\AD2.csv"



#Adding notes to this script