#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");

Describe "Get-Element" {
	
	. "$here\$sut";
	. "$here\Open-EaRepository.ps1";
	. "$here\Get-Model.ps1";
	. "$here\Get-Package.ps1";
	. "$here\Close-EaRepository.ps1";
	
	Context "Get-Element-ValidationTests" {
		It "Warmup" -Test {
			
			# Arrange
			
			# Act
			
			# Assert
			$true | Should Be $true;
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithNullEaModelOrPackage" {
			
			# Arrange

			# Act
			{ Get-Element -EaModelOrPackage $null; } | Should ThrowException 'ParameterBindingValidationException';

			# Assert
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithElementIdLessThanOne" {
			
			# Arrange
			$eaModel = New-Object -ComObject Scripting.Dictionary;
			
			# Act
			{ Get-Element -EaModelOrPackage $eaModel -ElementID 0; } | Should ThrowException 'ParameterBindingValidationException';
			
			# Assert
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithNullName" {
			
			# Arrange
			$eaModel = New-Object -ComObject Scripting.Dictionary;
			
			# Act
			{ Get-Element -EaModelOrPackage $eaModel -Name $null; } | Should ThrowException 'ParameterBindingValidationException';
			
			#Assert
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithEmptyName" {
			
			# Arrange
			$eaModel = New-Object -ComObject Scripting.Dictionary;
			
			# Act
			{ Get-Element -EaModelOrPackage $eaModel -Name ""; } | Should ThrowException 'ParameterBindingValidationException';
			
			#Assert
		}
	}
	
	Context "Get-Element-PositiveTests" {
		
		$pathToEaRepository = "$here\SampleModel.eapx";
		
		BeforeEach {
			$eaRepository = Open-EaRepository $pathToEaRepository;
			$eaModel = Get-Model $eaRepository;
			$eaPackage = Get-Package $eaModel -Recurse -Name "2";
		}
		
		It "RetrievesAndReturnsListOfAvailableElementsOfSpecifiedModelWhenInvokingWithValidEaModel" {
			
			# Arrange
			
			# Act
			$result = Get-Element $eaModel;
			
			# Assert
			$eaModel | Should Not Be $null;
			$result | Should Be $null;
		}
		
		It "RetrievesAndReturnsListOfAvailableElementsOfSpecifiedPackageWhenInvokingWithValidEaPackage" {
			
			# Arrange
			
			# Act
			$result = Get-Element $eaPackage;
			
			# Assert
			$eaPackage | Should Not Be $null;
			$result | Should Not Be $null;
			$result.Count | Should Be 2;
		}
		
		It "RetrievesAndReturnsDiagramElementByElementGUIDOfSpecifiedPackageWhenInvokingWithValidEaPackageAndElementGUID" {
			
			# Arrange
			$elementGUID = [guid]::Parse("87A73438-E142-4121-B437-F9D0F444692A");
			
			# Act
			$result = Get-Element $eaPackage -ElementGUID $elementGUID;
			
			# Assert
			$result | Should Not Be $null;
			$result.ElementGUID | Should Be $elementGUID;
			$result.Name | Should Be "arbitrary-uml-component";
		}
		
		It "RetrievesAndReturnsElementByIDOfSpecifiedPackageWhenInvokingWithValidEaPackageAndElementID" {
			
			# Arrange
			$elementID = 14;
			
			# Act
			$result = Get-Element $eaPackage -ElementID $elementID;
			
			# Assert
			$result | Should Not Be $null;
			$result.ElementID | Should Be $elementID;
			$result.Name | Should Be "component-2";
		}
		
		It "RetrievesAndReturnsElementByNameOfSpecifiedPackageWhenInvokingWithValidEaPackageAndName" {
			
			# Arrange
			$elementName = "arbitrary-uml-component";
			
			# Act
			$result = Get-Element $eaPackage -Name $elementName;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be $elementName;
		}
		
		It "RetrievesElementsOfSpecifiedModelRecursivelyAndReturnsThemWhenInvokingWithValidEaModelAndRecurseSwitch" {
			
			# Arrange
			
			# Act
			$result = Get-Element $eaModel -Recurse;
			
			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be 3;
		}
		
		It "RetrievesElementsOfSpecifiedPackageRecursivelyAndReturnsThemWhenInvokingWithValidEaPackageAndRecurseSwitch" {
			
			# Arrange
			$bizPkg = Get-Package $eaModel -Name "biz";
			
			# Act
			$result = Get-Element $bizPkg -Recurse;
			
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
