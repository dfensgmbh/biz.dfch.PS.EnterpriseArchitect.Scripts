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
	[Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'searchByDiagramGUID')]
	[guid] $EaDiagramGUID
	,
	[ValidateNotNullOrEmpty()]
	[Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'searchByEaDiagramName')]
	[string] $EaDiagramName
	,
	[ValidateScript( { Test-Path $_ -PathType Leaf; } )]
	[ValidateNotNullOrEmpty()]
	[Parameter(Mandatory = $true, Position = 2)]
	[string] $PathToVisioFile
	,
	[ValidateScript( { Test-Path $_ -PathType Container; } )]
	[ValidateNotNullOrEmpty()]
	[Parameter(Mandatory = $false)]
	[string] $VisioScriptsDirectory = "C:\src\biz.dfch.PS.Visio.Scripts\src"
)

BEGIN
{
	trap { Log-Exception $_; break; }

	$eaScriptFiles = @(".\Close-EaRepository.ps1", ".\Get-Diagram.ps1", ".\Get-Model.ps1", ".\Get-Package.ps1", ".\Open-EaRepository.ps1");
	
	foreach ($eaScriptFile in $eaScriptFiles)
	{
		Contract-Assert (Test-Path -Path $eaScriptFile -PathType Leaf);
		
		# dot source script files
		. $eaScriptFile;
	}
	
	$visioScriptFiles = @("Add-ShapeToPage.ps1", "Close-VisioDocument.ps1", "Get-Page.ps1", "Get-Shape.ps1", "Open-VisioDocument.ps1", "Save-VisioDocument.ps1");
	
	foreach ($visioScriptFile in $visioScriptFiles)
	{
		$path = Join-Path $VisioScriptsDirectory $visioScriptFile;
		Contract-Assert (Test-Path -Path $path -PathType Leaf);
		
		# dot source script files
		. $path;
	}

	Class EaShapeInfo
	{
		[long] $positionX1
		[long] $positionY1
		[long] $positionX2
		[long] $positionY2
		EaShapeInfo([long]$x1, [long]$y1, [long]$x2, [long]$y2)
			{
				$this.positionX1 = $x1
				$this.positionY1 = $y1
				$this.positionX2 = $x2
				$this.positionY2 = $y2
			}
	}
	
	Class VisioShapeInfo
	{
		[double] $positionX
		[double] $positionY
		[double] $width
		[double] $height
		VisioShapeInfo([double]$x, [double]$y, [double]$width, [double]$height)
			{
				$this.positionX = $x
				$this.positionY = $y
				$this.width = $width
				$this.height = $height
			}
	}
	
	Class ShapeInfoConverter
	{
		[long] $eaDimensionX
		[long] $eaDimensionY
		[double] $visioDimensionX
		[double] $visioDimensionY
		ShapeInfoConverter([long]$eaDimX, [long]$eaDimY, [double]$visioDimX, [double]$visioDimY)
			{
				$this.eaDimensionX = $eaDimX
				$this.eaDimensionY = $eaDimY
				$this.visioDimensionX = $visioDimX
				$this.visioDimensionY = $visioDimY
			}	
		[VisioShapeInfo] ConvertToVisioShapeInfo($eaShapeInfo)
			{
				$xScaling = $this.visioDimensionX / $this.eaDimensionX;
				$yScaling = $this.visioDimensionY / $this.eaDimensionY;
				
				$visioPosX = $eaShapeInfo.positionX1 * $xScaling;
				$visioPosY = ($this.eaDimensionY + $eaShapeInfo.positionY1) * $yScaling;
				$visioWidth = ($eaShapeInfo.positionX2 - $eaShapeInfo.positionX1) * $xScaling;
				$visioHeight = [math]::abs($eaShapeInfo.positionY2 - $eaShapeInfo.positionY1) * $yScaling;
				[VisioShapeInfo]$visioShapeInfo = [VisioShapeInfo]::new($visioPosX, $visioPosY, $visioWidth, $visioHeight);
				# DFTODO - convert background color
				
				return $visioShapeInfo;
			}
	}
}

PROCESS
{
	trap { Log-Exception $_; break; }

	$OutputParameter = $false;

	$eaLandscapeOrientation = "L";
	$visioPageName = "Mapping";
	$visioPageWidthCell = "PageWidth";
	$visioPageHeightCell = "PageHeight";
	$visioPrintPageOrientationCell = "PrintPageOrientation";
	$visioLandscapeOrientation = "2";
	$visioPortraitOrientation = "1";
	
	# open EA repository and get model
	$eaRepo = Open-EaRepository $PathToEaProject;
	Contract-Assert($eaRepo);
	$eaModel = Get-Model $eaRepo;
	Contract-Assert($eaModel);
	
	# get EA diagram
	if ($PSCmdlet.ParameterSetName -eq 'searchByDiagramGUID')
	{
		$diagram = Get-Diagram $eaModel -Recurse -DiagramGUID $EaDiagramGUID;
	}
	if ($PSCmdlet.ParameterSetName -eq 'searchByEaDiagramName')
	{
		$diagram = Get-Diagram $eaModel -Recurse -Name $EaDiagramName;
	}
	Contract-Assert ($diagram);

	# open visio document and get visio page
	$visioDoc = Open-VisioDocument $PathToVisioFile;
	Contract-Assert ($visioDoc);
	$visioPage = Get-Page -VisioDoc $visioDoc -Name $visioPageName;
	Contract-Assert ($visioPage);

	# set visio page orientation according to EA diagram orientation
	if ($diagram.Orientation -eq $eaLandscapeOrientation)
	{
		$visioPage.PageSheet.Cells($visioPageWidthCell).FormulaU = "420 mm";
		$visioPage.PageSheet.Cells($visioPageHeightCell).FormulaU = "297 mm";
		$visioPage.PageSheet.Cells($visioPrintPageOrientationCell).FormulaU = $visioLandscapeOrientation;
	}
	else 
	{
		$visioPage.PageSheet.Cells($visioPageWidthCell).FormulaU = "297 mm";
		$visioPage.PageSheet.Cells($visioPageHeightCell).FormulaU = "420 mm";
		$visioPage.PageSheet.Cells($visioPrintPageOrientationCell).FormulaU = $visioPortraitOrientation;
	}

	$visioPageSheet = $visioPage.PageSheet;
	[ShapeInfoConverter]$converter = [ShapeInfoConverter]::new($diagram.cx, $diagram.cy, $visioPageSheet.Cells($visioPageWidthCell).ResultIU, $visioPageSheet.Cells($visioPageHeightCell).ResultIU);
	
	foreach ($diagramObj in $diagram.DiagramObjects)
	{
		# DFTODO - get GUID and search shape by GUID
		#$shape = Get-Shape $visioPage -EaGuid $diagram.;

		if ($null -eq $shape)
		{
			[EaShapeInfo]$eaShapeInfo = [EaShapeInfo]::new($diagramObj.left, $diagramObj.top, $diagramObj.right, $diagramObj.bottom);

			$visioShapeInfo = $converter.ConvertToVisioShapeInfo($eaShapeInfo);

			# DFTODO - get text of shape
			# DFTODO - adjust parameters EaGUID and ShapeText
			$addedShape = Add-ShapeToPage -VisioDoc $visioDoc -PageName $visioPageName -PositionX $visioShapeInfo.positionX -PositionY $visioShapeInfo.positionY -Height $visioShapeInfo.height -Width $visioShapeInfo.width -EaGuid ([guid]::NewGuid()) -ShapeText "tralala";

			# DFTODO - send pools to background
			
			# DFTODO - set color
		}
		
		# DFTODO - else, adjust position of shape
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
