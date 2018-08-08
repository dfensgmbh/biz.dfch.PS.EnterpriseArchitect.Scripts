function Export-DiagramsOfModels {
<#
.SYNOPSIS

Exports diagrams of all models in an EA model repository to PDF and PNG.

.DESCRIPTION

Exports diagrams of all models in an EA model repository to PDF and PNG.

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
	[string] $PathToEaModelRepository
	,
	[ValidateNotNullOrEmpty()]
	[Parameter(Mandatory = $false)]
	[string] $EaInterop = 'Sparx Systems\EA\Interop.EA.dll'
)

BEGIN
{
	# preparing the scene
	$EaInteropPathAndFileName = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath $EaInterop;
	Add-Type -Path $EaInteropPathAndFileName;
 
	# instantiating the COM object
	# NOTE: this will not work reliably
	# $ea = [EA.RepositoryClass]::new();
	$ea = New-Object -ComObject EA.Repository;
 
	# loading the model repository
	$result = $ea.OpenFile($PathToEaModelRepository);
	#$result must be $true
}

PROCESS
{
	function Process-Packages($packages)
	{
		if(!$packages) { throw [System.ArgumentNullException]::new('packages'); }
		if(0 -ge $packages.Count) { return; }
	 
		$eaModelRepositoryDirectory = Split-Path -Path $PathToEaModelRepository -Parent;
	 
		foreach($package in $packages)
		{
			$diagrams = Get-EaDiagrams $package;
			foreach($diagram in $diagrams)
			{
				$diagramePdfPathAndFileName = Join-Path -Path $eaModelRepositoryDirectory -ChildPath ('img\{0}-{1}.pdf' -f $diagram.Name, $diagram.DiagramGUID);
				$result = $diagram.SaveAsPDF($diagramePdfPathAndFileName);

				if(1 -ge $diagram.PageWidth -and 1 -ge $diagram.PageHeight)
				{
					$diagramImgPathAndFileName = Join-Path -Path $eaModelRepositoryDirectory -ChildPath ('img\{0}-{1}.png' -f $diagram.Name, $diagram.DiagramGUID);
					$result = $diagram.SaveImagePage(1, 1, 0, 0, $diagramImgPathAndFileName, 0);
					continue;
				}

				for($pageWidth = 1; $pageWidth -le $diagram.PageWidth; $pageWidth++)
				{
					for($pageHeight = 1; $pageHeight -le $diagram.PageHeight; $pageHeight++)
					{
						$diagramImgPathAndFileName = Join-Path -Path $eaModelRepositoryDirectory -ChildPath ('img\{0}-{1}-x{2}-y{3}.png' -f $diagram.Name, $diagram.DiagramGUID, $pageWidth, $pageHeight);
						$result = $diagram.SaveImagePage($pageWidth, $pageHeight, 0, 0, $diagramImgPathAndFileName, 0);
					}
				}
			}
			Process-Packages $package.Packages;
		}
	}
	
	function Get-EaPackages($package)
	{
		if(!$package) { throw [System.ArgumentNullException]::new('package'); }

		$result = [System.Collections.ArrayList]::new();

		foreach($item in $package.Packages)
		{
			$null = $result.Add($item);
		}

		return $result;
	}
	 
	function Get-EaDiagrams($package)
	{
		if(!$package) { throw [System.ArgumentNullException]::new('package'); }

		$result = [System.Collections.ArrayList]::new();

		foreach($item in $package.Diagrams)
		{
			$null = $result.Add($item);
		}

		return $result;
	}
	
	$eaModelRepositoryDirectory = Split-Path -Path $PathToEaModelRepository -Parent;
	$imgDirectory = Join-Path -Path $eaModelRepositoryDirectory -ChildPath ('img');
	if (!(Test-Path $imgDirectory -PathType Container))
	{
		New-Item -ItemType Directory -Force -Path $imgDirectory;
	}
	
	foreach($model in $ea.Models)
	{
		Process-Packages $model.Packages;
	}
}

END
{
	$ea.CloseFile();
	$ea.Exit();
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
