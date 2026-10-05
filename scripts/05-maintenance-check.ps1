<#
.SYNOPSIS
    Health check rutin DC: dcdiag, replication summary, dan backup system state.
.NOTES
    Backup target harus di drive TERPISAH dari drive yang di-backup
    (lihat docs/05-security-and-maintenance.md — ini sempat jadi error
    "specified backup location could not be found" saat target-nya C:\Backup,
    satu drive dengan C: yang sedang di-backup).
#>

Write-Host "=== DC Health Check (dcdiag) ===" -ForegroundColor Cyan
dcdiag

Write-Host "`n=== Replication Summary ===" -ForegroundColor Cyan
repadmin /replsummary

Write-Host "`n=== Backup System State ===" -ForegroundColor Cyan
if (-not (Get-WindowsFeature Windows-Server-Backup).Installed) {
    Install-WindowsFeature Windows-Server-Backup
}

# Target backup harus drive terpisah, contoh E: (sesuaikan dengan drive yang tersedia)
$backupTarget = "E:"
if (Test-Path $backupTarget) {
    wbadmin start systemstatebackup -backuptarget:$backupTarget -quiet
} else {
    Write-Warning "Drive $backupTarget tidak ditemukan. Tambahkan virtual disk kedua dan format sebagai $backupTarget dulu."
}
