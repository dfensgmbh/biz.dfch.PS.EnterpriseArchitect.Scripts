#Requires -Modules @{ ModuleName = 'biz.dfch.PS.System.Logging'; ModuleVersion = '1.4.1' }

Function Get-Package {
<#
.SYNOPSIS

Retrieves one or more EA package objects from the specified EA model or EA package.

.DESCRIPTION

Retrieves one or more EA package objects from the specified EA model or EA package.

The EA model or EA package has to be provided as input by either positional or named parameter.

.EXAMPLE

Get-Package $eaModel

EA model is passed as a positional parameter to the Cmdlet.

.EXAMPLE

Get-Package $eaPackage

EA package is passed as a positional parameter to the Cmdlet.

.LINK

GitHub Repository: https://github.com/dfensgmbh/biz.dfch.PS.EnterpriseArchitect.Scripts

#>

[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = "Low"
	,
	DefaultParameterSetName = 'list'
)]
PARAM
(
	[ValidateNotNull()]
	[Parameter(Mandatory = $true, Position = 0)]
	$EaModelOrPackage
	,
	# Full name or part of it, for the EA model you want to search - this is not case sensitive
	[Parameter(Mandatory = $false, ParameterSetName = 'searchByName')]
	[ValidateNotNullOrEmpty()]
	[string] $Name = $null
	,
	# Lists all available EA packages of the EA model/package
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[Switch] $ListAvailable
	,
	# Considers recursively all available EA packages of the EA model/package
	[Parameter(Mandatory = $false)]
	[Switch] $Recurse
)

BEGIN
{
	trap { Log-Exception $_; break; }
}

PROCESS
{
	trap { Log-Exception $_; break; }
	
	function GetPackagesOfPackage($Package)
	{
		$temp = [System.Collections.ArrayList]::new();

		if ($Package.Packages -ne $null)
		{
			foreach($pkg in $Package.Packages)
			{
				$null = $temp.Add($pkg);
				$temp2 = GetPackagesOfPackage $pkg;
				if ($temp2 -ne $null)
				{
					if ($temp2.Count -gt 0)
					{
						$null = $temp.AddRange($temp2);
					}
					else 
					{
						$null = $temp.Add($temp2);
					}
				}
			}
		}
		
		return $temp;
	}

	if($Recurse)
	{
		$packages = [System.Collections.ArrayList]::new();
		
		foreach($package in $EaModelOrPackage.Packages)
		{
			$null = $packages.Add($package);
			$temp = GetPackagesOfPackage $package;
			if ($temp -ne $null)
			{
				if ($temp.Count -gt 0)
				{
					$null = $packages.AddRange($temp);
				}
				else
				{
					$null = $packages.Add($temp);
				}
			}
		}
	}
	else
	{
		$packages = $EaModelOrPackage.Packages;
	}
	
	if($PSCmdlet.ParameterSetName -eq 'list')
	{
		$result = $packages;
	}
	else
	{
		If ($PSCmdlet.ParameterSetName -eq 'SearchByName')
		{
			$result = $packages |? Name -match $Name;
		}
	}
	
	$OutputParameter = $result;
}

END
{	
	return $OutputParameter;
}
}

#
# Copyright 2018 d-fens GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
