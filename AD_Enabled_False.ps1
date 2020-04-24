get-aduser -filter "(enabled -eq 'false')" -properties title, company, department,officephone, canonicalname, whencreated, officephone,office,mail,lastlogontimestamp | export-csv "C:\Users\tkonsonlas\Documents\AD2.csv"


'''$pattern = '-'*81  
$content = Get-Content D:\Scripts\Temp\p.txt | Out-String
$content.Split($pattern,[System.StringSplitOptions]::RemoveEmptyEntries) | Where-Object {$_ -match '\S'} | ForEach-Object {

$item = $_ -split "\s+`n" | Where-Object {$_}

    New-Object PSobject -Property @{
        Name=$item[0].Split(':')[-1].Trim()
        Id = $item[1].Split(':')[-1].Trim()
        ResolutionPath=$item[2].Split(':')[-1].Trim()
        Endpoints=$item[4..($item.Count)]
    } | Select-Object Name,Id,ResolutionPath,@{n="Endpoints";e={[string]::join(";",$_.Endpoints)}
}


dn: cn=alice,ou=users,dc=foo
cn: alice
givenName: Alice
email: alice@foo.com

dn: cn=bob,ou=users,dc=foo
cn: bob
givenName: Bob
email: bob@foo.com

dn: cn=carol,ou=users,dc=foo
cn: carol
givenName: Carol
email: carol@foo.com'''