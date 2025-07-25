configuration WebApplications {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable[]]
        $Items
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -ModuleName WebAdministrationDsc

    $dscResourceName = 'WebApplication'

    foreach ($item in $Items)
    {
        # Remove Case Sensitivity of ordered Dictionary or Hashtables
        $item = @{} + $item

        if (-not $item.ContainsKey('Ensure'))
        {
            $item.Ensure = 'Present'
        }

        $executionName = "webapp_$($item.Name -replace '[{}#\-\s]','_')"

        (Get-DscSplattedResource -ResourceName $dscResourceName -ExecutionName $executionName -Properties $item -NoInvoke).Invoke($item)
    }
}
