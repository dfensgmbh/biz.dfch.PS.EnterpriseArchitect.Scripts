#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");

Describe "Get-Model" {
	
	. "$here\$sut";
	. "$here\Open-EaRepository.ps1";
	. "$here\Close-EaRepository.ps1";
	
	Context "Get-Model-ValidationTests" {
		It "Warmup" -Test {
			
			# Arrange
			
			# Act
			
			# Assert
			$true | Should Be $true;
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithNullEaRepository" {
			
			# Arrange

			# Act
			{ Get-Model -EaRepository $null; } | Should ThrowException 'ParameterBindingValidationException';

			# Assert
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithNullName" {
			
			# Arrange
			$eaRepository = New-Object -ComObject Scripting.Dictionary;
			
			# Act
			{ Get-Model -EaRepository $eaRepository -Name $null; } | Should ThrowException 'ParameterBindingValidationException';
			
			#Assert
		}
	}
	
	Context "Get-Model-PositiveTests" {
		
		$pathToEaRepository = "$here\SampleModel.eapx";
		
		BeforeEach {
			$eaRepository = Open-EaRepository -Path $pathToEaRepository;
		}
		
		It "RetrievesAndReturnsListOfAvailableModelsOfEaRepositoryWhenInvokingWithValidOpenedEaRepository" {
			
			# Arrange
			
			# Act
			$result = Get-Model $eaRepository;
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be "Model";
		}

		It "RetrievesModelByNameAndReturnsSpecifiedModelOfEaRepositoryWhenInvokingWithValidOpenedEaRepositoryAndExistingName" {
			
			# Arrange
			
			# Act
			$result = Get-Model $eaRepository -Name "Model";
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be "Model";
		}
		
		It "ReturnsNullWhenInvokingWithValidOpenedEaRepositoryAndNotExistingName" {
			
			# Arrange
			
			# Act
			$result = Get-Model $eaRepository -Name "Arbitrary";
			
			# Assert
			$result | Should Be $null;
		}
		
		AfterEach {
			Close-EaRepository $eaRepository;
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
