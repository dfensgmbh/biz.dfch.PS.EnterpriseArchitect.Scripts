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
  ,
	[Parameter(Mandatory = $false)]
	[int] $Index = 0
  ,
	[Parameter(Mandatory = $false)]
	[string] $ColumnName = 'BinContent'
)

[xml] $xml = Get-Content -Raw $InputObject
$base64 = ($xml.RefData.DataSet.DataRow[$Index].Column |? name -eq $ColumnName).'#text';
$bytes = [System.Convert]::FromBase64String($base64);
$data = [System.Text.Encoding]::Default.GetString($bytes);
Set-Content -Path $Path -Value $data;
