# define functions

# this function facilitates converting an Active Directory objectGuid into an Azure AD ImmutableId
function ConvertFrom-GuidToImmutableId ([Guid]$Guid)
{

    [System.Convert]::ToBase64String([Guid]::Parse($Guid).ToByteArray())
}

# this function facilitates converting an Azure AD ImmutableId into an Active Directory objectGuid
function ConvertFrom-ImmutableIdToGuid ([string]$ImmutableId)
{

    [Guid]([System.Convert]::FromBase64String($ImmutableId))
}

# converts a Jason Web Token into a readable PSObject
# https://www.michev.info/Blog/Post/2140/decode-jwt-access-and-id-tokens-via-powershell
function ConvertFrom-JWT
{
    [cmdletbinding()]
    param([Parameter(Mandatory = $true)][string]$token)
 
    #Validate as per https://tools.ietf.org/html/rfc7519
    #Access and ID tokens are fine, Refresh tokens will not work
    if (!$token.Contains(".") -or !$token.StartsWith("eyJ")) { Write-Error "Invalid token" -ErrorAction Stop }
 
    #Header
    $tokenheader = $token.Split(".")[0].Replace('-', '+').Replace('_', '/')
    #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
    while ($tokenheader.Length % 4) { Write-Verbose "Invalid length for a Base-64 char array or string, adding ="; $tokenheader += "=" }
    Write-Verbose "Base64 encoded (padded) header:"
    Write-Verbose $tokenheader
    #Convert from Base64 encoded string to PSObject all at once
    Write-Verbose "Decoded header:"
    [System.Text.Encoding]::ASCII.GetString([system.convert]::FromBase64String($tokenheader)) | ConvertFrom-Json | Format-List | Out-Default
 
    #Payload
    $tokenPayload = $token.Split(".")[1].Replace('-', '+').Replace('_', '/')
    #Fix padding as needed, keep adding "=" until string length modulus 4 reaches 0
    while ($tokenPayload.Length % 4) { Write-Verbose "Invalid length for a Base-64 char array or string, adding ="; $tokenPayload += "=" }
    Write-Verbose "Base64 encoded (padded) payoad:"
    Write-Verbose $tokenPayload
    #Convert to Byte array
    $tokenByteArray = [System.Convert]::FromBase64String($tokenPayload)
    #Convert to string array
    $tokenArray = [System.Text.Encoding]::ASCII.GetString($tokenByteArray)
    Write-Verbose "Decoded array in JSON format:"
    Write-Verbose $tokenArray
    #Convert from JSON to PSObject
    $tokobj = $tokenArray | ConvertFrom-Json
    Write-Verbose "Decoded Payload:"
    
    return $tokobj
}

# define list of aliases
$aliases = @{
    g2i   = "ConvertFrom-GuidToImmutableId"
    i2g   = "ConvertFrom-ImmutableIdToGuid"
    cmgg  = "Connect-MgGraph"
    imgg  = "Invoke-MgGraphRequest"
    gmgc  = "Get-MgContext"
    dmgg  = "Disconnect-MgGraph"
    cfjwt = "ConvertFrom-JWT"
}

foreach ($alias in $aliases.GetEnumerator())
{
    Set-Alias -Name $alias.Key -Value $alias.Value -Description 'azuread_profile'
}
