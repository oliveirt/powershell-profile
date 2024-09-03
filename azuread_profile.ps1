# define functions

# this function facilitates converting an Active Directory objectGuid into an Azure AD ImmutableId
function ConvertFrom-GuidToImmutableId ([Guid]$Guid){

    [System.Convert]::ToBase64String([Guid]::Parse($Guid).ToByteArray())
}

# this function facilitates converting an Azure AD ImmutableId into an Active Directory objectGuid
function ConvertFrom-ImmutableIdToGuid ([string]$ImmutableId) {

    [Guid]([System.Convert]::FromBase64String($ImmutableId))
}

# define list of aliases
$aliases = @{
    g2i    = "ConvertFrom-GuidToImmutableId"
    i2g    = "ConvertFrom-ImmutableIdToGuid"
    cmgg   = "Connect-MgGraph"
    imgg   = "Invoke-MgGraphRequest"
    gmgc   = "Get-MgContext"
    dmgg   = "Disconnect-MgGraph"
}

foreach ($alias in $aliases.GetEnumerator())
{
    Set-Alias -Name $alias.Key -Value $alias.Value
}
