#Requires -Modules @{ ModuleName = 'biz.dfch.PS.System.Logging'; ModuleVersion = '1.4.1' }

Function Get-Model {
<#
.SYNOPSIS

Retrieves one or more package objects from the specified model or package.

.DESCRIPTION

Retrieves one or more package objects from the specified model or package.

The EA model or package has to be provided as input by either positional or named parameter.

.EXAMPLE

Get-Package $eaModel

EA model is passed as a positional parameter to the Cmdlet.

.EXAMPLE

Get-Package $package

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
	[Parameter(Mandatory = $true, Position = 0)]
	$EaModelOrPackage
	,
	# Full name or part of it, for the model you want to search - this is not case sensitive
	[Parameter(Mandatory = $false, ParameterSetName = 'searchByName')]
	[ValidateNotNullOrEmpty()]
	[String] $Name = $null
	,
	# Lists all available products
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[Switch] $ListAvailable
)

BEGIN
{
	trap { Log-Exception $_; break; }
}

PROCESS
{
	if($PSCmdlet.ParameterSetName -eq 'list') 
	{
		$result = $EaModelOrPackage.Packages;
	}
	else
	{
		If ($PSCmdlet.ParameterSetName -eq 'SearchByName') 
		{
			$result = $EaModelOrPackage.Packages |? Name -match $Name;
		}
	}
	
	# $OutputParameter = $result
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
