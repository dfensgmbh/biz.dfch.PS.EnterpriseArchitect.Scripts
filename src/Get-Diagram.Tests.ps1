#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");

Describe "Get-Diagram" {
	
	. "$here\$sut";
	. "$here\Open-EaRepository.ps1";
	. "$here\Get-Model.ps1";
	. "$here\Get-Package.ps1";
	. "$here\Close-EaRepository.ps1";
	
	Context "Get-Diagram-ValidationTests" {
		It "Warmup" -Test {
			
			# Arrange
			
			# Act
			
			# Assert
			$true | Should Be $true;
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithNullEaModelOrPackage" {
			
			# Arrange

			# Act
			{ Get-Diagram -EaModelOrPackage $null; } | Should ThrowException 'ParameterBindingValidationException';

			# Assert
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithNullName" {
			
			# Arrange
			$eaModel = New-Object -ComObject Scripting.Dictionary;
			
			# Act
			{ Get-Diagram -EaModelOrPackage $eaModel -Name $null; } | Should ThrowException 'ParameterBindingValidationException';
			
			#Assert
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithEmptyName" {
			
			# Arrange
			$eaModel = New-Object -ComObject Scripting.Dictionary;
			
			# Act
			{ Get-Diagram -EaModelOrPackage $eaModel -Name ""; } | Should ThrowException 'ParameterBindingValidationException';
			
			#Assert
		}
	}
	
	Context "Get-Diagram-PositiveTests" {
		
		$pathToEaRepository = "$here\SampleModel.eapx";
		
		BeforeEach {
			$eaRepository = Open-EaRepository $pathToEaRepository;
			$eaModel = Get-Model $eaRepository;
			$eaPackage = Get-Package $eaModel -Recurse -Name "1";
		}
		
		It "RetrievesAndReturnsListOfAvailableDiagramsOfSpecifiedModelWhenInvokingWithValidEaModel" {
			
			# Arrange
			
			# Act
			$result = Get-Diagram $eaModel;
			
			# Assert
			$result | Should Be $null;
		}
		
		It "RetrievesAndReturnsListOfAvailableDiagramsOfSpecifiedPackageWhenInvokingWithValidEaPackage" {
			
			# Arrange
			
			# Act
			$result = Get-Diagram $eaPackage;
			
			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be 2;
		}
		
		It "RetrievesAndReturnsDiagramByNameOfSpecifiedPackageWhenInvokingWithValidEaPackageAndName" {
			
			# Arrange
			$diagramName = "class-diagram";
			
			# Act
			$result = Get-Diagram $eaPackage -Name $diagramName;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $diagramName;
		}
		
		It "RetrievesDiagramsOfSpecifiedModelRecursivelyAndReturnsThemWhenInvokingWithValidEaModelAndRecurseSwitch" {
			
			# Arrange
			
			# Act
			$result = Get-Diagram $eaModel -Recurse;
			
			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be 5;
		}
		
		It "RetrievesDiagramsOfSpecifiedPackageRecursivelyAndReturnsThemWhenInvokingWithValidEaPackageAndRecurseSwitch" {
			
			# Arrange
			
			# Act
			$result = Get-Diagram $eaPackage -Recurse;
			
			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be 2;
		}

		AfterEach {
			$null = Close-EaRepository $eaRepository;
		}
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
