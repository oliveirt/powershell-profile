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

function Get-SSLCertificateFromListeningPort {
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$ComputerName,

        [Parameter(Mandatory=$true)]
        [string]$Port,

        [Switch]$EnforceClientCertificateValidation
    )

    try 
    {	
        $Connection = New-Object System.Net.Sockets.TcpClient($ComputerName, $Port)	
        $TLSStream = New-Object System.Net.Security.SslStream($Connection.GetStream())

        if ($EnforceClientCertificateValidation)
        {
            # validate certificate endpoint
            try 
            {
                $TLSStream.AuthenticateAsClient($ComputerName)
                $Status = "Validated"
            } 
            catch 
            {
                Write-Warning -Message "Certificate validation failed for host '$ComputerName'."
                Write-Warning -Message $_.Message
                $Status = "Validation Failed"
                $Connection.Close
                Break
            }
        }

        # retrieve certificate and basic properties
        $RemoteCert = New-Object system.security.cryptography.x509certificates.x509certificate2($TLSStream.get_remotecertificate())
        # advanced properties
        try { $SAN = ($RemoteCert.Extensions | Where-Object { $_.Oid.Value -eq '2.5.29.17' }).Format(0) } catch {}
        try { $AppPolicies = ($RemoteCert.Extensions | Where-Object { $_.Oid.Value -eq '1.3.6.1.4.1.311.21.10' }).Format(0) } catch {}
        try { $V1TemplateName = ($RemoteCert.Extensions | Where-Object { $_.Oid.Value -eq '1.3.6.1.4.1.311.20.2' }).Format(0) } catch {}
        try { $V2TemplateName = ($RemoteCert.Extensions | Where-Object { $_.Oid.Value -eq '1.3.6.1.4.1.311.21.7' }).Format(0) } catch {}
        try { $SKI = ($RemoteCert.Extensions | Where-Object { $_.Oid.Value -eq '2.5.29.14' }).Format(0) } catch {}
        try { $AKI = ($RemoteCert.Extensions | Where-Object { $_.Oid.Value -eq '2.5.29.35' }).Format(0) } catch {}
        try { $BKU = ($RemoteCert.Extensions | Where-Object { $_.Oid.Value -eq '2.5.29.15' }).Format(0) } catch {}
        try { $EKU = ($RemoteCert.Extensions | Where-Object { $_.Oid.Value -eq '2.5.29.37' }).Format(0) } catch {}
        try { $CDP = ($RemoteCert.Extensions | Where-Object { $_.Oid.Value -eq '2.5.29.31' }).Format(0) } catch {}
        try { $AIA = ($RemoteCert.Extensions | Where-Object { $_.Oid.Value -eq '1.3.6.1.5.5.7.1.1' }).Format(0) } catch {}
        # return object
        New-Object -TypeName PSObject -Property ([ordered]@{
                ComputerName       = $ComputerName
                Port               = $Port
                Status             = $Status
                Subject            = $RemoteCert.Subject
                SAN                = $SAN
                FriendlyName       = $RemoteCert.FriendlyName
                Issuer             = $RemoteCert.Issuer
                ValidFrom          = $RemoteCert.NotBefore
                ValidTo            = $RemoteCert.NotAfter
                Thumbprint         = $RemoteCert.Thumbprint
                SignatureAlgorithm = $RemoteCert.SignatureAlgorithm.FriendlyName
                AIA                = $AIA
                AKI                = $AKI
                BKU                = $BKU
                CDP                = $CDP
                EKU                = $EKU
                SKI                = $SKI
                AppPolicies        = $AppPolicies
                V1TemplateName     = $V1TemplateName
                V2TemplateName     = $V2TemplateName
            })
    }
    catch { $Status = 'Connection Failed' }
    finally { $Connection.Close() }
}

# define list of aliases
$aliases = @{
    gmip = "Get-MyExternalIP"
}

foreach ($alias in $aliases.GetEnumerator())
{
    Set-Alias -Name $alias.Key -Value $alias.Value -Description 'network_profile'
}
