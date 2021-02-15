#91 Connect to Exchange Online
function Connect-ExchangeModule {
    Import-Module ExchangeOnlineManagement
    Connect-ExchangeOnline
}