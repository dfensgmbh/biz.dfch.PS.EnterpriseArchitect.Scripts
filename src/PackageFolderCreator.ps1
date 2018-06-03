PARAM
(
	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[System.IO.FileInfo] $Project
	,
	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[Guid] $PackageGuid
)

$packagePath = [System.IO.Path]::Combine(
  $Project.Directory.FullName, 
  [System.IO.Path]::GetFileNameWithoutExtension($Project.Name), 
  $PackageGuid.ToString()
);

if(![System.IO.Directory]::Exists($packagePath))
{
  [System.IO.Directory]::CreateDirectory($packagePath);
}

Start-Process -FilePath 'explorer.exe' -ArgumentList $packagePath;
