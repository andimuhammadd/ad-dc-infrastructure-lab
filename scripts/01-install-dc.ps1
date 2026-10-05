<#
.SYNOPSIS
    Install AD DS role dan promosi server jadi Domain Controller untuk domain lab.local
.NOTES
    Jalankan di server yang sudah di-rename dan diberi IP static terlebih dahulu
    (lihat docs/01-dc-installation.md untuk detail subnet yang perlu dicek dulu).
    Server akan restart otomatis setelah promosi selesai.
#>

# Install role AD DS beserta tools manajemennya
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Promosi jadi Domain Controller: membuat forest baru, domain baru, dan DNS server
Install-ADDSForest `
    -DomainName "lab.local" `
    -DomainNetbiosName "LAB" `
    -InstallDns `
    -SafeModeAdministratorPassword (ConvertTo-SecureString "GantiPasswordIni123!" -AsPlainText -Force) `
    -Force

# Setelah restart, validasi dengan:
#   Get-ADDomain
#   dcdiag
