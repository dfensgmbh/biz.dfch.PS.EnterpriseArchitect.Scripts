#Requires -Modules @{ ModuleName = 'biz.dfch.PS.System.Logging'; ModuleVersion = '1.4.1' }

Function Close-EaRepository {
<#
.SYNOPSIS

Closes a specific EA model repository.

.DESCRIPTION

Closes a specific EA model repository.

The EA model repository object has to be provided as input by either pipe, positional parameter or named parameter.

.EXAMPLE

$result = Close-EaRepository $eaRepo

EA model repository is passed as a positional parameter to the Cmdlet.

.EXAMPLE

$result = $eaRepo | Close-EaRepository

EA model repository is piped to the Cmdlet.

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
	[ValidateNotNull()]
	[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline=$true)]
	$EaRepository
)

BEGIN
{
	trap { Log-Exception $_; break; }
}

PROCESS
{
	trap { Log-Exception $_; break; }
	
	$OutputParameter = $false;
	
	$EaRepository.CloseFile();
	$EaRepository.Exit();
	
	$OutputParameter = $true;
}

END
{
	trap { Log-Exception $_; break; }
	
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
