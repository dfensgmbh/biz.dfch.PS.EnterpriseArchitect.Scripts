#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Pester.Assertions'; ModuleVersion = '1.1.1' }

$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");

Describe "Close-EaRepository" {
	
	. "$here\$sut";
	. "$here\Open-EaRepository.ps1";
	
	Context "Close-EaRepository-ValidationTests" {
		It "Warmup" -Test {
			
			# Arrange
			
			# Act
			
			# Assert
			$true | Should Be $true;
		}
		
		It "ThrowsParameterBindingValidationExceptionWhenInvokingWithNullEaRepository" {
			
			# Arrange

			# Act
			{ Close-EaRepository -EaRepository $null; } | Should ThrowException 'ParameterBindingValidationException';

			# Assert
		}
	}
	
	Context "Close-EaRepository-PositiveTests" {
		
		$pathToEaRepository = "$here\SampleModel.eapx";
		
		BeforeEach {
			$repository = Open-EaRepository -Path $pathToEaRepository;
		}
		
		It "ClosesEaRepositoryAndReturnsTrueWhenInvokingWithValidOpenedEaRepository" {
			
			# Arrange
			
			# Act
			$result = Close-EaRepository $repository;
			
			# Assert
			$result | Should Be $true;
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
