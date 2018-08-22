#Requires -Modules @{ ModuleName = 'biz.dfch.PS.System.Logging'; ModuleVersion = '1.4.1' }

[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = "Medium"
)]
PARAM
(
	[ValidateScript( { Test-Path $_ -PathType Leaf; } )]
	[ValidateNotNullOrEmpty()]
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $PathToEaProject
	,
	[ValidateScript( { Test-Path $_ -PathType Leaf; } )]
	[ValidateNotNullOrEmpty()]
	[Parameter(Mandatory = $true, Position = 1)]
	[string] $PathToVisioFile
	,
	[ValidateScript( { Test-Path $_ -PathType Container; } )]
	[ValidateNotNullOrEmpty()]
	[Parameter(Mandatory = $false)]
	[string] $EaScriptsDirectory = "C:\src\biz.dfch.PS.EnterpriseArchitect.Scripts\src\"
)

BEGIN
{
	trap { Log-Exception $_; break; }
	
	$eaScriptFiles = @("Open-EaRepository.ps1", "Get-Model.ps1", "Get-Package.ps1", "Close-EaRepository.ps1");
	
	foreach ($eaScriptFile in $eaScriptFiles)
	{
		$path = Join-Path $EaScriptsDirectory $eaScriptFile;
		Contract-Assert (Test-Path -Path $path -PathType Leaf);
		
		# dot source script files
		. $path;
	}
	
	$visioScriptFiles = @(".\Add-ShapeToPage.ps1", ".\Close-VisioDocument.ps1", ".\Get-Page.ps1", ".\Get-Shape.ps1", ".\Open-VisioDocument.ps1", ".\Save-VisioDocument.ps1");
	
	foreach ($visioScriptFile in $visioScriptFiles)
	{
		Contract-Assert (Test-Path -Path $visioScriptFile -PathType Leaf);
		
		# dot source script files
		. $visioScriptFile;
	}
}

PROCESS
{
	trap { Log-Exception $_; break; }

	$OutputParameter = $false;
	
	$eaModelName = "ch.kpt";
	$eaPackageName = "Dekompositionsmodell";
	$visioPageName = "Mapping";
	
	$xStart = 1.70;
	$yStart = 11.0;
	$xGap = 1.10;
	$yGap = 0.60;
	
	
	$eaRepo = Open-EaRepository $PathToEaProject;
	$eaModel = Get-Model $eaRepo -Name $eaModelName;
	$eaPackage = Get-Package $eaModel -Name $eaPackageName -Recurse;
	Contract-Assert ($eaPackage);
	
	$eaSubpackages = Get-Package $eaPackage -Recurse;
	
	$visioDoc = Open-VisioDocument $PathToVisioFile;
	$visioPage = Get-Page -VisioDoc $visioDoc -Name $visioPageName;
	Contract-Assert ($visioPage);
	
	$y = $yStart;
	
	foreach ($subPkg in $eaSubpackages)
	{
		$count = 0;
		$x = $xStart;
		
		$components = $subPkg.Elements |? MetaType -eq 'Component';
		
		if ($null -eq $components)
		{
			continue;
		}
		
		foreach ($comp in $components)
		{
			$count++;
		
			$shape = Get-Shape $visioPage -EaGuid $comp.ElementGUID;
			
			if ($null -eq $shape)
			{
				$addedShape = Add-ShapeToPage -VisioDoc $visioDoc -PageName $visioPageName -PositionX $x -PositionY $y -Height 0.48 -Width 0.88 -EaGuid $comp.ElementGUID -ShapeText $comp.Name;
			}
			
			$x = $x + $xGap;
			
			if (($count % 13) -eq 0)
			{
				$x = $xStart;
				$y = $y - $yGap;
			}
		}
		
		$y = $y - $yGap;
	}
	
	$result = $visioDoc | Save-VisioDocument
	Contract-Assert($result);
	
	$result = $visioDoc | Close-VisioDocument;
	Contract-Assert($result);
	
	$result = $eaRepo | Close-EaRepository;
	Contract-Assert($result);
	
	$OutputParameter = $true;
}

END
{	
	return $OutputParameter;
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
