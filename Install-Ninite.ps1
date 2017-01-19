Function Get-NiniteAppList
{
    $request = Invoke-WebRequest -Uri https://ninite.com/applist/pro.html
    $break = $request.Content[15] 
    $requestTable = $request.Content -split $break -match '<td>'
    $lastPosition = 0
    While($lastPosition -lt $requestTable.count)
    {
        [pscustomobject]@{
            Name = $requestTable[$lastPosition]  -replace '<\/*td>'
            Description = $requestTable[$lastPosition+1]  -replace '<\/*td>'
            SelectName = $requestTable[$lastPosition+2]  -replace '<\/*td>' -replace '&quot;'
        }
        $lastPosition += 3
    }
}



function Install-NiniteApp
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
       
        [Parameter(Mandatory=$True,Position=1)]
        [string]$computerName
    )

    DynamicParam {
        $ParameterName ='Install'
    
        # Create the dicitionary
        $RuntimeParameterDictionary = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        # Create the collection of attributes
        $AttributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        # Create and set the paramters' attributes
        $ParameterAttribute = New-Object System.Management.Automation.ParameterAttribute
        $ParameterAttribute.Mandatory = $true
        $ParameterAttribute.Position = 1
        
        # Add the attributes to the attributes collection
        $AttributeCollection.Add($ParameterAttribute)

        # Generate and set the ValidateSet
        #$arr = Get-NiniteAppList | Where-Object {$_.SelectName -eq "$Install"}
        $arr = Get-NiniteAppList
        $arrSet = $arr.SelectName
        $ValidateSetAttribute = New-Object System.Management.Automation.ValidateSetAttribute($arrSet)

        # Add the ValidateSet to the attributes collection
        $AttributeCollection.Add($ValidateSetAttribute)

        # Create and return the dynamic parameter
        $RuntimeParameter = New-Object System.Management.Automation.RuntimeDefinedParameter($ParameterName, [string], $AttributeCollection)
        $RuntimeParameterDictionary.Add($ParameterName, $RuntimeParameter)
        return $RuntimeParameterDictionary

    }
            begin {
                # Bind the parameter to a friendly variable
                $sn = $PSBoundParameters[$ParameterName]
            }

            process {

                             
                invoke-Command -ScriptBlock {.\NiniteOne.exe /remote $computername /select  $sn  #/silent report.txt
                
                
                }
                }
}

