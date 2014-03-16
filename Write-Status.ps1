Add-Type -Path (Join-Path (Get-Item $MyInvocation.MyCommand.Path).Directory.FullName PoshTfs.Utils.dll)
$powerlinePrompt = $true

$promptSettings = New-Object PSObject -Property @{
    DefaultForegroundColor = $Host.UI.RawUI.ForegroundColor
    DefaultBackgroundColor = $Host.UI.RawUI.BackgroundColor
    BracketForegroundColor = [ConsoleColor]::Yellow
    AddForegroundColor = [ConsoleColor]::Green
    EditForegroundColor = [ConsoleColor]::DarkCyan
    DeleteForegroundColor = [ConsoleColor]::Red
}

$powerlineSettings = New-Object PSObject -Property @{
    DefaultBackgroundColor = $Host.UI.RawUI.BackgroundColor
    PreviousBackgroundColor = [ConsoleColor]::DarkCyan
    BackgroundColor = [ConsoleColor]::Cyan
    BranchForegroundColor = [ConsoleColor]::DarkCyan
    DelimForegroundColor = [ConsoleColor]::DarkCyan
    AddForegroundColor = [ConsoleColor]::DarkGreen
    EditForegroundColor = [ConsoleColor]::DarkMagenta
    DeleteForegroundColor = [ConsoleColor]::Red
}

$branch = [PoshTfs.Utils.TfsUtils]::GetCurrentBranchName((Get-Item -Path .).FullName)
$changes = [PoshTfs.Utils.TfsUtils]::GetPendingChanges((Get-Item -Path .).FullName)
$changesExist = ($changes.Adds + $changes.Edits + $changes.Deletes) -gt 0

function Write-Prompt() {
    Write-Host " [" -n -b $promptSettings.DefaultBackgroundColor -f $promptSettings.BracketForegroundColor

    if ($branch -ne "") {
        Write-Host " $branch" -n -b $promptSettings.DefaultBackgroundColor -f $promptSettings.DefaultForegroundColor
    }

    if ($changesExist) {
        if ($branch -ne "" -and $changesExist) {
            Write-Host " |" -n -b $promptSettings.DefaultBackgroundColor -f $promptSettings.BracketForegroundColor
        }

        if ($changes.Adds -gt 0) {
            Write-Host " +$($changes.Adds)" -n -b $promptSettings.DefaultBackgroundColor -f $promptSettings.AddForegroundColor
        }

        if ($changes.Edits -gt 0) {
            Write-Host " ~$($changes.Edits)" -n -b $promptSettings.DefaultBackgroundColor -f $promptSettings.EditForegroundColor
        }

        if ($changes.Deletes -gt 0) {
            Write-Host " -$($changes.Deletes)" -n -b $promptSettings.DefaultBackgroundColor -f $promptSettings.DeleteForegroundColor
        }
    }

    Write-Host " ]" -n -b $promptSettings.DefaultBackgroundColor -f $promptSettings.BracketForegroundColor
}

function Write-PowerlinePrompt() {
    Write-Host "`b$([char]0xE0B0)" -n -b $powerlineSettings.BackgroundColor -f $powerlineSettings.PreviousBackgroundColor

    if ($branch -ne "") {
        Write-Host " $([char]0xE0A0)" -n -b $powerlineSettings.BackgroundColor -f $powerlineSettings.BranchForegroundColor
        Write-Host " $branch" -n -b $powerlineSettings.BackgroundColor -f $powerlineSettings.BranchForegroundColor
    }

    if ($changesExist) {
        if ($branch -ne "") {
            Write-Host " $([char]0xE0B1)" -n -b $powerlineSettings.BackgroundColor -f $powerlineSettings.DelimForegroundColor
        }

        if ($changes.Adds -gt 0) {
            Write-Host " +$($changes.Adds)" -n -b $powerlineSettings.BackgroundColor -f $powerlineSettings.AddForegroundColor
        }

        if ($changes.Edits -gt 0) {
            Write-Host " ~$($changes.Edits)" -n -b $powerlineSettings.BackgroundColor -f $powerlineSettings.EditForegroundColor
        }

        if ($changes.Deletes -gt 0) {
            Write-Host " -$($changes.Deletes)" -n -b $powerlineSettings.BackgroundColor -f $powerlineSettings.DeleteForegroundColor
        }
    }

    Write-Host "$([char]0xE0B0)" -n -b $powerlineSettings.DefaultBackgroundColor -f $powerlineSettings.BackgroundColor
}

if ($branch -ne "" -or $changesExist) {
    if ($powerlinePrompt) {
        Write-PowerlinePrompt
    }
    else {
        Write-Prompt
    }
}
