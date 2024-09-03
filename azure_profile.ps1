# wrapper around Select-AzContext
function Select-AzC
{
    $i = 0
    $contexts = Get-AzContext -ListAvailable | ForEach-Object {
        Add-Member -InputObject $_ -NotePropertyName '#' `
        -NotePropertyValue $i -PassThru
        $i++
    }

    $contexts | Select-Object '#', `
    @{n='SubscriptionName';e={$_.Subscription.Name}}, `
    @{n='SubscriptionId';e={$_.Subscription.Id}},
    'Account' | Out-Host

    do
    {
        $x = Read-Host -Prompt 'Please enter a subscription number:- '
    }
    while (0..($contexts.count -1) -notcontains $x)

    Select-AzContext -InputObject $contexts[$x] | Select-Object `
    @{n='SubscriptionName';e={$_.Subscription.Name}}, `
    @{n='SubscriptionId';e={$_.Subscription.Id}},
    'Account'
}

# wrapper around Get-AzContext
function Get-AzC ([switch]$ListAvailable)
{
    Get-AzContext -ListAvailable:$ListAvailable | Select-Object `
    @{n='SubscriptionName';e={$_.Subscription.Name}}, `
    @{n='SubscriptionId';e={$_.Subscription.Id}},
    @{n='TenantId';e={$_.Tenant.Id}},
    'Account'
}

# define list of aliases
$aliases = @{
    sazc   = "Select-AzC"
    gazc   = "Get-AzC"
    caza   = "Connect-AzAccount"
    daza   = "Disconnect-AzAccount"
    gazs   = "Get-AzSubscription"
    gazr   = "Get-AzResource"
    gazrg  = "Get-AzResourceGroup"
    nazrg  = "New-AzResourceGroup"
    razrg  = "Remove-AzResourceGroup"
}

foreach ($alias in $aliases.GetEnumerator())
{
    Set-Alias -Name $alias.Key -Value $alias.Value
}
