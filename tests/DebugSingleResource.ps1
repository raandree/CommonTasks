Import-Module -Name datum
$here = $PSScriptRoot

if ($PSVersionTable.PSEdition -eq 'Desktop')
{
    Import-Module -Name PSDesiredStateConfiguration -RequiredVersion 1.1
}

$datum = New-DatumStructure -DefinitionFile $here\Unit\DSCResources\Assets\Datum.yml
$allNodes = Get-Content -Path $here\Unit\DSCResources\Assets\AllNodes.yml -Raw | ConvertFrom-Yaml

$previousPSModulePath = $env:PSModulePath
Write-Host 'Reading DSC Resource metadata for supporting CIM based DSC parameters...'
Initialize-DscResourceMetaInfo -ModulePath $here\..\output\RequiredModules\
Write-Host 'Done'
$env:PSModulePath = $previousPSModulePath

$global:configurationData = @{
    AllNodes = [array]$allNodes
    Datum    = $Datum
}

$dscResourceName = 'DnsServerRootHints'

configuration "Config_$dscResourceName" {

    Import-DscResource -ModuleName CommonTasks -Name DnsServerRootHints

    node "localhost_$dscResourceName" {

        $data = $configurationData.Datum.Config."$dscResourceName"
        if (-not $data)
        {
            $data = @{}
        }

        (Get-DscSplattedResource -ResourceName $dscResourceName -ExecutionName $dscResourceName -Properties $data -NoInvoke).Invoke($data)
    }
}

& "Config_$dscResourceName" -ConfigurationData $configurationData -OutputPath $here -ErrorAction Stop
