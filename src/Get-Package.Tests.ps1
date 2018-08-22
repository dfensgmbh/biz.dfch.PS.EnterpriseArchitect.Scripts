#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");

Describe "Get-Package" {
	
	. "$here\$sut";
	. "$here\Open-EaRepository.ps1";
	. "$here\Get-Model.ps1";
	. "$here\Close-EaRepository.ps1";
	
	Context "Get-Package-ValidationTests" {
		It "Warmup" -Test {
			
			# Arrange
			
			# Act
			
			# Assert
			$true | Should Be $true;
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithNullEaModelOrPackage" {
			
			# Arrange

			# Act
			{ Get-Package -EaModelOrPackage $null; } | Should ThrowException 'ParameterBindingValidationException';

			# Assert
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithNullName" {
			
			# Arrange
			$eaModel = New-Object -ComObject Scripting.Dictionary;
			
			# Act
			{ Get-Package -EaModelOrPackage $eaModel -Name $null; } | Should ThrowException 'ParameterBindingValidationException';
			
			#Assert
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithEmptyName" {
			
			# Arrange
			$eaModel = New-Object -ComObject Scripting.Dictionary;
			
			# Act
			{ Get-Package -EaModelOrPackage $eaModel -Name ""; } | Should ThrowException 'ParameterBindingValidationException';
			
			#Assert
		}
	}
	
	Context "Get-Package-PositiveTests" {
		
		$pathToEaRepository = "$here\SampleModel.eapx";
		
		BeforeEach {
			$eaRepository = Open-EaRepository -Path $pathToEaRepository;
			$eaModel = Get-Model $eaRepository;
			$eaPackage = Get-Package $eaModel -Name "biz";
		}
		
		It "RetrievesAndReturnsListOfAvailablePackagesOfSpecifiedModelWhenInvokingWithValidEaModel" {
			
			# Arrange
			
			# Act
			$result = Get-Package $eaModel;
			
			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be 3;
		}
		
		It "RetrievesAndReturnsPackageByPackageGUIDOfSpecifiedModelWhenInvokingWithValidEaModelAndPackageGUID" {
			
			# Arrange
			$packageGUID = [guid]::Parse("640331EF-8A11-42e1-8A71-2214C0A7A655");
			
			# Act
			$result = Get-Package $eaModel -PackageGUID $packageGUID;
			
			# Assert
			$result | Should Not Be $null;
			$result.PackageGUID | Should Be $packageGUID;
			$result.Name | Should Be "biz";
		}
		
		It "RetrievesAndReturnsPackageByNameOfSpecifiedModelWhenInvokingWithValidEaModelAndName" {
			
			# Arrange
			
			# Act
			$result = Get-Package $eaModel -Name "ch";
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be "ch";
		}
		
		It "RetrievesPackagesOfSpecifiedModelRecursivelyAndReturnsThemWhenInvokingWithValidEaModelAndRecurseSwitch" {
			
			# Arrange
			
			# Act
			$result = Get-Package $eaModel -Recurse;
			
			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be 10;
		}
		
		It "RetrievesAndReturnsListOfAvailablePackagesOfSpecifiedPackageWhenInvokingWithValidEaPackage" {
			
			# Arrange
			
			# Act
			$result = Get-Package $eaPackage;
			
			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be 2;
		}
		
		It "RetrievesAndReturnsPackageByPackageGUIDOfSpecifiedPackageWhenInvokingWithValidEaPackageAndPackageGUID" {
			
			# Arrange
			$packageGUID = [guid]::Parse("33D3D912-54C7-452d-84AC-56171F5A4821");
			
			# Act
			$result = Get-Package $eaPackage -PackageGUID $packageGUID;
			
			# Assert
			$result | Should Not Be $null;
			$result.PackageGUID | Should Be $packageGUID;
			$result.Name | Should Be "sharedop";
		}
		
		It "RetrievesAndReturnsPackageByNameOfSpecifiedPackageWhenInvokingWithValidEaPackageAndName" {
			
			# Arrange
			
			# Act
			$result = Get-Package $eaPackage -Name "sharedop";
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be "sharedop";
		}
		
		It "RetrievesPackagesOfSpecifiedPackageRecursivelyAndReturnsThemWhenInvokingWithValidEaPackageAndRecurseSwitch" {
			
			# Arrange
			
			# Act
			$result = Get-Package $eaPackage -Recurse;
			
			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be 5;
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
