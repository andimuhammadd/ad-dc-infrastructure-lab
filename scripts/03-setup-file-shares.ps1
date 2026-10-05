<#
.SYNOPSIS
    Membuat shared folder per divisi dengan NTFS permission berbasis security group.
.DESCRIPTION
    Pola yang dipakai: share dibuka lebar untuk Authenticated Users,
    pembatasan sesungguhnya diatur lewat NTFS permission (icacls),
    bukan lewat share permission. Lihat docs/04-file-sharing-and-gpo-advanced.md
    untuk penjelasan kenapa dua lapis ini dipisah.
#>

$Shares = @(
    @{ Name = "IT-Data";      Group = "LAB\IT-Staff" },
    @{ Name = "Finance-Data"; Group = "LAB\Finance-Staff" },
    @{ Name = "HR-Data";      Group = "LAB\HR-Staff" }
)

foreach ($share in $Shares) {
    $path = "C:\Shares\$($share.Name)"

    New-Item -Path $path -ItemType Directory -Force | Out-Null
    New-SmbShare -Name $share.Name -Path $path -FullAccess "Authenticated Users" -ErrorAction SilentlyContinue

    icacls $path /inheritance:r `
        /grant "Administrators:(OI)(CI)F" `
        "SYSTEM:(OI)(CI)F" `
        "$($share.Group):(OI)(CI)M"

    Write-Host "Share siap: \\DC01\$($share.Name) — akses: $($share.Group)"
}

# Share khusus untuk folder redirection (Documents/Desktop user)
New-Item -Path "C:\Shares\UserFolders" -ItemType Directory -Force | Out-Null
New-SmbShare -Name "UserFolders" -Path "C:\Shares\UserFolders" -FullAccess "Authenticated Users" -ErrorAction SilentlyContinue
icacls "C:\Shares\UserFolders" /inheritance:r `
    /grant "Administrators:(OI)(CI)F" `
    "SYSTEM:(OI)(CI)F" `
    "Authenticated Users:(CI)(S,RD,AD,X,RA)"

Write-Host "`nValidasi: Get-SmbShare | Select Name, Path"
