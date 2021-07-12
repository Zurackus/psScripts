# Deploy Azure Resource Manager template using template and parameter file locally
New-AzSubscriptionDeployment -Name IntriniumSentinelConnection `
                 -Location WestUS2 `
                 -TemplateFile "C:\Users\tkonsonlas\Documents\Azure Lightnouse Deployment - Teamplate.json" `
                 -TemplateParameterFile "C:\Users\tkonsonlas\Documents\Azure Lightnouse Deployment - Parameters.json" `
                 -Verbose



