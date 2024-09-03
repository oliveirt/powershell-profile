function prompt
{
    $currentUser = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = ($currentUser.IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

    if ($isAdmin)
    {
        $admin = 'Admin'
        $host.UI.RawUI.ForegroundColor = 'Red'
    }
    else
    {
        $admin = 'Non-Admin'
    }

    $host.UI.RawUI.WindowTitle = "$($PSVersionTable.PSEdition) $admin"
}

# define list of aliases
$aliases = @{
    sel    = "Select-Object"
}

foreach ($alias in $aliases.GetEnumerator())
{
    Set-Alias -Name $alias.Key -Value $alias.Value
}

# load additional profile scripts
$profile_scripts = Get-ChildItem -Path "$PSScriptRoot\*_profile.ps1" -Exclude 'Microsoft.PowerShell_profile.ps1'
foreach ($script in $profile_scripts)
{
    Write-Host "Loading profile script $script" -ForegroundColor Yellow
    . $script
}

# change directory to HOME
if ($null -eq (Get-Item ENV:VSCODE*))
{
    Set-Location $HOME
}
