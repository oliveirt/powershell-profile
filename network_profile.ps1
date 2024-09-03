# define functions

# this function gets the external IP Address of the callling host
function Get-MyExternalIP
{
    $result = Resolve-DnsName `
        -Name  myip.opendns.com. `
        -Server resolver1.opendns.com
    return $result.IPAddress
}

# this function tests whether an IPv4Address matches a CIDR block
# credit https://d-fens.ch/2013/11/01/nobrainer-using-powershell-to-convert-an-ipv4-subnet-mask-length-into-a-subnet-mask-address 
function Test-IPV4AddressToCIDR
{
    [CmdletBinding(SupportsShouldProcess = $false, 
        PositionalBinding = $false,
        ConfirmImpact = 'Low')]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # IPV4 Address
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true, 
            ValueFromRemainingArguments = $false, 
            Position = 0)]
        [ValidateScript({ $_ -match "^([0-9]{1,3}\.){3}[0-9]{1,3}$" })]       
        $IPV4Address,

        # IPV4 CIDR Address Block
        [Parameter(Mandatory = $true, 
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true, 
            ValueFromRemainingArguments = $false, 
            Position = 0)]
        [ValidateScript({ $_ -match "^([0-9]{1,3}\.){3}[0-9]{1,3}(\/([0-9]|[1-2][0-9]|3[0-2]))?$" })]       
        $CIDRBlock
    )

    # extract subnet mask of CIDR block
    function Get-SubnetMask
    {
        param (
            $CIDRBlock
        )
        $CIDRComponents = $CIDRBlock -split "/"
        if ($CIDRComponents.count -eq 2)
        {
            $MaskLength = $CIDRComponents[1]
            
        }
        else 
        {
            $MaskLength = 32
        }
        [IPAddress] $ipMask = 0;
        $ipMask.Address = ([UInt32]::MaxValue - 1) -shl (32 - $MaskLength) -shr (32 - $MaskLength)
        return $ipMask
    }

    # extract subnet of CIDR block
    function Get-Subnet
    {
        param (
            $CIDRBlock
        )
        $CIDRComponents = $CIDRBlock -split "/"
        return $CIDRComponents[0]
    }

    $mask = Get-SubnetMask -CIDRBlock $CIDRBlock
    $subnet = Get-Subnet -CIDRBlock $CIDRBlock
    return (([IPAddress]"$IPV4Address").Address -band ($mask.Address)) -eq ([IPAddress]"$subnet").Address
}

# define list of aliases
$aliases = @{
    gmip = "Get-MyExternalIP"
}

foreach ($alias in $aliases.GetEnumerator())
{
    Set-Alias -Name $alias.Key -Value $alias.Value -Description 'network_profile'
}
