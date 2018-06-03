PARAM
(
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[System.IO.FileInfo] $InputObject
	,
	[Parameter(Mandatory = $false)]
	[System.Text.Encoding] $Encoding = [System.Text.Encoding]::Default
	,
	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[string] $Path
)

[xml] $xml = Get-Content -Raw $InputObject -Encoding Unicode;
$base64 = $xml.SSDocument.'SSDocument.Document'.'#text';
$bytes = [System.Convert]::FromBase64String($base64);
$data = $Encoding.GetString($bytes);
Set-Content -Path $Path -Value $data;
