#Requires -Modules @{ ModuleName = 'biz.dfch.PS.System.Logging'; ModuleVersion = '1.4.1' }

Function Open-EaRepository {
<#
.SYNOPSIS

Opens a specific EA model repository.

.DESCRIPTION

Opens a specific EA model repository.

The path to the EA model repository has to be provided as input by either positional or named parameter of type string.

.EXAMPLE

$eaRepo = Open-EaRepository C:\PATH\TO\EA\MODEL\REPOSITORY\MyModel.eapx

Path to the EA model repository is passed as a positional parameter to the Cmdlet.

.LINK

GitHub Repository: https://github.com/dfensgmbh/biz.dfch.PS.EnterpriseArchitect.Scripts

#>

[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = "Low"
)]
PARAM
(
	[ValidateScript( { Test-Path($_); } )]
	[ValidateNotNullOrEmpty()]
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $Path
	,
	[ValidateNotNullOrEmpty()]
	[Parameter(Mandatory = $false)]
	[string] $EaInterop = 'Sparx Systems\EA\Interop.EA.dll'
)

BEGIN
{
	trap { Log-Exception $_; break; }

	$OutputParameter = $null;

	# adding the EA reference
	$EaInteropPathAndFileName = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath $EaInterop;
	Add-Type -Path $EaInteropPathAndFileName;

	# instantiating the COM object
	# NOTE: this will not work reliably
	# $ea = [EA.RepositoryClass]::new();
	$ea = New-Object -ComObject EA.Repository;
}

PROCESS
{
	# loading the EA model repository
	$result = $ea.OpenFile($Path);
	Contract-Assert($result);
	
	$OutputParameter = $ea;
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
