<#
.SYNOPSIS
    Provisioning struktur organisasi: OU, security group, dan user per divisi.
.DESCRIPTION
    Versi awal lab ini dibuat manual satu-satu lewat command terpisah (lihat
    docs/02-domain-join-and-structure.md). Script ini merapikannya jadi satu
    alur yang bisa dijalankan ulang dan gampang ditambah divisi baru, cukup
    menambah baris di tabel $Divisions di bawah.
#>

$DomainDN = "DC=lab,DC=local"

$Divisions = @(
    @{ OU = "IT";      Group = "IT-Staff";      Users = @(
        @{ Name = "Budi Santoso"; SamAccountName = "budi" }
    )},
    @{ OU = "Finance";  Group = "Finance-Staff"; Users = @(
        @{ Name = "Siti Aminah";  SamAccountName = "siti" },
        @{ Name = "Rina Putri";   SamAccountName = "rina"; SkipGroup = $true }  # kontrol pembanding untuk security filtering
    )},
    @{ OU = "HR";       Group = "HR-Staff";      Users = @(
        @{ Name = "Andi Wijaya";  SamAccountName = "andiw" }
    )}
)

$DefaultPassword = ConvertTo-SecureString "Passw0rd123!" -AsPlainText -Force

foreach ($div in $Divisions) {
    $ouPath = "OU=$($div.OU),$DomainDN"

    # Bikin OU kalau belum ada
    if (-not (Get-ADOrganizationalUnit -Filter "Name -eq '$($div.OU)'" -SearchBase $DomainDN -ErrorAction SilentlyContinue)) {
        New-ADOrganizationalUnit -Name $div.OU -Path $DomainDN
        Write-Host "OU dibuat: $($div.OU)"
    }

    # Bikin security group kalau belum ada
    if (-not (Get-ADGroup -Filter "Name -eq '$($div.Group)'" -ErrorAction SilentlyContinue)) {
        New-ADGroup -Name $div.Group -GroupScope Global -GroupCategory Security -Path $ouPath
        Write-Host "Group dibuat: $($div.Group)"
    }

    # Bikin tiap user dan masukkan ke group (kecuali yang ditandai SkipGroup)
    foreach ($user in $div.Users) {
        if (-not (Get-ADUser -Filter "SamAccountName -eq '$($user.SamAccountName)'" -ErrorAction SilentlyContinue)) {
            New-ADUser -Name $user.Name -SamAccountName $user.SamAccountName `
                -Path $ouPath -AccountPassword $DefaultPassword -Enabled $true
            Write-Host "User dibuat: $($user.SamAccountName) di $($div.OU)"
        }

        if (-not $user.SkipGroup) {
            Add-ADGroupMember -Identity $div.Group -Members $user.SamAccountName
        }
    }
}

Write-Host "`nSelesai. Validasi dengan:"
Write-Host "  Get-ADUser -Filter * | Select Name, SamAccountName"
Write-Host "  Get-ADGroupMember -Identity 'IT-Staff'"
