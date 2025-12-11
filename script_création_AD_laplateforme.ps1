Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools

Install-ADDSForest -DomainName laplateforme.io -DomainNetBIOSName LAPLATEFORME -InstallDNS:$true -SafeModeAdministratorPassword (ConvertTo-SecureString "Azerty_2025!" -AsPlainText -Force)
