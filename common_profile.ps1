# define functions

# this function facilitates copying a command from PowerShell History to the clipboard
function Copy-HistoryToClipboard ($Id)
{
    Get-History -Id $Id `
    | Select-Object -ExpandProperty CommandLine `
    | Set-Clipboard
}

# this function facilitates quickly copying objects and their properties to the clipboard in tab-delimited format, from where they can be pasted directly into Microsoft Excel
function Copy-ToClipboardTabDelimited
{
    [CmdletBinding()]
    Param
    (
        # The pipeline InputObject
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        [PSObject]
        $InputObject
    )
    Begin
    {
        $callerErrorActionPreference = $ErrorActionPreference
        $OutputObject = @()
    }
    Process
    {
        $OutputObject += $InputObject
    }
    End
    {
        try
        {
            $OutputObject | ConvertTo-Csv -Delimiter "`t" -NoTypeInformation | Set-Clipboard
        }
        catch
        {
            Write-Warning "An error occurred converting the pipeline content to tab-delimited format."
            Write-Error -ErrorRecord $_ -ErrorAction $callerErrorActionPreference
        }
    }
}

# this function facilitates quickly copying tab-delimited data (such as Excel data) from the clipboard into PowerShell.
function Copy-FromClipboardTabDelimited
{
    [CmdletBinding()]
    Param
    (
    )
    Process
    {
        Get-Clipboard | ConvertFrom-Csv -Delimiter "`t"
    }
}

# this function faciitates quickly copying values from the clipboard, removing any empty strings and trimming and starting or trailing spaces
function Get-ClipboardTrimmed
{
    [CmdletBinding()]
    Param
    (
    )
    Begin
    {
        $callerErrorActionPreference = $ErrorActionPreference
    }
    Process
    {
        $OutputObject = @()
        $InputObjects = Get-Clipboard
        $i = 0

        forEach ($InputObject in $InputObjects)
        {
            try
            {
                if ($InputObject -notmatch "^\s*$")
                {
                    $OutputObject += $InputObject.ToString().Trim()
                }
            }
            catch
            {
                Write-Warning "An error occurred processing input object item $i."
                Write-Error -ErrorRecord $_ -ErrorAction $callerErrorActionPreference
            }
            $i++
        }

        Return $OutputObject
    }
    End
    {
    }
}

# this function quickly invokes the installation of PowerShell Core to the latest (stable) version
function Update-PSCore 
{
    Invoke-Expression "& {
        $(Invoke-RestMethod -Uri 'https://aka.ms/install-powershell.ps1')
    } -UseMSI"
}

# define list of aliases
$aliases = @{
    chy   = "Copy-HistoryToClipboard"
    ctdl  = "Copy-ToClipboardTabDelimited"
    itdl  = "Copy-FromClipboardTabDelimited"
    gcbt  = "Get-ClipboardTrimmed"
    uppsc = "Update-PSCore"
}

foreach ($alias in $aliases.GetEnumerator())
{
    Set-Alias -Name $alias.Key -Value $alias.Value -Description 'common_profile'
}
