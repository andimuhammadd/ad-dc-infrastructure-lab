<#
.SYNOPSIS
    Baseline security hardening: Fine-Grained Password Policy, disable Guest,
    audit Domain Admins, cek backup readiness.
.NOTES
    Lihat docs/05-security-and-maintenance.md untuk penjelasan tiap bagian.
#>

# Fine-Grained Password Policy: IT-Staff dapat kebijakan lebih ketat dari default domain
if (-not (Get-ADFineGrainedPasswordPolicy -Filter "Name -eq 'IT-StrictPolicy'" -ErrorAction SilentlyContinue)) {
    New-ADFineGrainedPasswordPolicy -Name "IT-StrictPolicy" -Precedence 10 `
        -MinPasswordLength 14 -PasswordHistoryCount 10 `
        -MaxPasswordAge "60.00:00:00" -MinPasswordAge "1.00:00:00" `
        -LockoutThreshold 3 -LockoutDuration "00:30:00" -LockoutObservationWindow "00:30:00" `
        -ComplexityEnabled $true

    Add-ADFineGrainedPasswordPolicySubject -Identity "IT-StrictPolicy" -Subjects "IT-Staff"
    Write-Host "FGPP IT-StrictPolicy diterapkan ke IT-Staff"
}

# Nonaktifkan akun Guest
Disable-ADAccount -Identity "Guest"
Write-Host "Akun Guest dinonaktifkan"

# Audit: siapa saja Domain Admins (prinsip least privilege)
Write-Host "`nAnggota Domain Admins:"
Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name, SamAccountName

# Audit log login terakhir
Write-Host "`n20 event login terakhir:"
Get-WinEvent -LogName Security -MaxEvents 20 |
    Where-Object { $_.Id -eq 4624 } |
    Select-Object TimeCreated, Message

Write-Host "`nValidasi FGPP: Get-ADUserResultantPasswordPolicy -Identity 'budi'"
